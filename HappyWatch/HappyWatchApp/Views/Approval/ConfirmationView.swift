import SwiftUI
import WatchKit

/// Success/failure haptic feedback + auto-dismiss
struct ConfirmationView: View {
    let approved: Bool

    @State private var showIcon = false
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: approved ? "checkmark.circle.fill" : "xmark.circle.fill")
                .font(.system(size: 48))
                .foregroundStyle(approved ? HappyColors.success : HappyColors.danger)
                .scaleEffect(showIcon ? 1.0 : 0.5)
                .opacity(showIcon ? 1.0 : 0.0)
                .animation(.spring(response: 0.3, dampingFraction: 0.6), value: showIcon)

            Text(approved ? "Approved" : "Denied")
                .font(HappyTypography.title)
                .opacity(showIcon ? 1.0 : 0.0)
                .animation(.easeIn(duration: 0.2).delay(0.15), value: showIcon)
        }
        .onAppear {
            showIcon = true
            WKInterfaceDevice.current().play(approved ? .success : .failure)

            // Auto-dismiss after delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                dismiss()
            }
        }
    }
}

#Preview("Approved") {
    ConfirmationView(approved: true)
}

#Preview("Denied") {
    ConfirmationView(approved: false)
}
