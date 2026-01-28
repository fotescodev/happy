import SwiftUI

/// SF Pro scale for 198x242px watchOS display
enum HappyTypography {
    static let largeTitle = Font.system(size: 22, weight: .bold)
    static let title      = Font.system(size: 19, weight: .semibold)
    static let headline   = Font.system(size: 17, weight: .bold)
    static let body       = Font.system(size: 15)
    static let callout    = Font.system(size: 14)
    static let caption    = Font.system(size: 12)
    static let caption2   = Font.system(size: 11)

    static let monoBody   = Font.system(size: 13, design: .monospaced)
    static let monoSmall  = Font.system(size: 11, design: .monospaced)
}
