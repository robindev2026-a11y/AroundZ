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
}
