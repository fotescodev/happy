import SwiftUI

/// Screen A3: Checkmark animation, auto-navigates to sessions
struct AuthSuccessView: View {
    @State private var showCheck = false

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 48))
                .foregroundStyle(HappyColors.success)
                .scaleEffect(showCheck ? 1.0 : 0.5)
                .opacity(showCheck ? 1.0 : 0.0)
                .animation(.spring(response: 0.4, dampingFraction: 0.6), value: showCheck)

            Text("Connected")
                .font(HappyTypography.title)
                .opacity(showCheck ? 1.0 : 0.0)
                .animation(.easeIn(duration: 0.3).delay(0.2), value: showCheck)
        }
        .onAppear {
            showCheck = true
        }
    }
}

#Preview {
    AuthSuccessView()
}
