import SwiftUI
import Combine

struct DriftChatThreadContext {
    let systemMessages: [SystemMessage]
    let messages: [ChatMessage]
    let participants: [ParticipantInfo]
}

protocol DriftChatThreadServiceProtocol {
    func loadThread(for drift: Drift) -> DriftChatThreadContext
}

struct MockDriftChatThreadService: DriftChatThreadServiceProtocol {
    func loadThread(for drift: Drift) -> DriftChatThreadContext {
        DriftChatThreadContext(
            systemMessages: AppConstants.MockData.chatSystemMessages,
            messages: AppConstants.MockData.chatHistoryMessages,
            participants: AppConstants.MockData.chatParticipants
        )
    }
}

class DriftChatViewModel: ObservableObject {
    @Published var drift: Drift
    @Published var messages: [ChatMessage] = []
    @Published var systemMessages: [SystemMessage] = []
    @Published var participants: [ParticipantInfo] = []
    @Published var messageText: String = ""
    @Published var isSending = false
    
    private let threadService: DriftChatThreadServiceProtocol
    
    init(
        drift: Drift,
        threadService: DriftChatThreadServiceProtocol = MockDriftChatThreadService()
    ) {
        self.drift = drift
        self.threadService = threadService
        loadThread()
    }
    
    func loadThread() {
        let thread = threadService.loadThread(for: drift)
        systemMessages = thread.systemMessages
        messages = thread.messages
        participants = thread.participants
    }
    
    func sendMessage() {
        let trimmedMessage = messageText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedMessage.isEmpty else { return }
        
        let newMessage = ChatMessage(
            senderId: "self",
            senderName: "You",
            senderInitials: "ME",
            content: trimmedMessage,
            timestamp: Date(),
            isSelf: true,
            status: .sent,
            type: .text
        )
        
        messages.append(newMessage)
        messageText = ""
    }
    
    func sendImageMessage(image: UIImage) {
        let newMessage = ChatMessage(
            senderId: "self",
            senderName: "You",
            senderInitials: "ME",
            content: "Sent an image",
            timestamp: Date(),
            isSelf: true,
            status: .sent,
            type: .image,
            attachmentImage: image
        )
        messages.append(newMessage)
    }
    
    func sendLocationMessage(locationName: String) {
        let newMessage = ChatMessage(
            senderId: "self",
            senderName: "You",
            senderInitials: "ME",
            content: locationName,
            timestamp: Date(),
            isSelf: true,
            status: .sent,
            type: .location,
            attachmentLocation: locationName
        )
        messages.append(newMessage)
    }
    
    func deleteMessage(_ message: ChatMessage) {
        messages.removeAll(where: { $0.id == message.id })
    }
}
