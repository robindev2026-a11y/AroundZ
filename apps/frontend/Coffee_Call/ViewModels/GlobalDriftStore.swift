import Foundation
import Combine
import UIKit
import FirebaseAuth
import CoreData

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
            self.driftsService = isFirebaseEnabled ? FirebaseDriftsService() : FirebaseDriftsService()
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
        
        let context = PersistenceController.shared.container.viewContext
        let fetchRequest: NSFetchRequest<CachedDrift> = CachedDrift.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", drift.id as CVarArg)
        
        do {
            let results = try context.fetch(fetchRequest)
            let cached: CachedDrift
            if let existing = results.first {
                cached = existing
            } else {
                cached = CachedDrift(context: context)
                cached.id = drift.id
                cached.isBookmarked = NSNumber(value: false)
            }
            cached.isLocalOnly = NSNumber(value: true)
            if let data = try? JSONEncoder().encode(drift) {
                cached.driftData = data
            }
            try context.save()
        } catch {
            print("Error saving local drift to Core Data: \(error)")
        }
    }

    func remove(_ id: UUID) {
        localDrifts.removeAll { $0.id == id }
        baseDrifts.removeAll { $0.id == id }
        mergeDrifts()
        
        let context = PersistenceController.shared.container.viewContext
        let fetchRequest: NSFetchRequest<CachedDrift> = CachedDrift.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        
        do {
            let results = try context.fetch(fetchRequest)
            if let cached = results.first {
                if cached.isBookmarked?.boolValue == true {
                    cached.isLocalOnly = NSNumber(value: false)
                } else {
                    context.delete(cached)
                }
                try context.save()
            }
        } catch {
            print("Error removing local drift from Core Data: \(error)")
        }
    }

    func updateDriftInStore(_ drift: Drift) {
        if let index = baseDrifts.firstIndex(where: { $0.id == drift.id }) {
            baseDrifts[index] = drift
        }
        if let index = localDrifts.firstIndex(where: { $0.id == drift.id }) {
            localDrifts[index] = drift
            
            let context = PersistenceController.shared.container.viewContext
            let fetchRequest: NSFetchRequest<CachedDrift> = CachedDrift.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id == %@", drift.id as CVarArg)
            
            do {
                let results = try context.fetch(fetchRequest)
                if let cached = results.first {
                    cached.driftData = try? JSONEncoder().encode(drift)
                    try context.save()
                }
            } catch {
                print("Error updating drift in Core Data: \(error)")
            }
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
        let context = PersistenceController.shared.container.viewContext
        let fetchRequest: NSFetchRequest<CachedDrift> = CachedDrift.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "isLocalOnly == %@", NSNumber(value: true))
        
        do {
            let cached = try context.fetch(fetchRequest)
            let decoder = JSONDecoder()
            self.localDrifts = cached.compactMap { cachedDrift in
                guard let data = cachedDrift.driftData else { return nil }
                return try? decoder.decode(Drift.self, from: data)
            }
        } catch {
            print("Error loading local drifts: \(error)")
            self.localDrifts = []
        }
    }

    private func persistLocalDrifts() {
        // Handled inline in modifying functions
    }

    func requestToJoin(driftId: UUID) {
        let currentUid = Auth.auth().currentUser?.uid ?? UIDevice.current.identifierForVendor?.uuidString ?? ""
        let currentUserName = UserDefaults.standard.string(forKey: "profile_name") ?? "User"
        let savedInitials = UserDefaults.standard.string(forKey: "profile_initials") ?? ""
        let currentUserInitials = savedInitials.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            ? "U"
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
