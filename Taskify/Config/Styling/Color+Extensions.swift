import SwiftUI

extension Color {
    // MARK: - Text Colors
    static let primaryText = Color.white                               // High contrast white text for glassy UI
    static let secondaryText = Color.white.opacity(0.7)                // Subtle secondary white text

    // MARK: - Gradient Colors
    static let shadowGray = Color.black.opacity(0.15)

    // MARK: - Semantic Colors
    static let accentGray = Color.gray//Color(red: 0.2, green: 0, blue: 0.8).opacity(0.5) // Standard blue - For accents
    static let destructiveRed = Color(red: 1.0, green: 0.1, blue: 0.2).opacity(0.9) // Muted red for destructive actions
    static let positiveGreen = Color(red: 0.7, green: 0.9, blue: 0.7)      // Consistent pastel green - for completed checkmark
    static let quickTicYellow = Color(red: 1.0, green: 0.9, blue: 0.3) // Brighter golden yellow for quick tics.
}

// Helper for hex colors if needed in the future
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
