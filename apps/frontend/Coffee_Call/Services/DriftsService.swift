import Foundation
import Combine

protocol DriftsServiceProtocol {
    func fetchDrifts() -> AnyPublisher<[Drift], Error>
    func createDrift(_ drift: Drift) -> AnyPublisher<Void, Error>
    func requestToJoin(driftId: UUID, request: JoinRequest) -> AnyPublisher<Void, Error>
    func cancelJoinRequest(driftId: UUID, userId: String) -> AnyPublisher<Void, Error>
    func acceptJoinRequest(driftId: UUID, request: JoinRequest) -> AnyPublisher<Void, Error>
    func rejectJoinRequest(driftId: UUID, requestId: UUID) -> AnyPublisher<Void, Error>
    func updateDriftStatus(driftId: UUID, status: DriftStatus) -> AnyPublisher<Void, Error>
    func updateDrift(_ drift: Drift) -> AnyPublisher<Void, Error>
    func deleteDrift(driftId: UUID) -> AnyPublisher<Void, Error>
    func leaveDrift(driftId: UUID, userId: String) -> AnyPublisher<Void, Error>
    func reportDrift(driftId: UUID, reason: String) -> AnyPublisher<Void, Error>
}

class MockDriftsService: DriftsServiceProtocol {
    static var mockDrifts: [Drift] = []
    
    init() {
        if MockDriftsService.mockDrifts.isEmpty {
            initializeMockDrifts()
        }
    }
    
    private func initializeMockDrifts() {
        let mockHost = Host(name: "Arjun", role: "Hosting this Drift", imageUrl: "host_arjun", isVerified: true)
        
        MockDriftsService.mockDrifts = [
            Drift(
                title: "Coffee Drift",
                description: "Spontaneous coffee meetup at a nice local cafe. Open to anyone who wants to chat and meet new people in the area.",
                location: "Panampilly Nagar, Kochi",
                meetingPoint: "Near the Main Entrance",
                time: "6:30 PM",
                endTime: "7:30 PM",
                date: "Today",
                distance: 1.2,
                status: .open,
                category: .coffee,
                hook: "Coffee on me ☕\nFirst round's on me!",
                host: mockHost,
                peopleGoing: 3,
                spotsLeft: 2,
                capacity: 5,
                vibeTags: ["Casual", "Friendly"],
                whatToBring: ["Good mood"],
                notes: "Just a quick chat.",
                participantInitials: ["AL", "RI", "MA"],
                imageUrl: "drift_coffee",
                isMine: true,
                latitude: 9.9634,
                longitude: 76.2949
            ),
            Drift(
                title: "Evening Walk",
                description: "A relaxed evening walk inside Cubbon Park. We'll walk, talk, unwind and enjoy the greenery.",
                location: "Marine Drive, Kochi",
                meetingPoint: "Near Kanteerava Stadium Gate",
                time: "6:30 PM",
                endTime: "7:45 PM",
                date: "Today",
                distance: 1.8,
                status: .open,
                category: .walk,
                hook: nil,
                host: Host(name: "Arjun", role: "Hosting this Drift", imageUrl: "host_arjun", isVerified: true),
                peopleGoing: 2,
                spotsLeft: 3,
                capacity: 5,
                vibeTags: ["Chill", "Friendly", "Outdoorsy"],
                whatToBring: ["Comfortable shoes", "Water"],
                notes: "Beginner-friendly. No running.",
                participantInitials: ["SA", "TH"],
                imageUrl: "drift_walk",
                latitude: 9.9806,
                longitude: 76.2758
            ),
            Drift(
                title: "Movie Drift",
                description: "Catching the latest movie at PVR. I have extra coupons!",
                location: "PVR Lulu Mall, Kochi",
                meetingPoint: "Ticket Counter",
                time: "7:45 PM",
                endTime: "10:00 PM",
                date: "Today",
                distance: 2.1,
                status: .startingSoon,
                category: .movie,
                hook: "2 movie coupons 🎟️🎟️\nLet's watch together.",
                host: Host(name: "Sarah", role: "Cinephile", imageUrl: "host_sarah", isVerified: true),
                peopleGoing: 4,
                spotsLeft: 0,
                capacity: 4,
                vibeTags: ["Fun", "Cinematic"],
                whatToBring: ["Popcorn money"],
                notes: "Starting soon!",
                participantInitials: ["PR", "DK", "MR", "NP"],
                imageUrl: "drift_movie",
                latitude: 10.0270,
                longitude: 76.3080
            ),
            Drift(
                title: "Dinner & Chats",
                description: "Dinner at Fort Kochi. Great food and even better conversations.",
                location: "Fort Kochi",
                meetingPoint: "The Old Lighthouse",
                time: "8:30 PM",
                endTime: "10:30 PM",
                date: "Today",
                distance: 2.4,
                status: .tonight,
                category: .food,
                hook: "Free entry with me 🎫\nCovering the entry!",
                host: Host(name: "Liam", role: "Foodie", imageUrl: "host_liam", isVerified: false),
                peopleGoing: 3,
                spotsLeft: 3,
                capacity: 6,
                vibeTags: ["Foodie", "Friendly"],
                whatToBring: ["Appetite"],
                notes: "Reservation is under CoffeeCall.",
                participantInitials: ["RO", "LM", "KK"],
                imageUrl: "drift_dinner",
                latitude: 9.9658,
                longitude: 76.2421
            )
        ]
    }
    
    func fetchDrifts() -> AnyPublisher<[Drift], Error> {
        JoinRequestDebugTracer.trace(
            "MockDriftsService.fetchDrifts called",
            details: "drifts=\(MockDriftsService.mockDrifts.count)"
        )
        return Just(MockDriftsService.mockDrifts)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    func createDrift(_ drift: Drift) -> AnyPublisher<Void, Error> {
        MockDriftsService.mockDrifts.insert(drift, at: 0)
        return Just(())
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    func requestToJoin(driftId: UUID, request: JoinRequest) -> AnyPublisher<Void, Error> {
        JoinRequestDebugTracer.trace(
            "MockDriftsService.requestToJoin called",
            driftId: driftId,
            requestId: request.id
        )
        if let index = MockDriftsService.mockDrifts.firstIndex(where: { $0.id == driftId }) {
            var updatedDrift = MockDriftsService.mockDrifts[index]
            updatedDrift.pendingRequests.append(request)
            MockDriftsService.mockDrifts[index] = updatedDrift
            JoinRequestDebugTracer.trace(
                "MockDriftsService.requestToJoin appended request",
                driftId: driftId,
                requestId: request.id,
                details: "pendingRequests=\(updatedDrift.pendingRequests.count)"
            )
        }
        return Just(())
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }

    func cancelJoinRequest(driftId: UUID, userId: String) -> AnyPublisher<Void, Error> {
        JoinRequestDebugTracer.trace(
            "MockDriftsService.cancelJoinRequest called",
            driftId: driftId,
            details: "userId=\(userId)"
        )
        if let index = MockDriftsService.mockDrifts.firstIndex(where: { $0.id == driftId }) {
            var updatedDrift = MockDriftsService.mockDrifts[index]
            updatedDrift.pendingRequests.removeAll { $0.userId == userId }
            MockDriftsService.mockDrifts[index] = updatedDrift
            JoinRequestDebugTracer.trace(
                "MockDriftsService.cancelJoinRequest removed request",
                driftId: driftId,
                details: "pendingRequests=\(updatedDrift.pendingRequests.count)"
            )
        }
        return Just(())
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    func acceptJoinRequest(driftId: UUID, request: JoinRequest) -> AnyPublisher<Void, Error> {
        JoinRequestDebugTracer.trace(
            "MockDriftsService.acceptJoinRequest called",
            driftId: driftId,
            requestId: request.id
        )
        if let index = MockDriftsService.mockDrifts.firstIndex(where: { $0.id == driftId }) {
            var updatedDrift = MockDriftsService.mockDrifts[index]
            updatedDrift.pendingRequests.removeAll { $0.id == request.id }
            if !updatedDrift.participantInitials.contains(request.userInitials) {
                updatedDrift.participantInitials.append(request.userInitials)
            }
            updatedDrift.peopleGoing += 1
            if let spots = updatedDrift.spotsLeft {
                updatedDrift.spotsLeft = max(spots - 1, 0)
            }
            MockDriftsService.mockDrifts[index] = updatedDrift
        }
        return Just(())
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    func rejectJoinRequest(driftId: UUID, requestId: UUID) -> AnyPublisher<Void, Error> {
        JoinRequestDebugTracer.trace(
            "MockDriftsService.rejectJoinRequest called",
            driftId: driftId,
            requestId: requestId
        )
        if let index = MockDriftsService.mockDrifts.firstIndex(where: { $0.id == driftId }) {
            var updatedDrift = MockDriftsService.mockDrifts[index]
            updatedDrift.pendingRequests.removeAll { $0.id == requestId }
            MockDriftsService.mockDrifts[index] = updatedDrift
        }
        return Just(())
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    func updateDriftStatus(driftId: UUID, status: DriftStatus) -> AnyPublisher<Void, Error> {
        if let index = MockDriftsService.mockDrifts.firstIndex(where: { $0.id == driftId }) {
            var updatedDrift = MockDriftsService.mockDrifts[index]
            updatedDrift.status = status
            MockDriftsService.mockDrifts[index] = updatedDrift
        }
        return Just(())
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    // MARK: - New CRUD Methods
    func updateDrift(_ drift: Drift) -> AnyPublisher<Void, Error> {
        // In mock, simply replace the drift in the array if it exists
        if let index = MockDriftsService.mockDrifts.firstIndex(where: { $0.id == drift.id }) {
            MockDriftsService.mockDrifts[index] = drift
        }
        return Just(())
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }

    func deleteDrift(driftId: UUID) -> AnyPublisher<Void, Error> {
        MockDriftsService.mockDrifts.removeAll { $0.id == driftId }
        return Just(())
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }

    func leaveDrift(driftId: UUID, userId: String) -> AnyPublisher<Void, Error> {
        if let index = MockDriftsService.mockDrifts.firstIndex(where: { $0.id == driftId }) {
            var updatedDrift = MockDriftsService.mockDrifts[index]
            let userInitials = UserDefaults.standard.string(forKey: "profile_initials") ?? AppConstants.MockData.userInitials
            print("[LeaveDrift] MockDriftsService.leaveDrift called for drift: \(updatedDrift.title). Removing userInitials: \(userInitials)")
            updatedDrift.participantInitials.removeAll { $0 == userInitials }
            updatedDrift.peopleGoing = max(updatedDrift.peopleGoing - 1, 1)
            if let spots = updatedDrift.spotsLeft {
                updatedDrift.spotsLeft = spots + 1
            }
            MockDriftsService.mockDrifts[index] = updatedDrift
        }
        return Just(())
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }

    func reportDrift(driftId: UUID, reason: String) -> AnyPublisher<Void, Error> {
        print("MockDriftsService: Drift \(driftId) reported for reason: \(reason)")
        return Just(())
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
}

enum JoinRequestDebugTracer {
    static func trace(
        _ step: String,
        driftId: UUID? = nil,
        requestId: UUID? = nil,
        details: String = "",
        file: StaticString = #fileID,
        line: UInt = #line
    ) {
        #if DEBUG
        let driftText = driftId.map { " driftId=\($0.uuidString)" } ?? ""
        let requestText = requestId.map { " requestId=\($0.uuidString)" } ?? ""
        let detailText = details.isEmpty ? "" : " \(details)"
        print("[JoinRequestFlow] \(step)\(driftText)\(requestText)\(detailText) @ \(file):\(line)")
        // BREAKPOINT: Set one Xcode breakpoint here to pause on every join-request flow trace.
        #endif
    }
}
