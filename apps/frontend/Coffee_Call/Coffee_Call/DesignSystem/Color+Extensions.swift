import SwiftUI

extension Color {
    // MARK: - Brand Colors
    static let brandPrimary = Color("coffeePrimary")
    static let brandSecondary = Color("coffeePeach")
    static let brandPrimaryLight = Color("coffeePrimaryLight")
    static let brandPrimaryDark = Color("coffeePrimaryDark")
    
    // MARK: - UI & Layout
    static let backgroundMain = Color("coffeeBackground")
    static let surfaceMain = Color("coffeeSurface")
    static let appBorder = Color("coffeeBorder")
    
    // MARK: - Text & Content
    static let textPrimary = Color("coffeeTextPrimary")
    static let textSecondary = Color("coffeeTextSecondary")
    static let textOnBrand = Color.white
    
    // MARK: - Status
    static let statusSuccess = Color("coffeeSuccess")
    static let statusError = Color(red: 0.87, green: 0.27, blue: 0.27)
}
