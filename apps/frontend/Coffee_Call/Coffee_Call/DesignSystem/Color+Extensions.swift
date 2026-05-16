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

    // MARK: - Social Refresh Palette (Referencing Asset Catalog)
    static let brandPrimary      = Color("coffeePrimary")
    static let brandPrimaryDark  = Color("coffeePrimaryDark")
    static let brandPurple       = Color("coffeePurple")
    static let brandSecondary    = Color("coffeePeach")
    
    static let backgroundMain    = Color("coffeeBackground")
    static let surfaceMain       = Color("coffeeSurface")
    static let surfaceSecondary  = Color("coffeeSurfaceSecondary")
    static let appBorder         = Color("coffeeBorder")
    
    static let textPrimary       = Color("coffeeTextPrimary")
    static let textSecondary     = Color("coffeeTextSecondary")
    static let textOnBrand       = Color.white
    
    static let darkOverlay       = Color("coffeeTextPrimary").opacity(0.4)
    
    // MARK: - Status
    static let statusSuccess     = Color("coffeeSuccess")
    static let statusError       = Color("coffeeError")
}
