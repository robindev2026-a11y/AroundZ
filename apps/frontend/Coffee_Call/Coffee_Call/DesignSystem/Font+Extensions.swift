import SwiftUI

extension Font {
    // MARK: - CoffeeCall Design Tokens (100% Native SwiftUI - Outfit + SF Pro Hybrid)
    
    // Large expressive titles (Outfit Custom Font - scales natively relative to system titles)
    static let heading1 = Font.custom("Outfit-Black", size: AppConstants.Typography.sizeDisplay, relativeTo: .title)
    static let heading2 = Font.custom("Outfit-Black", size: AppConstants.Typography.sizeTitle, relativeTo: .title2)
    
    // Core body and UI text (SF Pro Native System - scales natively out of the box!)
    static let bodyStandard = Font.system(.body, design: .default).weight(.medium)
    static let bodyBold = Font.system(.body, design: .default).weight(.black)
    static let bodySmall = Font.system(.subheadline, design: .default).weight(.bold)
    static let captionText = Font.system(.caption, design: .default).weight(.bold)
    
    // Metadata and utility (SF Pro Native System - scales natively out of the box!)
    static let metadata = Font.system(.caption2, design: .default).weight(.bold)
    static let micro = Font.system(.caption2, design: .default).weight(.black)
    
    // Actions (Outfit Custom Font - scales natively relative to system buttons)
    static let buttonText = Font.custom("Outfit-Black", size: AppConstants.Typography.sizeHeadline, relativeTo: .headline)
}


