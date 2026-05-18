import SwiftUI
import Combine

class ChatsViewModel: ObservableObject {
    var title: String { AppStrings.Chat.title }
    var subtitle: String? { AppStrings.Chat.subtitle }
    
    @Published var activeDrifts: [Drift] = []
    @Published var upcomingDrifts: [Drift] = []
    @Published var pastDrifts: [Drift] = []
    
    init() {
        loadMockChats()
    }
    
    func loadMockChats() {
        let hostArjun = Host(name: "Arjun R.", role: "Host", imageUrl: nil, isVerified: true)
        let hostRiley = Host(name: "Riley", role: "Host", imageUrl: nil, isVerified: true)
        
        self.activeDrifts = [
            Drift(
                title: "Sunset Walk + Convo",
                description: "", location: "Cubbon Park", meetingPoint: "", time: "6:00 PM", endTime: "", date: "Today", distance: 0.5, status: .open, category: .walk, hook: nil, host: hostRiley, peopleGoing: 4, spotsLeft: 2, capacity: 6, vibeTags: [], whatToBring: [], notes: "", participantInitials: ["R", "A", "K", "L"], imageUrl: nil,
                lastMessage: "See you all at the gate!", lastMessageTime: "5:30 PM", unreadCount: 2
            )
        ]
        
        self.upcomingDrifts = [
            Drift(
                title: "Coffee & Startups",
                description: "", location: "Third Wave", meetingPoint: "", time: "10:00 AM", endTime: "", date: "Tomorrow", distance: 1.2, status: .open, category: .coffee, hook: nil, host: hostArjun, peopleGoing: 3, spotsLeft: 1, capacity: 4, vibeTags: [], whatToBring: [], notes: "", participantInitials: ["A", "S", "M"], imageUrl: nil,
                lastMessage: "I'll bring my laptop.", lastMessageTime: "Yesterday", unreadCount: 0
            )
        ]
        
        self.pastDrifts = [
            Drift(
                title: "Movie Night",
                description: "", location: "PVR", meetingPoint: "", time: "8:00 PM", endTime: "", date: "2 days ago", distance: 2.0, status: .ended, category: .movie, hook: nil, host: hostArjun, peopleGoing: 5, spotsLeft: 0, capacity: 5, vibeTags: [], whatToBring: [], notes: "", participantInitials: ["A", "J", "K", "L", "M"], imageUrl: nil,
                lastMessage: "That was fun!", lastMessageTime: "2 days ago", unreadCount: 0
            )
        ]
    }
}
