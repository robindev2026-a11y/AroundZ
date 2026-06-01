import Foundation
import SwiftUI

struct Drift: Identifiable, Codable {
    var id: UUID = UUID()
    let title: String
    let description: String
    let location: String
    let meetingPoint: String
    let time: String
    let endTime: String
    let date: String
    var distance: Double // km
    var status: DriftStatus
    let category: DriftCategory
    let hook: String?
    var host: Host
    var peopleGoing: Int
    var spotsLeft: Int?
    let capacity: Int
    let vibeTags: [String]
    let whatToBring: [String]
    let notes: String?
    var participantInitials: [String]
    var participantIds: [String]?
    let imageUrl: String?
    var pendingRequests: [JoinRequest] = []
    var isMine: Bool = false
    var lastMessage: String? = nil
    var lastMessageTime: String? = nil
    var unreadCount: Int = 0
    let latitude: Double?
    let longitude: Double?
    let joinMode: JoinMode
    
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
        participantIds: [String]? = nil,
        imageUrl: String? = nil,
        pendingRequests: [JoinRequest] = [],
        isMine: Bool = false,
        lastMessage: String? = nil,
        lastMessageTime: String? = nil,
        unreadCount: Int = 0,
        latitude: Double? = nil,
        longitude: Double? = nil,
        joinMode: JoinMode = .open
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
        self.notes = notes
        self.participantInitials = participantInitials
        self.participantIds = participantIds
        self.imageUrl = imageUrl
        self.pendingRequests = pendingRequests
        self.isMine = isMine
        self.lastMessage = lastMessage
        self.lastMessageTime = lastMessageTime
        self.unreadCount = unreadCount
        self.latitude = latitude
        self.longitude = longitude
        self.joinMode = joinMode
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
    let firestoreUID: String
    
    init(
        id: UUID = UUID(),
        name: String,
        role: String,
        imageUrl: String?,
        isVerified: Bool,
        hostedCount: Int? = nil,
        joinedCount: Int? = nil,
        completedCount: Int? = nil,
        verified: Bool? = nil,
        otherActiveDrifts: [Drift] = [],
        pastDrifts: [String]? = nil,
        interests: [String]? = nil,
        firestoreUID: String = ""
    ) {
        self.id = id
        self.name = name
        self.role = role
        self.imageUrl = imageUrl
        self.isVerified = isVerified
        
        let isFirebase = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist") != nil
        
        self.hostedCount = hostedCount ?? (isFirebase ? 0 : 4)
        self.joinedCount = joinedCount ?? (isFirebase ? 0 : 12)
        self.completedCount = completedCount ?? (isFirebase ? 0 : 16)
        self.verified = verified ?? (isFirebase ? false : true)
        self.otherActiveDrifts = otherActiveDrifts
        self.pastDrifts = pastDrifts ?? (isFirebase ? [] : ["Walk in Indiranagar", "Coffee chat"])
        self.interests = interests ?? (isFirebase ? [] : ["Walks", "Coffee", "Movies"])
        self.firestoreUID = firestoreUID
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

// MARK: - Core Domain Enums
public enum ActivityType: String, CaseIterable, Identifiable {
    case coffee, walk, food, movie, study,
         fitness, games, music, sports, drinks, custom
    public var id: String { rawValue }
}

public enum TimeOption: String, CaseIterable, Identifiable {
    case now, in30Mins, tonight, tomorrow, custom
    public var id: String { rawValue }
}

public enum CapacityOption: String, CaseIterable, Identifiable {
    case one, three, five, eightPlus
    public var id: String { rawValue }
    public var value: Int {
        switch self {
        case .one: return 1
        case .three: return 3
        case .five: return 5
        case .eightPlus: return 8
        }
    }
}

public enum VibeOption: String, CaseIterable, Identifiable {
    case casual, chill, friendly, focused, adventurous, social
    public var id: String { rawValue }
}

public enum JoinMode: String, CaseIterable, Identifiable,Codable {
    case open, approval
    public var id: String { rawValue }
}

// MARK: - UI Extensions

extension VibeOption {
    var title: String {
        switch self {
        case .casual:       return AppStrings.Create.Vibe.casual
        case .chill:        return AppStrings.Create.Vibe.chill
        case .friendly:     return AppStrings.Create.Vibe.friendly
        case .focused:      return AppStrings.Create.Vibe.focused
        case .adventurous:  return AppStrings.Create.Vibe.adventurous
        case .social:       return AppStrings.Create.Vibe.social
        }
    }

    var icon: String {
        switch self {
        case .casual:       return "leaf"
        case .chill:        return "snowflake"
        case .friendly:     return "hand.wave"
        case .focused:      return "target"
        case .adventurous:  return "globe"
        case .social:       return "person.2"
        }
    }

    var tint: Color {
        switch self {
        case .casual, .chill:          return .brandSecondary
        case .friendly, .social:       return .brandPrimary
        case .focused, .adventurous:   return .brandPurple
        }
    }
}

extension ActivityType {
    var title: String {
        switch self {
        case .coffee:      return AppStrings.Create.Activity.coffee
        case .walk:        return AppStrings.Create.Activity.walk
        case .food:        return AppStrings.Create.Activity.food
        case .movie:       return AppStrings.Create.Activity.movie
        case .study:       return AppStrings.Create.Activity.study
        case .fitness:     return AppStrings.Create.Activity.fitness
        case .games:       return AppStrings.Create.Activity.games
        case .music:       return AppStrings.Create.Activity.music
        case .sports:      return AppStrings.Create.Activity.sports
        case .drinks:      return AppStrings.Create.Activity.drinks
        case .custom:      return AppStrings.Create.Activity.custom
        }
    }

    var iconName: String {
        switch self {
        case .coffee:      return AppIcons.coffee
        case .walk:        return AppIcons.walk
        case .food:        return AppIcons.food
        case .movie:       return AppIcons.movie
        case .study:       return AppIcons.study
        case .fitness:     return AppIcons.fitness
        case .games:       return AppIcons.games
        case .music:       return AppIcons.music
        case .sports:      return AppIcons.sports
        case .drinks:      return AppIcons.drinks
        case .custom:      return AppIcons.custom
        }
    }

    var tint: Color {
        switch self {
        case .coffee, .walk, .fitness:
            return .brandPrimary
        case .food, .drinks:
            return .brandSecondary
        case .movie, .music, .games, .sports:
            return .brandPurple
        case .study, .custom:
            return .textPrimary
        }
    }
}

extension TimeOption {
    var title: String {
        switch self {
        case .now: return AppStrings.Create.Time.now
        case .in30Mins: return AppStrings.Create.Time.in30Mins
        case .tonight: return AppStrings.Create.Time.tonight
        case .tomorrow: return AppStrings.Create.Time.tomorrow
        case .custom: return AppStrings.Create.Time.custom
        }
    }

    var icon: String {
        switch self {
        case .now: return AppIcons.bolt
        case .in30Mins: return AppIcons.clock
        case .tonight: return AppIcons.moon
        case .tomorrow: return AppIcons.calendar
        case .custom: return AppIcons.ellipsis
        }
    }
}
