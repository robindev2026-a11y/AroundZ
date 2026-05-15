import SwiftUI
import Combine

class DriftsViewModel: ObservableObject, CoffeeScreenConfiguration {
    // CoffeeScreenConfiguration Conformance
    var title: String { AppStrings.Drifts.title }
    var subtitle: String? { AppStrings.Drifts.subtitle }
    var trailingActions: AnyView? {
        AnyView(
            HStack(spacing: 12) {
                CoffeeHeaderButton(icon: AppIcons.search, action: {})
                CoffeeHeaderButton(icon: AppIcons.filter, action: {})
            }
        )
    }
    
    @Published var drifts: [Drift] = []
    @Published var selectedMode: DriftMode = .discover
    @Published var selectedTimeState: TimeState = .all
    @Published var searchText: String = ""
    
    enum DriftMode: String, CaseIterable {
        case discover = "Discover"
        case mine = "Mine"
    }
    
    enum TimeState: String, CaseIterable {
        case all = "All"
        case openNow = "Open now"
        case startingSoon = "Starting soon"
        case tonight = "Tonight"
        
        var icon: String {
            switch self {
            case .all: return "square.grid.2x2.fill"
            case .openNow: return "bolt.fill"
            case .startingSoon: return "clock.fill"
            case .tonight: return "moon.fill"
            }
        }
    }
    
    init() {
        loadMockDrifts()
    }
    
    func loadMockDrifts() {
        let mockHost = Host(name: "Arjun", role: "Hosting this Drift", imageUrl: "host_arjun", isVerified: true)
        
        self.drifts = [
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
                isMine: true
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
                imageUrl: "drift_walk"
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
                imageUrl: "drift_movie"
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
                imageUrl: "drift_dinner"
            )
        ]
    }
    
    var filteredDrifts: [Drift] {
        drifts.filter { drift in
            // Filter by Mode (Discover vs Mine)
            if selectedMode == .mine && !drift.isMine { return false }
            if selectedMode == .discover && drift.isMine { return false }
            
            // Filter by Time State
            if selectedTimeState == .all { return true }
            if selectedTimeState == .openNow && drift.status == .open { return true }
            if selectedTimeState == .startingSoon && drift.status == .startingSoon { return true }
            if selectedTimeState == .tonight && drift.status == .tonight { return true }
            return false
        }
    }
}
