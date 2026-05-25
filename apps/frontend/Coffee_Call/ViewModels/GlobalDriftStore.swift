import Foundation
import Combine

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

    // Backwards-compatible with `CreatedDriftStore` so existing caches keep working.
    private let storageKey = "created_drifts"

    init(
        driftsService: DriftsServiceProtocol? = nil,
        locationService: LocationService = .shared
    ) {
        self.locationService = locationService

        if let driftsService {
            self.driftsService = driftsService
        } else {
            let isFirebaseEnabled = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist") != nil
            self.driftsService = isFirebaseEnabled ? FirebaseDriftsService() : MockDriftsService()
        }

        loadLocalDrifts()
        bindLocationUpdates()
        mergeDrifts()
    }

    func start() {
        fetchDrifts()
    }

    func fetchDrifts() {
        guard fetchCancellable == nil else { return }

        fetchCancellable = driftsService.fetchDrifts()
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: { [weak self] completion in
                guard let self else { return }
                self.fetchCancellable = nil
            }, receiveValue: { [weak self] drifts in
                guard let self else { return }
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

        for var drift in localDrifts + baseDrifts {
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
}
