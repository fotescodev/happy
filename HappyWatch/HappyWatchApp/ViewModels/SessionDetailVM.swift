import Foundation

/// View model driving session detail (working/idle/approval states)
@MainActor @Observable
final class SessionDetailVM {
    private let appState: AppState
    let sessionId: String

    init(appState: AppState, sessionId: String) {
        self.appState = appState
        self.sessionId = sessionId
    }

    var session: WatchSession? {
        appState.sync.sessions.first { $0.id == sessionId }
    }

    var claudeState: ClaudeState {
        session?.claudeState ?? .offline
    }

    var displayName: String {
        session?.displayName ?? "Session"
    }

    var hostName: String {
        session?.metadata?.host ?? "Unknown"
    }

    var summary: String? {
        session?.metadata?.summary?.text
    }

    var pendingRequests: [WatchAgentState.PermissionRequest] {
        session?.pendingRequests ?? []
    }

    var hasPendingApprovals: Bool {
        !pendingRequests.isEmpty
    }

    func approve(requestId: String) {
        appState.approveRequest(sessionId: sessionId, requestId: requestId)
    }

    func deny(requestId: String) {
        appState.denyRequest(sessionId: sessionId, requestId: requestId)
    }
}
