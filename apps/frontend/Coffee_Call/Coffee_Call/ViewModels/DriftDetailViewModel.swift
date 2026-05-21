import SwiftUI
import Combine
import FirebaseAuth
import FirebaseFirestore

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
            self.participants = [
                ParticipantDetail(name: "Liam", initials: "LJ", interests: ["Walks", "Coffee", "Music"], joinTimeDescription: "Joined today 2:14 PM"),
                ParticipantDetail(name: "Maya", initials: "MM", interests: ["Coffee", "Walks", "Music"], joinTimeDescription: "Joined today 1:45 PM"),
                ParticipantDetail(name: "Sarah", initials: "SJ", interests: ["Walks", "Coffee", "Music"], joinTimeDescription: "Joined today 12:30 PM"),
                ParticipantDetail(name: "Dev", initials: "DG", interests: ["Music", "Coffee", "Walks"], joinTimeDescription: "Joined today 11:15 AM")
            ]
        }
        
        if let initialJoinStatus {
            self.joinStatus = initialJoinStatus
        } else if drift.status == .ended {
            self.joinStatus = .ended
        } else if drift.isMine {
            self.joinStatus = .joined
        } else if drift.spotsLeft == 0 {
            self.joinStatus = .full
        } else {
            self.joinStatus = .notJoined
        }
        
        setupBookmarkSubscription()
    }
    
    private func setupBookmarkSubscription() {
        BookmarkManager.shared.$savedDrifts
            .receive(on: RunLoop.main)
            .assign(to: \.savedDrifts, on: self)
            .store(in: &cancellables)
    }
    
    func requestToJoin() {
        let currentUid = Auth.auth().currentUser?.uid ?? ""

        // Use real profile data from UserDefaults (written by ProfileViewModel on save/fetch).
        // Falls back to MockData only if UserDefaults has nothing (offline preview mode).
        let currentUserName = UserDefaults.standard.string(forKey: "profile_name")
            ?? AppConstants.MockData.userName
        let currentUserInitials = UserDefaults.standard.string(forKey: "profile_initials")
            ?? AppConstants.MockData.userInitials
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

        driftsService.requestToJoin(driftId: drift.id, request: joinRequest)
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: { completionResult in
                if case .failure(let error) = completionResult {
                    print("Error requesting to join: \(error)")
                }
            }, receiveValue: { [weak self] in
                guard let self = self else { return }
                withAnimation(.spring()) {
                    self.joinStatus = .requested
                    self.showingRequestSentConfirmation = true
                }
            })
            .store(in: &cancellables)
    }

    // MARK: - Firebase Participants Fetch
    private var isFirebaseEnabled: Bool {
        Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist") != nil
    }

    func fetchParticipants() {
        guard isFirebaseEnabled else { return }
        let db = Firestore.firestore()
        let postId = drift.id.uuidString

        db.collection("acceptances")
            .whereField("postId", isEqualTo: postId)
            .getDocuments { [weak self] snapshot, error in
                guard let self = self, let docs = snapshot?.documents, error == nil else { return }

                let group = DispatchGroup()
                var fetched: [ParticipantDetail] = []

                for doc in docs {
                    let data = doc.data()
                    guard let acceptorId = data["acceptorId"] as? String else { continue }

                    group.enter()
                    db.collection("users").document(acceptorId).getDocument { userSnap, _ in
                        defer { group.leave() }
                        let userData = userSnap?.data() ?? [:]
                        let name = userData["name"] as? String ?? "Someone"
                        let parts = name.components(separatedBy: " ")
                        let initials = parts.compactMap { $0.first }.map { String($0) }.joined().uppercased()
                        let interests = userData["interestTags"] as? [String] ?? []

                        var joinTimeDesc = "Joined recently"
                        if let ts = data["acceptedAt"] as? Timestamp {
                            let fmt = DateFormatter()
                            fmt.timeStyle = .short
                            joinTimeDesc = "Joined \(fmt.string(from: ts.dateValue()))"
                        }

                        fetched.append(ParticipantDetail(
                            name: name,
                            initials: initials,
                            interests: interests,
                            joinTimeDescription: joinTimeDesc
                        ))
                    }
                }

                group.notify(queue: .main) { [weak self] in
                    self?.participants = fetched
                }
            }
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
    
    func setReminder() {
        print("Setting reminder...")
    }
}
