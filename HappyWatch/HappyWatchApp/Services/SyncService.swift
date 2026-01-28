import Foundation

/// Coordinator service: WatchConnectivity as primary, REST as fallback.
/// Exposes @Observable session state for UI consumption.
@Observable
final class SyncService {
    private(set) var sessions: [WatchSession] = []
    private(set) var isLoading = false
    private(set) var lastError: String?
    private(set) var syncSource: SyncSource = .none

    private let connectivity: ConnectivityService
    private let rest = RESTService()
    private let auth: AuthService

    enum SyncSource {
        case none
        case watchConnectivity
        case rest
    }

    init(connectivity: ConnectivityService, auth: AuthService) {
        self.connectivity = connectivity
        self.auth = auth

        // Load cached sessions
        sessions = AppGroupStorage.shared.loadSessions()

        setupConnectivityCallbacks()
    }

    // MARK: - WatchConnectivity Callbacks

    private func setupConnectivityCallbacks() {
        connectivity.onAuthReceived = { [weak self] token, serverUrl in
            self?.auth.authenticate(token: token, serverUrl: serverUrl)
        }

        connectivity.onSessionsReceived = { [weak self] sessions in
            guard let self else { return }
            self.sessions = sessions
            self.syncSource = .watchConnectivity
            self.persistSessions()
        }

        connectivity.onSessionKeysReceived = { [weak self] keys in
            self?.auth.storeSessionKeys(keys)
        }

        connectivity.onSessionUpdate = { [weak self] updatedSession in
            guard let self else { return }
            if let idx = self.sessions.firstIndex(where: { $0.id == updatedSession.id }) {
                self.sessions[idx] = updatedSession
            } else {
                self.sessions.append(updatedSession)
            }
            self.persistSessions()
        }

        connectivity.onEphemeral = { [weak self] sessionId, isThinking in
            guard let self,
                  let idx = self.sessions.firstIndex(where: { $0.id == sessionId }) else { return }
            self.sessions[idx].thinking = isThinking
            self.sessions[idx].thinkingAt = Date().timeIntervalSince1970
        }

        connectivity.onPermissionRequest = { [weak self] sessionId, request in
            guard let self,
                  let idx = self.sessions.firstIndex(where: { $0.id == sessionId }) else { return }
            if self.sessions[idx].agentState == nil {
                self.sessions[idx].agentState = WatchAgentState()
            }
            if self.sessions[idx].agentState?.requests == nil {
                self.sessions[idx].agentState?.requests = [:]
            }
            self.sessions[idx].agentState?.requests?[request.id] = request

            // Show notification
            NotificationService.shared.showPermissionNotification(
                sessionName: self.sessions[idx].displayName,
                tool: request.tool,
                requestId: request.id,
                sessionId: sessionId
            )
        }

        connectivity.onPermissionResult = { [weak self] sessionId, requestId, _ in
            guard let self,
                  let idx = self.sessions.firstIndex(where: { $0.id == sessionId }) else { return }
            self.sessions[idx].agentState?.requests?.removeValue(forKey: requestId)
        }
    }

    // MARK: - Permission Actions

    func approveRequest(sessionId: String, requestId: String, decision: PermissionDecision = .approved) {
        if connectivity.isReachable {
            connectivity.sendPermissionDecision(
                sessionId: sessionId,
                requestId: requestId,
                decision: decision
            )
        } else {
            Task { await sendPermissionViaREST(sessionId: sessionId, requestId: requestId, decision: decision) }
        }
    }

    func denyRequest(sessionId: String, requestId: String, decision: PermissionDecision = .denied) {
        if connectivity.isReachable {
            connectivity.sendPermissionDecision(
                sessionId: sessionId,
                requestId: requestId,
                decision: decision
            )
        } else {
            Task { await sendPermissionViaREST(sessionId: sessionId, requestId: requestId, decision: decision) }
        }
    }

    // MARK: - REST Fallback

    func refreshViaREST() async {
        guard let serverUrl = auth.serverUrl, let token = auth.authToken else { return }
        isLoading = true
        defer { isLoading = false }

        do {
            let dtos = try await rest.fetchActiveSessions(serverUrl: serverUrl, token: token)
            // DTOs have encrypted fields - attempt decryption for sessions with cached keys
            var decryptedSessions: [WatchSession] = []
            for dto in dtos {
                if let session = try? decryptSessionDTO(dto) {
                    decryptedSessions.append(session)
                }
            }
            sessions = decryptedSessions
            syncSource = .rest
            persistSessions()
            lastError = nil
        } catch {
            lastError = error.localizedDescription
        }
    }

    private func decryptSessionDTO(_ dto: WatchSessionDTO) throws -> WatchSession {
        let keyData = auth.sessionKey(for: dto.id)

        var metadata: WatchMetadata?
        if let enc = dto.metadata, let key = keyData {
            metadata = try? EncryptionBridge.decryptJSON(enc, key: key, as: WatchMetadata.self)
        }

        var agentState: WatchAgentState?
        if let enc = dto.agentState, let key = keyData {
            agentState = try? EncryptionBridge.decryptJSON(enc, key: key, as: WatchAgentState.self)
        }

        return WatchSession(
            id: dto.id,
            seq: dto.seq,
            createdAt: dto.createdAt,
            updatedAt: dto.updatedAt,
            active: dto.active,
            activeAt: dto.activeAt,
            metadata: metadata,
            metadataVersion: dto.metadataVersion,
            agentState: agentState,
            agentStateVersion: dto.agentStateVersion,
            thinking: false,
            thinkingAt: 0,
            presence: dto.active ? .online : .lastSeen(dto.updatedAt),
            permissionMode: nil
        )
    }

    private func sendPermissionViaREST(sessionId: String, requestId: String, decision: PermissionDecision) async {
        guard let serverUrl = auth.serverUrl,
              let token = auth.authToken,
              let keyData = auth.sessionKey(for: sessionId) else { return }

        let approved = (decision == .approved || decision == .approvedForSession)
        let params: [String: Any] = [
            "id": requestId,
            "approved": approved,
            "decision": decision.rawValue,
        ]

        guard let paramsData = try? JSONSerialization.data(withJSONObject: params),
              let encrypted = try? EncryptionBridge.encryptAES256GCM(data: paramsData, key: keyData) else { return }

        try? await rest.sendPermissionDecision(
            serverUrl: serverUrl,
            token: token,
            sessionId: sessionId,
            requestId: requestId,
            decision: decision,
            encryptedParams: encrypted.base64EncodedString()
        )
    }

    // MARK: - Data Access

    /// All sessions with pending permission requests
    var sessionsNeedingApproval: [WatchSession] {
        sessions.filter(\.hasPendingApprovals)
    }

    /// All pending requests across all sessions, with session context
    var allPendingRequests: [(session: WatchSession, request: WatchAgentState.PermissionRequest)] {
        sessions.flatMap { session in
            session.pendingRequests.map { (session: session, request: $0) }
        }.sorted { ($0.request.createdAt ?? 0) < ($1.request.createdAt ?? 0) }
    }

    /// Active sessions sorted by priority (awaiting approval first, then by activity)
    var sortedSessions: [WatchSession] {
        sessions
            .filter(\.active)
            .sorted { $0.claudeState > $1.claudeState }
    }

    var hasUrgentApprovals: Bool {
        !sessionsNeedingApproval.isEmpty
    }

    // MARK: - Persistence

    private func persistSessions() {
        AppGroupStorage.shared.saveSessions(sessions)
        AppGroupStorage.shared.updateWidgetData(
            approvalCount: allPendingRequests.count,
            activeCount: sessions.filter(\.active).count,
            topSession: sortedSessions.first?.displayName
        )
    }
}
