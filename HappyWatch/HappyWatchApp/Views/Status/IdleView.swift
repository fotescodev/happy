import SwiftUI

/// Agent idle/completed/offline state
struct IdleView: View {
    let session: WatchSession

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: session.claudeState.systemImage)
                .font(.system(size: 32))
                .foregroundStyle(session.claudeState.color)

            StatusBadge(state: session.claudeState)

            VStack(spacing: 6) {
                if let host = session.metadata?.host {
                    Label(host, systemImage: "desktopcomputer")
                        .font(HappyTypography.caption)
                        .foregroundStyle(.secondary)
                }

                if let summary = session.metadata?.summary?.text {
                    Text(summary)
                        .font(HappyTypography.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(4)
                        .multilineTextAlignment(.center)
                }
            }

            if session.claudeState == .paused {
                Text("Waiting for input")
                    .font(HappyTypography.caption2)
                    .foregroundStyle(HappyColors.warning)
            }
        }
        .padding()
    }
}
