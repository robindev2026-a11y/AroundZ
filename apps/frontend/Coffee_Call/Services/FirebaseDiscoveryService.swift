import Foundation
import SwiftUI
import FirebaseCore
import FirebaseAuth
import FirebaseFirestore
import CoreLocation


class FirebaseDiscoveryService: DiscoveryServiceProtocol {
    private let radarSnapshotLimit = 40
    private let radarFreshnessInterval: TimeInterval = 24 * 60 * 60

    private var isFirebaseEnabled: Bool {
        return Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist") != nil
    }

    private var cachedPeople: [RadarPerson] = []
    private var cachedCategories: [InterestCategory] = []

    func refreshRadarSnapshot(completion: @escaping () -> Void) {
        guard isFirebaseEnabled else {
            completion()
            return
        }

        let db = Firestore.firestore()
        let oneDayAgo = Date().addingTimeInterval(-radarFreshnessInterval)
        db.collection("users")
            .whereField("lastLocationUpdate", isGreaterThanOrEqualTo: Timestamp(date: oneDayAgo))
            .order(by: "lastLocationUpdate", descending: true)
            .limit(to: radarSnapshotLimit)
            .getDocuments { [weak self] querySnapshot, error in
                if let error = error {
                    print("FirebaseDiscoveryService: Error fetching radar snapshot: \(error.localizedDescription)")
                } else if let documents = querySnapshot?.documents {
                    self?.applyRadarDocuments(documents)
                }
                DispatchQueue.main.async {
                    completion()
                }
            }
    }

    func fetchInterestCategories() -> [InterestCategory] {
        guard isFirebaseEnabled else {
            return MockDiscoveryService().fetchInterestCategories()
        }
        return cachedCategories.isEmpty ? makeInterestCategories(from: [:]) : cachedCategories
    }

    func fetchRadarPeople() -> [RadarPerson] {
        guard isFirebaseEnabled else {
            return MockDiscoveryService().fetchRadarPeople()
        }
        return cachedPeople
    }

    private func applyRadarDocuments(_ documents: [QueryDocumentSnapshot]) {
        let currentUid = Auth.auth().currentUser?.uid
        var newPeople: [RadarPerson] = []
        var interestCounts: [String: Int] = [:]
        
        let userLocation = PermissionsManager.shared.currentLocation

        for doc in documents {
            let userId = doc.documentID
            if userId == currentUid { continue }

            let data = doc.data()
            let isVisible = data["isRadarVisible"] as? Bool ?? true
            if !isVisible { continue }

            let name = data["name"] as? String ?? "Someone"
            let initials = initials(from: name)
            let interestTags = data["interestTags"] as? [String] ?? []

            for interest in interestTags {
                interestCounts[interest, default: 0] += 1
            }

            let fallbackPosition = fallbackRadarPosition(for: userId)
            var distance = data["distance"] as? Double ?? fallbackPosition.distance
            let angle = data["angle"] as? Double ?? fallbackPosition.angle

            if let userLoc = userLocation,
               let otherLocGeo = data["lastLocation"] as? GeoPoint {
                let userCLLoc = CLLocation(latitude: userLoc.coordinate.latitude, longitude: userLoc.coordinate.longitude)
                let otherCLLoc = CLLocation(latitude: otherLocGeo.latitude, longitude: otherLocGeo.longitude)
                let actualDistanceKm = userCLLoc.distance(from: otherCLLoc) / 1000.0

                if actualDistanceKm > 10.0 {
                    continue
                }

                // Map 0..10 km to a normalized radar circle radius (0.2..0.95)
                distance = 0.2 + (actualDistanceKm / 10.0) * 0.75
            } else if userLocation != nil {
                // If user location is available but other user doesn't have a location, exclude them
                continue
            }

            newPeople.append(
                RadarPerson(
                    initials: initials,
                    name: name,
                    color: colorForInterests(interestTags),
                    distance: distance,
                    angle: angle,
                    hasPresence: true,
                    interests: interestTags
                )
            )
        }

        cachedPeople = newPeople
        cachedCategories = makeInterestCategories(from: interestCounts)
    }

    private func makeInterestCategories(from interestCounts: [String: Int]) -> [InterestCategory] {
        [
            InterestCategory(id: "Coffee", label: AppStrings.Discovery.Categories.coffee, icon: AppIcons.coffee, count: interestCounts["Coffee"] ?? 0, color: .brandPrimary),
            InterestCategory(id: "Walks",  label: AppStrings.Discovery.Categories.walks,  icon: AppIcons.walk,   count: interestCounts["Walks"] ?? 0, color: .brandPrimary),
            InterestCategory(id: "Movies", label: AppStrings.Discovery.Categories.movies, icon: AppIcons.movie,  count: interestCounts["Movies"] ?? 0, color: .brandPurple),
            InterestCategory(id: "Food",   label: AppStrings.Discovery.Categories.food,   icon: AppIcons.food,   count: interestCounts["Food"] ?? 0, color: .brandSecondary),
            InterestCategory(id: "Music",  label: AppStrings.Discovery.Categories.music,  icon: "music.note",    count: interestCounts["Music"] ?? 0, color: .brandSecondary),
            InterestCategory(id: "Gaming", label: AppStrings.Discovery.Categories.gaming, icon: AppIcons.games,   count: interestCounts["Gaming"] ?? 0, color: .brandSecondary),
            InterestCategory(id: "Books",  label: "Books",                                icon: "book",          count: interestCounts["Books"] ?? 0, color: .brandPrimary),
            InterestCategory(id: "Workout",label: "Workout",                               icon: "dumbbell.fill", count: interestCounts["Workout"] ?? 0, color: .brandPurple)
        ]
    }

    private func initials(from name: String) -> String {
        let initials = name
            .components(separatedBy: " ")
            .compactMap { $0.first }
            .map { String($0) }
            .joined()
            .uppercased()
        return initials.isEmpty ? "?" : initials
    }

    private func fallbackRadarPosition(for userId: String) -> (distance: Double, angle: Double) {
        var hash: UInt32 = 2_166_136_261
        for scalar in userId.unicodeScalars {
            hash = (hash ^ UInt32(scalar.value)) &* 16_777_619
        }

        let distance = 0.2 + Double(hash % 75) / 100.0
        let angle = Double((hash / 75) % 360)
        return (distance, angle)
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
