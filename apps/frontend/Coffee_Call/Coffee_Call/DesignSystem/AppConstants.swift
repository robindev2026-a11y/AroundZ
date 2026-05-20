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

        // Map Preview
        static let mapPreviewHeight: CGFloat = 180
        static let mapGridStep: CGFloat = 40
        static let mapGridOffset: CGFloat = 20
        static let mapGridOffsetSmall: CGFloat = 10
        static let mapRadiusSize: CGFloat = 100
        static let mapTextOffset: CGFloat = 74
        
        // Presentation sheets
        static let sheetCollapsedOffset: CGFloat = 420
        static let sheetExpandedOffset: CGFloat = 110
        static let sheetSnapThreshold: CGFloat = 140
        static let sheetRadius: CGFloat = Grid.step36
        static let sheetHandleWidth: CGFloat = Grid.step44
        static let sheetHandleHeight: CGFloat = 5
        static let sheetHandleTopPadding: CGFloat = Grid.step8
        static let sheetHandleBottomPadding: CGFloat = Grid.step16
        static let createSheetRadius: CGFloat = 32
        static let createSheetFooterHeight: CGFloat = 112
        static let createSheetFooterSpacing: CGFloat = Grid.step16
        static let createSheetCardMinHeight: CGFloat = 54
        static let createSheetChipHeight: CGFloat = 44
        static let createSheetIconWellSize: CGFloat = 48
        static let createSheetLocationCardHeight: CGFloat = 132
        static let createSheetTimeChipWidth: CGFloat = 92
        static let createSheetCapacityChipWidth: CGFloat = 56
        static let createSheetJoinModeHeight: CGFloat = 72
        static let createSheetOptionalCollapsedHeight: CGFloat = 84

        static let confirmationSheetHeight: CGFloat = 380

        // Avatar asset scales
        static let avatarSizeSmall: CGFloat = 38
        static let avatarSizeMedium: CGFloat = 44
        static let avatarSizeLarge: CGFloat = 48
        static let avatarSizeXLarge: CGFloat = 62 // Replaced old avatarSizeLarge
        static let avatarSizeXXLarge: CGFloat = 72
        static let avatarSizeXXXLarge: CGFloat = 80

        static let cardThumbnailWidth: CGFloat = 80
        static let cardThumbnailHeight: CGFloat = 60
        static let cardGalleryWidth: CGFloat = 120
        static let cardGalleryHeight: CGFloat = 80
        static let cardGalleryContainerWidth: CGFloat = 136

        static let cornerRadiusTiny: CGFloat = Grid.step4
        static let mappinSize: CGFloat = 44
        
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

    enum Create {
        static let activityGridCollapsedCount: Int = 6
    }

    enum Auth {
        static let screenHorizontalPadding: CGFloat = 32
        static let topSpacing: CGFloat = 40
        static let sectionSpacing: CGFloat = 12
        static let titleBottomSpacing: CGFloat = 48
        static let helperTopSpacing: CGFloat = 24
        static let fieldHeight: CGFloat = 64
        static let backButtonSize: CGFloat = 48
        static let backButtonCornerRadius: CGFloat = 24
        static let fieldCornerRadius: CGFloat = 16
        static let countryFieldWidth: CGFloat = 110
        static let countryFieldSpacing: CGFloat = 14
        static let countryFlagSize: CGFloat = 20
        static let countryCodeFontSize: CGFloat = 16
        static let countryChevronSize: CGFloat = 12
        static let phoneFontSize: CGFloat = 20
        static let smsHelperFontSize: CGFloat = 14
        static let phoneButtonFontSize: CGFloat = 18
        static let authButtonBottomSpacing: CGFloat = 12
        static let minPhoneDigits: Int = 8
        static let maxPhoneDigits: Int = 15
        static let titleLineSpacing: CGFloat = 4
        static let helperLineSpacing: CGFloat = 3
        static let labelKerning: CGFloat = 1.8
        static let countryItemSpacing: CGFloat = 16
        static let countryItemFlagSize: CGFloat = 28
        static let countryItemCornerRadius: CGFloat = 16
        static let countryItemVerticalPadding: CGFloat = 4
        static let backButtonShadowRadius: CGFloat = 12
        static let backButtonShadowY: CGFloat = 4
        static let fieldShadowRadius: CGFloat = 12
        static let fieldShadowY: CGFloat = 4
        static let loadingScale: CGFloat = 0.9
        static let phoneButtonShadowRadius: CGFloat = 18
        static let phoneButtonShadowY: CGFloat = 8
        static let countryHeight: CGFloat = 64
        static let countryFieldShadowRadius: CGFloat = 12
        static let countryFieldShadowY: CGFloat = 4
        static let borderWidth: CGFloat = 1
        static let disabledButtonOpacity: CGFloat = 0.24
        static let brandShadowOpacity: CGFloat = 0.22
        static let secondaryTextOpacity: CGFloat = 0.82
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
