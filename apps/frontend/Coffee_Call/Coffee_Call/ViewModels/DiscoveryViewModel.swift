import SwiftUI
import Combine

class DiscoveryViewModel: ObservableObject, CoffeeScreenConfiguration {
    // CoffeeScreenConfiguration Conformance
    var title: String { AppStrings.Discovery.title }
    var subtitle: String? { 
        isScanning ? AppStrings.Discovery.subtitleRefreshing : AppStrings.Discovery.subtitleDefault
    }
    var showNotificationIndicator: Bool { true }
    var trailingActions: AnyView? {
        AnyView(
            HStack(spacing: 12) {
                // Notification Bell (Trailing)
                Button(action: { /* Show Notifications */ }) {
                    ZStack {
                        Image(systemName: AppIcons.bell)
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.textPrimary)
                            .frame(width: 44, height: 44)
                            .background(Color.surfaceMain)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.appBorder.opacity(0.5), lineWidth: 1))
                        
                        // Notification Badge
                        Circle()
                            .fill(Color.brandPrimary)
                            .frame(width: 14, height: 14)
                            .overlay(
                                Text("3")
                                    .font(.system(size: 8, weight: .black))
                                    .foregroundColor(.white)
                            )
                            .offset(x: 12, y: -12)
                    }
                }
            }
        )
    }
    
    // MARK: - Published State
    @Published var radarPeople: [RadarPerson] = []
    @Published var interestCategories: [InterestCategory] = []
    @Published var selectedCategory: String = AppStrings.Discovery.Categories.coffee
    @Published var isScanning: Bool = false
    
    private var scanTask: AnyCancellable?
    
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
    
    func refreshNearby() {
        guard !isScanning else { return }
        
        isScanning = true
        
        // Lightweight 5-second scan simulation
        scanTask = Just(false)
            .delay(for: .seconds(5), scheduler: RunLoop.main)
            .sink { [weak self] _ in
                withAnimation {
                    self?.isScanning = false
                    self?.loadMockData()
                }
            }
    }
    
    // MARK: - Private Helpers
    private func loadMockData() {
        // Mock radar people with initials
        let mockInitials = ["NP", "AL", "DK", "MR", "LM"]
        let mockDistances = [0.6, 0.45, 0.35, 0.55, 0.7]
        let mockAngles = [160.0, 30.0, 210.0, 340.0, 240.0]
        let colors: [Color] = [.brandPrimary, .brandPurple, .brandSecondary, .brandPurple, .brandPrimary]
        
        self.radarPeople = zip(mockInitials, zip(mockDistances, mockAngles)).enumerated().map { i, data in
            let (initial, geo) = data
            return RadarPerson(
                initials: initial,
                color: colors[i % colors.count],
                distance: geo.0,
                angle: geo.1,
                hasPresence: true,
                imageUrl: nil
            )
        }
        
        // Mock interest categories
        self.interestCategories = [
            InterestCategory(id: "Coffee", label: AppStrings.Discovery.Categories.coffee, icon: AppIcons.coffee, count: 3),
            InterestCategory(id: "Walk",   label: AppStrings.Discovery.Categories.walks,  icon: AppIcons.walk,   count: 4),
            InterestCategory(id: "Movie",  label: AppStrings.Discovery.Categories.movies, icon: AppIcons.movie,  count: 2),
            InterestCategory(id: "Food",   label: AppStrings.Discovery.Categories.food,   icon: AppIcons.food,   count: 5),
            InterestCategory(id: "Study",  label: AppStrings.Discovery.Categories.study,  icon: AppIcons.briefcase, count: 1)
        ]
    }
}
