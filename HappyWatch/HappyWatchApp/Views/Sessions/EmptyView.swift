import SwiftUI

/// No active sessions state
struct EmptySessionsView: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "tray")
                .font(.system(size: 36))
                .foregroundStyle(HappyColors.idle)

            Text("No Active Sessions")
                .font(HappyTypography.headline)

            Text("Start a Claude Code session on your machine")
                .font(HappyTypography.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            if !appState.connectivity.isReachable {
                Label("iPhone not connected", systemImage: "iphone.slash")
                    .font(HappyTypography.caption2)
                    .foregroundStyle(HappyColors.warning)
            }
        }
        .padding()
        .refreshable {
            await appState.refresh()
        }
    }
}

#Preview {
    EmptySessionsView()
        .environment(AppState())
}
