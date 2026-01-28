import SwiftUI

/// Screen A1: "Open Happy on iPhone" prompt
struct PairingView: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "iphone.and.arrow.forward")
                .font(.system(size: 40))
                .foregroundStyle(HappyColors.brand)

            Text("Open Happy on iPhone")
                .font(HappyTypography.headline)
                .multilineTextAlignment(.center)

            Text("Pair your watch to get started")
                .font(HappyTypography.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            if appState.connectivity.isActivated && !appState.connectivity.isReachable {
                Label("iPhone not reachable", systemImage: "wifi.slash")
                    .font(HappyTypography.caption2)
                    .foregroundStyle(HappyColors.warning)
            }
        }
        .padding()
        .onChange(of: appState.auth.isAuthenticated) { _, isAuth in
            // Auto-transition when auth arrives
        }
    }
}

#Preview {
    PairingView()
        .environment(AppState())
}
