import Foundation

// MARK: - Activity Model

struct Activity: Identifiable {
    let id = UUID()
    let userName: String
    let userInitials: String
    let backgroundImageURL: String
    let title: String
    let category: String
    let distanceKm: Double
    let time: String
    let attendeeCount: Int
    let vibeTag: String
    let status: ActivityStatus
    var isJoined: Bool = false
    var isSaved: Bool = false
}

// MARK: - Activity Status

enum ActivityStatus: String {
    case startingSoon = "STARTING SOON"
    case happening   = "HAPPENING NOW"
    case later       = "LATER TODAY"
}
