import Foundation
import SwiftUI

struct Drift: Identifiable, Hashable, Codable {
    var id: UUID = UUID()
    let title: String
    let description: String
    let location: String
    let meetingPoint: String
    let time: String
    let endTime: String
    let date: String
    let distance: Double // km
    var status: DriftStatus
    let category: DriftCategory
    let hook: String?
    var host: Host
    var peopleGoing: Int
    var spotsLeft: Int?
    let capacity: Int
    let vibeTags: [String]
    let whatToBring: [String]
    let notes: String? = nil
    var participantInitials: [String]
    let imageUrl: String?
    var pendingRequests: [JoinRequest] = []
    var isMine: Bool = false
    var lastMessage: String? = nil
    var lastMessageTime: String? = nil
    var unreadCount: Int = 0
    
    init(
        id: UUID = UUID(),
        title: String,
        description: String,
        location: String,
        meetingPoint: String,
        time: String,
        endTime: String,
        date: String,
        distance: Double,
        status: DriftStatus,
        category: DriftCategory,
        hook: String? = nil,
        host: Host,
        peopleGoing: Int = 1,
        spotsLeft: Int? = nil,
        capacity: Int = 5,
        vibeTags: [String] = [],
        whatToBring: [String] = [],
        notes: String? = nil,
        participantInitials: [String] = [],
        imageUrl: String? = nil,
        pendingRequests: [JoinRequest] = [],
        isMine: Bool = false,
        lastMessage: String? = nil,
        lastMessageTime: String? = nil,
        unreadCount: Int = 0
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.location = location
        self.meetingPoint = meetingPoint
        self.time = time
        self.endTime = endTime
        self.date = date
        self.distance = distance
        self.status = status
        self.category = category
        self.hook = hook
        self.host = host
        self.peopleGoing = peopleGoing
        self.spotsLeft = spotsLeft
        self.capacity = capacity
        self.vibeTags = vibeTags
        self.whatToBring = whatToBring
        self.participantInitials = participantInitials
        self.imageUrl = imageUrl
        self.pendingRequests = pendingRequests
        self.isMine = isMine
        self.lastMessage = lastMessage
        self.lastMessageTime = lastMessageTime
        self.unreadCount = unreadCount
    }
    
    // Hashable conformance (synthesized)
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: Drift, rhs: Drift) -> Bool {
        lhs.id == rhs.id
    }
}

struct Host: Identifiable, Hashable, Codable {
    let id: UUID
    let name: String
    let role: String
    let imageUrl: String?
    let isVerified: Bool
    
    // Rich details for ISSUE-013 (organic trust metrics & history)
    let hostedCount: Int
    let joinedCount: Int
    let completedCount: Int
    let verified: Bool
    let otherActiveDrifts: [Drift]
    let pastDrifts: [String]
    let interests: [String]
    
    init(
        id: UUID = UUID(),
        name: String,
        role: String,
        imageUrl: String?,
        isVerified: Bool,
        hostedCount: Int = 4,
        joinedCount: Int = 12,
        completedCount: Int = 16,
        verified: Bool = true,
        otherActiveDrifts: [Drift] = [],
        pastDrifts: [String] = ["Walk in Indiranagar", "Coffee chat"],
        interests: [String] = ["Walks", "Coffee", "Movies"]
    ) {
        self.id = id
        self.name = name
        self.role = role
        self.imageUrl = imageUrl
        self.isVerified = isVerified
        self.hostedCount = hostedCount
        self.joinedCount = joinedCount
        self.completedCount = completedCount
        self.verified = verified
        self.otherActiveDrifts = otherActiveDrifts
        self.pastDrifts = pastDrifts
        self.interests = interests
    }
    
    var initials: String {
        name.components(separatedBy: " ")
            .compactMap { $0.first }
            .map { String($0) }
            .joined()
            .uppercased()
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: Host, rhs: Host) -> Bool {
        lhs.id == rhs.id
    }
}

enum DriftStatus: String, Hashable, Codable {
    case open = "OPEN"
    case startingSoon = "STARTING SOON"
    case tonight = "TONIGHT"
    case ended = "ENDED"
    
    var color: Color {
        switch self {
        case .open: return .brandPrimary
        case .startingSoon: return .brandPurple
        case .tonight: return .brandSecondary
        case .ended: return .textSecondary
        }
    }
}

enum DriftCategory: String, Hashable, CaseIterable, Codable {
    case coffee, walk, movie, food, study, gaming, music, yoga, event
    
    var icon: String {
        switch self {
        case .coffee: return AppIcons.coffee
        case .walk:   return AppIcons.walk
        case .movie:  return AppIcons.movie
        case .food:   return AppIcons.food
        case .study:  return "book"
        case .gaming: return "gamecontroller"
        case .music: return "music.note"
        case .yoga: return "dumbbell.fill"
        case .event: return AppIcons.calendar
        }
    }
    
    var color: Color {
        switch self {
        case .coffee: return .brandPrimary
        case .walk:   return .brandPurple
        case .movie:  return .brandPurple
        case .food:   return .brandSecondary
        case .study:  return .brandPrimary
        case .gaming: return .brandSecondary
        case .music: return .brandPurple
        case .yoga: return .brandPrimary
        case .event: return .brandSecondary
        }
    }
}

struct JoinRequest: Identifiable, Hashable, Codable {
    var id: UUID = UUID()
    let userId: String
    let userName: String
    let userInitials: String
    let userRole: String
    let message: String
    let timestamp: String

    init(
        id: UUID = UUID(),
        userId: String = "",
        userName: String,
        userInitials: String,
        userRole: String,
        message: String,
        timestamp: String
    ) {
        self.id = id
        self.userId = userId
        self.userName = userName
        self.userInitials = userInitials
        self.userRole = userRole
        self.message = message
        self.timestamp = timestamp
    }
}

struct ParticipantInfo: Identifiable, Hashable {
    let id = UUID()
    let initials: String
    let name: String
    let color: Color
    let isHost: Bool
    let isMe: Bool
}
