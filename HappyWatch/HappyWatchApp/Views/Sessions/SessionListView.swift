import SwiftUI

/// Screen A4: Active sessions with status badges, Digital Crown scrollable
struct SessionListView: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        List {
            // Approval banner if needed
            if appState.sync.hasUrgentApprovals {
                NavigationLink(value: AppState.NavigationDestination.approvalList) {
                    HStack(spacing: 8) {
                        Image(systemName: "hand.raised.fill")
                            .foregroundStyle(HappyColors.question)
                        Text("\(appState.pendingApprovals.count) pending")
                            .font(HappyTypography.callout)
                        Spacer()
                    }
                    .padding(.vertical, 4)
                }
                .listRowBackground(HappyColors.question.opacity(0.15))
            }

            // Session rows
            ForEach(appState.sessions) { session in
                NavigationLink(value: AppState.NavigationDestination.sessionDetail(session.id)) {
                    SessionRowView(session: session)
                }
            }
        }
        .navigationTitle("Sessions")
        .refreshable {
            await appState.refresh()
        }
    }
}

#Preview {
    NavigationStack {
        SessionListView()
            .environment(AppState())
    }
}
