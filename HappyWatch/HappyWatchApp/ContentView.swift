import SwiftUI

/// Root view: routes based on ViewState priority
struct ContentView: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        NavigationStack {
            Group {
                switch appState.viewState {
                case .onboarding:
                    PairingView()

                case .noSessions:
                    EmptySessionsView()

                case .sessionList:
                    SessionListView()

                case .sessionDetail(let session):
                    SessionDetailContainerView(session: session)

                case .approvalRequired:
                    ApprovalListView()
                }
            }
            .navigationDestination(for: AppState.NavigationDestination.self) { dest in
                switch dest {
                case .sessionDetail(let id):
                    SessionDetailContainerView(
                        session: appState.sync.sessions.first { $0.id == id } ?? appState.sessions.first!
                    )
                case .approvalDetail(let sessionId, let requestId):
                    ApprovalDetailView(sessionId: sessionId, requestId: requestId)
                case .approvalList:
                    ApprovalListView()
                }
            }
        }
    }
}

/// Routes to WorkingView or IdleView based on Claude state
struct SessionDetailContainerView: View {
    let session: WatchSession

    var body: some View {
        Group {
            switch session.claudeState {
            case .working, .thinking:
                WorkingView(session: session)
            case .awaitingApproval:
                // Show the session's pending approvals
                if let first = session.pendingRequests.first {
                    ApprovalDetailView(sessionId: session.id, requestId: first.id)
                } else {
                    WorkingView(session: session)
                }
            default:
                IdleView(session: session)
            }
        }
        .navigationTitle(session.displayName)
    }
}
