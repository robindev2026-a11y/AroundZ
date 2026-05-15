import SwiftUI
import Combine

class DiscoveryViewModel: ObservableObject, CoffeeScreenConfiguration {
    // CoffeeScreenConfiguration Conformance
    var title: String { AppStrings.Tabs.discover }
    var subtitle: String? { "\(radarPeople.count) people open to plans around you" }
    var showNotificationIndicator: Bool { true }
    var trailingActions: AnyView? { nil }
    
    // MARK: - Published State
    @Published var radarPeople: [RadarPerson] = []
    @Published var interestCategories: [InterestCategory] = []
    @Published var selectedCategory: String = AppStrings.Discovery.Categories.coffee
    @Published var selectedTabIndex: Int = 0
    
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
        let colors: [Color] = [.brandPrimary, .brandPurple, .brandSecondary, .brandPurple, .brandPrimary, .brandSecondary]
        
        self.radarPeople = zip(AppConstants.MockData.radarInitials, zip(AppConstants.MockData.radarDistances, AppConstants.MockData.radarAngles)).enumerated().map { i, data in
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
    }
}

// MARK: - Supporting Models
struct InterestCategory: Identifiable {
    let id: String
    let label: String
    let icon: String
    let count: Int
}
