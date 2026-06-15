import Foundation
import Combine
@testable import Coffee_Call

// MARK: - Mock Constants
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

// MARK: - Mock Drifts Service
class MockDriftsService: DriftsServiceProtocol {
    static var mockDrifts: [Drift] = []
    
    init() {
        if MockDriftsService.mockDrifts.isEmpty {
            initializeMockDrifts()
        }
    }
    
    private func initializeMockDrifts() {
        let mockHost = Host(name: "Arjun", role: "Hosting this Drift", imageUrl: "host_arjun", isVerified: true)
        
        MockDriftsService.mockDrifts = [
            Drift(
                title: "Coffee Drift",
                description: "Spontaneous coffee meetup at a nice local cafe. Open to anyone who wants to chat and meet new people in the area.",
                location: "Panampilly Nagar, Kochi",
                meetingPoint: "Near the Main Entrance",
                time: "6:30 PM",
                endTime: "7:30 PM",
                date: "Today",
                distance: 1.2,
                status: .open,
                category: .coffee,
                hook: "Coffee on me ☕\nFirst round's on me!",
                host: mockHost,
                peopleGoing: 3,
                spotsLeft: 2,
                capacity: 5,
                vibeTags: ["Casual", "Friendly"],
                whatToBring: ["Good mood"],
                notes: "Just a quick chat.",
                participantInitials: ["AL", "RI", "MA"],
                imageUrl: "drift_coffee",
                isMine: true,
                latitude: 9.9634,
                longitude: 76.2949
            ),
            Drift(
                title: "Evening Walk",
                description: "A relaxed evening walk inside Cubbon Park. We'll walk, talk, unwind and enjoy the greenery.",
                location: "Marine Drive, Kochi",
                meetingPoint: "Near Kanteerava Stadium Gate",
                time: "6:30 PM",
                endTime: "7:45 PM",
                date: "Today",
                distance: 1.8,
                status: .open,
                category: .walk,
                hook: nil,
                host: Host(name: "Arjun", role: "Hosting this Drift", imageUrl: "host_arjun", isVerified: true),
                peopleGoing: 2,
                spotsLeft: 3,
                capacity: 5,
                vibeTags: ["Chill", "Friendly", "Outdoorsy"],
                whatToBring: ["Comfortable shoes", "Water"],
                notes: "Beginner-friendly. No running.",
                participantInitials: ["SA", "TH"],
                imageUrl: "drift_walk",
                latitude: 9.9806,
                longitude: 76.2758
            ),
            Drift(
                title: "Movie Drift",
                description: "Catching the latest movie at PVR. I have extra coupons!",
                location: "PVR Lulu Mall, Kochi",
                meetingPoint: "Ticket Counter",
                time: "7:45 PM",
                endTime: "10:00 PM",
                date: "Today",
                distance: 2.1,
                status: .startingSoon,
                category: .movie,
                hook: "2 movie coupons 🎟️🎟️\nLet's watch together.",
                host: Host(name: "Sarah", role: "Cinephile", imageUrl: "host_sarah", isVerified: true),
                peopleGoing: 4,
                spotsLeft: 0,
                capacity: 4,
                vibeTags: ["Fun", "Cinematic"],
                whatToBring: ["Popcorn money"],
                notes: "Starting soon!",
                participantInitials: ["PR", "DK", "MR", "NP"],
                imageUrl: "drift_movie",
                latitude: 10.0270,
                longitude: 76.3080
            ),
            Drift(
                title: "Dinner & Chats",
                description: "Dinner at Fort Kochi. Great food and even better conversations.",
                location: "Fort Kochi",
                meetingPoint: "The Old Lighthouse",
                time: "8:30 PM",
                endTime: "10:30 PM",
                date: "Today",
                distance: 2.4,
                status: .tonight,
                category: .food,
                hook: "Free entry with me 🎫\nCovering the entry!",
                host: Host(name: "Liam", role: "Foodie", imageUrl: "host_liam", isVerified: false),
                peopleGoing: 3,
                spotsLeft: 3,
                capacity: 6,
                vibeTags: ["Foodie", "Friendly"],
                whatToBring: ["Appetite"],
                notes: "Reservation is under CoffeeCall.",
                participantInitials: ["RO", "LM", "KK"],
                imageUrl: "drift_dinner",
                latitude: 9.9658,
                longitude: 76.2421
            )
        ]
    }
    
    func fetchDrifts() -> AnyPublisher<[Drift], Error> {
        JoinRequestDebugTracer.trace(
            "MockDriftsService.fetchDrifts called",
            details: "drifts=\(MockDriftsService.mockDrifts.count)"
        )
        return Just(MockDriftsService.mockDrifts)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    func createDrift(_ drift: Drift) -> AnyPublisher<Void, Error> {
        MockDriftsService.mockDrifts.insert(drift, at: 0)
        return Just(())
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    func requestToJoin(driftId: UUID, request: JoinRequest) -> AnyPublisher<Void, Error> {
        JoinRequestDebugTracer.trace(
            "MockDriftsService.requestToJoin called",
            driftId: driftId,
            requestId: request.id
        )
        if let index = MockDriftsService.mockDrifts.firstIndex(where: { $0.id == driftId }) {
            var updatedDrift = MockDriftsService.mockDrifts[index]
            updatedDrift.pendingRequests.append(request)
            MockDriftsService.mockDrifts[index] = updatedDrift
            JoinRequestDebugTracer.trace(
                "MockDriftsService.requestToJoin appended request",
                driftId: driftId,
                requestId: request.id,
                details: "pendingRequests=\(updatedDrift.pendingRequests.count)"
            )
        }
        return Just(())
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }

    func cancelJoinRequest(driftId: UUID, userId: String) -> AnyPublisher<Void, Error> {
        JoinRequestDebugTracer.trace(
            "MockDriftsService.cancelJoinRequest called",
            driftId: driftId,
            details: "userId=\(userId)"
        )
        if let index = MockDriftsService.mockDrifts.firstIndex(where: { $0.id == driftId }) {
            var updatedDrift = MockDriftsService.mockDrifts[index]
            updatedDrift.pendingRequests.removeAll { $0.userId == userId }
            MockDriftsService.mockDrifts[index] = updatedDrift
            JoinRequestDebugTracer.trace(
                "MockDriftsService.cancelJoinRequest removed request",
                driftId: driftId,
                details: "pendingRequests=\(updatedDrift.pendingRequests.count)"
            )
        }
        return Just(())
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    func acceptJoinRequest(driftId: UUID, request: JoinRequest) -> AnyPublisher<Void, Error> {
        JoinRequestDebugTracer.trace(
            "MockDriftsService.acceptJoinRequest called",
            driftId: driftId,
            requestId: request.id
        )
        if let index = MockDriftsService.mockDrifts.firstIndex(where: { $0.id == driftId }) {
            var updatedDrift = MockDriftsService.mockDrifts[index]
            updatedDrift.pendingRequests.removeAll { $0.id == request.id }
            if !updatedDrift.participantInitials.contains(request.userInitials) {
                updatedDrift.participantInitials.append(request.userInitials)
            }
            updatedDrift.peopleGoing += 1
            if let spots = updatedDrift.spotsLeft {
                updatedDrift.spotsLeft = max(spots - 1, 0)
            }
            MockDriftsService.mockDrifts[index] = updatedDrift
        }
        return Just(())
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    func rejectJoinRequest(driftId: UUID, requestId: UUID) -> AnyPublisher<Void, Error> {
        JoinRequestDebugTracer.trace(
            "MockDriftsService.rejectJoinRequest called",
            driftId: driftId,
            requestId: requestId
        )
        if let index = MockDriftsService.mockDrifts.firstIndex(where: { $0.id == driftId }) {
            var updatedDrift = MockDriftsService.mockDrifts[index]
            updatedDrift.pendingRequests.removeAll { $0.id == requestId }
            MockDriftsService.mockDrifts[index] = updatedDrift
        }
        return Just(())
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    func updateDriftStatus(driftId: UUID, status: DriftStatus) -> AnyPublisher<Void, Error> {
        if let index = MockDriftsService.mockDrifts.firstIndex(where: { $0.id == driftId }) {
            var updatedDrift = MockDriftsService.mockDrifts[index]
            updatedDrift.status = status
            MockDriftsService.mockDrifts[index] = updatedDrift
        }
        return Just(())
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    func updateDrift(_ drift: Drift) -> AnyPublisher<Void, Error> {
        if let index = MockDriftsService.mockDrifts.firstIndex(where: { $0.id == drift.id }) {
            MockDriftsService.mockDrifts[index] = drift
        }
        return Just(())
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }

    func deleteDrift(driftId: UUID) -> AnyPublisher<Void, Error> {
        MockDriftsService.mockDrifts.removeAll { $0.id == driftId }
        return Just(())
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }

    func leaveDrift(driftId: UUID, userId: String) -> AnyPublisher<Void, Error> {
        if let index = MockDriftsService.mockDrifts.firstIndex(where: { $0.id == driftId }) {
            var updatedDrift = MockDriftsService.mockDrifts[index]
            let rawInitials = UserDefaults.standard.string(forKey: "profile_initials") ?? MockData.userInitials
            let userInitials = rawInitials.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
            print("[LeaveDrift] MockDriftsService.leaveDrift called for drift: \(updatedDrift.title). Removing userInitials: \(userInitials)")
            updatedDrift.participantInitials.removeAll { 
                $0.trimmingCharacters(in: .whitespacesAndNewlines).uppercased() == userInitials 
            }
            updatedDrift.peopleGoing = max(updatedDrift.peopleGoing - 1, 1)
            if let spots = updatedDrift.spotsLeft {
                updatedDrift.spotsLeft = spots + 1
            }
            MockDriftsService.mockDrifts[index] = updatedDrift
        }
        return Just(())
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }

    func reportDrift(driftId: UUID, reason: String) -> AnyPublisher<Void, Error> {
        print("MockDriftsService: Drift \(driftId) reported for reason: \(reason)")
        return Just(())
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
}

// MARK: - Mock Drift Chat Thread Service
struct MockDriftChatThreadService: DriftChatThreadServiceProtocol {
    func loadThread(for drift: Drift) -> DriftChatThreadContext {
        DriftChatThreadContext(
            systemMessages: MockData.chatSystemMessages,
            messages: MockData.chatHistoryMessages,
            participants: MockData.chatParticipants
        )
    }
}

// MARK: - High Fidelity Mock Chat Service
class MockChatService: ChatServiceProtocol {
    // onUpdate is never fired for mock — data is static and returned synchronously.
    var onUpdate: (([Drift]) -> Void)? = nil
    func getChats() -> [Drift] {
        let hostArjun = Host(name: "Arjun R.", role: "Host", imageUrl: nil, isVerified: true)
        let hostMira = Host(name: "Mira", role: "Host", imageUrl: nil, isVerified: true)
        let hostRahul = Host(name: "Rahul", role: "Host", imageUrl: nil, isVerified: true)
        let hostAisha = Host(name: "Aisha", role: "Host", imageUrl: nil, isVerified: true)
        
        return [
            Drift(
                title: "Coffee after work",
                description: "Meet near the entrance, quick hello.",
                location: "Panampilly Nagar",
                meetingPoint: "Main Entrance",
                time: "Today • 6:30 PM",
                endTime: "7:30 PM",
                date: "Today",
                distance: 0.5,
                status: .startingSoon,
                category: .coffee,
                hook: "See you near the metro.",
                host: hostMira,
                peopleGoing: 5,
                spotsLeft: 1,
                capacity: 6,
                vibeTags: ["Casual"],
                whatToBring: ["Good vibe"],
                notes: "Meet near the entrance, quick hello.",
                participantInitials: ["M", "R", "A", "N", "Y"],
                imageUrl: nil,
                isMine: false,
                lastMessage: "See you near the metro.",
                lastMessageTime: "2m",
                unreadCount: 1
            ),
            Drift(
                title: "Street Food Walk",
                description: "Exploring local street food spots together.",
                location: "Indiranagar",
                meetingPoint: "Metro Station Exit A",
                time: "Today • 7:30 PM",
                endTime: "9:00 PM",
                date: "Today",
                distance: 1.2,
                status: .open,
                category: .food,
                hook: "Meet at the entrance.",
                host: hostArjun,
                peopleGoing: 4,
                spotsLeft: 2,
                capacity: 6,
                vibeTags: ["Foodies"],
                whatToBring: ["Hungry stomach"],
                notes: "Wear comfortable shoes.",
                participantInitials: ["A", "S", "M", "K"],
                imageUrl: nil,
                isMine: true,
                lastMessage: "Meet at the entrance.",
                lastMessageTime: "25m",
                unreadCount: 3
            ),
            Drift(
                title: "Movie plan",
                description: "Catching the latest sci-fi movie release.",
                location: "PVR Forum Mall",
                meetingPoint: "Box Office",
                time: "Today • 7:00 PM",
                endTime: "10:00 PM",
                date: "Today",
                distance: 2.3,
                status: .startingSoon,
                category: .movie,
                hook: "Tickets booked.",
                host: hostRahul,
                peopleGoing: 3,
                spotsLeft: 3,
                capacity: 6,
                vibeTags: ["Sci-Fi"],
                whatToBring: ["Popcorn budget"],
                notes: "Screens at Audi 3.",
                participantInitials: ["R", "J", "M"],
                imageUrl: nil,
                isMine: false,
                lastMessage: "Tickets booked.",
                lastMessageTime: "1h",
                unreadCount: 0
            ),
            Drift(
                title: "Morning walk",
                description: "A refreshing brisk walk to start the day.",
                location: "Cubbon Park",
                meetingPoint: "Hudson Circle Gate",
                time: "Tomorrow • 7:00 AM",
                endTime: "8:00 AM",
                date: "Tomorrow",
                distance: 0.8,
                status: .startingSoon,
                category: .walk,
                hook: "7am works.",
                host: hostMira,
                peopleGoing: 2,
                spotsLeft: 4,
                capacity: 6,
                vibeTags: ["Fresh Air"],
                whatToBring: ["Water bottle"],
                notes: "Brisk pace walk.",
                participantInitials: ["M", "Y"],
                imageUrl: nil,
                isMine: false,
                lastMessage: "7am works.",
                lastMessageTime: "Yesterday",
                unreadCount: 1
            ),
            Drift(
                title: "Books & chai",
                description: "Discussing our favorite reads over warm chai.",
                location: "Chai Point",
                meetingPoint: "Outdoor Seating",
                time: "Today • 4:00 PM",
                endTime: "5:30 PM",
                date: "Today",
                distance: 1.5,
                status: .open,
                category: .study,
                hook: "Any genre preference?",
                host: hostAisha,
                peopleGoing: 3,
                spotsLeft: 2,
                capacity: 5,
                vibeTags: ["Literary"],
                whatToBring: ["Your current read"],
                notes: "Relaxed cozy vibe.",
                participantInitials: ["A", "H", "P"],
                imageUrl: nil,
                isMine: false,
                lastMessage: "Any genre preference?",
                lastMessageTime: "Tue",
                unreadCount: 1
            ),
            Drift(
                title: "Workout buddy",
                description: "Pushing limits at the local gym partner routine.",
                location: "Gold Gym",
                meetingPoint: "Reception Area",
                time: "Tomorrow • 6:00 PM",
                endTime: "7:30 PM",
                date: "Tomorrow",
                distance: 1.9,
                status: .open,
                category: .yoga,
                hook: "Gym at 6?",
                host: hostArjun,
                peopleGoing: 2,
                spotsLeft: 1,
                capacity: 3,
                vibeTags: ["Active"],
                whatToBring: ["Gym towel"],
                notes: "Focusing on leg day.",
                participantInitials: ["A", "D"],
                imageUrl: nil,
                isMine: true,
                lastMessage: "Gym at 6?",
                lastMessageTime: "Mon",
                unreadCount: 1
            ),
            Drift(
                title: "Chai Time",
                description: "Grab a cup of hot tea.",
                location: "Panampilly Nagar",
                meetingPoint: "Chai Shop",
                time: "Today • 5:00 PM",
                endTime: "6:00 PM",
                date: "Today",
                distance: 0.4,
                status: .open,
                category: .coffee,
                hook: "See you at the stall!",
                host: hostAisha,
                peopleGoing: 2,
                spotsLeft: 3,
                capacity: 5,
                vibeTags: ["Casual"],
                whatToBring: ["Good conversation"],
                notes: "Quick tea run.",
                participantInitials: ["K", "P"],
                imageUrl: nil,
                isMine: false,
                lastMessage: "See you at the stall!",
                lastMessageTime: "Today",
                unreadCount: 0
            ),
            Drift(
                title: "Food",
                description: "Quick lunch meetup.",
                location: "Food Court",
                meetingPoint: "Central Table",
                time: "Today • 12:00 PM",
                endTime: "1:00 PM",
                date: "Today",
                distance: 1.1,
                status: .open,
                category: .food,
                hook: "Ready when you are.",
                host: hostRahul,
                peopleGoing: 2,
                spotsLeft: 4,
                capacity: 6,
                vibeTags: ["Lunch"],
                whatToBring: ["Appetite"],
                notes: "Fast food bite.",
                participantInitials: ["S", "N"],
                imageUrl: nil,
                isMine: false,
                lastMessage: "Ready when you are.",
                lastMessageTime: "Today",
                unreadCount: 1
            ),
            Drift(
                title: "Coffee",
                description: "Quick espresso chat.",
                location: "Starbucks",
                meetingPoint: "Counter",
                time: "Today • 9:00 AM",
                endTime: "9:30 AM",
                date: "Today",
                distance: 0.6,
                status: .open,
                category: .coffee,
                hook: "Already ordered!",
                host: hostMira,
                peopleGoing: 2,
                spotsLeft: 2,
                capacity: 4,
                vibeTags: ["Quick"],
                whatToBring: ["Caffeine need"],
                notes: "Just a 15 min catch up.",
                participantInitials: ["B", "K"],
                imageUrl: nil,
                isMine: false,
                lastMessage: "Already ordered!",
                lastMessageTime: "Today",
                unreadCount: 0
            ),
            Drift(
                title: "Walks",
                description: "Short evening stroll.",
                location: "Walking Track",
                meetingPoint: "Start line",
                time: "Today • 5:30 PM",
                endTime: "6:00 PM",
                date: "Today",
                distance: 0.9,
                status: .open,
                category: .walk,
                hook: "On my way.",
                host: hostMira,
                peopleGoing: 2,
                spotsLeft: 3,
                capacity: 5,
                vibeTags: ["Stroll"],
                whatToBring: ["Walking shoes"],
                notes: "Just a gentle walk.",
                participantInitials: ["M", "L"],
                imageUrl: nil,
                isMine: false,
                lastMessage: "On my way.",
                lastMessageTime: "Today",
                unreadCount: 0
            ),
            Drift(
                title: "Movies",
                description: "Checking out the new comedy.",
                location: "Cineplex",
                meetingPoint: "Lobby",
                time: "Today • 8:30 PM",
                endTime: "10:30 PM",
                date: "Today",
                distance: 2.1,
                status: .open,
                category: .movie,
                hook: "Meet in the lobby.",
                host: hostRahul,
                peopleGoing: 2,
                spotsLeft: 4,
                capacity: 6,
                vibeTags: ["Comedy"],
                whatToBring: ["Ticket"],
                notes: "Starts sharp at 8:30.",
                participantInitials: ["R", "D"],
                imageUrl: nil,
                isMine: false,
                lastMessage: "Meet in the lobby.",
                lastMessageTime: "Today",
                unreadCount: 0
            ),
            Drift(
                title: "Sunset photos",
                description: "Capturing beautiful golden hour frames.",
                location: "Sunset Point Hill",
                meetingPoint: "Base of Trail",
                time: "Today • 5:45 PM",
                endTime: "7:00 PM",
                date: "Today",
                distance: 3.5,
                status: .ended,
                category: .event,
                hook: "I'm running 10 late.",
                host: hostMira,
                peopleGoing: 4,
                spotsLeft: 0,
                capacity: 4,
                vibeTags: ["Creative"],
                whatToBring: ["Camera/Phone"],
                notes: "Charge your batteries.",
                participantInitials: ["M", "B", "R", "Y"],
                imageUrl: nil,
                isMine: false,
                lastMessage: "I'm running 10 late.",
                lastMessageTime: "Sun",
                unreadCount: 0
            ),
            Drift(
                title: "Board games",
                description: "Playing Catan and other tabletop favorites.",
                location: "Board Game Cafe",
                meetingPoint: "Table 4",
                time: "Yesterday • 3:00 PM",
                endTime: "6:00 PM",
                date: "Yesterday",
                distance: 1.0,
                status: .ended,
                category: .gaming,
                hook: "Bring one game if you can.",
                host: hostArjun,
                peopleGoing: 5,
                spotsLeft: 1,
                capacity: 6,
                vibeTags: ["Fun"],
                whatToBring: ["Good humor"],
                notes: "Cafe cover charge applies.",
                participantInitials: ["A", "J", "L", "W", "K"],
                imageUrl: nil,
                isMine: true,
                lastMessage: "Bring one game if you can.",
                lastMessageTime: "Sat",
                unreadCount: 0
            )
        ]
    }
}
