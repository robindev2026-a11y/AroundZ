import Foundation
import Combine

class BookmarkManager: ObservableObject {
    static let shared = BookmarkManager()
    
    @Published var savedDrifts: [Drift] = []
    
    private init() {
        loadBookmarks()
    }
    
    func loadBookmarks() {
        if let data = UserDefaults.standard.data(forKey: "saved_drifts") {
            do {
                let decoded = try JSONDecoder().decode([Drift].self, from: data)
                self.savedDrifts = decoded
            } catch {
                print("Error decoding saved drifts: \(error)")
            }
        }
    }
    
    func saveBookmarks() {
        do {
            let encoded = try JSONEncoder().encode(savedDrifts)
            UserDefaults.standard.set(encoded, forKey: "saved_drifts")
        } catch {
            print("Error encoding saved drifts: \(error)")
        }
    }
    
    func isBookmarked(_ drift: Drift) -> Bool {
        savedDrifts.contains(where: { $0.id == drift.id || ($0.title == drift.title && $0.host.name == drift.host.name) })
    }
    
    func toggleBookmark(_ drift: Drift) {
        if let index = savedDrifts.firstIndex(where: { $0.id == drift.id || ($0.title == drift.title && $0.host.name == drift.host.name) }) {
            savedDrifts.remove(at: index)
        } else {
            savedDrifts.append(drift)
        }
        saveBookmarks()
    }
    
    func clearExpired() {
        savedDrifts.removeAll { $0.status == .ended }
        saveBookmarks()
    }
}
