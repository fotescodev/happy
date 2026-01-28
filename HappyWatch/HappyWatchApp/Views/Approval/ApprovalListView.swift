import SwiftUI

/// Pending permission requests across all sessions, sorted by creation time
struct ApprovalListView: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        List {
            ForEach(appState.pendingApprovals, id: \.request.id) { item in
                NavigationLink(value: AppState.NavigationDestination.approvalDetail(item.session.id, item.request.id)) {
                    ApprovalRowView(sessionName: item.session.displayName, request: item.request)
                }
            }

            if appState.pendingApprovals.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: 24))
                        .foregroundStyle(HappyColors.success)
                    Text("All clear")
                        .font(HappyTypography.body)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
                .listRowBackground(Color.clear)
            }
        }
        .navigationTitle("Approvals")
    }
}

/// Compact row for the approval list
struct ApprovalRowView: View {
    let sessionName: String
    let request: WatchAgentState.PermissionRequest

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(request.tool)
                    .font(HappyTypography.body)
                    .lineLimit(1)

                Spacer()

                let risk = ApprovalVM.riskTier(for: request.tool)
                Text(risk.label)
                    .font(HappyTypography.caption2)
                    .foregroundStyle(risk.color)
            }

            Text(sessionName)
                .font(HappyTypography.caption2)
                .foregroundStyle(.secondary)
                .lineLimit(1)
        }
        .padding(.vertical, 2)
    }
}
