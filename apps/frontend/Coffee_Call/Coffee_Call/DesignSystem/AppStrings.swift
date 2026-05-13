import Foundation

enum AppStrings {
    static let appTitle = "CoffeeCall"
    static let betaTag = "COFFEECALL BETA"
    
    enum Onboarding {
        static let slide1Title1 = "Meet people"
        static let slide1Title2 = "nearby in"
        static let slide1Title3 = "real life."
        static let slide1CTA = "Let's Go →"
        
        static let slide5Title = "You're ready to join the moment."
        static let slide5Subtitle = "CoffeeCall is about real connections in real time. Grab a coffee, join a walk, or catch a movie."
        static let slide5CTA = "Start Exploring"
        
        static let nowNearby = "NOW NEARBY"
        static let peopleJoined = "PEOPLE JOINED"
    }
    
    enum Auth {
        static let phoneTitle = "What's your phone number?"
        static let phoneSubtitle = "We'll send you a code to verify your account. Your number is never shared."
        static let sendCode = "Send Verification Code"
        
        static let otpTitle = "Enter verification code"
        static let otpSubtitle = "Sent to your phone number"
        static let verifyCode = "Verify and Continue"
        static let resendCode = "Didn't get the code? Resend"
        
        static let setupTitle = "Set up your profile"
        static let setupSubtitle = "This is how your friends will see you on CoffeeCall."
        static let firstNamePlaceholder = "First Name"
        static let completeProfile = "Complete Profile"
    }
    
    enum Permissions {
        static let title = "Almost there"
        static let subtitle = "To find activities near you, we need your location and notification permissions."
        static let locationLabel = "Location Services"
        static let locationDesc = "Find coffee and meetups within 10km"
        static let notificationsLabel = "Notifications"
        static let notificationsDesc = "Get notified when someone accepts your post"
        static let continueBtn = "Continue"
    }
}
