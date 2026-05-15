import Foundation
import SwiftUI

struct ChatMessage: Identifiable, Hashable {
    let id = UUID()
    let senderId: String
    let senderName: String
    let senderInitials: String
    let content: String
    let timestamp: Date
    let isSelf: Bool
    var status: MessageStatus = .sent
    let type: MessageType = .text
}

enum MessageStatus: Hashable {
    case sending, sent, failed
}

enum MessageType: Hashable {
    case text, system
}

struct SystemMessage: Identifiable, Hashable {
    let id = UUID()
    let content: String
    let icon: String?
    let timestamp: Date
}
