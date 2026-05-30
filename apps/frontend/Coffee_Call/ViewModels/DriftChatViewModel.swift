import SwiftUI
import Combine
import FirebaseCore
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

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
    private let driftsService: DriftsServiceProtocol
    private var listenerRegistration: ListenerRegistration?
    private var cancellables = Set<AnyCancellable>()
    
    private var isFirebaseEnabled: Bool {
        return Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist") != nil
    }
    
    init(
        drift: Drift,
        threadService: DriftChatThreadServiceProtocol? = nil,
        driftsService: DriftsServiceProtocol? = nil
    ) {
        self.drift = drift
        if let threadService = threadService {
            self.threadService = threadService
        } else {
            let isFirebase = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist") != nil
            self.threadService = isFirebase ? FirebaseChatService() : MockDriftChatThreadService()
        }
        
        if let driftsService = driftsService {
            self.driftsService = driftsService
        } else {
            let isFirebase = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist") != nil
            self.driftsService = isFirebase ? FirebaseDriftsService() : MockDriftsService()
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
        if isFirebaseEnabled {
            guard let currentUid = Auth.auth().currentUser?.uid else { return }
            let db = Firestore.firestore()
            let threadId = drift.id.uuidString
            
            // Get sender profile name
            db.collection("users").document(currentUid).getDocument { [weak self] document, error in
                guard let self = self else { return }
                let senderName = document?.data()?["name"] as? String ?? "You"
                
                // Compress and convert to data
                guard let data = image.jpegData(compressionQuality: 0.8) else { return }
                
                let storageRef = Storage.storage().reference()
                let photoId = UUID().uuidString
                let photoRef = storageRef.child("chat_attachments/\(threadId)/\(photoId).jpg")
                
                let metadata = StorageMetadata()
                metadata.contentType = "image/jpeg"
                
                photoRef.putData(data, metadata: metadata) { metadata, error in
                    if let error = error {
                        print("Failed to upload chat image: \(error.localizedDescription)")
                        return
                    }
                    
                    photoRef.downloadURL { url, error in
                        guard let downloadURL = url?.absoluteString, error == nil else {
                            print("Failed to get download URL for chat image")
                            return
                        }
                        
                        db.collection("messageThreads")
                            .document(threadId)
                            .collection("messages")
                            .addDocument(data: [
                                "senderId": currentUid,
                                "senderName": senderName,
                                "text": downloadURL,
                                "timestamp": FieldValue.serverTimestamp(),
                                "type": "image"
                            ])
                    }
                }
            }
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

    func leaveDrift(completion: @escaping (Bool) -> Void) {
        let userId = Auth.auth().currentUser?.uid ?? UIDevice.current.identifierForVendor?.uuidString ?? ""
        driftsService.leaveDrift(driftId: drift.id, userId: userId)
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: { completionResult in
                if case .failure(let error) = completionResult {
                    print("Error leaving drift: \(error)")
                    completion(false)
                }
            }, receiveValue: {
                completion(true)
            })
            .store(in: &cancellables)
    }

    func reportDrift(reason: String, completion: @escaping (Bool) -> Void) {
        driftsService.reportDrift(driftId: drift.id, reason: reason)
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: { completionResult in
                if case .failure(let error) = completionResult {
                    print("Error reporting drift: \(error)")
                    completion(false)
                }
            }, receiveValue: {
                completion(true)
            })
            .store(in: &cancellables)
    }

    func blockUser(name: String, completion: @escaping (Bool) -> Void) {
        var blocked = UserDefaults.standard.stringArray(forKey: "blocked_users") ?? []
        if !blocked.contains(name) {
            blocked.append(name)
            UserDefaults.standard.set(blocked, forKey: "blocked_users")
        }
        
        if isFirebaseEnabled, let currentUid = Auth.auth().currentUser?.uid {
            let db = Firestore.firestore()
            db.collection("users").document(currentUid).updateData([
                "blockedUsers": FieldValue.arrayUnion([name])
            ]) { error in
                DispatchQueue.main.async {
                    completion(error == nil)
                }
            }
        } else {
            DispatchQueue.main.async {
                completion(true)
            }
        }
    }
}
