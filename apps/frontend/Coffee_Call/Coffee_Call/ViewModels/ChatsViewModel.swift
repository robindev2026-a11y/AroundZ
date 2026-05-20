import SwiftUI
import Combine

// MARK: - Chat Service Dependency Injection
protocol ChatServiceProtocol {
    func getChats() -> [Drift]
}

enum ChatFilter: String, CaseIterable, Identifiable {
    case active
    case joined
    case hosted
    case expired
    
    var id: String { self.rawValue }
    
    var title: String {
        switch self {
        case .active: return AppStrings.Chat.active
        case .joined: return AppStrings.Chat.joined
        case .hosted: return AppStrings.Chat.hosted
        case .expired: return AppStrings.Chat.expired
        }
    }
}

class ChatsViewModel: ObservableObject {
    var title: String { AppStrings.Chat.title }
    var subtitle: String? { AppStrings.Chat.subtitle }
    
    @Published var allChats: [Drift] = []
    
    private let chatService: ChatServiceProtocol
    
    init(chatService: ChatServiceProtocol? = nil) {
        if let chatService = chatService {
            self.chatService = chatService
        } else {
            let isFirebaseEnabled = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist") != nil
            self.chatService = isFirebaseEnabled ? FirebaseChatService() : MockChatService()
        }
        loadChats()
    }
    
    func loadChats() {
        self.allChats = chatService.getChats()
    }
    
    func filteredChats(for filter: ChatFilter) -> [Drift] {
        switch filter {
        case .active:
            return allChats.filter { $0.status != .ended }
        case .joined:
            return allChats.filter { !$0.isMine && $0.status != .ended }
        case .hosted:
            return allChats.filter { $0.isMine && $0.status != .ended }
        case .expired:
            return allChats.filter { $0.status == .ended }
        }
    }
}

// MARK: - High Fidelity Mock Chat Service
class MockChatService: ChatServiceProtocol {
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
