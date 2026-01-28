import Foundation

/// View model driving the session list
@MainActor @Observable
final class SessionListVM {
    private let appState: AppState

    init(appState: AppState) {
        self.appState = appState
    }

    var sessions: [WatchSession] {
        appState.sessions
    }

    var isEmpty: Bool {
        sessions.isEmpty
    }

    var approvalCount: Int {
        appState.pendingApprovals.count
    }

    var hasApprovals: Bool {
        approvalCount > 0
    }

    func select(_ session: WatchSession) {
        appState.selectSession(session)
    }

    func refresh() async {
        await appState.refresh()
    }
}
