import SwiftUI

enum AppColors: String {
    // Brand
    case primary = "coffeePrimary"
    case primaryDark = "coffeePrimaryDark"
    case purple = "coffeePurple"
    case peach = "coffeePeach"
    
    // Layout
    case background = "coffeeBackground"
    case surface = "coffeeSurface"
    case surfaceSecondary = "coffeeSurfaceSecondary"
    case border = "coffeeBorder"
    
    // Typography
    case textPrimary = "coffeeTextPrimary"
    case textSecondary = "coffeeTextSecondary"
    
    // Status
    case success = "coffeeSuccess"
    case error = "coffeeError"
    
    var color: Color {
        if self == .error {
            return Color(red: 0.86, green: 0.25, blue: 0.25) // Beautiful warm brand error red
        }
        return Color(self.rawValue)
    }
}
