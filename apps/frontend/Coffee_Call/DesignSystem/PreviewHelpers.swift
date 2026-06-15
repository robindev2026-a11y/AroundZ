import Foundation
import Combine

// MARK: - Preview-Only Stubs
// Lightweight service stubs used by SwiftUI PreviewProviders.
// These contain no sensitive data — just empty publishers and minimal
// sample Drift objects so previews render without hitting Firebase.
class PreviewDriftsService: DriftsServiceProtocol {
    func fetchDrifts() -> AnyPublisher<[Drift], Error> {
        Just(PreviewDriftsService.sampleDrifts)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }

    func createDrift(_ drift: Drift) -> AnyPublisher<Void, Error> {
        Just(()).setFailureType(to: Error.self).eraseToAnyPublisher()
    }

    func requestToJoin(driftId: UUID, request: JoinRequest) -> AnyPublisher<Void, Error> {
        Just(()).setFailureType(to: Error.self).eraseToAnyPublisher()
    }

    func cancelJoinRequest(driftId: UUID, userId: String) -> AnyPublisher<Void, Error> {
        Just(()).setFailureType(to: Error.self).eraseToAnyPublisher()
    }

    func acceptJoinRequest(driftId: UUID, request: JoinRequest) -> AnyPublisher<Void, Error> {
        Just(()).setFailureType(to: Error.self).eraseToAnyPublisher()
    }

    func rejectJoinRequest(driftId: UUID, requestId: UUID) -> AnyPublisher<Void, Error> {
        Just(()).setFailureType(to: Error.self).eraseToAnyPublisher()
    }

    func updateDriftStatus(driftId: UUID, status: DriftStatus) -> AnyPublisher<Void, Error> {
        Just(()).setFailureType(to: Error.self).eraseToAnyPublisher()
    }

    func updateDrift(_ drift: Drift) -> AnyPublisher<Void, Error> {
        Just(()).setFailureType(to: Error.self).eraseToAnyPublisher()
    }

    func deleteDrift(driftId: UUID) -> AnyPublisher<Void, Error> {
        Just(()).setFailureType(to: Error.self).eraseToAnyPublisher()
    }

    func leaveDrift(driftId: UUID, userId: String) -> AnyPublisher<Void, Error> {
        Just(()).setFailureType(to: Error.self).eraseToAnyPublisher()
    }

    func reportDrift(driftId: UUID, reason: String) -> AnyPublisher<Void, Error> {
        Just(()).setFailureType(to: Error.self).eraseToAnyPublisher()
    }

    // MARK: - Sample Data

    static let sampleHost = Host(name: "Preview Host", role: "Host", imageUrl: nil, isVerified: true)

    static let sampleDrifts: [Drift] = [
        Drift(
            title: "Coffee Drift",
            description: "Quick coffee meetup.",
            location: "Panampilly Nagar",
            meetingPoint: "Main Entrance",
            time: "6:30 PM",
            endTime: "7:30 PM",
            date: "Today",
            distance: 1.2,
            status: .open,
            category: .coffee,
            host: sampleHost,
            peopleGoing: 3,
            spotsLeft: 2,
            capacity: 5,
            participantInitials: ["A", "R", "M"],
            isMine: true
        ),
        Drift(
            title: "Evening Walk",
            description: "A relaxed evening walk.",
            location: "Marine Drive",
            meetingPoint: "Near Stadium Gate",
            time: "6:30 PM",
            endTime: "7:45 PM",
            date: "Today",
            distance: 1.8,
            status: .open,
            category: .walk,
            host: sampleHost,
            peopleGoing: 2,
            spotsLeft: 3,
            capacity: 5,
            participantInitials: ["S", "T"],
            isMine: false
        )
    ]

    /// A single sample drift for detail/chat previews
    static var sampleDrift: Drift { sampleDrifts[0] }
}

/// Lightweight preview-only chat service
class PreviewChatService: ChatServiceProtocol {
    var onUpdate: (([Drift]) -> Void)? = nil
    func getChats() -> [Drift] { PreviewDriftsService.sampleDrifts }
}
