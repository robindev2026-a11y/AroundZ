import Foundation
import SwiftUI

struct Drift: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let description: String
    let location: String
    let meetingPoint: String
    let time: String
    let endTime: String
    let date: String
    let distance: Double // km
    let status: DriftStatus
    let category: DriftCategory
    let hook: String?
    let host: Host
    let peopleGoing: Int
    let spotsLeft: Int?
    let capacity: Int
    let vibeTags: [String]
    let whatToBring: [String]
    let notes: String?
    var participantInitials: [String]
    let imageUrl: String?
    var pendingRequests: [JoinRequest] = []
    var isMine: Bool = false
    var lastMessage: String? = nil
    var lastMessageTime: String? = nil
    var unreadCount: Int = 0
    
    // Hashable conformance (synthesized)
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: Drift, rhs: Drift) -> Bool {
        lhs.id == rhs.id
    }
}

struct Host: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let role: String
    let imageUrl: String?
    let isVerified: Bool
    
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

enum DriftStatus: String, Hashable {
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

enum DriftCategory: String, Hashable, CaseIterable {
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

struct JoinRequest: Identifiable, Hashable {
    let id = UUID()
    let userName: String
    let userInitials: String
    let userRole: String
    let message: String
    let timestamp: String
}

struct ParticipantInfo: Identifiable, Hashable {
    let id = UUID()
    let initials: String
    let name: String
    let color: Color
    let isHost: Bool
    let isMe: Bool
}
