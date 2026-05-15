import SwiftUI
import Combine

class ProfileViewModel: ObservableObject {
    @Published var name: String = AppConstants.MockData.userName
    @Published var bio: String = "Usually up for walks, coffee, and casual food plans."
    @Published var initials: String = AppConstants.MockData.userInitials
    @Published var driftsJoined: Int = 24
    @Published var driftsHosted: Int = 8
    @Published var pastDriftsCount: Int = 16
    
    @Published var interests: [DriftCategory] = [.coffee, .walk, .food, .movie, .study]
    
    @Published var historyDrifts: [Drift] = []
    @Published var selectedHistoryTab: Int = 0
    
    init() {
        loadMockHistory()
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
                description: "", location: "Ended • 5 days ago", meetingPoint: "", time: "", endTime: "", date: "", distance: 0, status: .ended, category: .study, hook: nil, host: mockHost, peopleGoing: 6, spotsLeft: 0, capacity: 6, vibeTags: [], whatToBring: [], notes: "", participantInitials: [], imageUrl: "drift_study"
            ),
            Drift(
                title: "Brunch & Banter in Indiranagar",
                description: "", location: "Ended • 1 week ago", meetingPoint: "", time: "", endTime: "", date: "", distance: 0, status: .ended, category: .food, hook: nil, host: mockHost, peopleGoing: 5, spotsLeft: 0, capacity: 5, vibeTags: [], whatToBring: [], notes: "", participantInitials: [], imageUrl: "drift_brunch"
            )
        ]
    }
    
    func signOut() {
        // Sign out logic
    }
}
