
import SwiftUI

extension Color {
    // MARK: - Primary Colors
    static let primaryAppBlue = Color(red: 0.0, green: 0.478, blue: 1.0) // Standard systemBlue
    static let accentOrange = Color.orange

    // MARK: - Background Colors
    static let appBackground = Color(UIColor.systemGray6) // Light, neutral background
    static let componentBackground = Color(UIColor.systemBackground) // For cards, input fields

    // MARK: - Text Colors
    static let primaryText = Color.primary
    static let secondaryText = Color.secondary

    // MARK: - Semantic Colors
    static let destructiveRed = Color.red
    static let positiveGreen = Color(red: 0.2, green: 0.8, blue: 0.4) // A slightly more vibrant green
    static let reminderUpcoming = Color(red: 0.64, green: 0.89, blue: 0.86) // Pastel teal
    static let reminderOverdue = Color(red: 0.96, green: 0.66, blue: 0.63) // Pastel coral
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

