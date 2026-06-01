import SwiftUI
import Combine
import FirebaseAuth
import FirebaseFirestore
import UserNotifications

struct ParticipantDetail: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let initials: String
    let interests: [String]
    let joinTimeDescription: String
}

class DriftDetailViewModel: ObservableObject {
    @Published var drift: Drift
    @Published var joinStatus: JoinStatus = .notJoined
    @Published var participants: [ParticipantDetail] = []
    @Published var savedDrifts: [Drift] = []
    @Published var showingRequestSentConfirmation = false
    @Published var isReminderSet = false
    @Published var showCalendarAddConfirmation = false
    @Published var showCalendarUntapDisclaimer = false
    
    var onDriftUpdated: ((Drift) -> Void)?
    
    private var cancellables = Set<AnyCancellable>()
    
    enum JoinStatus {
        case notJoined
        case requested
        case joined
        case full
        case ended
    }
    
    var canAccessChat: Bool {
        joinStatus == .joined
    }
    
    private let driftsService: DriftsServiceProtocol
    
    init(drift: Drift, initialJoinStatus: JoinStatus? = nil, driftsService: DriftsServiceProtocol? = nil) {
        if let driftsService = driftsService {
            self.driftsService = driftsService
        } else {
            let isFirebaseEnabled = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist") != nil
            self.driftsService = isFirebaseEnabled ? FirebaseDriftsService() : MockDriftsService()
        }
        // Build rich mock details for the host to display in the Host Context Card
        let hostName = drift.host.name
        let mockOtherActive = [
            Drift(
                title: "Walk in Indiranagar",
                description: "Morning stroll followed by filter coffee.",
                location: "Indiranagar, Bangalore",
                meetingPoint: "Cult Fit entrance",
                time: "7:00 AM",
                endTime: "8:00 AM",
                date: "Tomorrow",
                distance: 1.5,
                status: .open,
                category: .walk,
                hook: "Morning energy 🚶‍♂️",
                host: Host(name: hostName, role: drift.host.role, imageUrl: drift.host.imageUrl, isVerified: drift.host.isVerified),
                peopleGoing: 2,
                spotsLeft: 3,
                capacity: 5,
                vibeTags: ["Fresh", "Early birds"],
                whatToBring: ["Comfortable footwear"],
                participantInitials: ["SR", "AP"],
                imageUrl: nil
            ),
            Drift(
                title: "Specialty Coffee Tasting",
                description: "Let's explore some local light roasts.",
                location: "Koramangala, Bangalore",
                meetingPoint: "Third Wave Coffee",
                time: "4:00 PM",
                endTime: "5:00 PM",
                date: "Saturday",
                distance: 3.2,
                status: .open,
                category: .coffee,
                hook: "For coffee nerds ☕",
                host: Host(name: hostName, role: drift.host.role, imageUrl: drift.host.imageUrl, isVerified: drift.host.isVerified),
                peopleGoing: 1,
                spotsLeft: 4,
                capacity: 5,
                vibeTags: ["Educational", "Casual"],
                whatToBring: ["An open palate"],
                participantInitials: ["KT"],
                imageUrl: nil
            )
        ]
        
        let richHost = Host(
            id: drift.host.id,
            name: drift.host.name,
            role: drift.host.role,
            imageUrl: drift.host.imageUrl,
            isVerified: drift.host.isVerified,
            hostedCount: 4,
            joinedCount: 12,
            completedCount: 16,
            verified: true,
            otherActiveDrifts: mockOtherActive,
            pastDrifts: ["Walk in Indiranagar", "Coffee chat"],
            interests: ["Walks", "Coffee", "Movies"],
            firestoreUID: drift.host.firestoreUID
        )
        
        var updatedDrift = drift
        updatedDrift.host = richHost
        self.drift = updatedDrift

        // Participants: fetch live from Firestore when Firebase is enabled.
        // Fall back to mock people in offline/preview mode.
        if isFirebaseEnabled {
            self.participants = [] // will be populated by fetchParticipants()
            fetchParticipants()
            fetchHostOtherActiveDrifts()
        } else {
            rebuildMockParticipants()
        }
        
        if let initialJoinStatus {
            self.joinStatus = initialJoinStatus
        } else if drift.status == .ended {
            self.joinStatus = .ended
        } else if drift.isMine {
            self.joinStatus = .joined
        } else {
            self.refreshJoinStatus()
        }
        
        setupBookmarkSubscription()
        checkReminderStatus()
    }
    
    private func setupBookmarkSubscription() {
        BookmarkManager.shared.$savedDrifts
            .receive(on: RunLoop.main)
            .assign(to: \.savedDrifts, on: self)
            .store(in: &cancellables)
    }

    func syncDrift(_ updatedDrift: Drift) {
        drift = updatedDrift
        refreshJoinStatus()
        if isFirebaseEnabled {
            fetchParticipants()
        } else {
            rebuildMockParticipants()
        }
        JoinRequestDebugTracer.trace(
            "DriftDetailViewModel synced drift",
            driftId: updatedDrift.id,
            details: "joinStatus=\(joinStatus), pendingRequests=\(updatedDrift.pendingRequests.count)"
        )
    }

    private func refreshJoinStatus() {
        if drift.status == .ended {
            joinStatus = .ended
        } else if drift.isMine {
            joinStatus = .joined
        } else if isCurrentUserParticipant(in: drift) {
            joinStatus = .joined
        } else if hasCurrentUserPendingRequest(in: drift) {
            joinStatus = .requested
        } else if drift.spotsLeft == 0 {
            joinStatus = .full
        } else {
            joinStatus = .notJoined
        }
    }

    private func hasCurrentUserPendingRequest(in drift: Drift) -> Bool {
        let userId = currentUserId
        let initials = currentUserInitials
        return drift.pendingRequests.contains { request in
            if !request.userId.isEmpty {
                return request.userId == userId
            }
            return request.userInitials.trimmingCharacters(in: .whitespacesAndNewlines).uppercased() == initials.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        }
    }

    private func isCurrentUserParticipant(in drift: Drift) -> Bool {
        if isFirebaseEnabled {
            return drift.participantIds?.contains(currentUserId) == true
        }

        let userInitStr = currentUserInitials.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        guard !userInitStr.isEmpty else { return false }

        return drift.participantInitials.contains { $0.trimmingCharacters(in: .whitespacesAndNewlines).uppercased() == userInitStr }
    }

    private var currentUserId: String {
        Auth.auth().currentUser?.uid ?? UIDevice.current.identifierForVendor?.uuidString ?? ""
    }

    private var currentUserInitials: String {
        let savedInitials = UserDefaults.standard.string(forKey: "profile_initials") ?? ""
        return savedInitials.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? AppConstants.MockData.userInitials : savedInitials
    }
    
    func requestToJoin() {
        let driftId = drift.id
        guard joinStatus == .notJoined else { return }
        JoinRequestDebugTracer.trace(
            "DriftDetailViewModel.requestToJoin started",
            driftId: driftId,
            details: "currentStatus=\(joinStatus)"
        )
        let currentUid = currentUserId

        // Use real profile data from UserDefaults (written by ProfileViewModel on save/fetch).
        // Falls back to MockData only if UserDefaults has nothing (offline preview mode).
        let currentUserName = UserDefaults.standard.string(forKey: "profile_name")
            ?? AppConstants.MockData.userName
        let savedInitials = UserDefaults.standard.string(forKey: "profile_initials") ?? ""
        let currentUserInitials = savedInitials.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            ? AppConstants.MockData.userInitials
            : savedInitials
        let currentUserRole = "Member"

        let formatter = DateFormatter()
        formatter.timeStyle = .short
        let timestamp = formatter.string(from: Date())

        let joinRequest = JoinRequest(
            userId: currentUid,
            userName: currentUserName,
            userInitials: currentUserInitials,
            userRole: currentUserRole,
            message: "Hey, I'd love to join your drift!",
            timestamp: timestamp
        )
        JoinRequestDebugTracer.trace(
            "DriftDetailViewModel built JoinRequest",
            driftId: driftId,
            requestId: joinRequest.id,
            details: "userId=\(currentUid), userName=\(currentUserName)"
        )

        driftsService.requestToJoin(driftId: driftId, request: joinRequest)
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: { completionResult in
                if case .failure(let error) = completionResult {
                    JoinRequestDebugTracer.trace(
                        "DriftDetailViewModel.requestToJoin failed",
                        driftId: driftId,
                        requestId: joinRequest.id,
                        details: "error=\(error.localizedDescription)"
                    )
                    print("Error requesting to join: \(error)")
                }
            }, receiveValue: { [weak self] in
                guard let self = self else { return }
                JoinRequestDebugTracer.trace(
                    "DriftDetailViewModel.requestToJoin succeeded",
                    driftId: self.drift.id,
                    requestId: joinRequest.id
                )
                withAnimation(.spring()) {
                    if !self.drift.pendingRequests.contains(where: { $0.id == joinRequest.id }) {
                        self.drift.pendingRequests.append(joinRequest)
                    }
                    self.refreshJoinStatus()
                    self.showingRequestSentConfirmation = true
                }
                self.onDriftUpdated?(self.drift)
            })
            .store(in: &cancellables)
    }

    func cancelJoinRequest() {
        let driftId = drift.id
        let userId = currentUserId
        guard joinStatus == .requested else { return }
        JoinRequestDebugTracer.trace(
            "DriftDetailViewModel.cancelJoinRequest started",
            driftId: driftId,
            details: "userId=\(userId)"
        )

        driftsService.cancelJoinRequest(driftId: driftId, userId: userId)
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: { completionResult in
                if case .failure(let error) = completionResult {
                    JoinRequestDebugTracer.trace(
                        "DriftDetailViewModel.cancelJoinRequest failed",
                        driftId: driftId,
                        details: "error=\(error.localizedDescription)"
                    )
                    print("Error cancelling join request: \(error)")
                }
            }, receiveValue: { [weak self] in
                guard let self else { return }
                JoinRequestDebugTracer.trace(
                    "DriftDetailViewModel.cancelJoinRequest succeeded",
                    driftId: self.drift.id
                )
                withAnimation(.spring()) {
                    self.drift.pendingRequests.removeAll { request in
                        if !request.userId.isEmpty {
                            return request.userId == userId
                        }
                        return request.userInitials == self.currentUserInitials
                    }
                    self.refreshJoinStatus()
                }
                self.onDriftUpdated?(self.drift)
            })
            .store(in: &cancellables)
    }

    func leaveDrift(completion: @escaping (Bool) -> Void) {
        let userId = currentUserId
        print("[LeaveDrift] Detail ViewModel calling service. leaveDrift(driftId: \(drift.id), userId: \(userId))")
        driftsService.leaveDrift(driftId: drift.id, userId: userId)
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: { completionResult in
                if case .failure(let error) = completionResult {
                    print("Error leaving drift: \(error)")
                    completion(false)
                }
            }, receiveValue: { [weak self] in
                guard let self = self else { return }
                print("[LeaveDrift] Service call succeeded. Resetting local ViewModel state.")
                
                // 1. Immediately update local state for instant UI feedback
                withAnimation(.spring()) {
                    self.drift.participantInitials.removeAll { initStr in
                        initStr.trimmingCharacters(in: .whitespacesAndNewlines).uppercased() == 
                        self.currentUserInitials.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
                    }
                    self.drift.participantIds?.removeAll { $0 == userId }
                    self.drift.peopleGoing = max(self.drift.peopleGoing - 1, 1)
                    if let spots = self.drift.spotsLeft {
                        self.drift.spotsLeft = spots + 1
                    }
                    
                    self.refreshJoinStatus()
                    self.participants.removeAll { $0.initials.trimmingCharacters(in: .whitespacesAndNewlines).uppercased() == 
                        self.currentUserInitials.trimmingCharacters(in: .whitespacesAndNewlines).uppercased() 
                    }
                }
                
                self.onDriftUpdated?(self.drift)
                
                // 2. Notify the global store to re-fetch and sync everything
                NotificationCenter.default.post(name: NSNotification.Name("DriftStateChanged"), object: nil)
                
                completion(true)
            })
            .store(in: &cancellables)
    }

    // MARK: - Firebase Participants Fetch
    private var isFirebaseEnabled: Bool {
        Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist") != nil
    }

    func fetchParticipants() {
        guard isFirebaseEnabled else {
            rebuildMockParticipants()
            return
        }
        
        let db = Firestore.firestore()
        let postId = drift.id.uuidString
        let hostUid = drift.host.firestoreUID
        
        db.collection("messageThreads").document(postId).getDocument { [weak self] snapshot, error in
            guard let self = self else { return }
            if let error = error {
                print("Error fetching message thread (likely not a member yet): \(error.localizedDescription)")
                DispatchQueue.main.async {
                    let currentUid = self.currentUserId
                    self.drift.participantIds?.removeAll { $0 == currentUid }
                    if !self.drift.isMine && self.drift.status != .ended {
                        self.refreshJoinStatus()
                    }
                    self.generateFallbackParticipants()
                }
                return
            }
            
            guard let data = snapshot?.data(),
                  let participantIds = data["participants"] as? [String] else {
                self.generateFallbackParticipants()
                return
            }
            print("[FirebaseDetail] messageThreads document participants: \(String(describing: data["participants"]))")
            
            // If the current user UID is in participantIds of the thread, override joinStatus to .joined
            let currentUid = self.currentUserId
            if participantIds.contains(currentUid) {
                DispatchQueue.main.async {
                    // Only override to .joined if the user is also recognized as a participant in the canonical post document
                    let wasParticipantInPost = self.drift.participantIds?.contains(currentUid) ?? false
                    if wasParticipantInPost {
                        if self.drift.participantIds?.contains(currentUid) != true {
                            var ids = self.drift.participantIds ?? []
                            ids.append(currentUid)
                            self.drift.participantIds = Array(Set(ids))
                        }
                        if self.joinStatus != .joined {
                            self.joinStatus = .joined
                        }
                    }
                }
            } else {
                DispatchQueue.main.async {
                    self.drift.participantIds?.removeAll { $0 == currentUid }
                    if !self.drift.isMine && self.drift.status != .ended {
                        self.refreshJoinStatus()
                    }
                }
            }
            
            // Filter out host from participants list
            let guestIds = participantIds.filter { $0 != hostUid }
            
            if guestIds.isEmpty {
                DispatchQueue.main.async {
                    self.participants = []
                }
                return
            }
            
            let group = DispatchGroup()
            var fetched: [ParticipantDetail] = []
            
            for userId in guestIds {
                group.enter()
                db.collection("users").document(userId).getDocument { userSnap, userError in
                    defer { group.leave() }
                    if let userData = userSnap?.data(), userSnap?.exists == true {
                        let name = userData["name"] as? String ?? "Someone"
                        let parts = name.components(separatedBy: " ")
                        let initials = parts.compactMap { $0.first }.map { String($0) }.joined().uppercased()
                        let interests = userData["interestTags"] as? [String] ?? []
                        
                        fetched.append(ParticipantDetail(
                            name: name,
                            initials: initials.isEmpty ? "P" : initials,
                            interests: interests,
                            joinTimeDescription: "Joined recently"
                        ))
                    }
                }
            }
            
            group.notify(queue: .main) {
                self.participants = fetched
            }
        }
    }
    
    private func generateFallbackParticipants() {
        let guestInitials = drift.participantInitials
        var fetched: [ParticipantDetail] = []
        
        let namesMap = ["LJ": "Liam", "MM": "Maya", "SJ": "Sarah", "DG": "Dev", "AL": "Albin", "RI": "Riya", "MA": "Maya A.", "SR": "Sneha", "KM": "Karthik"]
        let interestsMap = [
            "LJ": ["Walks", "Coffee", "Music"],
            "MM": ["Coffee", "Walks", "Music"],
            "SJ": ["Walks", "Coffee", "Music"],
            "DG": ["Music", "Coffee", "Walks"],
            "AL": ["Walks", "Coffee"],
            "RI": ["Coffee", "Music"],
            "MA": ["Movies", "Music"],
            "SR": ["Walks", "Coffee"],
            "KM": ["Movies", "Coffee"]
        ]
        
        for initials in guestInitials {
            let name = namesMap[initials] ?? "Member"
            let interests = interestsMap[initials] ?? ["Coffee"]
            fetched.append(ParticipantDetail(
                name: name,
                initials: initials,
                interests: interests,
                joinTimeDescription: "Joined recently"
            ))
        }
        
        DispatchQueue.main.async {
            self.participants = fetched
        }
    }
    
    private func rebuildMockParticipants() {
        generateFallbackParticipants()
    }
    
    func fetchHostOtherActiveDrifts() {
        guard isFirebaseEnabled else { return }
        let creatorId = drift.host.firestoreUID
        guard !creatorId.isEmpty else { return }
        
        let db = Firestore.firestore()
        db.collection("posts")
            .whereField("creatorId", isEqualTo: creatorId)
            .getDocuments { [weak self] snapshot, error in
                guard let self = self, let docs = snapshot?.documents, error == nil else { return }
                
                let currentUid = Auth.auth().currentUser?.uid
                let fetchedDrifts: [Drift] = docs.compactMap { doc -> Drift? in
                    // Let's skip the current drift!
                    if doc.documentID == self.drift.id.uuidString { return nil }
                    
                    let data = doc.data()
                    let isActive = data["isActive"] as? Bool ?? true
                    if !isActive { return nil }
                    
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
                        isMine: isMine
                    )
                }
                
                DispatchQueue.main.async {
                    var updatedHost = self.drift.host
                    let newHost = Host(
                        id: updatedHost.id,
                        name: updatedHost.name,
                        role: updatedHost.role,
                        imageUrl: updatedHost.imageUrl,
                        isVerified: updatedHost.isVerified,
                        hostedCount: updatedHost.hostedCount,
                        joinedCount: updatedHost.joinedCount,
                        completedCount: updatedHost.completedCount,
                        verified: updatedHost.verified,
                        otherActiveDrifts: fetchedDrifts,
                        pastDrifts: updatedHost.pastDrifts,
                        interests: updatedHost.interests,
                        firestoreUID: updatedHost.firestoreUID
                    )
                    self.drift.host = newHost
                }
            }
    }
    
    var isBookmarked: Bool {
        savedDrifts.contains(where: { $0.id == drift.id || ($0.title == drift.title && $0.host.name == drift.host.name) })
    }
    
    func saveDrift() {
        BookmarkManager.shared.toggleBookmark(drift)
    }
    
    func shareDrift() {
        let inviteText = AppStrings.Drifts.Detail.inviteText(
            title: drift.title,
            date: drift.date,
            time: drift.time,
            location: drift.location
        )
        UIApplication.shareText(inviteText)
    }
    
    func checkReminderStatus() {
        let key = "calendar_added_\(drift.id.uuidString)"
        isReminderSet = UserDefaults.standard.bool(forKey: key)
    }
    
    func setReminder() {
        if isReminderSet {
            showCalendarUntapDisclaimer = true
            return
        }
        showCalendarAddConfirmation = true
    }
    
    func confirmAddReminderToCalendar() {
        EventKitManager.shared.addDriftToCalendar(drift: drift) { [weak self] success, error in
            guard let self = self else { return }
            if success {
                self.isReminderSet = true
                let key = "calendar_added_\(self.drift.id.uuidString)"
                UserDefaults.standard.set(true, forKey: key)
            } else {
                print("Failed to add to calendar: \(error?.localizedDescription ?? "Unknown error")")
            }
        }
    }
}
