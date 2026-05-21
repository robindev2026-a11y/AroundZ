import Foundation
import Combine
import FirebaseCore
import FirebaseAuth
import FirebaseFirestore

class FirebaseDriftsService: DriftsServiceProtocol {
    private var isFirebaseEnabled: Bool {
        return Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist") != nil
    }
    
    func fetchDrifts() -> AnyPublisher<[Drift], Error> {
        guard isFirebaseEnabled else {
            return MockDriftsService().fetchDrifts()
        }
        
        let subject = PassthroughSubject<[Drift], Error>()
        let db = Firestore.firestore()
        
        db.collection("posts")
            .order(by: "createdAt", descending: true)
            .addSnapshotListener { querySnapshot, error in
                if let error = error {
                    subject.send(completion: .failure(error))
                    return
                }
                
                guard let documents = querySnapshot?.documents else {
                    subject.send([])
                    return
                }
                
                let currentUid = Auth.auth().currentUser?.uid
                let drifts: [Drift] = documents.compactMap { doc -> Drift? in
                    let data = doc.data()
                    
                    let id = UUID.fromString(doc.documentID)
                    let title = data["title"] as? String ?? ""
                    let description = data["description"] as? String ?? ""
                    let location = data["location"] as? String ?? ""
                    let meetingPoint = data["meetingPoint"] as? String ?? ""
                    let time = data["time"] as? String ?? ""
                    let endTime = data["endTime"] as? String ?? ""
                    let date = data["date"] as? String ?? ""
                    let distance = data["distance"] as? Double ?? 1.2
                    
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
                    let hook = data["hook"] as? String
                    
                    let creatorId = data["creatorId"] as? String ?? ""
                    let hostName = data["creatorName"] as? String ?? "Host"
                    
                    let host = Host(
                        id: UUID.fromString(creatorId),
                        name: hostName,
                        role: "Host",
                        imageUrl: data["creatorImageUrl"] as? String,
                        isVerified: data["creatorVerified"] as? Bool ?? false,
                        firestoreUID: creatorId
                    )
                    
                    let peopleGoing = data["participantCount"] as? Int ?? 1
                    let capacity = data["capacity"] as? Int ?? 5
                    let spotsLeft = data["spotsLeft"] as? Int ?? (capacity - peopleGoing)
                    
                    let vibeTags = data["vibeTags"] as? [String] ?? []
                    let whatToBring = data["whatToBring"] as? [String] ?? []
                    let participantInitials = data["participantInitials"] as? [String] ?? []
                    let imageUrl = data["imageUrl"] as? String
                    let pendingRequestsData = data["pendingRequests"] as? [[String: Any]] ?? []
                    let pendingRequests = pendingRequestsData.compactMap { reqDict -> JoinRequest? in
                        guard let idStr = reqDict["id"] as? String,
                              let id = UUID(uuidString: idStr),
                              let userName = reqDict["userName"] as? String,
                              let userInitials = reqDict["userInitials"] as? String,
                              let userRole = reqDict["userRole"] as? String,
                              let message = reqDict["message"] as? String,
                              let timestamp = reqDict["timestamp"] as? String else {
                            return nil
                        }
                        let userId = reqDict["userId"] as? String ?? ""
                        return JoinRequest(
                            id: id,
                            userId: userId,
                            userName: userName,
                            userInitials: userInitials,
                            userRole: userRole,
                            message: message,
                            timestamp: timestamp
                        )
                    }
                    
                    let isMine = (creatorId == currentUid)
                    
                    return Drift(
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
                        hook: hook,
                        host: host,
                        peopleGoing: peopleGoing,
                        spotsLeft: spotsLeft,
                        capacity: capacity,
                        vibeTags: vibeTags,
                        whatToBring: whatToBring,
                        participantInitials: participantInitials,
                        imageUrl: imageUrl,
                        pendingRequests: pendingRequests,
                        isMine: isMine
                    )
                }
                
                subject.send(drifts)
            }
            
        return subject.eraseToAnyPublisher()
    }
    
    func createDrift(_ drift: Drift) -> AnyPublisher<Void, Error> {
        guard isFirebaseEnabled else {
            return MockDriftsService().createDrift(drift)
        }
        
        let subject = PassthroughSubject<Void, Error>()
        let db = Firestore.firestore()
        let postId = drift.id.uuidString
        let currentUid = Auth.auth().currentUser?.uid ?? ""
        
        let postData: [String: Any] = [
            "title": drift.title,
            "description": drift.description,
            "location": drift.location,
            "meetingPoint": drift.meetingPoint,
            "time": drift.time,
            "endTime": drift.endTime,
            "date": drift.date,
            "distance": drift.distance,
            "status": drift.status.rawValue,
            "category": drift.category.rawValue,
            "hook": drift.hook ?? "",
            "creatorId": currentUid,
            "creatorName": drift.host.name,
            "creatorImageUrl": drift.host.imageUrl ?? "",
            "creatorVerified": drift.host.isVerified,
            "participantCount": 1,
            "capacity": drift.capacity,
            "spotsLeft": max(drift.capacity - 1, 0),
            "vibeTags": drift.vibeTags,
            "whatToBring": drift.whatToBring,
            "participantInitials": drift.participantInitials,
            "imageUrl": drift.imageUrl ?? "",
            "createdAt": FieldValue.serverTimestamp()
        ]
        
        let batch = db.batch()
        let postRef = db.collection("posts").document(postId)
        let threadRef = db.collection("messageThreads").document(postId)
        
        batch.setData(postData, forDocument: postRef)
        batch.setData([
            "participants": [currentUid],
            "lastMessage": [
                "text": "Drift created! Welcome to the chat room.",
                "timestamp": FieldValue.serverTimestamp(),
                "senderId": "system",
                "senderName": "System"
            ]
        ], forDocument: threadRef)
        
        batch.commit { error in
            if let error = error {
                subject.send(completion: .failure(error))
            } else {
                subject.send(())
                subject.send(completion: .finished)
            }
        }
        
        return subject.eraseToAnyPublisher()
    }
    
    func requestToJoin(driftId: UUID, request: JoinRequest) -> AnyPublisher<Void, Error> {
        guard isFirebaseEnabled else {
            return MockDriftsService().requestToJoin(driftId: driftId, request: request)
        }
        
        let subject = PassthroughSubject<Void, Error>()
        let db = Firestore.firestore()
        let postId = driftId.uuidString
        let postRef = db.collection("posts").document(postId)
        
        postRef.updateData([
            "pendingRequests": FieldValue.arrayUnion([request.dictionary])
        ]) { error in
            if let error = error {
                subject.send(completion: .failure(error))
            } else {
                subject.send(())
                subject.send(completion: .finished)
            }
        }
        
        return subject.eraseToAnyPublisher()
    }
    
    func acceptJoinRequest(driftId: UUID, request: JoinRequest) -> AnyPublisher<Void, Error> {
        guard isFirebaseEnabled else {
            return MockDriftsService().acceptJoinRequest(driftId: driftId, request: request)
        }
        
        let subject = PassthroughSubject<Void, Error>()
        let db = Firestore.firestore()
        let postId = driftId.uuidString
        
        let postRef = db.collection("posts").document(postId)
        let threadRef = db.collection("messageThreads").document(postId)
        
        db.runTransaction({ (transaction, errorPointer) -> Any? in
            let postDocument: DocumentSnapshot
            do {
                try postDocument = transaction.getDocument(postRef)
            } catch let fetchError as NSError {
                errorPointer?.pointee = fetchError
                return nil
            }
            
            guard let postData = postDocument.data() else {
                let error = NSError(domain: "FirebaseDriftsService", code: 404, userInfo: [NSLocalizedDescriptionKey: "Post document not found"])
                errorPointer?.pointee = error
                return nil
            }
            
            let pendingRequestsData = postData["pendingRequests"] as? [[String: Any]] ?? []
            let updatedPendingRequests = pendingRequestsData.filter { dict in
                if let idStr = dict["id"] as? String {
                    return idStr != request.id.uuidString
                }
                return true
            }
            
            var participantInitials = postData["participantInitials"] as? [String] ?? []
            if !participantInitials.contains(request.userInitials) {
                participantInitials.append(request.userInitials)
            }
            
            let participantCount = postData["participantCount"] as? Int ?? 1
            let capacity = postData["capacity"] as? Int ?? 5
            let newParticipantCount = participantCount + 1
            let newSpotsLeft = max(capacity - newParticipantCount, 0)
            
            transaction.updateData([
                "pendingRequests": updatedPendingRequests,
                "participantInitials": participantInitials,
                "participantCount": newParticipantCount,
                "spotsLeft": newSpotsLeft
            ], forDocument: postRef)
            
            if !request.userId.isEmpty {
                transaction.updateData([
                    "participants": FieldValue.arrayUnion([request.userId])
                ], forDocument: threadRef)
            }
            
            return nil
        }) { (object, error) in
            if let error = error {
                subject.send(completion: .failure(error))
            } else {
                subject.send(())
                subject.send(completion: .finished)
            }
        }
        
        return subject.eraseToAnyPublisher()
    }
    
    func rejectJoinRequest(driftId: UUID, requestId: UUID) -> AnyPublisher<Void, Error> {
        guard isFirebaseEnabled else {
            return MockDriftsService().rejectJoinRequest(driftId: driftId, requestId: requestId)
        }
        
        let subject = PassthroughSubject<Void, Error>()
        let db = Firestore.firestore()
        let postId = driftId.uuidString
        let postRef = db.collection("posts").document(postId)
        
        db.runTransaction({ (transaction, errorPointer) -> Any? in
            let postDocument: DocumentSnapshot
            do {
                try postDocument = transaction.getDocument(postRef)
            } catch let fetchError as NSError {
                errorPointer?.pointee = fetchError
                return nil
            }
            
            guard let postData = postDocument.data() else {
                let error = NSError(domain: "FirebaseDriftsService", code: 404, userInfo: [NSLocalizedDescriptionKey: "Post document not found"])
                errorPointer?.pointee = error
                return nil
            }
            
            let pendingRequestsData = postData["pendingRequests"] as? [[String: Any]] ?? []
            let updatedPendingRequests = pendingRequestsData.filter { dict in
                if let idStr = dict["id"] as? String {
                    return idStr != requestId.uuidString
                }
                return true
            }
            
            transaction.updateData([
                "pendingRequests": updatedPendingRequests
            ], forDocument: postRef)
            
            return nil
        }) { (object, error) in
            if let error = error {
                subject.send(completion: .failure(error))
            } else {
                subject.send(())
                subject.send(completion: .finished)
            }
        }
        
        return subject.eraseToAnyPublisher()
    }
    
    func updateDriftStatus(driftId: UUID, status: DriftStatus) -> AnyPublisher<Void, Error> {
        guard isFirebaseEnabled else {
            return MockDriftsService().updateDriftStatus(driftId: driftId, status: status)
        }
        
        let subject = PassthroughSubject<Void, Error>()
        let db = Firestore.firestore()
        let postId = driftId.uuidString
        let postRef = db.collection("posts").document(postId)
        
        postRef.updateData([
            "status": status.rawValue
        ]) { error in
            if let error = error {
                subject.send(completion: .failure(error))
            } else {
                subject.send(())
                subject.send(completion: .finished)
            }
        }
        
        return subject.eraseToAnyPublisher()
    }
}

extension JoinRequest {
    var dictionary: [String: Any] {
        return [
            "id": id.uuidString,
            "userId": userId,
            "userName": userName,
            "userInitials": userInitials,
            "userRole": userRole,
            "message": message,
            "timestamp": timestamp
        ]
    }
}

// MARK: - UUID Extension Helper
extension UUID {
    static func fromString(_ string: String) -> UUID {
        if let uuid = UUID(uuidString: string) {
            return uuid
        }
        
        // Return deterministic UUID based on string data
        var data = Data(string.utf8)
        if data.count < 16 {
            data.append(contentsOf: Array(repeating: 0, count: 16 - data.count))
        } else {
            data = data.prefix(16)
        }
        return UUID(uuid: (
            data[0], data[1], data[2], data[3],
            data[4], data[5], data[6], data[7],
            data[8], data[9], data[10], data[11],
            data[12], data[13], data[14], data[15]
        ))
    }
}
