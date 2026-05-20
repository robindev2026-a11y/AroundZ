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
                        isVerified: data["creatorVerified"] as? Bool ?? false
                    )
                    
                    let peopleGoing = data["participantCount"] as? Int ?? 1
                    let capacity = data["capacity"] as? Int ?? 5
                    let spotsLeft = data["spotsLeft"] as? Int ?? (capacity - peopleGoing)
                    
                    let vibeTags = data["vibeTags"] as? [String] ?? []
                    let whatToBring = data["whatToBring"] as? [String] ?? []
                    let participantInitials = data["participantInitials"] as? [String] ?? []
                    let imageUrl = data["imageUrl"] as? String
                    
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
                        isMine: isMine
                    )
                }
                
                subject.send(drifts)
            }
            
        return subject.eraseToAnyPublisher()
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
