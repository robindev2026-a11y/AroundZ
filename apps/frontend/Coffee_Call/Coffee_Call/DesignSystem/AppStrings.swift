import Foundation

enum AppStrings {
    static let appTitle = "CoffeeCall"
    static let betaTag = "COFFEECALL BETA"
    
    enum Onboarding {
        static let slide1Title1 = "Meet people"
        static let slide1Title2 = "nearby in"
        static let slide1Title3 = "real life."
        static let slide1CTA = "Let's Go"
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
        static let phoneTitle = "What's your number?"
        static let phoneSubtitle = "We'll send you a verification code to keep your account secure."
        static let phoneLabel = "PHONE NUMBER"
        static let phonePlaceholder = "(555) 000-0000"
        static let phoneCTA = "Send Code"
        static let sending = "Sending..."
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
        static let readySubtitle = "Your profile is complete and we've found activities near you."
        static let readyCTA = "Start Exploring"
        static let privacyNote = "YOUR PRIVACY IS OUR PRIORITY"
        static let tipTitle = "First Activity Tip"
        static let tipDesc = "Don't be shy! Most people on\nCoffeeCall are just as eager to meet\nsomeone new."
        
        static let otpTitle = "Verify it's you"
        static let verifying = "Verifying..."
        static let otpCTA = "Verify"
        static let sentTo = "Enter the 6-digit code sent to"
        static let resendCode = "Resend code"
    }
    
    enum Error {
        static let invalidPhoneNumber = "Enter a valid phone number with country code."
        static let missingVerificationID = "Firebase did not return a verification ID."
        static let generic = "Something went wrong. Please try again."
        static let incorrectCode = "Incorrect code. Please try again."
        static let notSignedIn = "Not signed in."
    }

    enum Tabs {
        static let discover  = "Around"
        static let myPosts   = "Drifts"
        static let messages  = "Chats"
        static let profile   = "You"
        static let create    = "Create"
    }

    enum Discovery {
        static let title = "Around"
        static let subtitleDefault = "People nearby are open to plans"
        static let subtitleRefreshing = "Refreshing nearby activity..."
        
        static let contextTitle = "People around you are open to plans."
        static let contextSubtitle = "Join a Drift or create your own."
        static let seeNearbyDrifts = "See nearby Drifts"
        static let driftsForming = "Nearby Drifts are forming"
        static let driftsFormingSub = "Join one or create your own."
        static let anonymousSignal = "Someone nearby is open to plans"
        static let startDrift = "Start Drift"
        
        static let locationLabel = "NEARBY"
        static let searchPlaceholder = "Search moments, vibes, or people..."
        static let joinBtn = "Join"
        static let joinedBtn = "Joined"
        static let joinMomentBtn = "Join Moment"
        static let distanceKm = "%d km away"
        static let timeAgo = "%@ ago"
        static let postBtn = "Post Activity"
        static let meetupsNearby = "%d meetups happening nearby"
        static let interestsNearby = "Your interests nearby"
        static let driftActivityTip = "Join a Drift or start your own to chat."
        static let defaultCategory = "Coffee"
        static let createDrift = "Create Drift"
        static let createDriftSubtitle = "Share what you're up for"
        static let nearby = "nearby"

        enum Categories {
            static let coffee = "Coffee"
            static let walks = "Walks"
            static let gaming = "Gaming"
            static let study = "Study"
            static let food = "Food"
            static let startup = "Startup"
            static let music = "Music"
            static let yoga = "Yoga"
            static let movies = "Movies"
        }
    }

    enum Drifts {
        static let title = "Drifts"
        static let subtitle = "Plans happening around you"
        static let featured = "Featured near you"
        static let openNow = "Open now"
        static let startingSoon = "Starting soon"
        static let laterToday = "Later today"
        static let seeAll = "See all"
        static let imIn = "I'm in"
        static let bestMatch = "BEST MATCH"
        static let going = "going"
        static let spotsLeft = "spots left"
        
        enum Detail {
            static let share = "Share"
            static let save = "Save"
            static let reminder = "Reminder"
            static let aboutHeader = "About this Drift"
            static let hostHeader = "Hosted by"
            static let participantsHeader = "Who's coming"
            static let detailsHeader = "Details"
            static let timeLabel = "Time"
            static let meetingPointLabel = "Meeting point"
            static let bringLabel = "What to bring"
            static let vibeLabel = "Vibe"
            static let notesLabel = "Notes"
            static let safetyTitle = "We keep it safe and respectful"
            static let safetySubtitle = "Meet in public places. No personal contact shared."
            static let coordinationNote = "Exact coordination happens in the Drift chat after joining."
            
            enum CTA {
                static let join = "Join Drift"
                static let joinSubtitle = "You'll be able to chat after joining"
                static let requested = "Request Sent"
                static let requestedSubtitle = "Host will review your request"
                static let joined = "Open Chat"
                static let joinedSubtitle = "Coordination is happening here"
                static let full = "Drift Full"
                static let fullSubtitle = "Try another drift nearby"
                static let ended = "Drift Ended"
                static let endedSubtitle = "This drift has ended"
            }
        }
    }

    enum Create {
        static let title = "Create Drift"
        static let step1 = "1. What's the plan?"
        static let step2 = "2. Plan title"
        static let step3 = "3. When?"
        static let step4 = "4. Where?"
        static let step5 = "5. Capacity"
        static let step6 = "6. Join mode"
        
        static let titlePlaceholder = "e.g. Evening walk at Cubbon Park"
        static let locationApprox = "Approximate area"
        static let locationNote = "Exact coordination happens in Drift chat after joining."
        static let manageDrift = "Manage Drift"
        static let creating = "Creating your Drift..."
        static let settingUp = "Setting things up for you"
        static let created = "Drift created!"
        static let createdSubtitle = "Your plan is live and people can join."
        static let redirectNote = "We'll take you to manage your Drift."
        
        static let discardTitle = "Discard changes?"
        static let discardMessage = "You have unsaved changes. If you go back now, they will be lost."
        static let discardAction = "Discard changes"
        static let continueEditing = "Continue editing"
    }
    
    enum Main {
        static let myPosts = "My Posts"
        static let messages = "Messages"
        static let profile = "Profile"
    }

    enum Manage {
        static let title = "Manage Drift"
        static let edit = "Edit"
        static let share = "Share"
        static let close = "Close"
        static let delete = "Delete"
        static let requests = "Requests"
        static let participants = "Participants"
        static let openChat = "Open Drift Chat"
        static let chatSubtitle = "Coordinate with your group"
        static let requestsSubtitle = "Review people who want to join"
        static let reminder = "Safety Reminder"
        static let reminderSubtitle = "Meet in public and stay within the group chat for coordination."
        
        static func capacity(count: Int) -> String { "Open to \(count) people" }
        static func joinedCount(count: Int) -> String { "\(count) joined" }
        static func openTo(count: Int) -> String { "Open to \(count)" }
        static func requestsPending(count: Int) -> String { "\(count) requests pending" }
    }

    enum Chat {
        static let title = "Chats"
        static let subtitle = "All your Drift conversations.\nNo chats exist outside a Drift."
        static let bannerTitle = "Chats are only available after you join or are accepted into a Drift."
        static let bannerSubtitle = "No cold messaging. No phone exchange."
        static let active = "Active Drifts"
        static let upcoming = "Upcoming Drifts"
        static let past = "Past Drifts"
        static let viewAll = "View all"
        static let emptyTitle = "No chats yet"
        static let emptySubtitle = "Join a Drift to start chatting with others.\nAll conversations happen inside Drifts."
        static let exploreCTA = "Explore Drifts"
    }

    enum Profile {
        static let title = "You"
        static let subtitle = "Your profile, preferences and Drift history."
        static let editProfile = "Edit Profile"
        static let joined = "Drifts joined"
        static let hosted = "Drifts hosted"
        static let past = "Past Drifts"
        static let activeThisMonth = "This month"
        static let activeStatus = "Active"
        
        static let interests = "Interests"
        static let edit = "Edit"
        static let addInterest = "Add interest"
        
        static let availability = "Availability"
        static let safety = "Safety & Privacy"
        static let history = "Drift History"
        static let settings = "Settings"
        
        static let phoneNotShared = "Phone numbers are not shared"
        static let phoneCoordination = "Coordination happens only in Drift chat."
        static let approxDistance = "Approximate distance only"
        static let locationApprox = "Your location is kept approximate."
        static let blockedUsers = "Blocked users"
        static let blockedDesc = "Manage people you've blocked."
        static let reportSafety = "Report / safety access"
        static let reportDesc = "Help keep CoffeeCall safe for all."
        static let locationVisibility = "Location visibility"
        static let visibilityDesc = "Control how your location is shown."
        
        static let notifications = "Notifications"
        static let notificationsDesc = "Manage alerts and reminders"
        static let locPermissions = "Location permissions"
        static let locPermsDesc = "Update location access"
        static let accountSettings = "Account settings"
        static let accountDesc = "Profile, email, password"
        static let signOut = "Sign out"
        static let signOutDesc = "Log out of your account"
        
        static let hostedTab = "Hosted"
        static let joinedTab = "Joined"
        static let pastTab = "Past"
        static let viewAll = "View all"
        static let createNew = "Create a new Drift"
        
        static let usuallyFree = "Usually free"
        static let weekdayEvenings = "Weekday evenings"
        static let weekends = "Weekends"
        static let visibleToOthers = "Visible to others"
        static let visibleEveryone = "Everyone"
        static let visibleDesc = "Who can see your availability"
        static let changePhoto = "Change Photo"
        static let bioLabel = "BIO"
        
        static let verifiedPhone = "Verified phone"
        static let statsHeader = "Your stats"
        static let statsPrivate = "Stats are private to you."
        static let hostedLabel = "Hosted"
        static let joinedLabel = "People joined"
        static let noShowsLabel = "No-shows"
        static let scoreLabel = "Score"
        static let locationLabel = "Location"
        static let help = "Help"
        static let activityLog = "Activity Log"
        static let noActivities = "No past activities yet."
        static let preferences = "Preferences"
        static let accountHeader = "Account"
        static let signOutConfirmation = "Are you sure you want to sign out of your account?"
        static let interestsDescription = "Select what you are open to today. This updates your discovery filter."
        static let availabilityDescription = "Let others know when you are generally free for nearby activities."
        static let daytimeLunch = "Daytime / Lunch"
        static let notificationsDescription = "Choose what system notifications you want to receive."
        static let pushNotifications = "Push Notifications"
        static let inAppAlerts = "In-App Alerts"
        static let nearbyDriftsLabel = "Nearby Drift Alerts (<10km)"
        static let privacyDescription = "Safety is our top priority. We never share phone numbers or exact locations in the discovery radar."
        static let approxDistanceLabel = "Show approximate distance only"
        static let keepStatsPrivate = "Keep stats private to me"
        static let privacySafetyHeader = "Privacy & Safety"
        static let fixedRadiusLabel = "Search is fixed to a 10 km discovery radius."
        static let updatingLoc = "Updating location..."
        static let updateLoc = "Update current location"
        static let welcomeLabel = "Welcome to CoffeeCall!"
        static let helpDescription = "CoffeeCall helps you turn nearby interests into real-world meetups. Here's how to stay safe and have fun:"
        static let helpTitle1 = "1. The Drift is the unit of action"
        static let helpDesc1 = "Always coordinate through Drifts. There are no cold direct messages or private browsing lists. Everything revolves around physical plans."
        static let helpTitle2 = "2. Keep details inside pre-meetup chats"
        static let helpDesc2 = "Exact meeting locations and details remain locked in the chat room until a user has hosted or successfully joined the Drift."
        static let helpTitle3 = "3. Safe and respectful spaces"
        static let helpDesc3 = "Meet in well-populated public places (e.g. popular local coffee houses, parks, study hubs). Be reliable and keep your no-show rates low."
        static let helpGuidelinesHeader = "Help & Guidelines"
        static let tenKmRadiusSuffix = " • 10 km radius"
    }
    
    enum Common {
        static let cancel = "Cancel"
        static let save = "Save"
        static let done = "Done"
        static let delete = "Delete"
        static let close = "Close"
        static let appName = "CoffeeCall"
        static let appVersion = "Version 1.0.0 (Beta)"
        static let environment = "Environment"
        static let production = "Production"
        static let clientIdLabel = "Client ID"
        static let clientIdValue = "iOS-MVP-2026"
        static let buildPhaseLabel = "Build Phase"
        static let buildPhaseValue = "Release Verification"
        static let copyright = "© 2026 CoffeeCall Inc. All rights reserved."
    }
}
