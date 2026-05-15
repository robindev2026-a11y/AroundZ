import SwiftUI
import Combine

class ChatsViewModel: ObservableObject {
    @Published var activeDrifts: [Drift] = []
    @Published var upcomingDrifts: [Drift] = []
    @Published var pastDrifts: [Drift] = []
    
    init() {
        loadMockChats()
    }
    
    func loadMockChats() {
        let mockHost = Host(name: "Arjun", role: "Host", imageUrl: "host_arjun", isVerified: true)
        
        // Active Drifts
        activeDrifts = [
            Drift(
                title: "Evening walk at Cubbon Park",
                description: "", location: "Indiranagar", meetingPoint: "", time: "6:30 PM", endTime: "", date: "Today", distance: 0, status: .open, category: .walk, hook: nil, host: mockHost, peopleGoing: 5, spotsLeft: 0, capacity: 5, vibeTags: [], whatToBring: [], notes: "", participantInitials: [], imageUrl: "drift_walk",
                lastMessage: "Karthik: See you all at the main gate!", lastMessageTime: "10:24 AM", unreadCount: 2
            ),
            Drift(
                title: "Sunday Coffee at Third Wave",
                description: "", location: "Koramangala", meetingPoint: "", time: "9:15 AM", endTime: "", date: "Today", distance: 0, status: .open, category: .coffee, hook: nil, host: mockHost, peopleGoing: 4, spotsLeft: 0, capacity: 4, vibeTags: [], whatToBring: [], notes: "", participantInitials: [], imageUrl: "drift_coffee",
                lastMessage: "Sneha: I'll reach by 10!", lastMessageTime: "9:15 AM", unreadCount: 0
            )
        ]
        
        // Upcoming Drifts
        upcomingDrifts = [
            Drift(
                title: "Study session at Koramangala",
                description: "", location: "HSR Layout", meetingPoint: "", time: "5:45 PM", endTime: "", date: "Today", distance: 0, status: .startingSoon, category: .study, hook: nil, host: mockHost, peopleGoing: 6, spotsLeft: 0, capacity: 6, vibeTags: [], whatToBring: [], notes: "", participantInitials: [], imageUrl: "drift_study",
                lastMessage: "Arjun (Host): We'll start around 6:30 PM.", lastMessageTime: "Today, 5:45 PM", unreadCount: 1
            ),
            Drift(
                title: "Morning Yoga at Ulsoor Lake",
                description: "", location: "Ulsoor", meetingPoint: "", time: "7:00 AM", endTime: "", date: "Tomorrow", distance: 0, status: .startingSoon, category: .walk, hook: nil, host: mockHost, peopleGoing: 7, spotsLeft: 0, capacity: 7, vibeTags: [], whatToBring: [], notes: "", participantInitials: [], imageUrl: "drift_yoga",
                lastMessage: "Maya: Looking forward!", lastMessageTime: "Tomorrow, 7:00 AM", unreadCount: 0
            ),
            Drift(
                title: "Brunch & Banter in Indiranagar",
                description: "", location: "Indiranagar", meetingPoint: "", time: "11:00 AM", endTime: "", date: "Sun", distance: 0, status: .startingSoon, category: .food, hook: nil, host: mockHost, peopleGoing: 5, spotsLeft: 0, capacity: 5, vibeTags: [], whatToBring: [], notes: "", participantInitials: [], imageUrl: "drift_brunch",
                lastMessage: "Karthik (Host): Final headcount soon.", lastMessageTime: "Sun, 11:00 AM", unreadCount: 0
            )
        ]
        
        // Past Drifts
        pastDrifts = [
            Drift(
                title: "Night walk at Cubbon Park",
                description: "", location: "Cubbon Park", meetingPoint: "", time: "", endTime: "", date: "", distance: 0, status: .ended, category: .walk, hook: nil, host: mockHost, peopleGoing: 6, spotsLeft: 0, capacity: 6, vibeTags: [], whatToBring: [], notes: "", participantInitials: [], imageUrl: "drift_night_walk",
                lastMessage: "Arjun: Thanks everyone, great walk!", lastMessageTime: "Yesterday", unreadCount: 0
            ),
            Drift(
                title: "Live Music at HSR Club",
                description: "", location: "HSR Club", meetingPoint: "", time: "", endTime: "", date: "", distance: 0, status: .ended, category: .music, hook: nil, host: mockHost, peopleGoing: 5, spotsLeft: 0, capacity: 5, vibeTags: [], whatToBring: [], notes: "", participantInitials: [], imageUrl: "drift_music",
                lastMessage: "Sneha: Such a vibe! 🤘", lastMessageTime: "Sat", unreadCount: 0
            )
        ]
    }
}
