import SwiftUI
import Combine
import FirebaseCore
import FirebaseAuth
import FirebaseFirestore

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
    private var listenerRegistration: ListenerRegistration?
    
    private var isFirebaseEnabled: Bool {
        return Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist") != nil
    }
    
    init(
        drift: Drift,
        threadService: DriftChatThreadServiceProtocol? = nil
    ) {
        self.drift = drift
        if let threadService = threadService {
            self.threadService = threadService
        } else {
            let isFirebase = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist") != nil
            self.threadService = isFirebase ? FirebaseChatService() : MockDriftChatThreadService()
        }
        loadThread()
    }
    
    deinit {
        listenerRegistration?.remove()
    }
    
    func loadThread() {
        let thread = threadService.loadThread(for: drift)
        systemMessages = thread.systemMessages
        messages = thread.messages
        participants = thread.participants
        
        if isFirebaseEnabled {
            setupFirebaseListener()
        }
    }
    
    private func setupFirebaseListener() {
        let db = Firestore.firestore()
        let threadId = drift.id.uuidString
        
        // Listen to active message thread messages
        listenerRegistration = db.collection("messageThreads")
            .document(threadId)
            .collection("messages")
            .order(by: "timestamp", descending: false)
            .addSnapshotListener { [weak self] querySnapshot, error in
                guard let self = self, let documents = querySnapshot?.documents else { return }
                
                let currentUid = Auth.auth().currentUser?.uid
                let fetchedMessages: [ChatMessage] = documents.compactMap { doc -> ChatMessage? in
                    let data = doc.data()
                    let senderId = data["senderId"] as? String ?? ""
                    let senderName = data["senderName"] as? String ?? "User"
                    let text = data["text"] as? String ?? ""
                    
                    let timestamp: Date
                    if let ts = data["timestamp"] as? Timestamp {
                        timestamp = ts.dateValue()
                    } else {
                        timestamp = Date()
                    }
                    
                    let typeStr = data["type"] as? String ?? "text"
                    let type: MessageType
                    switch typeStr {
                    case "text": type = .text
                    case "image": type = .image
                    case "location": type = .location
                    default: type = .text
                    }
                    
                    let senderInitials = senderName.components(separatedBy: " ")
                        .compactMap { $0.first }.map { String($0) }.joined().uppercased()
                        
                    return ChatMessage(
                        id: UUID.fromString(doc.documentID),
                        senderId: senderId,
                        senderName: senderName,
                        senderInitials: senderInitials,
                        content: text,
                        timestamp: timestamp,
                        isSelf: senderId == currentUid,
                        status: .sent,
                        type: type
                    )
                }
                
                DispatchQueue.main.async {
                    self.messages = fetchedMessages
                }
            }
    }
    
    func sendMessage() {
        let trimmedMessage = messageText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedMessage.isEmpty else { return }
        
        if isFirebaseEnabled {
            guard let currentUid = Auth.auth().currentUser?.uid else { return }
            let db = Firestore.firestore()
            let threadId = drift.id.uuidString
            
            isSending = true
            
            // Get user profile name
            db.collection("users").document(currentUid).getDocument { [weak self] document, error in
                guard let self = self else { return }
                let senderName = document?.data()?["name"] as? String ?? "You"
                
                db.collection("messageThreads")
                    .document(threadId)
                    .collection("messages")
                    .addDocument(data: [
                        "senderId": currentUid,
                        "senderName": senderName,
                        "text": trimmedMessage,
                        "timestamp": FieldValue.serverTimestamp(),
                        "type": "text"
                    ]) { error in
                        DispatchQueue.main.async {
                            self.isSending = false
                            if error == nil {
                                self.messageText = ""
                            }
                        }
                    }
            }
            return
        }
        
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
        // In real Firebase, we would upload to Firebase Storage, get URL, and send a message.
        // For MVP frontend code integration:
        if isFirebaseEnabled {
            // Placeholder: upload logic or mock image send
            let trimmedMessage = "[Image attachment]"
            guard let currentUid = Auth.auth().currentUser?.uid else { return }
            let db = Firestore.firestore()
            let threadId = drift.id.uuidString
            
            db.collection("messageThreads")
                .document(threadId)
                .collection("messages")
                .addDocument(data: [
                    "senderId": currentUid,
                    "senderName": "You",
                    "text": trimmedMessage,
                    "timestamp": FieldValue.serverTimestamp(),
                    "type": "image"
                ])
            return
        }
        
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
        if isFirebaseEnabled {
            guard let currentUid = Auth.auth().currentUser?.uid else { return }
            let db = Firestore.firestore()
            let threadId = drift.id.uuidString
            
            db.collection("messageThreads")
                .document(threadId)
                .collection("messages")
                .addDocument(data: [
                    "senderId": currentUid,
                    "senderName": "You",
                    "text": locationName,
                    "timestamp": FieldValue.serverTimestamp(),
                    "type": "location"
                ])
            return
        }
        
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
        if isFirebaseEnabled {
            let db = Firestore.firestore()
            let threadId = drift.id.uuidString
            let messageId = message.id.uuidString
            db.collection("messageThreads").document(threadId).collection("messages").document(messageId).delete()
            return
        }
        messages.removeAll(where: { $0.id == message.id })
    }
}
