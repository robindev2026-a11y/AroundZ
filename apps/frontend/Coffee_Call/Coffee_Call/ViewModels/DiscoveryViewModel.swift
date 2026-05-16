import SwiftUI
import Combine

class DiscoveryViewModel: ObservableObject {
    @Published var interestCategories: [InterestCategory] = []
    @Published var radarPeople: [RadarPerson] = []
    @Published var isScanning: Bool = false
    
    // Header Strings
    let title = "Around"
    let subtitle = "Plans forming nearby"
    
    // Context Card Strings
    let contextTitle = "Nearby Drifts are forming"
    let contextBody = "Join one or create your own."
    let contextCTA = "See nearby Drifts"

    init() {
        loadData()
    }
    
    func loadData() {
        // Target Interest Categories (4 columns x 2 rows = 8 items)
        self.interestCategories = [
            InterestCategory(id: "Coffee", label: "Coffee", icon: AppIcons.coffee, count: 3, color: .brandPrimary),
            InterestCategory(id: "Walks",  label: "Walks",  icon: AppIcons.walk,   count: 4, color: Color(hex: "#4CAF50")),
            InterestCategory(id: "Movies", label: "Movies", icon: AppIcons.movie,  count: 2, color: .brandPurple),
            InterestCategory(id: "Food",   label: "Food",   icon: AppIcons.food,   count: 5, color: .brandSecondary),
            InterestCategory(id: "Music",  label: "Music",  icon: "music.note",    count: 3, color: Color(hex: "#FF4081")),
            InterestCategory(id: "Gaming", label: "Gaming", icon: AppIcons.games,   count: 2, color: Color(hex: "#FFC107")),
            InterestCategory(id: "Books",  label: "Books",  icon: "book",          count: 2, color: Color(hex: "#2196F3")),
            InterestCategory(id: "Workout",label: "Workout",icon: "dumbbell.fill", count: 4, color: .brandPurple)
        ]
        
        // Target Radar People with names and interests
        self.radarPeople = [
            RadarPerson(initials: "LM", name: "Liam M.", color: .brandPrimary, distance: 0.75, angle: 110, hasPresence: true, interests: ["Coffee", "Walks"]),
            RadarPerson(initials: "DK", name: "David K.", color: .brandSecondary, distance: 0.45, angle: 195, hasPresence: true, interests: ["Food", "Gaming"]),
            RadarPerson(initials: "NP", name: "Neha P.", color: .brandPrimary, distance: 0.85, angle: 250, hasPresence: true, interests: ["Movies", "Music"]),
            RadarPerson(initials: "MR", name: "Maya R.", color: .brandPurple, distance: 0.65, angle: 40, hasPresence: true, interests: ["Books", "Study"]),
            RadarPerson(initials: "AL", name: "Alex L.", color: .brandPurple, distance: 0.85, angle: 320, hasPresence: true, interests: ["Workout", "Food"])
        ]
    }
    
    func refreshNearby() {
        guard !isScanning else { return }
        isScanning = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.isScanning = false
        }
    }
}
