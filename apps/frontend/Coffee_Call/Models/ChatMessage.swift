import Foundation
import SwiftUI

struct ChatMessage: Identifiable, Hashable {
    let id: UUID
    let senderId: String
    let senderName: String
    let senderInitials: String
    let content: String
    let timestamp: Date
    let isSelf: Bool
    var status: MessageStatus
    let type: MessageType
    let attachmentImage: UIImage?
    let attachmentLocation: String?
    
    init(
        id: UUID = UUID(),
        senderId: String,
        senderName: String,
        senderInitials: String,
        content: String,
        timestamp: Date,
        isSelf: Bool,
        status: MessageStatus = .sent,
        type: MessageType = .text,
        attachmentImage: UIImage? = nil,
        attachmentLocation: String? = nil
    ) {
        self.id = id
        self.senderId = senderId
        self.senderName = senderName
        self.senderInitials = senderInitials
        self.content = content
        self.timestamp = timestamp
        self.isSelf = isSelf
        self.status = status
        self.type = type
        self.attachmentImage = attachmentImage
        self.attachmentLocation = attachmentLocation
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: ChatMessage, rhs: ChatMessage) -> Bool {
        lhs.id == rhs.id
    }
}

enum MessageStatus: Hashable {
    case sending, sent, failed
}

enum MessageType: Hashable {
    case text, system, image, location
}

struct SystemMessage: Identifiable, Hashable {
    let id = UUID()
    let content: String
    let icon: String?
    let timestamp: Date
}
