import Foundation

/// Priority-ordered UI state that determines what the root ContentView shows
enum ViewState: Equatable {
    case onboarding
    case noSessions
    case sessionList
    case sessionDetail(WatchSession)
    case approvalRequired

    /// Derive the current view state from app state
    static func derive(
        isAuthenticated: Bool,
        sessions: [WatchSession],
        selectedSession: WatchSession?,
        hasUrgentApprovals: Bool
    ) -> ViewState {
        guard isAuthenticated else {
            return .onboarding
        }

        // If any session needs approval, show that first
        if hasUrgentApprovals {
            return .approvalRequired
        }

        // If a session is selected, show its detail
        if let session = selectedSession {
            return .sessionDetail(session)
        }

        // Otherwise show list or empty state
        if sessions.isEmpty {
            return .noSessions
        }

        return .sessionList
    }
}
