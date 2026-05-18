import Foundation
import CoreGraphics
import SwiftUI

enum AppConstants {
    // MARK: - Private 8-Point Grid Scales (Single Source of Truth)
    private enum Grid {
        static let step4: CGFloat = 4
        static let step8: CGFloat = 8
        static let step12: CGFloat = 12
        static let step16: CGFloat = 16
        static let step20: CGFloat = 20
        static let step24: CGFloat = 24
        static let step30: CGFloat = 30
        static let step36: CGFloat = 36
        static let step44: CGFloat = 44
        static let step56: CGFloat = 56
        static let step80: CGFloat = 80
        static let step120: CGFloat = 120
    }
    
    enum Radar {
        static let distances: [Double] = [0.15, 0.35, 0.55, 0.75, 0.95]
        static let maxDistance: Double = 1.0
        static let ringOpacity: Double = 0.2
        static let ringLineWidth: CGFloat = 0.5
        static let personAvatarSize: CGFloat = 46.0 // Match DESIGN.md
        static let centerAvatarSize: CGFloat = 72.0 // Match DESIGN.md
        static let centerGlowSize: CGFloat = 84.0
    }
    
    // MARK: - Specific Surface Naming (Mapped to Core Grid Scales)
    enum Layout {
        static let radarBlurFactor: CGFloat = Grid.step8
        
        // Screen padding & edge margins
        static let standardPadding: CGFloat = Grid.step20
        static let headerTopPadding: CGFloat = Grid.step8
        static let floatingTabBarBottomPadding: CGFloat = Grid.step20
        static let screenBottomSpacer: CGFloat = Grid.step120
        static let miniPadding: CGFloat = Grid.step4
        
        // Spacing & layout gaps
        static let sectionSpacing: CGFloat = Grid.step24
        static let elementSpacing: CGFloat = Grid.step12
        static let subElementSpacing: CGFloat = Grid.step8
        
        // Buttons, inputs & touch targets
        static let minTouchTarget: CGFloat = Grid.step44
        static let createDriftButtonHeight: CGFloat = Grid.step56
        static let refreshButtonSize: CGFloat = 58 // Custom action bounds
        static let refreshButtonBottomPadding: CGFloat = Grid.step120
        
        // Cards & containers
        static let interestCardWidth: CGFloat = 79 // Match DESIGN.md
        static let interestCardHeight: CGFloat = 112 // Match DESIGN.md
        static let interestCardRadius: CGFloat = 22 // Match DESIGN.md
        static let headerHeight: CGFloat = 82
        static let headerRadius: CGFloat = Grid.step30
        static let tooltipRadius: CGFloat = Grid.step12
        
        // Presentation sheets
        static let sheetCollapsedOffset: CGFloat = 420
        static let sheetExpandedOffset: CGFloat = 110
        static let sheetSnapThreshold: CGFloat = 140
        static let sheetRadius: CGFloat = Grid.step36
        static let sheetHandleWidth: CGFloat = Grid.step44
        static let sheetHandleHeight: CGFloat = 5
        static let sheetHandleTopPadding: CGFloat = Grid.step8
        static let sheetHandleBottomPadding: CGFloat = Grid.step16
        
        // Avatar asset scales
        static let avatarSizeLarge: CGFloat = 62
        
        // Action margins
        static let buttonPaddingHorizontal: CGFloat = Grid.step16
        static let buttonPaddingVertical: CGFloat = Grid.step8
    }

    enum Typography {
        static let sizeDisplay: CGFloat = 28 // H1 (Header Titles)
        static let sizeTitle: CGFloat = 20 // H2 (Sub-sections)
        static let sizeHeadline: CGFloat = 17 // H3 (Card Titles)
        static let sizeBody: CGFloat = 15 // Body (Standard lists)
        static let sizeCaption: CGFloat = 12 // Caption
        static let sizeTiny: CGFloat = 10 // Detail Tags
        static let sizeMicro: CGFloat = 9 // Micro tags
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
        static let opacityMuted: CGFloat = 0.3
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
        
        static let chatParticipants: [ParticipantInfo] = [
            ParticipantInfo(initials: "M", name: "Mira", color: .brandPrimary, isHost: true, isMe: false),
            ParticipantInfo(initials: "R", name: "Rahul", color: .brandPurple, isHost: false, isMe: false),
            ParticipantInfo(initials: "A", name: "Aditi", color: .brandSecondary, isHost: false, isMe: false),
            ParticipantInfo(initials: "N", name: "Neel", color: .blue, isHost: false, isMe: false),
            ParticipantInfo(initials: "Y", name: "You", color: .brandPrimary, isHost: false, isMe: true)
        ]
        
        static var chatSystemMessages: [SystemMessage] {
            [
                SystemMessage(content: "Arjun (Host) created this Drift", icon: AppIcons.person, timestamp: Date().addingTimeInterval(-3600)),
                SystemMessage(content: "Maya joined the Drift", icon: AppIcons.verified, timestamp: Date().addingTimeInterval(-3000)),
                SystemMessage(content: "Drift starts in 30 mins", icon: AppIcons.clockFill, timestamp: Date().addingTimeInterval(-2400))
            ]
        }
        
        static var chatHistoryMessages: [ChatMessage] {
            [
                ChatMessage(senderId: "host_1", senderName: "Arjun (Host)", senderInitials: "AR", content: "Hi everyone! Looking forward to a relaxing evening walk. See you there! 🌿", timestamp: Date().addingTimeInterval(-1800), isSelf: false),
                ChatMessage(senderId: "user_2", senderName: "Sneha R.", senderInitials: "SR", content: "Excited to join! I'll be there.", timestamp: Date().addingTimeInterval(-1500), isSelf: false),
                ChatMessage(senderId: "user_3", senderName: "Karthik M.", senderInitials: "KM", content: "I might be a few minutes late. See you soon!", timestamp: Date().addingTimeInterval(-1200), isSelf: true)
            ]
        }
    }
}
