import Foundation
import Combine

final class CreatedDriftStore: ObservableObject {
    static let shared = CreatedDriftStore()

    @Published private(set) var createdDrifts: [Drift] = []

    private let storageKey = "created_drifts"

    private init() {
        load()
    }

    func load() {
        guard let data = UserDefaults.standard.data(forKey: storageKey) else {
            createdDrifts = []
            return
        }

        do {
            createdDrifts = try JSONDecoder().decode([Drift].self, from: data)
        } catch {
            print("Error decoding created drifts: \(error)")
            createdDrifts = []
        }
    }

    func add(_ drift: Drift) {
        if let index = createdDrifts.firstIndex(where: { $0.id == drift.id }) {
            createdDrifts[index] = drift
        } else {
            createdDrifts.append(drift)
        }
        save()
    }

    func clear() {
        createdDrifts.removeAll()
        save()
    }

    private func save() {
        do {
            let encoded = try JSONEncoder().encode(createdDrifts)
            UserDefaults.standard.set(encoded, forKey: storageKey)
        } catch {
            print("Error encoding created drifts: \(error)")
        }
    }
}
