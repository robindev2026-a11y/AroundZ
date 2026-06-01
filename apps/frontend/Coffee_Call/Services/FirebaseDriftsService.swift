import Foundation
import Combine
import FirebaseCore
import FirebaseAuth
import FirebaseFirestore
import CoreLocation


class FirebaseDriftsService: DriftsServiceProtocol {
    private var isFirebaseEnabled: Bool {
        return Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist") != nil
    }
    
    func fetchDrifts() -> AnyPublisher<[Drift], Error> {
        JoinRequestDebugTracer.trace("FirebaseDriftsService.fetchDrifts called")
        guard isFirebaseEnabled else {
            return MockDriftsService().fetchDrifts()
        }
        
        let subject = PassthroughSubject<[Drift], Error>()
        let db = Firestore.firestore()
        
        db.collection("posts")
            .order(by: "createdAt", descending: true)
            .addSnapshotListener { querySnapshot, error in
                if let error = error {
                    JoinRequestDebugTracer.trace(
                        "FirebaseDriftsService.fetchDrifts snapshot failed",
                        details: "error=\(error.localizedDescription)"
                    )
                    subject.send(completion: .failure(error))
                    return
                }
                
                guard let documents = querySnapshot?.documents else {
                    subject.send([])
                    return
                }
                
                let currentUid = Auth.auth().currentUser?.uid ?? UIDevice.current.identifierForVendor?.uuidString ?? ""
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
                    
                    let latitude = data["latitude"] as? Double
                    let longitude = data["longitude"] as? Double
                    
                    var distance = data["distance"] as? Double ?? 1.2
                    if let lat = latitude, let lng = longitude,
                       let userLoc = PermissionsManager.shared.currentLocation {
                        let userCLLoc = CLLocation(latitude: userLoc.coordinate.latitude, longitude: userLoc.coordinate.longitude)
                        let driftCLLoc = CLLocation(latitude: lat, longitude: lng)
                        distance = userCLLoc.distance(from: driftCLLoc) / 1000.0
                    }
                    
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
                    let participantIds = data["participantIds"] as? [String]
                    print("[FirebaseFetch] Drift title: '\(title)', participantIds: \(String(describing: participantIds)), participantInitials: \(participantInitials)")
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
                    
                    let joinModeStr = data["joinMode"] as? String ?? "open"
                    let joinMode = JoinMode(rawValue: joinModeStr.lowercased()) ?? .open
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
                        participantIds: participantIds,
                        imageUrl: imageUrl,
                        pendingRequests: pendingRequests,
                        isMine: isMine,
                        latitude: latitude,
                        longitude: longitude,
                        joinMode: joinMode
                    )
                }
                
                subject.send(drifts)
                JoinRequestDebugTracer.trace(
                    "FirebaseDriftsService.fetchDrifts snapshot sent",
                    details: "drifts=\(drifts.count), pendingRequests=\(drifts.reduce(0) { $0 + $1.pendingRequests.count })"
                )
            }
            
        return NetworkInterceptor.shared.execute(subject.eraseToAnyPublisher())
    }
    
    func createDrift(_ drift: Drift) -> AnyPublisher<Void, Error> {
        guard isFirebaseEnabled else {
            return MockDriftsService().createDrift(drift)
        }
        
        let subject = PassthroughSubject<Void, Error>()
        let db = Firestore.firestore()
        let postId = drift.id.uuidString
        let currentUid = Auth.auth().currentUser?.uid ?? UIDevice.current.identifierForVendor?.uuidString ?? ""
        
        var postData: [String: Any] = [
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
            "participantIds": [currentUid],
            "imageUrl": drift.imageUrl ?? "",
            "joinMode": drift.joinMode.rawValue,
            "createdAt": FieldValue.serverTimestamp()
        ]
        
        if let lat = drift.latitude {
            postData["latitude"] = lat
        }
        if let lng = drift.longitude {
            postData["longitude"] = lng
        }
        
        let batch = db.batch()
        let postRef = db.collection("posts").document(postId)
        let threadRef = db.collection("messageThreads").document(postId)
        
        batch.setData(postData, forDocument: postRef)
        batch.setData([
            "postId": postId,
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
        
        return NetworkInterceptor.shared.execute(subject.eraseToAnyPublisher())
    }
    
    func requestToJoin(driftId: UUID, request: JoinRequest) -> AnyPublisher<Void, Error> {
        JoinRequestDebugTracer.trace(
            "FirebaseDriftsService.requestToJoin called",
            driftId: driftId,
            requestId: request.id,
            details: "userId=\(request.userId)"
        )
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
                JoinRequestDebugTracer.trace(
                    "FirebaseDriftsService.requestToJoin Firestore update failed",
                    driftId: driftId,
                    requestId: request.id,
                    details: "error=\(error.localizedDescription)"
                )
                subject.send(completion: .failure(error))
            } else {
                JoinRequestDebugTracer.trace(
                    "FirebaseDriftsService.requestToJoin Firestore update succeeded",
                    driftId: driftId,
                    requestId: request.id
                )
                subject.send(())
                subject.send(completion: .finished)
            }
        }
        
        return NetworkInterceptor.shared.execute(subject.eraseToAnyPublisher())
    }

    func cancelJoinRequest(driftId: UUID, userId: String) -> AnyPublisher<Void, Error> {
        JoinRequestDebugTracer.trace(
            "FirebaseDriftsService.cancelJoinRequest called",
            driftId: driftId,
            details: "userId=\(userId)"
        )
        guard isFirebaseEnabled else {
            return MockDriftsService().cancelJoinRequest(driftId: driftId, userId: userId)
        }

        let subject = PassthroughSubject<Void, Error>()
        let db = Firestore.firestore()
        let postRef = db.collection("posts").document(driftId.uuidString)

        db.runTransaction({ transaction, errorPointer -> Any? in
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
                (dict["userId"] as? String) != userId
            }

            transaction.updateData([
                "pendingRequests": updatedPendingRequests
            ], forDocument: postRef)

            return nil
        }) { _, error in
            if let error = error {
                JoinRequestDebugTracer.trace(
                    "FirebaseDriftsService.cancelJoinRequest failed",
                    driftId: driftId,
                    details: "error=\(error.localizedDescription)"
                )
                subject.send(completion: .failure(error))
            } else {
                JoinRequestDebugTracer.trace(
                    "FirebaseDriftsService.cancelJoinRequest succeeded",
                    driftId: driftId
                )
                subject.send(())
                subject.send(completion: .finished)
            }
        }

        return NetworkInterceptor.shared.execute(subject.eraseToAnyPublisher())
    }
    
    func acceptJoinRequest(driftId: UUID, request: JoinRequest) -> AnyPublisher<Void, Error> {
        JoinRequestDebugTracer.trace(
            "FirebaseDriftsService.acceptJoinRequest called",
            driftId: driftId,
            requestId: request.id
        )
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
            
            let requestInitials = request.userInitials.trimmingCharacters(in: .whitespacesAndNewlines)
            var participantInitials = postData["participantInitials"] as? [String] ?? []
            if !requestInitials.isEmpty && !participantInitials.contains(requestInitials) {
                participantInitials.append(requestInitials)
            }
            
            let participantCount = postData["participantCount"] as? Int ?? 1
            let capacity = postData["capacity"] as? Int ?? 5
            let newParticipantCount = participantCount + 1
            let newSpotsLeft = max(capacity - newParticipantCount, 0)
            
            transaction.updateData([
                "pendingRequests": updatedPendingRequests,
                "participantInitials": participantInitials,
                "participantIds": FieldValue.arrayUnion([request.userId]),
                "participantCount": newParticipantCount,
                "spotsLeft": newSpotsLeft
            ], forDocument: postRef)
            
            return nil
        }) { (object, error) in
            if let error = error {
                JoinRequestDebugTracer.trace(
                    "FirebaseDriftsService.acceptJoinRequest failed",
                    driftId: driftId,
                    requestId: request.id,
                    details: "error=\(error.localizedDescription)"
                )
                subject.send(completion: .failure(error))
            } else {
                if !request.userId.isEmpty {
                    threadRef.updateData([
                        "participants": FieldValue.arrayUnion([request.userId])
                    ]) { threadError in
                        if let threadError = threadError {
                            print("Warning: Failed to update message thread participants: \(threadError.localizedDescription)")
                        }
                        JoinRequestDebugTracer.trace(
                            "FirebaseDriftsService.acceptJoinRequest succeeded",
                            driftId: driftId,
                            requestId: request.id
                        )
                        subject.send(())
                        subject.send(completion: .finished)
                    }
                } else {
                    JoinRequestDebugTracer.trace(
                        "FirebaseDriftsService.acceptJoinRequest succeeded (no userId)",
                        driftId: driftId,
                        requestId: request.id
                    )
                    subject.send(())
                    subject.send(completion: .finished)
                }
            }
        }
        
        return NetworkInterceptor.shared.execute(subject.eraseToAnyPublisher())
    }
    
    func rejectJoinRequest(driftId: UUID, requestId: UUID) -> AnyPublisher<Void, Error> {
        JoinRequestDebugTracer.trace(
            "FirebaseDriftsService.rejectJoinRequest called",
            driftId: driftId,
            requestId: requestId
        )
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
                JoinRequestDebugTracer.trace(
                    "FirebaseDriftsService.rejectJoinRequest failed",
                    driftId: driftId,
                    requestId: requestId,
                    details: "error=\(error.localizedDescription)"
                )
                subject.send(completion: .failure(error))
            } else {
                JoinRequestDebugTracer.trace(
                    "FirebaseDriftsService.rejectJoinRequest succeeded",
                    driftId: driftId,
                    requestId: requestId
                )
                subject.send(())
                subject.send(completion: .finished)
            }
        }
        
        return NetworkInterceptor.shared.execute(subject.eraseToAnyPublisher())
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
        
        return NetworkInterceptor.shared.execute(subject.eraseToAnyPublisher())
    }
    
    // MARK: - Update Drift (full fields)
    func updateDrift(_ drift: Drift) -> AnyPublisher<Void, Error> {
        guard isFirebaseEnabled else {
            return MockDriftsService().updateDrift(drift)
        }
        let subject = PassthroughSubject<Void, Error>()
        let db = Firestore.firestore()
        let postRef = db.collection("posts").document(drift.id.uuidString)
        var data: [String: Any] = [
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
            "capacity": drift.capacity,
            "vibeTags": drift.vibeTags,
            "whatToBring": drift.whatToBring,
            "participantInitials": drift.participantInitials,
            "imageUrl": drift.imageUrl ?? "",
            "joinMode": drift.joinMode.rawValue,
            "latitude": drift.latitude as Any,
            "longitude": drift.longitude as Any
        ]
        // Remove nil entries for optional fields
        data = data.filter { !($0.value is NSNull) }
        postRef.setData(data, merge: true) { error in
            if let error = error {
                subject.send(completion: .failure(error))
            } else {
                subject.send(())
                subject.send(completion: .finished)
            }
        }
        return NetworkInterceptor.shared.execute(subject.eraseToAnyPublisher())
    }
    
    // MARK: - Delete Drift
    func deleteDrift(driftId: UUID) -> AnyPublisher<Void, Error> {
        guard isFirebaseEnabled else {
            return MockDriftsService().deleteDrift(driftId: driftId)
        }
        let subject = PassthroughSubject<Void, Error>()
        let db = Firestore.firestore()
        let postRef = db.collection("posts").document(driftId.uuidString)
        let threadRef = db.collection("messageThreads").document(driftId.uuidString)
        let batch = db.batch()
        batch.deleteDocument(postRef)
        batch.deleteDocument(threadRef)
        batch.commit { error in
            if let error = error {
                subject.send(completion: .failure(error))
            } else {
                subject.send(())
                subject.send(completion: .finished)
            }
        }
        return NetworkInterceptor.shared.execute(subject.eraseToAnyPublisher())
    }

    func leaveDrift(driftId: UUID, userId: String) -> AnyPublisher<Void, Error> {
        guard isFirebaseEnabled else {
            return MockDriftsService().leaveDrift(driftId: driftId, userId: userId)
        }
        
        let subject = PassthroughSubject<Void, Error>()
        let db = Firestore.firestore()
        let postId = driftId.uuidString
        
        let postRef = db.collection("posts").document(postId)
        let threadRef = db.collection("messageThreads").document(postId)
        
        let savedInitials = UserDefaults.standard.string(forKey: "profile_initials") ?? ""
        let userInitials = savedInitials.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? AppConstants.MockData.userInitials : savedInitials
        
        print("[LeaveDrift] Starting Resilient Cleanup for postId: \(postId), userId: \(userId)")
        
        // 1. Remove from Message Thread FIRST (while user still has 'participant' status)
        threadRef.updateData([
            "participants": FieldValue.arrayRemove([userId])
        ]) { threadErr in
            if let threadErr = threadErr {
                print("[LeaveDrift] WARNING: Thread update failed: \(threadErr.localizedDescription)")
            } else {
                print("[LeaveDrift] SUCCESS: User removed from thread.")
            }
            
            // 2. Delete Acceptance Document (The Bottom Connection)
            db.collection("acceptances")
                .whereField("postId", isEqualTo: postId)
                .whereField("acceptorId", isEqualTo: userId)
                .getDocuments { acceptanceSnap, acceptanceErr in
                    if let acceptanceErr = acceptanceErr {
                        print("[LeaveDrift] ERROR finding acceptances: \(acceptanceErr.localizedDescription)")
                    } else {
                        for doc in acceptanceSnap?.documents ?? [] {
                            print("[LeaveDrift] Deleting acceptance: \(doc.documentID)")
                            doc.reference.delete()
                        }
                    }
                    
                    // 3. Update Post Metadata
                    postRef.getDocument { postSnap, postFetchErr in
                        guard let postSnap = postSnap, postSnap.exists, let postData = postSnap.data() else {
                            subject.send(completion: .failure(postFetchErr ?? NSError(domain: "Firestore", code: 404)))
                            return
                        }
                        
                        print("[LeaveDrift] Loaded postData: participantIds = \(String(describing: postData["participantIds"])), participantInitials = \(String(describing: postData["participantInitials"]))")
                        
                        let cleanInitials = userInitials.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
                        var participantInitials = postData["participantInitials"] as? [String] ?? []
                        participantInitials.removeAll { 
                            $0.trimmingCharacters(in: .whitespacesAndNewlines).uppercased() == cleanInitials 
                        }
                        
                        let participantCount = postData["participantCount"] as? Int ?? 1
                        let newParticipantCount = max(participantCount - 1, 1)
                        
                        var updateData: [String: Any] = [
                            "participantInitials": participantInitials,
                            "participantCount": newParticipantCount,
                            "spotsLeft": FieldValue.increment(Int64(1))
                        ]
                        
                        if postData["participantIds"] != nil {
                            let cleanUserId = userId.trimmingCharacters(in: .whitespacesAndNewlines)
                            updateData["participantIds"] = FieldValue.arrayRemove([cleanUserId])
                        }
                        
                        postRef.updateData(updateData) { finalErr in
                            if let finalErr = finalErr {
                                print("[LeaveDrift] ERROR final post update: \(finalErr.localizedDescription)")
                                subject.send(completion: .failure(finalErr))
                            } else {
                                print("[LeaveDrift] SUCCESS: User has fully left the drift.")
                                subject.send(())
                                subject.send(completion: .finished)
                            }
                        }
                    }
                }
        }
        
        return NetworkInterceptor.shared.execute(subject.eraseToAnyPublisher())
    }

    func reportDrift(driftId: UUID, reason: String) -> AnyPublisher<Void, Error> {
        guard isFirebaseEnabled else {
            return MockDriftsService().reportDrift(driftId: driftId, reason: reason)
        }
        
        let subject = PassthroughSubject<Void, Error>()
        let db = Firestore.firestore()
        let currentUid = Auth.auth().currentUser?.uid ?? "anonymous"
        
        let reportData: [String: Any] = [
            "postId": driftId.uuidString,
            "reporterId": currentUid,
            "reason": reason,
            "createdAt": FieldValue.serverTimestamp()
        ]
        
        db.collection("reports").addDocument(data: reportData) { error in
            if let error = error {
                subject.send(completion: .failure(error))
            } else {
                subject.send(())
                subject.send(completion: .finished)
            }
        }
        
        return NetworkInterceptor.shared.execute(subject.eraseToAnyPublisher())
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
