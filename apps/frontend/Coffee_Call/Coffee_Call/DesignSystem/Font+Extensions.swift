import SwiftUI

extension Font {
    // Large expressive titles
    static let heading1 = Font.system(size: AppConstants.Typography.sizeDisplay, weight: .black)
    static let heading2 = Font.system(size: AppConstants.Typography.sizeTitle, weight: .black)
    
    // Core body and UI text
    static let bodyStandard = Font.system(size: AppConstants.Typography.sizeBody, weight: .medium)
    static let bodyBold = Font.system(size: AppConstants.Typography.sizeBody, weight: .black)
    static let bodySmall = Font.system(size: AppConstants.Typography.sizeCaption, weight: .bold)
    static let captionText = Font.system(size: AppConstants.Typography.sizeCaption, weight: .bold)
    
    // Metadata and utility
    static let metadata = Font.system(size: AppConstants.Typography.sizeTiny, weight: .bold)
    static let micro = Font.system(size: AppConstants.Typography.sizeMicro, weight: .black)
    
    // Actions
    static let buttonText = Font.system(size: AppConstants.Typography.sizeHeadline, weight: .black)
}
