import SwiftUI
import Combine

class DiscoveryViewModel: ObservableObject {
    // MARK: - Published State
    @Published var radarPeople: [RadarPerson] = []
    @Published var interestCategories: [InterestCategory] = []
    @Published var selectedCategory: String = "Coffee"
    @Published var selectedTabIndex: Int = 0
    
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
        self.radarPeople = [
            RadarPerson(initials: "DK", color: .brandPrimary, distance: 0.35, angle: 160, hasPresence: true),
            RadarPerson(initials: "MR", color: .brandPurple, distance: 0.45, angle: 30, hasPresence: true),
            RadarPerson(initials: "LM", color: .brandSecondary, distance: 0.65, angle: 120, hasPresence: true),
            RadarPerson(initials: "NP", color: .brandPurple, distance: 0.75, angle: 210, hasPresence: true),
            RadarPerson(initials: "RO", color: .brandPrimary, distance: 0.25, angle: 280, hasPresence: true),
            RadarPerson(initials: "TH", color: .brandSecondary, distance: 0.55, angle: 330, hasPresence: true)
        ]
        
        // Mock interest categories
        self.interestCategories = [
            InterestCategory(id: "Coffee", label: "Coffee", icon: AppIcons.coffee, count: 3),
            InterestCategory(id: "Walk",   label: "Walk",   icon: AppIcons.walk,   count: 4),
            InterestCategory(id: "Movie",  label: "Movie",  icon: AppIcons.movie,  count: 2),
            InterestCategory(id: "Food",   label: "Food",   icon: AppIcons.food,   count: 5)
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
