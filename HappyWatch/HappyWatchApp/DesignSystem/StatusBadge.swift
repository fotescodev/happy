import SwiftUI

/// Reusable state indicator badge showing a ClaudeState
struct StatusBadge: View {
    let state: ClaudeState
    var compact: Bool = false

    var body: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(state.color)
                .frame(width: 8, height: 8)
                .overlay {
                    if state == .thinking || state == .working {
                        Circle()
                            .fill(state.color.opacity(0.4))
                            .frame(width: 14, height: 14)
                            .modifier(PulseModifier())
                    }
                }
            if !compact {
                Text(state.label)
                    .font(HappyTypography.caption2)
                    .foregroundStyle(state.color)
            }
        }
    }
}

/// Pulse animation for active states
private struct PulseModifier: ViewModifier {
    @State private var isPulsing = false

    func body(content: Content) -> some View {
        content
            .scaleEffect(isPulsing ? 1.3 : 1.0)
            .opacity(isPulsing ? 0.0 : 0.5)
            .animation(.easeInOut(duration: 1.2).repeatForever(autoreverses: false), value: isPulsing)
            .onAppear { isPulsing = true }
    }
}

#Preview {
    VStack(spacing: 8) {
        ForEach(ClaudeState.allCases, id: \.rawValue) { state in
            StatusBadge(state: state)
        }
    }
}
