import SwiftUI

/// Tool name + arguments preview + risk level
struct ApprovalDetailView: View {
    @Environment(AppState.self) private var appState
    let sessionId: String
    let requestId: String

    private var session: WatchSession? {
        appState.sync.sessions.first { $0.id == sessionId }
    }

    private var request: WatchAgentState.PermissionRequest? {
        session?.agentState?.requests?[requestId]
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                if let request {
                    // Tool name + risk
                    let risk = ApprovalVM.riskTier(for: request.tool)
                    HStack {
                        Image(systemName: "wrench.fill")
                            .foregroundStyle(risk.color)
                        Text(request.tool)
                            .font(HappyTypography.headline)
                        Spacer()
                        Text(risk.label)
                            .font(HappyTypography.caption2)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(risk.color.opacity(0.2), in: Capsule())
                    }

                    // Session context
                    if let name = session?.displayName {
                        Text(name)
                            .font(HappyTypography.caption)
                            .foregroundStyle(.secondary)
                    }

                    Divider()

                    // Arguments preview
                    Text("Arguments")
                        .font(HappyTypography.caption)
                        .foregroundStyle(.secondary)

                    Text(request.arguments.prettyJSON)
                        .font(HappyTypography.monoSmall)
                        .foregroundStyle(.primary)
                        .lineLimit(20)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(8)
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 8))

                    // Actions
                    ApprovalActionsView(sessionId: sessionId, requestId: requestId)
                } else {
                    // Request already handled
                    ConfirmationView(approved: true)
                }
            }
            .padding()
        }
        .navigationTitle("Permission")
    }
}
