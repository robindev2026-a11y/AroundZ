import Foundation
import CoreGraphics

enum AppConstants {
    enum Radar {
        static let distances: [Double] = [0.3, 0.6, 0.8]
        static let maxDistance: Double = 1.0
        static let ringOpacity: Double = 0.3
        static let ringLineWidth: CGFloat = 1.0
        static let personAvatarSize: CGFloat = 40.0
        static let centerAvatarSize: CGFloat = 72.0
        static let centerGlowSize: CGFloat = 90.0
    }
    
    enum Layout {
        static let standardPadding: CGFloat = 24.0
        static let headerTopPadding: CGFloat = 16.0
        static let interestCardWidth: CGFloat = 100.0
        static let interestCardHeight: CGFloat = 130.0
        static let interestCardRadius: CGFloat = 32.0
        static let createDriftButtonHeight: CGFloat = 80.0
        static let floatingTabBarBottomPadding: CGFloat = 24.0
        static let screenBottomSpacer: CGFloat = 120.0
    }
    
    enum Animation {
        static let entranceStagger: Double = 0.1
    }
    
    enum UI {
        static let cornerRadiusLarge: CGFloat = 32.0
        static let cornerRadiusMedium: CGFloat = 24.0
        static let cornerRadiusSmall: CGFloat = 16.0
        static let cornerRadiusExtraSmall: CGFloat = 12.0
        
        static let opacitySubtle: Double = 0.05
        static let opacityLight: Double = 0.1
        static let opacityMedium: Double = 0.3
        static let opacityOverlay: Double = 0.9
        
        static let shadowRadius: CGFloat = 15.0
        static let shadowY: CGFloat = 8.0
    }
    
    enum MockData {
        static let radarDistances: [Double] = [0.35, 0.45, 0.65, 0.75, 0.25, 0.55]
        static let radarAngles: [Double] = [160, 30, 120, 210, 280, 330]
        static let userInitials = "AR"
        static let userName = "Arjun R."
    }
}
