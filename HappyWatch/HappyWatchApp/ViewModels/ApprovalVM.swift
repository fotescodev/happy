import SwiftUI
import WatchKit

/// Permission decision logic and haptic feedback
@MainActor @Observable
final class ApprovalVM {
    private let appState: AppState

    private(set) var lastDecision: DecisionResult?
    private(set) var isProcessing = false

    struct DecisionResult {
        let requestId: String
        let approved: Bool
        let timestamp: Date
    }

    init(appState: AppState) {
        self.appState = appState
    }

    var allPendingRequests: [(session: WatchSession, request: WatchAgentState.PermissionRequest)] {
        appState.pendingApprovals
    }

    var pendingCount: Int {
        allPendingRequests.count
    }

    // MARK: - Actions

    func approve(sessionId: String, requestId: String) {
        guard !isProcessing else { return }
        isProcessing = true

        appState.approveRequest(sessionId: sessionId, requestId: requestId)

        lastDecision = DecisionResult(requestId: requestId, approved: true, timestamp: Date())
        WKInterfaceDevice.current().play(.success)

        Task {
            try? await Task.sleep(for: .seconds(0.5))
            isProcessing = false
        }
    }

    func approveForSession(sessionId: String, requestId: String) {
        guard !isProcessing else { return }
        isProcessing = true

        appState.approveForSession(sessionId: sessionId, requestId: requestId)

        lastDecision = DecisionResult(requestId: requestId, approved: true, timestamp: Date())
        WKInterfaceDevice.current().play(.success)

        Task {
            try? await Task.sleep(for: .seconds(0.5))
            isProcessing = false
        }
    }

    func deny(sessionId: String, requestId: String) {
        guard !isProcessing else { return }
        isProcessing = true

        appState.denyRequest(sessionId: sessionId, requestId: requestId)

        lastDecision = DecisionResult(requestId: requestId, approved: false, timestamp: Date())
        WKInterfaceDevice.current().play(.failure)

        Task {
            try? await Task.sleep(for: .seconds(0.5))
            isProcessing = false
        }
    }

    func abort(sessionId: String, requestId: String) {
        guard !isProcessing else { return }
        isProcessing = true

        appState.abortRequest(sessionId: sessionId, requestId: requestId)

        lastDecision = DecisionResult(requestId: requestId, approved: false, timestamp: Date())
        WKInterfaceDevice.current().play(.failure)

        Task {
            try? await Task.sleep(for: .seconds(0.5))
            isProcessing = false
        }
    }

    /// Risk tier based on tool name
    static func riskTier(for tool: String) -> RiskTier {
        switch tool.lowercased() {
        case let t where t.contains("bash"), let t where t.contains("execute"):
            return .high
        case let t where t.contains("write"), let t where t.contains("edit"),
             let t where t.contains("delete"):
            return .medium
        case let t where t.contains("read"), let t where t.contains("glob"),
             let t where t.contains("grep"), let t where t.contains("list"):
            return .low
        default:
            return .medium
        }
    }

    enum RiskTier {
        case low, medium, high

        var label: String {
            switch self {
            case .low: "Low Risk"
            case .medium: "Medium Risk"
            case .high: "High Risk"
            }
        }

        var color: Color {
            switch self {
            case .low: HappyColors.success
            case .medium: HappyColors.warning
            case .high: HappyColors.danger
            }
        }
    }
}
