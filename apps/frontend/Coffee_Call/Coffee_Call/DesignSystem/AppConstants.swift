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
        static let standardPadding: CGFloat = 24
        static let headerTopPadding: CGFloat = 20
        static let sectionSpacing: CGFloat = 28
        static let elementSpacing: CGFloat = 16
        static let subElementSpacing: CGFloat = 8
        
        static let interestCardWidth: CGFloat = 100
        static let interestCardHeight: CGFloat = 130
        static let createDriftButtonHeight: CGFloat = 64
        static let interestCardRadius: CGFloat = 20
        static let floatingTabBarBottomPadding: CGFloat = 24
        static let screenBottomSpacer: CGFloat = 120
    }

    enum Typography {
        static let sizeDisplay: CGFloat = 32
        static let sizeTitle: CGFloat = 20
        static let sizeHeadline: CGFloat = 18
        static let sizeBody: CGFloat = 16
        static let sizeCaption: CGFloat = 13
        static let sizeTiny: CGFloat = 11
        static let sizeMicro: CGFloat = 10
    }
    
    enum Animation {
        static let entranceStagger: Double = 0.1
    }
    
    enum UI {
        static let cornerRadiusLarge: CGFloat = 32
        static let cornerRadiusMedium: CGFloat = 24
        static let cornerRadiusSmall: CGFloat = 16
        static let cornerRadiusTiny: CGFloat = 8
        
        static let shadowRadius: CGFloat = 15
        static let shadowY: CGFloat = 8
        
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
