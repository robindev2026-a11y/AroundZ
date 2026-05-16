import Foundation
import CoreGraphics

enum AppConstants {
    enum Radar {
        static let distances: [Double] = [0.3, 0.6, 0.8]
        static let maxDistance: Double = 1.0
        static let ringOpacity: Double = 0.2
        static let ringLineWidth: CGFloat = 0.5
        static let personAvatarSize: CGFloat = 46.0 // Match DESIGN.md
        static let centerAvatarSize: CGFloat = 72.0 // Match DESIGN.md
        static let centerGlowSize: CGFloat = 84.0
    }
    
    enum Layout {
        static let standardPadding: CGFloat = 20
        static let headerTopPadding: CGFloat = 16
        static let sectionSpacing: CGFloat = 22
        static let elementSpacing: CGFloat = 12
        static let subElementSpacing: CGFloat = 6
        
        static let interestCardWidth: CGFloat = 79 // Match DESIGN.md
        static let interestCardHeight: CGFloat = 112 // Match DESIGN.md
        static let createDriftButtonHeight: CGFloat = 56
        static let interestCardRadius: CGFloat = 22 // Match DESIGN.md
        
        static let headerHeight: CGFloat = 82
        static let headerRadius: CGFloat = 30
        static let tooltipRadius: CGFloat = 14
        
        static let sheetCollapsedOffset: CGFloat = 420
        static let sheetExpandedOffset: CGFloat = 110
        static let sheetSnapThreshold: CGFloat = 140
        static let sheetRadius: CGFloat = 36
        
        static let refreshButtonSize: CGFloat = 58
        static let refreshButtonBottomPadding: CGFloat = 120
        
        static let buttonPaddingHorizontal: CGFloat = 16
        static let buttonPaddingVertical: CGFloat = 10
        
        static let floatingTabBarBottomPadding: CGFloat = 20
        static let screenBottomSpacer: CGFloat = 80 // Reduced to match compact UI
    }

    enum Typography {
        static let sizeDisplay: CGFloat = 32 // H1
        static let sizeTitle: CGFloat = 24 // H2
        static let sizeHeadline: CGFloat = 20 // H3
        static let sizeBody: CGFloat = 16 // Body
        static let sizeCaption: CGFloat = 12 // Caption
        static let sizeTiny: CGFloat = 10
        static let sizeMicro: CGFloat = 9
    }
    
    enum Animation {
        static let entranceStagger: Double = 0.1
    }
    
    enum UI {
        static let cornerRadiusLarge: CGFloat = 24
        static let cornerRadiusMedium: CGFloat = 20
        static let cornerRadiusSmall: CGFloat = 12
        static let cornerRadiusTiny: CGFloat = 6
        
        static let shadowRadius: CGFloat = 12
        static let shadowY: CGFloat = 6
        
        static let opacityOverlay: CGFloat = 0.92
        static let opacityNormal: CGFloat = 0.4
        static let opacityLight: CGFloat = 0.15
        static let opacitySubtle: CGFloat = 0.05
    }
    
    enum MockData {
        static let radarDistances: [Double] = [0.35, 0.45, 0.65, 0.75, 0.25, 0.55]
        static let radarAngles: [Double] = [160, 30, 120, 210, 280, 330]
        static let radarInitials: [String] = ["DK", "MR", "LM", "NP", "TH", "AL"]
        static let userInitials = "AR"
        static let userName = "Arjun R."
        static let userBio = "Usually up for walks, coffee, and casual food plans."
    }
}
