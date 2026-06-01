import Foundation
import Combine
import UIKit
import FirebaseAuth

@MainActor
final class GlobalDriftStore: ObservableObject {
    @Published private(set) var drifts: [Drift] = []

    /// MVP Dynamically Generated Notifications
    var activeNotifications: [AppNotification] {
        var notifications: [AppNotification] = []

        let myHostedDrifts = drifts.filter { $0.isMine && $0.status != .ended }
        for drift in myHostedDrifts {
            if drift.pendingRequests.count > 0 {
                let idString = "\(drift.id.uuidString)-requests"
                // Generate a deterministic ID so the list doesn't jump randomly
                var hasher = Hasher()
                hasher.combine(idString)
                hasher.combine(drift.pendingRequests.count)
                let notifId = UUID(uuidString: String(format: "%032llx", hasher.finalize())) ?? UUID()

                let notif = AppNotification(
                    id: notifId,
                    driftId: drift.id,
                    title: "Join Requests",
                    message: "You have \(drift.pendingRequests.count) pending request(s) for '\(drift.title)'.",
                    timestamp: "Just now",
                    isRead: false,
                    type: .joinRequest
                )
                notifications.append(notif)
            }
        }

        return notifications
    }

    private let driftsService: DriftsServiceProtocol
    private let locationService: LocationService

    private var cancellables = Set<AnyCancellable>()
    private var fetchCancellable: AnyCancellable?
    private var baseDrifts: [Drift] = []
    private var localDrifts: [Drift] = []
    private let prefersRemoteDrifts: Bool

    // Backwards-compatible with `CreatedDriftStore` so existing caches keep working.
    private let storageKey = "created_drifts"

    init(
        driftsService: DriftsServiceProtocol? = nil,
        locationService: LocationService = .shared
    ) {
        self.locationService = locationService
        let isFirebaseEnabled = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist") != nil
        self.prefersRemoteDrifts = driftsService == nil && isFirebaseEnabled

        if let driftsService {
            self.driftsService = driftsService
        } else {
            self.driftsService = isFirebaseEnabled ? FirebaseDriftsService() : MockDriftsService()
        }

        loadLocalDrifts()
        bindLocationUpdates()
        
        // Listen for manual triggers from Detail screens (e.g., Leave Drift)
        NotificationCenter.default.publisher(for: NSNotification.Name("DriftStateChanged"))
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.fetchDrifts()
            }
            .store(in: &cancellables)
            
        mergeDrifts()
    }

    func start() {
        JoinRequestDebugTracer.trace("GlobalDriftStore.start")
        fetchDrifts()
    }

    func fetchDrifts() {
        JoinRequestDebugTracer.trace("GlobalDriftStore.fetchDrifts requested")
        guard fetchCancellable == nil else {
            JoinRequestDebugTracer.trace("GlobalDriftStore.fetchDrifts already listening")
            return
        }

        fetchCancellable = driftsService.fetchDrifts()
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: { [weak self] completion in
                guard let self else { return }
                self.fetchCancellable = nil
            }, receiveValue: { [weak self] drifts in
                guard let self else { return }
                JoinRequestDebugTracer.trace(
                    "GlobalDriftStore.fetchDrifts received snapshot",
                    details: "drifts=\(drifts.count), pendingRequests=\(drifts.reduce(0) { $0 + $1.pendingRequests.count })"
                )
                baseDrifts = drifts
                mergeDrifts()
            })
    }

    func deleteDrift(driftId: UUID) -> AnyPublisher<Void, Error> {
        driftsService.deleteDrift(driftId: driftId)
            .receive(on: RunLoop.main)
            .handleEvents(receiveCompletion: { [weak self] completion in
                guard case .finished = completion else { return }
                self?.remove(driftId)
            })
            .eraseToAnyPublisher()
    }

    func addOrUpdate(_ drift: Drift) {
        if let index = localDrifts.firstIndex(where: { $0.id == drift.id }) {
            localDrifts[index] = drift
        } else {
            localDrifts.append(drift)
        }

        mergeDrifts()
        persistLocalDrifts()
    }

    func remove(_ id: UUID) {
        localDrifts.removeAll { $0.id == id }
        baseDrifts.removeAll { $0.id == id }
        mergeDrifts()
        persistLocalDrifts()
    }

    func updateDriftInStore(_ drift: Drift) {
        if let index = baseDrifts.firstIndex(where: { $0.id == drift.id }) {
            baseDrifts[index] = drift
        }
        if let index = localDrifts.firstIndex(where: { $0.id == drift.id }) {
            localDrifts[index] = drift
            persistLocalDrifts()
        }
        mergeDrifts()
    }

    private func bindLocationUpdates() {
        locationService.$currentLocation
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.mergeDrifts()
            }
            .store(in: &cancellables)
    }

    private func mergeDrifts() {
        var merged: [Drift] = []
        let userLocation = locationService.currentLocationModel
        let baseIds = Set(baseDrifts.map(\.id))
        let candidates: [Drift]

        // Canonical base drifts from the service should ALWAYS take precedence over local cache
        // to prevent stale local data (e.g. from UserDefaults) from overwriting actual updates.
        let localOnlyDrifts = localDrifts.filter { !baseIds.contains($0.id) }
        candidates = localOnlyDrifts + baseDrifts

        for var drift in candidates {
            guard !merged.contains(where: { $0.id == drift.id }) else { continue }

            if let lat = drift.latitude, let lng = drift.longitude, let userLoc = userLocation {
                drift.distance = haversineDistance(
                    lat1: userLoc.latitude,
                    lon1: userLoc.longitude,
                    lat2: lat,
                    lon2: lng
                )
            }

            merged.append(drift)
        }

        drifts = merged
        JoinRequestDebugTracer.trace(
            "GlobalDriftStore.mergeDrifts completed",
            details: "drifts=\(drifts.count), activeNotifications=\(activeNotifications.count), prefersRemote=\(prefersRemoteDrifts)"
        )
    }

    private func loadLocalDrifts() {
        guard let data = UserDefaults.standard.data(forKey: storageKey) else {
            localDrifts = []
            return
        }

        do {
            localDrifts = try JSONDecoder().decode([Drift].self, from: data)
        } catch {
            print("Error decoding local drifts: \(error)")
            localDrifts = []
        }
    }

    private func persistLocalDrifts() {
        do {
            let encoded = try JSONEncoder().encode(localDrifts)
            UserDefaults.standard.set(encoded, forKey: storageKey)
        } catch {
            print("Error encoding local drifts: \(error)")
        }
    }

    func requestToJoin(driftId: UUID) {
        let currentUid = Auth.auth().currentUser?.uid ?? UIDevice.current.identifierForVendor?.uuidString ?? ""
        let currentUserName = UserDefaults.standard.string(forKey: "profile_name") ?? AppConstants.MockData.userName
        let savedInitials = UserDefaults.standard.string(forKey: "profile_initials") ?? ""
        let currentUserInitials = savedInitials.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            ? AppConstants.MockData.userInitials
            : savedInitials
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        let timestamp = formatter.string(from: Date())

        let joinRequest = JoinRequest(
            userId: currentUid,
            userName: currentUserName,
            userInitials: currentUserInitials,
            userRole: "Member",
            message: "Hey, I'd love to join your drift!",
            timestamp: timestamp
        )

        driftsService.requestToJoin(driftId: driftId, request: joinRequest)
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    print("Error requesting to join drift: \(error)")
                }
            }, receiveValue: { [weak self] in
                guard let self = self else { return }
                self.fetchDrifts()
            })
            .store(in: &cancellables)
    }
}
