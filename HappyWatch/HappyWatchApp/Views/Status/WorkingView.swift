import SwiftUI

/// Agent working/thinking state with pulse animation
struct WorkingView: View {
    let session: WatchSession
    @State private var isPulsing = false

    var body: some View {
        VStack(spacing: 12) {
            // Animated state indicator
            ZStack {
                Circle()
                    .fill(session.claudeState.color.opacity(0.2))
                    .frame(width: 60, height: 60)
                    .scaleEffect(isPulsing ? 1.3 : 1.0)
                    .opacity(isPulsing ? 0.0 : 0.5)
                    .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: false), value: isPulsing)

                Circle()
                    .fill(session.claudeState.color.opacity(0.4))
                    .frame(width: 40, height: 40)
                    .scaleEffect(isPulsing ? 1.2 : 1.0)
                    .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: false).delay(0.3), value: isPulsing)

                Image(systemName: session.claudeState.systemImage)
                    .font(.system(size: 20))
                    .foregroundStyle(session.claudeState.color)
            }

            Text(session.claudeState.label)
                .font(HappyTypography.headline)

            if let summary = session.metadata?.summary?.text {
                Text(summary)
                    .font(HappyTypography.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(3)
                    .multilineTextAlignment(.center)
            }

            // Pending approvals shortcut
            if session.hasPendingApprovals {
                NavigationLink(value: AppState.NavigationDestination.approvalList) {
                    Label("\(session.pendingRequests.count) needs approval", systemImage: "hand.raised.fill")
                        .font(HappyTypography.callout)
                        .foregroundStyle(HappyColors.question)
                }
            }
        }
        .padding()
        .onAppear { isPulsing = true }
    }
}
