import Foundation

enum AppStrings {
    static let appTitle = "CoffeeCall"
    static let betaTag = "COFFEECALL BETA"
    
    enum Onboarding {
        static let slide1Title1 = "Meet people"
        static let slide1Title2 = "nearby in"
        static let slide1Title3 = "real life."
        static let slide1CTA = "Let's Go →"
        static let activity1Title = "Sunset Walk + Convo"
        static let activity2Title = "Photo Session at Park"
        
        static let slide2Title = "Discover what's\nhappening nearby."
        static let slide2Subtitle = "Coffee chats, walks, gaming, and spontaneous social moments."
        static let slide2CTA = "Next →"
        
        static let slide3Title = "Safe, friendly,\nand verified."
        static let slide3Subtitle = "We prioritize trust and real connections through verified profiles and community vibes."
        static let slide3CTA = "Sounds Good →"
        static let safetyFeature1 = "Verified Community"
        static let safetyFeature2 = "Shared Mutual Friends"
        static let safetyFeature3 = "Vibe-Checked Meetups"
        
        static let slide4Title = "What are you into today?"
        static let slide4Subtitle = "Select at least 3 to find your vibe."
        static let selectMore = "Select %d more"
        static let readyToGo = "Let's Go"
        
        static let slide5Title = "You're ready to\njoin the moment."
        static let slide5Subtitle = "48 meetups happening in your city right now."
        static let slide5CTA = "Start Exploring"
        static let communityJoinNote = "JOIN RILEY AND 1,204 OTHERS NEARBY"
        static let socialProofCount = "+1.2k"
        static let joinFreeNote = "NO CREDIT CARD REQUIRED • JOIN FOR FREE"
        
        static let nowNearby = "NOW NEARBY"
        static let peopleJoined = "%d PEOPLE JOINED"
        static let activeCount = "%d ACTIVE"
    }
    
    enum Auth {
        static let phoneTitle = "What's your\nphone number?"
        static let phoneSubtitle = "We'll send a one-time code to verify your number."
        static let phonePlaceholder = "Phone number"
        static let phoneCTA = "Send Code →"
        static let sending = "Sending..."
        static let skipDebug = "⚡ Skip OTP (Debug)"
        static let skipVerifyDebug = "⚡ Skip Verify (Debug)"
        static let skipProfileDebug = "⚡ Skip Profile (Debug)"
        static let searchCountry = "Search country"
        static let selectCountry = "Select Country"
        
        static let profileTitle = "Create your profile"
        static let profileCTA = "Complete Profile"
        static let saving = "Saving..."
        static let takePhoto = "Take Photo"
        static let chooseLibrary = "Choose Library"
        static let displayNameLabel = "DISPLAY NAME"
        static let displayNamePlaceholder = "What should we call you?"
        static let displayNameSubtitle = "This is how your friends will see you on CoffeeCall."
        
        static let permissionsTitle = "Almost there"
        static let permissionsSubtitle = "CoffeeCall works best when we can find\nactivities and keep you updated."
        static let locationTitle = "Location Services"
        static let locationDesc = "We use your location to show you spontaneous activities happening right around you."
        static let locationRadiusDesc = "CoffeeCall uses your location to match you with nearby people and activities within a 10km radius."
        static let locationCTA = "Allow Location Access"
        static let locationSimpleCTA = "Allow Location"
        static let locationGranted = "Location Granted"
        static let locationSkip = "Skip for now"
        static let notificationsTitle = "Real-time Updates"
        static let notificationsDesc = "Get notified instantly when someone joins your activity or starts something nearby."
        static let notificationsCTA = "Enable Notifications"
        static let notificationsEnabled = "Notifications Enabled"
        
        static let readyTitle = "You're ready!"
        static let readySubtitle = "Your profile is set up and you're part of\nthe CoffeeCall community."
        static let readyCTA = "Start Exploring"
        static let privacyNote = "YOUR PRIVACY IS OUR PRIORITY"
        static let tipTitle = "First Activity Tip"
        static let tipDesc = "Don't be shy! Most people on\nCoffeeCall are just as eager to meet\nsomeone new."
    }
    
    enum Error {
        static let otpTimeout = "OTP request timed out. Use a Firebase test phone number in the simulator."
        static let missingVerificationID = "Firebase did not return a verification ID."
        static let generic = "Something went wrong. Please try again."
        static let incorrectCode = "Incorrect code. Please try again."
        static let notSignedIn = "Not signed in."
    }
}
