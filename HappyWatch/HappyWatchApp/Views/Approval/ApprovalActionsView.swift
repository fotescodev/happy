import SwiftUI

/// Approve/Deny glass buttons
struct ApprovalActionsView: View {
    @Environment(AppState.self) private var appState
    let sessionId: String
    let requestId: String

    @State private var showConfirmation: Bool?

    var body: some View {
        VStack(spacing: 8) {
            // Primary: Approve
            Button {
                appState.approveRequest(sessionId: sessionId, requestId: requestId)
                showConfirmation = true
            } label: {
                Label("Approve", systemImage: "checkmark.circle.fill")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.glass(tint: HappyColors.success))

            // Secondary: Approve for session
            Button {
                appState.approveForSession(sessionId: sessionId, requestId: requestId)
                showConfirmation = true
            } label: {
                Label("Approve All", systemImage: "checkmark.circle")
                    .frame(maxWidth: .infinity)
                    .font(HappyTypography.callout)
            }
            .buttonStyle(.glass(tint: HappyColors.info))

            // Deny
            Button {
                appState.denyRequest(sessionId: sessionId, requestId: requestId)
                showConfirmation = false
            } label: {
                Label("Deny", systemImage: "xmark.circle.fill")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.glass(tint: HappyColors.danger))
        }
        .sheet(item: Binding(
            get: { showConfirmation.map { ConfirmationID(approved: $0) } },
            set: { showConfirmation = $0?.approved }
        )) { item in
            ConfirmationView(approved: item.approved)
        }
    }
}

private struct ConfirmationID: Identifiable {
    let approved: Bool
    var id: String { approved ? "approved" : "denied" }
}
