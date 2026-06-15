import Foundation
import Combine
import FirebaseCore
import FirebaseAuth
import FirebaseFirestore

class FirebaseChatService: ChatServiceProtocol, DriftChatThreadServiceProtocol {
    private var isFirebaseEnabled: Bool {
        return Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist") != nil
    }

    private var cachedChats: [Drift] = []
    /// Closure called on the main queue whenever Firestore delivers new chat data.
    var onUpdate: (([Drift]) -> Void)?

    init() {
        if isFirebaseEnabled {
            setupChatsListener()
        }
    }
    
    private func setupChatsListener() {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore()
        
        // Listen to threads where the current user is a participant
        db.collection("messageThreads")
            .whereField("participants", arrayContains: currentUid)
            .addSnapshotListener { [weak self] querySnapshot, error in
                guard let self = self, let documents = querySnapshot?.documents else { return }
                
                var chats: [Drift] = []
                let dispatchGroup = DispatchGroup()
                
                for doc in documents {
                    let postId = doc.documentID
                    let threadData = doc.data()
                    
                    // Fetch the corresponding Drift Post details to construct the preview card
                    dispatchGroup.enter()
                    db.collection("posts").document(postId).getDocument { postDocSnapshot, postError in
                        defer { dispatchGroup.leave() }
                        
                        guard let postDoc = postDocSnapshot, postDoc.exists, let data = postDoc.data() else {
                            return
                        }
                        
                        let id = UUID.fromString(postId)
                        let title = data["title"] as? String ?? ""
                        let description = data["description"] as? String ?? ""
                        let location = data["location"] as? String ?? ""
                        let meetingPoint = data["meetingPoint"] as? String ?? ""
                        let time = data["time"] as? String ?? ""
                        let endTime = data["endTime"] as? String ?? ""
                        let date = data["date"] as? String ?? ""
                        let distance = data["distance"] as? Double ?? 1.0
                        
                        let statusStr = data["status"] as? String ?? "OPEN"
                        let status: DriftStatus
                        switch statusStr.uppercased() {
                        case "OPEN": status = .open
                        case "STARTING SOON": status = .startingSoon
                        case "TONIGHT": status = .tonight
                        case "ENDED": status = .ended
                        default: status = .open
                        }
                        
                        let categoryStr = data["category"] as? String ?? "coffee"
                        let category = DriftCategory(rawValue: categoryStr.lowercased()) ?? .coffee
                        
                        let creatorId = data["creatorId"] as? String ?? ""
                        let host = Host(
                            id: UUID.fromString(creatorId),
                            name: data["creatorName"] as? String ?? "Host",
                            role: "Host",
                            imageUrl: data["creatorImageUrl"] as? String,
                            isVerified: data["creatorVerified"] as? Bool ?? false,
                            firestoreUID: creatorId
                        )
                        
                        let lastMessageData = threadData["lastMessage"] as? [String: Any]
                        let lastMessage = lastMessageData?["text"] as? String
                        
                        var lastMessageTime: String? = nil
                        if let ts = lastMessageData?["timestamp"] as? Timestamp {
                            let formatter = RelativeDateTimeFormatter()
                            formatter.unitsStyle = .abbreviated
                            lastMessageTime = formatter.localizedString(for: ts.dateValue(), relativeTo: Date())
                        }
                        
                        let participantInitials = data["participantInitials"] as? [String] ?? []
                        let participantIds = data["participantIds"] as? [String]
                        
                        let chatDrift = Drift(
                            id: id,
                            title: title,
                            description: description,
                            location: location,
                            meetingPoint: meetingPoint,
                            time: time,
                            endTime: endTime,
                            date: date,
                            distance: distance,
                            status: status,
                            category: category,
                            host: host,
                            peopleGoing: data["participantCount"] as? Int ?? 1,
                            capacity: data["capacity"] as? Int ?? 5,
                            participantInitials: participantInitials,
                            participantIds: participantIds,
                            isMine: (data["creatorId"] as? String ?? "") == currentUid,
                            lastMessage: lastMessage,
                            lastMessageTime: lastMessageTime,
                            unreadCount: 0
                        )
                        
                        chats.append(chatDrift)
                    }
                }
                
                dispatchGroup.notify(queue: .main) {
                    self.cachedChats = chats
                    // Notify ChatsViewModel so the UI refreshes immediately.
                    self.onUpdate?(chats)
                }
            }
    }
    
    // Conforming to ChatServiceProtocol
    func getChats() -> [Drift] {
        guard isFirebaseEnabled else {
            return []
        }
        return cachedChats
    }
    
    // Conforming to DriftChatThreadServiceProtocol
    func loadThread(for drift: Drift) -> DriftChatThreadContext {
        // Real-time messages are handled dynamically via real-time listeners inside the view model.
        guard isFirebaseEnabled else {
            return DriftChatThreadContext(systemMessages: [], messages: [], participants: [])
        }
        return DriftChatThreadContext(systemMessages: [], messages: [], participants: [])
    }
}
