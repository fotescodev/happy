import Foundation
import WatchConnectivity

/// WatchConnectivity wrapper: receives data from iPhone companion app
@Observable
final class ConnectivityService: NSObject {
    private(set) var isReachable = false
    private(set) var isActivated = false

    // Callbacks for received data
    var onAuthReceived: ((String, String) -> Void)?  // (token, serverUrl)
    var onSessionsReceived: (([WatchSession]) -> Void)?
    var onSessionKeysReceived: (([String: Data]) -> Void)?
    var onSessionUpdate: ((WatchSession) -> Void)?
    var onEphemeral: ((String, Bool) -> Void)?  // (sessionId, isThinking)
    var onPermissionRequest: ((String, WatchAgentState.PermissionRequest) -> Void)?  // (sessionId, request)
    var onPermissionResult: ((String, String, Bool) -> Void)?  // (sessionId, requestId, success)

    override init() {
        super.init()
    }

    func activate() {
        guard WCSession.isSupported() else { return }
        WCSession.default.delegate = self
        WCSession.default.activate()
    }

    /// Send permission decision to iPhone for relay to server
    func sendPermissionDecision(
        sessionId: String,
        requestId: String,
        decision: PermissionDecision,
        mode: String? = nil,
        allowedTools: [String]? = nil
    ) {
        guard WCSession.default.isReachable else { return }

        var message: [String: Any] = [
            "type": "permission-decision",
            "sessionId": sessionId,
            "requestId": requestId,
            "decision": decision.rawValue,
        ]
        if let mode { message["mode"] = mode }
        if let allowedTools { message["allowedTools"] = allowedTools }

        WCSession.default.sendMessage(message, replyHandler: nil) { error in
            print("[WC] Send permission decision failed: \(error)")
        }
    }

    /// Request fresh session data from iPhone
    func requestSessionRefresh() {
        guard WCSession.default.isReachable else { return }
        WCSession.default.sendMessage(["type": "request-refresh"], replyHandler: nil)
    }
}

// MARK: - WCSessionDelegate

extension ConnectivityService: WCSessionDelegate {

    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        DispatchQueue.main.async {
            self.isActivated = activationState == .activated
            self.isReachable = session.isReachable
        }

        // Process any applicationContext that arrived before activation
        if !session.applicationContext.isEmpty {
            processApplicationContext(session.applicationContext)
        }
    }

    func sessionReachabilityDidChange(_ session: WCSession) {
        DispatchQueue.main.async {
            self.isReachable = session.isReachable
        }
    }

    // MARK: - Application Context (bulk state transfer)

    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String: Any]) {
        processApplicationContext(applicationContext)
    }

    private func processApplicationContext(_ context: [String: Any]) {
        // Auth token
        if let token = context["authToken"] as? String,
           let serverUrl = context["serverUrl"] as? String {
            DispatchQueue.main.async {
                self.onAuthReceived?(token, serverUrl)
            }
        }

        // Sessions (already decrypted by iPhone)
        if let sessionsData = context["sessions"] as? Data {
            if let sessions = try? JSONDecoder().decode([WatchSession].self, from: sessionsData) {
                DispatchQueue.main.async {
                    self.onSessionsReceived?(sessions)
                }
            }
        }

        // Session encryption keys (for REST fallback)
        if let keysData = context["sessionKeys"] as? Data {
            if let keysDict = try? JSONDecoder().decode([String: String].self, from: keysData) {
                let dataDict = keysDict.compactMapValues { Data(base64Encoded: $0) }
                DispatchQueue.main.async {
                    self.onSessionKeysReceived?(dataDict)
                }
            }
        }
    }

    // MARK: - Real-time Messages

    func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {
        guard let type = message["type"] as? String else { return }

        DispatchQueue.main.async {
            switch type {
            case "session-update":
                if let data = message["session"] as? Data,
                   let session = try? JSONDecoder().decode(WatchSession.self, from: data) {
                    self.onSessionUpdate?(session)
                }

            case "ephemeral":
                if let sessionId = message["sessionId"] as? String,
                   let thinking = message["thinking"] as? Bool {
                    self.onEphemeral?(sessionId, thinking)
                }

            case "permission-request":
                if let sessionId = message["sessionId"] as? String,
                   let data = message["request"] as? Data,
                   let request = try? JSONDecoder().decode(WatchAgentState.PermissionRequest.self, from: data) {
                    self.onPermissionRequest?(sessionId, request)
                }

            case "permission-result":
                if let sessionId = message["sessionId"] as? String,
                   let requestId = message["requestId"] as? String,
                   let success = message["success"] as? Bool {
                    self.onPermissionResult?(sessionId, requestId, success)
                }

            default:
                break
            }
        }
    }
}
