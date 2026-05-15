import SwiftUI
import Combine

class DiscoveryViewModel: ObservableObject {
    // MARK: - Published State
    @Published var radarPeople: [RadarPerson] = []
    @Published var interestCategories: [InterestCategory] = []
    @Published var selectedCategory: String = "Coffee"
    @Published var selectedTabIndex: Int = 0
    @Published var featuredDrifts: [Drift] = []
    
    // MARK: - Constants
    let userName = "Robin"
    let userInitials = "RO"
    
    // MARK: - Init
    init() {
        loadMockData()
    }
    
    // MARK: - Actions
    func selectCategory(_ category: String) {
        withAnimation(CoffeeAnimation.spring) {
            selectedCategory = category
        }
    }
    
    func createDrift() {
        // Logic to navigate to create drift flow
        print("Creating drift...")
    }
    
    // MARK: - Private Helpers
    private func loadMockData() {
        // Mock radar people
        let initials = ["DK", "MR", "LM", "NP", "TH", "AL"]
        let colors: [Color] = [.brandPrimary, .brandPurple, .brandSecondary, .brandPurple, .brandPrimary, .brandSecondary]
        
        self.radarPeople = zip(initials, zip(AppConstants.MockData.radarDistances, AppConstants.MockData.radarAngles)).enumerated().map { i, data in
            let (initial, geo) = data
            return RadarPerson(initials: initial, color: colors[i % colors.count], distance: geo.0, angle: geo.1, hasPresence: true)
        }
        
        // Mock interest categories
        self.interestCategories = [
            InterestCategory(id: "Coffee", label: AppStrings.Discovery.Categories.coffee, icon: AppIcons.coffee, count: 3),
            InterestCategory(id: "Walk",   label: AppStrings.Discovery.Categories.walks,  icon: AppIcons.walk,   count: 4),
            InterestCategory(id: "Movie",  label: AppStrings.Discovery.Categories.music,  icon: AppIcons.movie,  count: 2),
            InterestCategory(id: "Food",   label: AppStrings.Discovery.Categories.food,   icon: AppIcons.food,   count: 5)
        ]
        
        let mockHost = Host(name: AppConstants.MockData.userName, role: "Host", imageUrl: "host_arjun", isVerified: true)
        let otherHost = Host(name: "Sarah", role: "Cinephile", imageUrl: "host_sarah", isVerified: true)
        
        self.featuredDrifts = [
            Drift(
                title: "Morning Yoga at Ulsoor",
                description: "Start your day with some peace and yoga. Open to all levels.",
                location: "Ulsoor Lake", meetingPoint: "Main Gate", time: "7:00 AM", endTime: "8:00 AM", date: "Tomorrow", distance: 1.2, status: .startingSoon, category: .yoga, hook: nil, host: otherHost, peopleGoing: 4, spotsLeft: 6, capacity: 10, vibeTags: ["Peaceful", "Active"], whatToBring: ["Yoga mat"], notes: "", participantInitials: ["AL", "MA"], imageUrl: "drift_yoga", isMine: false
            ),
            Drift(
                title: "Koramangala Coffee",
                description: "Let's grab a coffee and talk about design or anything else.",
                location: "Third Wave Coffee", meetingPoint: "Inside", time: "5:30 PM", endTime: "6:30 PM", date: "Today", distance: 0.8, status: .open, category: .coffee, hook: "First round on me!", host: mockHost, peopleGoing: 2, spotsLeft: 3, capacity: 5, vibeTags: ["Casual"], whatToBring: [], notes: "", participantInitials: [AppConstants.MockData.userInitials], imageUrl: "drift_coffee", isMine: true
            )
        ]
    }
}

// MARK: - Supporting Models
struct InterestCategory: Identifiable {
    let id: String
    let label: String
    let icon: String
    let count: Int
}
