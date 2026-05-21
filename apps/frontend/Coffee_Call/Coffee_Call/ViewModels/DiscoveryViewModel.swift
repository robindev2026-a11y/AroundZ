import SwiftUI
import Combine

protocol DiscoveryServiceProtocol {
    func fetchInterestCategories() -> [InterestCategory]
    func fetchRadarPeople() -> [RadarPerson]
    var onUpdate: (() -> Void)? { get set }
}

class MockDiscoveryService: DiscoveryServiceProtocol {
    var onUpdate: (() -> Void)? = nil
    
    func fetchInterestCategories() -> [InterestCategory] {
        [
            InterestCategory(id: "Coffee", label: AppStrings.Discovery.Categories.coffee, icon: AppIcons.coffee, count: 3, color: .brandPrimary),
            InterestCategory(id: "Walks",  label: AppStrings.Discovery.Categories.walks,  icon: AppIcons.walk,   count: 4, color: .brandPrimary),
            InterestCategory(id: "Movies", label: AppStrings.Discovery.Categories.movies, icon: AppIcons.movie,  count: 2, color: .brandPurple),
            InterestCategory(id: "Food",   label: AppStrings.Discovery.Categories.food,   icon: AppIcons.food,   count: 5, color: .brandSecondary),
            InterestCategory(id: "Music",  label: AppStrings.Discovery.Categories.music,  icon: "music.note",    count: 3, color: .brandSecondary),
            InterestCategory(id: "Gaming", label: AppStrings.Discovery.Categories.gaming, icon: AppIcons.games,   count: 2, color: .brandSecondary),
            InterestCategory(id: "Books",  label: "Books",                                icon: "book",          count: 2, color: .brandPrimary),
            InterestCategory(id: "Workout",label: "Workout",                               icon: "dumbbell.fill", count: 4, color: .brandPurple)
        ]
    }
    
    func fetchRadarPeople() -> [RadarPerson] {
        [
            RadarPerson(initials: "LM", name: "Liam M.", color: .brandPrimary, distance: 0.75, angle: 110, hasPresence: true, interests: ["Coffee", "Walks"]),
            RadarPerson(initials: "DK", name: "David K.", color: .brandSecondary, distance: 0.45, angle: 195, hasPresence: true, interests: ["Food", "Gaming"]),
            RadarPerson(initials: "NP", name: "Neha P.", color: .brandPrimary, distance: 0.85, angle: 250, hasPresence: true, interests: ["Movies", "Music"]),
            RadarPerson(initials: "MR", name: "Maya R.", color: .brandPurple, distance: 0.65, angle: 40, hasPresence: true, interests: ["Books", "Study"]),
            RadarPerson(initials: "AL", name: "Alex L.", color: .brandPurple, distance: 0.85, angle: 320, hasPresence: true, interests: ["Workout", "Food"])
        ]
    }
}

class DiscoveryViewModel: ObservableObject {
    @Published var interestCategories: [InterestCategory] = []
    @Published var radarPeople: [RadarPerson] = []
    @Published var isScanning: Bool = false
    
    private var service: DiscoveryServiceProtocol
    
    // Header Strings (Using AppStrings)
    let title = AppStrings.Discovery.title
    let subtitle = AppStrings.Discovery.subtitleDefault
    
    // Context Card Strings (Using AppStrings)
    let contextTitle = AppStrings.Discovery.driftsForming
    let contextBody = AppStrings.Discovery.driftsFormingSub
    let contextCTA = AppStrings.Discovery.seeNearbyDrifts

    init(service: DiscoveryServiceProtocol? = nil) {
        if let service = service {
            self.service = service
        } else {
            let isFirebaseEnabled = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist") != nil
            self.service = isFirebaseEnabled ? FirebaseDiscoveryService() : MockDiscoveryService()
        }
        self.service.onUpdate = { [weak self] in
            DispatchQueue.main.async {
                self?.loadData()
            }
        }
        loadData()
    }
    
    func loadData() {
        self.interestCategories = service.fetchInterestCategories()
        self.radarPeople = service.fetchRadarPeople()
    }
    
    func refreshNearby() {
        guard !isScanning else { return }
        isScanning = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self] in
            self?.isScanning = false
        }
    }
}
