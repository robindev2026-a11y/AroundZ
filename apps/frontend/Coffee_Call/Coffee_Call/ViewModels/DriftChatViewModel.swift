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
        // Mock system messages
        systemMessages = [
            SystemMessage(content: "Arjun (Host) created this Drift", icon: AppIcons.person, timestamp: Date().addingTimeInterval(-3600)),
            SystemMessage(content: "Maya joined the Drift", icon: AppIcons.verified, timestamp: Date().addingTimeInterval(-3000)),
            SystemMessage(content: "Drift starts in 30 mins", icon: AppIcons.clockFill, timestamp: Date().addingTimeInterval(-2400))
        ]
        
        // Mock chat messages
        messages = [
            ChatMessage(senderId: "host_1", senderName: "Arjun (Host)", senderInitials: "AR", content: "Hi everyone! Looking forward to a relaxing evening walk. See you there! 🌿", timestamp: Date().addingTimeInterval(-1800), isSelf: false),
            ChatMessage(senderId: "user_2", senderName: "Sneha R.", senderInitials: "SR", content: "Excited to join! I'll be there.", timestamp: Date().addingTimeInterval(-1500), isSelf: false),
            ChatMessage(senderId: "user_3", senderName: "Karthik M.", senderInitials: "KM", content: "I might be a few minutes late. See you soon!", timestamp: Date().addingTimeInterval(-1200), isSelf: true)
        ]
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
