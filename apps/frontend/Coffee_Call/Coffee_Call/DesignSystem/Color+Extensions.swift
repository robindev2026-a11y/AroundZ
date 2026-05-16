import SwiftUI

extension Color {
    /// Initialize a Color from the AppColors enum (linked to Asset Catalog)
    init(_ appColor: AppColors) {
        self = appColor.color
    }

    // Direct accessors for common tokens to maintain existing code compatibility
    static let brandPrimary      = AppColors.primary.color
    static let brandPrimaryDark  = AppColors.primaryDark.color
    static let brandPurple       = AppColors.purple.color
    static let brandSecondary    = AppColors.peach.color
    
    static let backgroundMain    = AppColors.background.color
    static let surfaceMain       = AppColors.surface.color
    static let surfaceSecondary  = AppColors.surfaceSecondary.color
    static let appBorder         = AppColors.border.color
    
    static let textPrimary       = AppColors.textPrimary.color
    static let textSecondary     = AppColors.textSecondary.color
    static let textOnBrand       = Color.white
    
    static let darkOverlay       = AppColors.textPrimary.color.opacity(0.4)
    
    static let statusSuccess     = AppColors.success.color
    static let statusError       = AppColors.error.color
}
