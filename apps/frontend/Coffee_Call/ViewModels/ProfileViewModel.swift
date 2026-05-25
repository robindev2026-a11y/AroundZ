import SwiftUI
import UIKit
import Combine
import CoreLocation

import FirebaseCore
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

class ProfileViewModel: ObservableObject {
    var title: String { AppStrings.Profile.title }
    var subtitle: String? { "Your profile" }
    
    @Published var showingSettingsSheet = false
    
    // MARK: - Persisted Fields with didSet Observers (CRUD: Update)
    @Published var name: String = "" {
        didSet {
            UserDefaults.standard.set(name, forKey: "profile_name")
            if isLoaded { syncProfileToFirebase() }
        }
    }
    @Published var bio: String = "" {
        didSet {
            UserDefaults.standard.set(bio, forKey: "profile_bio")
            if isLoaded { syncProfileToFirebase() }
        }
    }
    @Published var initials: String = "U" {
        didSet {
            UserDefaults.standard.set(initials, forKey: "profile_initials")
            if isLoaded { syncProfileToFirebase() }
        }
    }
    @Published var profileImage: UIImage? = nil
    
    @Published var location: String = "" {
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
    @Published var driftsJoined: Int = 0
    @Published var driftsHosted: Int = 0
    @Published var noShowsCount: Int = 0
    @Published var score: String = "Coming soon"
    @Published var pastDriftsCount: Int = 0
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
        if !isFirebaseEnabled {
            loadMockHistory()
            driftsJoined = 24
            driftsHosted = 8
            noShowsCount = 4
            pastDriftsCount = 16
        } else {
            loadRealHistory()
        }
        setupBookmarkSubscription()
        // setupLocationObservation() removed – location handled by LocationService
        // Subscribe to location updates from PermissionsManager to automatically update profile location
        PermissionsManager.shared.$currentLocation
            .receive(on: RunLoop.main)
            .compactMap { $0 }
            .sink { [weak self] location in
                self?.geocodeLocation(location) { success, address in
                    if success, let address = address {
                        self?.location = address
                    }
                }
            }
            .store(in: &cancellables)
        self.isLoaded = true
    }
    
    private func setupBookmarkSubscription() {
        BookmarkManager.shared.$savedDrifts
            .receive(on: RunLoop.main)
            .assign(to: \.savedDrifts, on: self)
            .store(in: &cancellables)
    }
    
    func loadPersistedData() {
        let isFirebase = isFirebaseEnabled
        
        if isFirebase {
            if UserDefaults.standard.string(forKey: "profile_name") == AppConstants.MockData.userName {
                UserDefaults.standard.removeObject(forKey: "profile_name")
                UserDefaults.standard.removeObject(forKey: "profile_bio")
                UserDefaults.standard.removeObject(forKey: "profile_initials")
                UserDefaults.standard.removeObject(forKey: "profile_location")
                UserDefaults.standard.removeObject(forKey: "profile_availability_weekday_evenings")
                UserDefaults.standard.removeObject(forKey: "profile_availability_weekends")
                UserDefaults.standard.removeObject(forKey: "profile_availability_daytime")
                UserDefaults.standard.removeObject(forKey: "profile_interests")
                ProfileImageHelper.clearProfileImage()
            }
        }
        
        if let savedName = UserDefaults.standard.string(forKey: "profile_name") {
            self.name = savedName
        } else {
            self.name = isFirebase ? "" : AppConstants.MockData.userName
        }
        if let savedBio = UserDefaults.standard.string(forKey: "profile_bio") {
            self.bio = savedBio
        } else {
            self.bio = isFirebase ? "" : AppConstants.MockData.userBio
        }
        if let savedInitials = UserDefaults.standard.string(forKey: "profile_initials") {
            self.initials = savedInitials
        } else {
            self.initials = isFirebase ? "U" : AppConstants.MockData.userInitials
        }
        if let savedLocation = UserDefaults.standard.string(forKey: "profile_location") {
            self.location = savedLocation
        } else {
            self.location = isFirebase ? "" : "Bengaluru, India"
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
        } else {
            self.interests = isFirebase ? [] : [.coffee, .walk, .food, .movie, .study]
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
                        if data["initials"] == nil {
                            let computed = self.computeInitials(name: name)
                            self.initials = computed
                            UserDefaults.standard.set(computed, forKey: "profile_initials")
                        }
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
                    
                    if let profilePhotoUrl = data["profilePhotoUrl"] as? String {
                        if profilePhotoUrl.isEmpty {
                            self.profileImage = nil
                            ProfileImageHelper.clearProfileImage()
                        } else {
                            self.downloadProfileImage(from: profilePhotoUrl)
                        }
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
    
    func loadRealHistory() {
        guard isFirebaseEnabled, let uid = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore()
        
        // 1. Query hosted drifts: posts where creatorId == uid
        db.collection("posts")
            .whereField("creatorId", isEqualTo: uid)
            .addSnapshotListener { [weak self] querySnapshot, error in
                guard let self = self, let documents = querySnapshot?.documents else { return }
                DispatchQueue.main.async {
                    self.driftsHosted = documents.count
                    self.updatePastDriftsCount()
                }
            }
            
        // 2. Query all message threads where participants contains uid
        db.collection("messageThreads")
            .whereField("participants", arrayContains: uid)
            .addSnapshotListener { [weak self] querySnapshot, error in
                guard let self = self, let documents = querySnapshot?.documents else { return }
                
                let threadIds = documents.map { $0.documentID }
                if threadIds.isEmpty {
                    DispatchQueue.main.async {
                        self.historyDrifts = []
                        self.driftsJoined = 0
                        self.updatePastDriftsCount()
                    }
                    return
                }
                
                let group = DispatchGroup()
                var fetchedDrifts: [Drift] = []
                
                for threadId in threadIds {
                    group.enter()
                    db.collection("posts").document(threadId).getDocument { document, error in
                        defer { group.leave() }
                        if let document = document, document.exists, let drift = self.parseDrift(document) {
                            fetchedDrifts.append(drift)
                        }
                    }
                }
                
                group.notify(queue: .main) {
                    self.historyDrifts = fetchedDrifts.sorted(by: { $0.date > $1.date })
                    self.driftsJoined = fetchedDrifts.filter { !$0.isMine }.count
                    self.updatePastDriftsCount()
                }
            }
    }
    
    private func updatePastDriftsCount() {
        self.pastDriftsCount = self.driftsHosted + self.driftsJoined
    }
    
    private func parseDrift(_ doc: DocumentSnapshot) -> Drift? {
        guard let data = doc.data() else { return nil }
        
        let id = UUID.fromString(doc.documentID)
        let title = data["title"] as? String ?? ""
        let description = data["description"] as? String ?? ""
        let location = data["location"] as? String ?? ""
        let meetingPoint = data["meetingPoint"] as? String ?? ""
        let time = data["time"] as? String ?? ""
        let endTime = data["endTime"] as? String ?? ""
        let date = data["date"] as? String ?? ""
        let distance = data["distance"] as? Double ?? 1.2
        
        let statusStr = data["status"] as? String ?? "OPEN"
        let status: DriftStatus
        switch statusStr.uppercased() {
        case "OPEN": status = .open
        case "STARTING SOON": status = .startingSoon
        case "TONIGHT": status = .tonight
        case "ENDED": status = .ended
        default: status = .open
        }
        
        let categoryStr = data["category"] as? String ?? "coffee"
        let category = DriftCategory(rawValue: categoryStr.lowercased()) ?? .coffee
        let hook = data["hook"] as? String
        
        let creatorId = data["creatorId"] as? String ?? ""
        let hostName = data["creatorName"] as? String ?? "Host"
        
        let host = Host(
            id: UUID.fromString(creatorId),
            name: hostName,
            role: "Host",
            imageUrl: data["creatorImageUrl"] as? String,
            isVerified: data["creatorVerified"] as? Bool ?? false,
            firestoreUID: creatorId
        )
        
        let peopleGoing = data["participantCount"] as? Int ?? 1
        let capacity = data["capacity"] as? Int ?? 5
        let spotsLeft = data["spotsLeft"] as? Int ?? (capacity - peopleGoing)
        
        let vibeTags = data["vibeTags"] as? [String] ?? []
        let whatToBring = data["whatToBring"] as? [String] ?? []
        let participantInitials = data["participantInitials"] as? [String] ?? []
        let imageUrl = data["imageUrl"] as? String
        let pendingRequestsData = data["pendingRequests"] as? [[String: Any]] ?? []
        let pendingRequests = pendingRequestsData.compactMap { reqDict -> JoinRequest? in
            guard let idStr = reqDict["id"] as? String,
                  let id = UUID(uuidString: idStr),
                  let userName = reqDict["userName"] as? String,
                  let userInitials = reqDict["userInitials"] as? String,
                  let userRole = reqDict["userRole"] as? String,
                  let message = reqDict["message"] as? String,
                  let timestamp = reqDict["timestamp"] as? String else {
                return nil
            }
            let userId = reqDict["userId"] as? String ?? ""
            return JoinRequest(
                id: id,
                userId: userId,
                userName: userName,
                userInitials: userInitials,
                userRole: userRole,
                message: message,
                timestamp: timestamp
            )
        }
        
        let currentUid = Auth.auth().currentUser?.uid
        let isMine = (creatorId == currentUid)
        
        return Drift(
            id: id,
            title: title,
            description: description,
            location: location,
            meetingPoint: meetingPoint,
            time: time,
            endTime: endTime,
            date: date,
            distance: distance,
            status: status,
            category: category,
            hook: hook,
            host: host,
            peopleGoing: peopleGoing,
            spotsLeft: spotsLeft,
            capacity: capacity,
            vibeTags: vibeTags,
            whatToBring: whatToBring,
            participantInitials: participantInitials,
            imageUrl: imageUrl,
            pendingRequests: pendingRequests,
            isMine: isMine
        )
    }
    
    // MARK: - Save Profile (CRUD: Update)
    func updateProfile(name: String, bio: String, image: UIImage? = nil, removePhoto: Bool = false) {
        self.name = name
        self.bio = bio
        self.initials = computeInitials(name: name)
        
        if removePhoto {
            self.profileImage = nil
            ProfileImageHelper.clearProfileImage()
            if isFirebaseEnabled, let uid = Auth.auth().currentUser?.uid {
                let db = Firestore.firestore()
                db.collection("users").document(uid).setData(["profilePhotoUrl": ""], merge: true) { error in
                    if let error = error {
                        print("Failed to clear profilePhotoUrl in Firestore: \(error.localizedDescription)")
                    }
                }
            }
        } else if let image = image {
            ProfileImageHelper.saveProfileImage(image)
            self.profileImage = image
            if isFirebaseEnabled, let uid = Auth.auth().currentUser?.uid {
                uploadProfileImageToFirebase(image, uid: uid)
            }
        }
    }
    
    private func uploadProfileImageToFirebase(_ image: UIImage, uid: String) {
        guard let data = image.jpegData(compressionQuality: 0.8) else { return }
        
        let storageRef = Storage.storage().reference()
        let photoRef = storageRef.child("profile_photos/\(uid).jpg")
        
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        photoRef.putData(data, metadata: metadata) { [weak self] metadata, error in
            guard let self = self else { return }
            if let error = error {
                print("Failed to upload profile photo to Firebase Storage: \(error.localizedDescription)")
                return
            }
            
            photoRef.downloadURL { url, error in
                if let error = error {
                    print("Failed to retrieve profile photo download URL: \(error.localizedDescription)")
                    return
                }
                
                guard let downloadURL = url?.absoluteString else { return }
                
                // Sync URL to Firestore
                let db = Firestore.firestore()
                db.collection("users").document(uid).setData(["profilePhotoUrl": downloadURL], merge: true) { error in
                    if let error = error {
                        print("Failed to sync profilePhotoUrl to Firestore: \(error.localizedDescription)")
                    }
                }
            }
        }
    }
    
    private func downloadProfileImage(from urlString: String) {
        guard !urlString.isEmpty else { return }
        guard ProfileImageHelper.loadProfileImage() == nil else { return }
        
        guard let url = URL(string: urlString) else { return }
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let self = self, let data = data, error == nil, let image = UIImage(data: data) else {
                return
            }
            DispatchQueue.main.async {
                ProfileImageHelper.saveProfileImage(image)
                self.profileImage = image
            }
        }.resume()
    }
    
    // MARK: - Sign Out & Reset (CRUD: Delete/Reset)
    // Note: Firebase session sign-out is handled exclusively by AuthViewModel.signOut().
    // This method only clears local profile state and UserDefaults.
    func signOut() {
        let wasLoaded = self.isLoaded
        self.isLoaded = false

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

        // When Firebase is enabled, reset to blank so real data loads on next login.
        // In offline/preview mode, restore mock persona so screens remain previewable.
        if isFirebaseEnabled {
            self.name = ""
            self.bio = ""
            self.initials = ""
            self.location = ""
            self.driftsJoined = 0
            self.driftsHosted = 0
            self.noShowsCount = 0
            self.pastDriftsCount = 0
            self.historyDrifts = []
        } else {
            self.name = AppConstants.MockData.userName
            self.bio = AppConstants.MockData.userBio
            self.initials = AppConstants.MockData.userInitials
            self.location = "Bengaluru, India"
            self.driftsJoined = 24
            self.driftsHosted = 8
            self.noShowsCount = 4
            self.pastDriftsCount = 16
            loadMockHistory()
        }
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
    
    func updateLocationFromGPS(completion: @escaping (Bool, String?) -> Void) {
        // Request location via LocationService and update profile location
        LocationService.shared.fetchLocation { result in
            switch result {
            case .success(let model):
                self.location = model.displayString
                UserDefaults.standard.set(self.location, forKey: "profile_location")
                completion(true, nil)
            case .failure(let error):
                completion(false, error.localizedDescription)
            }
        }
    }
    
    func geocodeLocation(_ location: CLLocation, completion: @escaping (Bool, String?) -> Void) {
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { [weak self] placemarks, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Reverse geocoding failed: \(error.localizedDescription)")
                    completion(false, "Failed to resolve address: \(error.localizedDescription)")
                    return
                }
                
                guard let placemark = placemarks?.first else {
                    completion(false, "No address found for this location.")
                    return
                }
                
                let resolvedLocation: String
                if let locality = placemark.locality {
                    if let adminArea = placemark.administrativeArea {
                        resolvedLocation = "\(locality), \(adminArea)"
                    } else if let country = placemark.country {
                        resolvedLocation = "\(locality), \(country)"
                    } else {
                        resolvedLocation = locality
                    }
                } else if let adminArea = placemark.administrativeArea {
                    resolvedLocation = adminArea
                } else {
                    resolvedLocation = "Unknown Location"
                }
                
                self?.location = resolvedLocation
                completion(true, resolvedLocation)
            }
        }
    }
}
