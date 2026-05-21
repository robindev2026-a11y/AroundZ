import SwiftUI
import UIKit
import Combine
import FirebaseCore
import FirebaseAuth
import FirebaseFirestore

class ProfileViewModel: ObservableObject {
    var title: String { AppStrings.Profile.title }
    var subtitle: String? { "Your profile" }
    
    @Published var showingSettingsSheet = false
    
    // MARK: - Persisted Fields with didSet Observers (CRUD: Update)
    @Published var name: String = AppConstants.MockData.userName {
        didSet {
            UserDefaults.standard.set(name, forKey: "profile_name")
            if isLoaded { syncProfileToFirebase() }
        }
    }
    @Published var bio: String = AppConstants.MockData.userBio {
        didSet {
            UserDefaults.standard.set(bio, forKey: "profile_bio")
            if isLoaded { syncProfileToFirebase() }
        }
    }
    @Published var initials: String = AppConstants.MockData.userInitials {
        didSet {
            UserDefaults.standard.set(initials, forKey: "profile_initials")
            if isLoaded { syncProfileToFirebase() }
        }
    }
    @Published var profileImage: UIImage? = nil
    
    @Published var location: String = "Bengaluru, India" {
        didSet {
            UserDefaults.standard.set(location, forKey: "profile_location")
            if isLoaded { syncProfileToFirebase() }
        }
    }
    
    @Published var availabilityWeekdayEvenings: Bool = true {
        didSet {
            UserDefaults.standard.set(availabilityWeekdayEvenings, forKey: "profile_availability_weekday_evenings")
            if isLoaded { syncProfileToFirebase() }
        }
    }
    @Published var availabilityWeekends: Bool = true {
        didSet {
            UserDefaults.standard.set(availabilityWeekends, forKey: "profile_availability_weekends")
            if isLoaded { syncProfileToFirebase() }
        }
    }
    @Published var availabilityDaytime: Bool = false {
        didSet {
            UserDefaults.standard.set(availabilityDaytime, forKey: "profile_availability_daytime")
            if isLoaded { syncProfileToFirebase() }
        }
    }
    
    @Published var interests: [DriftCategory] = [.coffee, .walk, .food, .movie, .study] {
        didSet {
            let rawValues = interests.map { $0.rawValue }
            UserDefaults.standard.set(rawValues, forKey: "profile_interests")
            if isLoaded { syncProfileToFirebase() }
        }
    }
    
    // Stats & History
    @Published var driftsJoined: Int = 24
    @Published var driftsHosted: Int = 8
    @Published var noShowsCount: Int = 4
    @Published var score: String = "Coming soon"
    @Published var pastDriftsCount: Int = 16
    @Published var historyDrifts: [Drift] = []
    @Published var selectedHistoryTab: Int = 0
    @Published var savedDrifts: [Drift] = []
    
    private var cancellables = Set<AnyCancellable>()
    private var isLoaded = false
    
    private var isFirebaseEnabled: Bool {
        return Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist") != nil
    }
    
    // Preferences Summaries
    var notificationsSummary: String { "Push, In-app" }
    var privacySummary: String { "Your data, safety tools" }
    
    var availabilitySummary: String {
        var active: [String] = []
        if availabilityWeekdayEvenings { active.append("Evenings") }
        if availabilityWeekends { active.append("Weekends") }
        if availabilityDaytime { active.append("Daytime") }
        return active.isEmpty ? "Not set" : active.joined(separator: ", ")
    }
    
    // MARK: - Initializer (CRUD: Read)
    init() {
        loadPersistedData()
        loadMockHistory()
        setupBookmarkSubscription()
        self.isLoaded = true
    }
    
    private func setupBookmarkSubscription() {
        BookmarkManager.shared.$savedDrifts
            .receive(on: RunLoop.main)
            .assign(to: \.savedDrifts, on: self)
            .store(in: &cancellables)
    }
    
    func loadPersistedData() {
        if let savedName = UserDefaults.standard.string(forKey: "profile_name") {
            self.name = savedName
        }
        if let savedBio = UserDefaults.standard.string(forKey: "profile_bio") {
            self.bio = savedBio
        }
        if let savedInitials = UserDefaults.standard.string(forKey: "profile_initials") {
            self.initials = savedInitials
        } else {
            self.initials = computeInitials(name: self.name)
        }
        if let savedLocation = UserDefaults.standard.string(forKey: "profile_location") {
            self.location = savedLocation
        }
        
        if UserDefaults.standard.object(forKey: "profile_availability_weekday_evenings") != nil {
            self.availabilityWeekdayEvenings = UserDefaults.standard.bool(forKey: "profile_availability_weekday_evenings")
        }
        if UserDefaults.standard.object(forKey: "profile_availability_weekends") != nil {
            self.availabilityWeekends = UserDefaults.standard.bool(forKey: "profile_availability_weekends")
        }
        if UserDefaults.standard.object(forKey: "profile_availability_daytime") != nil {
            self.availabilityDaytime = UserDefaults.standard.bool(forKey: "profile_availability_daytime")
        }
        
        if let savedInterests = UserDefaults.standard.stringArray(forKey: "profile_interests") {
            self.interests = savedInterests.compactMap { DriftCategory(rawValue: $0) }
        }

        // Load profile photo from disk
        self.profileImage = ProfileImageHelper.loadProfileImage()

        // Sync from Firebase if authenticated
        fetchProfileFromFirebase()
    }

    // MARK: - Firebase Sync
    func syncProfileToFirebase() {
        guard isFirebaseEnabled, let uid = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore()
        let data: [String: Any] = [
            "uid": uid,
            "name": name,
            "bio": bio,
            "initials": initials,
            "location": location,
            "availabilityWeekdayEvenings": availabilityWeekdayEvenings,
            "availabilityWeekends": availabilityWeekends,
            "availabilityDaytime": availabilityDaytime,
            "interests": interests.map { $0.rawValue },
            "updatedAt": FieldValue.serverTimestamp()
        ]
        db.collection("users").document(uid).setData(data, merge: true) { error in
            if let error = error {
                print("Error syncing profile to Firebase: \(error.localizedDescription)")
            }
        }
    }

    func fetchProfileFromFirebase() {
        guard isFirebaseEnabled, let uid = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore()
        db.collection("users").document(uid).getDocument { [weak self] document, error in
            guard let self = self else { return }
            if let document = document, document.exists, let data = document.data() {
                DispatchQueue.main.async {
                    let wasLoaded = self.isLoaded
                    self.isLoaded = false
                    
                    if let name = data["name"] as? String {
                        self.name = name
                        UserDefaults.standard.set(name, forKey: "profile_name")
                    }
                    if let bio = data["bio"] as? String {
                        self.bio = bio
                        UserDefaults.standard.set(bio, forKey: "profile_bio")
                    }
                    if let initials = data["initials"] as? String {
                        self.initials = initials
                        UserDefaults.standard.set(initials, forKey: "profile_initials")
                    }
                    if let location = data["location"] as? String {
                        self.location = location
                        UserDefaults.standard.set(location, forKey: "profile_location")
                    }
                    if let availabilityWeekdayEvenings = data["availabilityWeekdayEvenings"] as? Bool {
                        self.availabilityWeekdayEvenings = availabilityWeekdayEvenings
                        UserDefaults.standard.set(availabilityWeekdayEvenings, forKey: "profile_availability_weekday_evenings")
                    }
                    if let availabilityWeekends = data["availabilityWeekends"] as? Bool {
                        self.availabilityWeekends = availabilityWeekends
                        UserDefaults.standard.set(availabilityWeekends, forKey: "profile_availability_weekends")
                    }
                    if let availabilityDaytime = data["availabilityDaytime"] as? Bool {
                        self.availabilityDaytime = availabilityDaytime
                        UserDefaults.standard.set(availabilityDaytime, forKey: "profile_availability_daytime")
                    }
                    if let interestsRaw = data["interests"] as? [String] {
                        self.interests = interestsRaw.compactMap { DriftCategory(rawValue: $0) }
                        UserDefaults.standard.set(interestsRaw, forKey: "profile_interests")
                    }
                    
                    self.isLoaded = wasLoaded
                }
            }
        }
    }
    
    func loadMockHistory() {
        let mockHost = Host(name: "Arjun", role: "Host", imageUrl: "host_arjun", isVerified: true)
        
        self.historyDrifts = [
            Drift(
                title: "Evening walk at Cubbon Park",
                description: "", location: "Open • Yesterday", meetingPoint: "", time: "", endTime: "", date: "", distance: 0, status: .open, category: .walk, hook: nil, host: mockHost, peopleGoing: 5, spotsLeft: 0, capacity: 5, vibeTags: [], whatToBring: [], notes: "", participantInitials: [], imageUrl: "drift_walk"
            ),
            Drift(
                title: "Sunday Coffee at Third Wave",
                description: "", location: "Closed • 2 days ago", meetingPoint: "", time: "", endTime: "", date: "", distance: 0, status: .ended, category: .coffee, hook: nil, host: mockHost, peopleGoing: 4, spotsLeft: 0, capacity: 4, vibeTags: [], whatToBring: [], notes: "", participantInitials: [], imageUrl: "drift_coffee"
            ),
            Drift(
                title: "Study session at Koramangala",
                description: "", location: "Ended • 5 days ago", meetingPoint: "", time: "", endTime: "", date: "", distance: 0, status: .ended, category: .study, hook: nil, host: mockHost, peopleGoing: 6, spotsLeft: 0, capacity: 6, vibeTags: [], whatToBring: [], notes: "" , participantInitials: [], imageUrl: "drift_study"
            ),
            Drift(
                title: "Brunch & Banter in Indiranagar",
                description: "", location: "Ended • 1 week ago", meetingPoint: "", time: "", endTime: "", date: "", distance: 0, status: .ended, category: .food, hook: nil, host: mockHost, peopleGoing: 5, spotsLeft: 0, capacity: 5, vibeTags: [], whatToBring: [], notes: "", participantInitials: [], imageUrl: "drift_brunch"
            )
        ]
    }
    
    // MARK: - Save Profile (CRUD: Update)
    func updateProfile(name: String, bio: String, image: UIImage? = nil) {
        self.name = name
        self.bio = bio
        self.initials = computeInitials(name: name)
        if let image = image {
            ProfileImageHelper.saveProfileImage(image)
            self.profileImage = image
        }
    }
    
    // MARK: - Sign Out & Reset (CRUD: Delete/Reset)
    func signOut() {
        let wasLoaded = self.isLoaded
        self.isLoaded = false
        
        if isFirebaseEnabled {
            try? Auth.auth().signOut()
        }
        
        UserDefaults.standard.removeObject(forKey: "profile_name")
        UserDefaults.standard.removeObject(forKey: "profile_bio")
        UserDefaults.standard.removeObject(forKey: "profile_initials")
        UserDefaults.standard.removeObject(forKey: "profile_location")
        UserDefaults.standard.removeObject(forKey: "profile_availability_weekday_evenings")
        UserDefaults.standard.removeObject(forKey: "profile_availability_weekends")
        UserDefaults.standard.removeObject(forKey: "profile_availability_daytime")
        UserDefaults.standard.removeObject(forKey: "profile_interests")
        ProfileImageHelper.clearProfileImage()
        self.profileImage = nil
        
        self.name = AppConstants.MockData.userName
        self.bio = AppConstants.MockData.userBio
        self.initials = AppConstants.MockData.userInitials
        self.location = "Bengaluru, India"
        self.availabilityWeekdayEvenings = true
        self.availabilityWeekends = true
        self.availabilityDaytime = false
        self.interests = [.coffee, .walk, .food, .movie, .study]
        
        self.isLoaded = wasLoaded
    }
    
    // Helper to extract clean dynamic initials
    private func computeInitials(name: String) -> String {
        let parts = name.components(separatedBy: " ").filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
        guard let firstLetter = parts.first?.first else { return "U" }
        if parts.count > 1, let lastLetter = parts.last?.first {
            return "\(firstLetter)\(lastLetter)".uppercased()
        }
        return String(firstLetter).uppercased()
    }
}
