import SwiftUI
import Combine

class DriftChatViewModel: ObservableObject {
    @Published var drift: Drift
    @Published var messages: [ChatMessage] = []
    @Published var systemMessages: [SystemMessage] = []
    @Published var messageText: String = ""
    @Published var isSending = false
    
    init(drift: Drift) {
        self.drift = drift
        loadMockHistory()
    }
    
    func loadMockHistory() {
        systemMessages = AppConstants.MockData.chatSystemMessages
        messages = AppConstants.MockData.chatHistoryMessages
    }
    
    func sendMessage() {
        guard !messageText.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        
        let newMessage = ChatMessage(
            senderId: "self",
            senderName: "You",
            senderInitials: "ME",
            content: messageText,
            timestamp: Date(),
            isSelf: true,
            status: .sent
        )
        
        messages.append(newMessage)
        messageText = ""
    }
}
