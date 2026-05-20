import Foundation
import SwiftUI
import FirebaseCore
import FirebaseAuth
import FirebaseFirestore

class FirebaseDiscoveryService: DiscoveryServiceProtocol {
    private var isFirebaseEnabled: Bool {
        return Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist") != nil
    }
    
    private var cachedPeople: [RadarPerson] = []
    private var cachedCategories: [InterestCategory] = []
    
    init() {
        if isFirebaseEnabled {
            setupListeners()
        }
    }
    
    private func setupListeners() {
        let db = Firestore.firestore()
        
        // Listen to active users in the same geohash area (10 km prefix bounds)
        // For MVP, listen to all active users updated in last 24h
        let oneDayAgo = Date().addingTimeInterval(-24 * 60 * 60)
        db.collection("users")
            .whereField("lastLocationUpdate", isGreaterThanOrEqualTo: Timestamp(date: oneDayAgo))
            .addSnapshotListener { [weak self] querySnapshot, error in
                guard let self = self, let documents = querySnapshot?.documents else { return }
                
                let currentUid = Auth.auth().currentUser?.uid
                var newPeople: [RadarPerson] = []
                var interestCounts: [String: Int] = [:]
                
                for doc in documents {
                    let userId = doc.documentID
                    if userId == currentUid { continue }
                    
                    let data = doc.data()
                    let name = data["name"] as? String ?? "Someone"
                    
                    // Construct initials from name
                    let nameParts = name.components(separatedBy: " ")
                    let initials = nameParts.compactMap { $0.first }.map { String($0) }.joined().uppercased()
                    
                    let interestTags = data["interestTags"] as? [String] ?? []
                    
                    // Keep track of counts
                    for interest in interestTags {
                        interestCounts[interest, default: 0] += 1
                    }
                    
                    // Approximate distance/angle for radar layout
                    let distance = data["distance"] as? Double ?? Double.random(in: 0.2...0.95)
                    let angle = data["angle"] as? Double ?? Double.random(in: 0...360)
                    
                    newPeople.append(
                        RadarPerson(
                            initials: initials,
                            name: name,
                            color: self.colorForInterests(interestTags),
                            distance: distance,
                            angle: angle,
                            hasPresence: true,
                            interests: interestTags
                        )
                    )
                }
                
                self.cachedPeople = newPeople
                
                // Update interest category counts based on active nearby users
                self.cachedCategories = [
                    InterestCategory(id: "Coffee", label: AppStrings.Discovery.Categories.coffee, icon: AppIcons.coffee, count: interestCounts["Coffee"] ?? 1, color: .brandPrimary),
                    InterestCategory(id: "Walks",  label: AppStrings.Discovery.Categories.walks,  icon: AppIcons.walk,   count: interestCounts["Walks"] ?? 2, color: .brandPrimary),
                    InterestCategory(id: "Movies", label: AppStrings.Discovery.Categories.movies, icon: AppIcons.movie,  count: interestCounts["Movies"] ?? 1, color: .brandPurple),
                    InterestCategory(id: "Food",   label: AppStrings.Discovery.Categories.food,   icon: AppIcons.food,   count: interestCounts["Food"] ?? 3, color: .brandSecondary),
                    InterestCategory(id: "Music",  label: AppStrings.Discovery.Categories.music,  icon: "music.note",    count: interestCounts["Music"] ?? 1, color: .brandSecondary),
                    InterestCategory(id: "Gaming", label: AppStrings.Discovery.Categories.gaming, icon: AppIcons.games,   count: interestCounts["Gaming"] ?? 1, color: .brandSecondary),
                    InterestCategory(id: "Books",  label: "Books",                                icon: "book",          count: interestCounts["Books"] ?? 1, color: .brandPrimary),
                    InterestCategory(id: "Workout",label: "Workout",                               icon: "dumbbell.fill", count: interestCounts["Workout"] ?? 2, color: .brandPurple)
                ]
            }
    }
    
    func fetchInterestCategories() -> [InterestCategory] {
        guard isFirebaseEnabled else {
            return MockDiscoveryService().fetchInterestCategories()
        }
        return cachedCategories.isEmpty ? MockDiscoveryService().fetchInterestCategories() : cachedCategories
    }
    
    func fetchRadarPeople() -> [RadarPerson] {
        guard isFirebaseEnabled else {
            return MockDiscoveryService().fetchRadarPeople()
        }
        return cachedPeople.isEmpty ? MockDiscoveryService().fetchRadarPeople() : cachedPeople
    }
    
    private func colorForInterests(_ interests: [String]) -> Color {
        if interests.contains("Coffee") || interests.contains("Books") {
            return .brandPrimary
        } else if interests.contains("Food") || interests.contains("Gaming") {
            return .brandSecondary
        } else {
            return .brandPurple
        }
    }
}
