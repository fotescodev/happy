import SwiftUI

/// Screen A2: Progress indicator during auth transfer
struct WaitingView: View {
    var body: some View {
        VStack(spacing: 16) {
            ProgressView()
                .tint(HappyColors.brand)

            Text("Connecting...")
                .font(HappyTypography.body)
                .foregroundStyle(.secondary)
        }
        .padding()
    }
}

#Preview {
    WaitingView()
}
