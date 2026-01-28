import SwiftUI

/// 9-color palette from the Pencil design spec
enum HappyColors {
    static let brand    = Color(hex: 0xD97757)  // Claude orange
    static let success  = Color(hex: 0x34C759)  // Green
    static let warning  = Color(hex: 0xFF9500)  // Orange
    static let danger   = Color(hex: 0xFF3B30)  // Red
    static let info     = Color(hex: 0x007AFF)  // Blue
    static let idle     = Color(hex: 0x8E8E93)  // Gray
    static let plan     = Color(hex: 0xBF5AF2)  // Purple
    static let context  = Color(hex: 0x5AC8FA)  // Light blue
    static let question = Color(hex: 0xAF52DE)  // Deep purple

    // Background shades for cards
    static let cardBackground = Color.white.opacity(0.08)
    static let cardBorder = Color.white.opacity(0.15)
}

extension Color {
    init(hex: UInt32, opacity: Double = 1.0) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255,
            opacity: opacity
        )
    }
}
