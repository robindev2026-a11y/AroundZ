import SwiftUI
import Combine
import FirebaseAuth

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
            interests: ["Walks", "Coffee", "Movies"]
        )
        
        var updatedDrift = drift
        updatedDrift.host = richHost
        self.drift = updatedDrift
        
        self.participants = [
            ParticipantDetail(name: "Liam", initials: "LJ", interests: ["Walks", "Coffee", "Music"], joinTimeDescription: "Joined today 2:14 PM"),
            ParticipantDetail(name: "Maya", initials: "MM", interests: ["Coffee", "Walks", "Music"], joinTimeDescription: "Joined today 1:45 PM"),
            ParticipantDetail(name: "Sarah", initials: "SJ", interests: ["Walks", "Coffee", "Music"], joinTimeDescription: "Joined today 12:30 PM"),
            ParticipantDetail(name: "Dev", initials: "DG", interests: ["Music", "Coffee", "Walks"], joinTimeDescription: "Joined today 11:15 AM")
        ]
        
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
        let currentUserName = AppConstants.MockData.userName
        let currentUserInitials = AppConstants.MockData.userInitials
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
    
    var isBookmarked: Bool {
        savedDrifts.contains(where: { $0.id == drift.id || ($0.title == drift.title && $0.host.name == drift.host.name) })
    }
    
    func saveDrift() {
        BookmarkManager.shared.toggleBookmark(drift)
    }
    
    func shareDrift() {
        print("Sharing drift...")
    }
    
    func setReminder() {
        print("Setting reminder...")
    }
}
