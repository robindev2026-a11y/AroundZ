import SwiftUI

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
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }

    // MARK: - Social Refresh Palette
    static let brandPrimary = Color(hex: "#53B8A6")     // Mint
    static let brandPrimaryDark = Color(hex: "#3D8D7A") // Pressed Mint
    static let brandPurple = Color(hex: "#8E7DBE")      // Lavender
    static let brandSecondary = Color(hex: "#E88C6B")   // Peach
    
    static let backgroundMain = Color(hex: "#F6F1EB")    // Warm White
    static let surfaceMain = Color(hex: "#FFFDF9")       // Card Surface
    static let surfaceSecondary = Color(hex: "#F4F4F8")  // Secondary Surface
    static let appBorder = Color(hex: "#E7DED4")         // Border
    
    static let textPrimary = Color(hex: "#243447")       // Dark Blue/Grey
    static let textSecondary = Color(hex: "#5F6368")     // Muted Grey
    static let textOnBrand = Color.white
    
    static let darkOverlay = Color(hex: "#243447").opacity(0.4)
    
    // MARK: - Status
    static let statusSuccess = Color(hex: "#53B8A6")
    static let statusError = Color(hex: "#DE4545")
}
