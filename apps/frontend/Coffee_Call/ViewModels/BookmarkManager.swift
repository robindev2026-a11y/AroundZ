import Foundation
import Combine
import CoreData

class BookmarkManager: ObservableObject {
    static let shared = BookmarkManager()
    
    @Published var savedDrifts: [Drift] = []
    
    private let context = PersistenceController.shared.container.viewContext
    
    private init() {
        loadBookmarks()
    }
    
    func loadBookmarks() {
        let fetchRequest: NSFetchRequest<CachedDrift> = CachedDrift.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "isBookmarked == %@", NSNumber(value: true))
        
        do {
            let cached = try context.fetch(fetchRequest)
            let decoder = JSONDecoder()
            self.savedDrifts = cached.compactMap { cachedDrift in
                guard let data = cachedDrift.driftData else { return nil }
                return try? decoder.decode(Drift.self, from: data)
            }
        } catch {
            print("Error fetching bookmarks: \(error)")
        }
    }
    
    func saveBookmarks() {
        do {
            try context.save()
        } catch {
            print("Error saving Core Data context: \(error)")
        }
    }
    
    func isBookmarked(_ drift: Drift) -> Bool {
        savedDrifts.contains(where: { $0.id == drift.id })
    }
    
    func toggleBookmark(_ drift: Drift) {
        let fetchRequest: NSFetchRequest<CachedDrift> = CachedDrift.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", drift.id as CVarArg)
        
        do {
            let results = try context.fetch(fetchRequest)
            if let cached = results.first {
                if cached.isBookmarked?.boolValue == true {
                    cached.isBookmarked = NSNumber(value: false)
                    if cached.isLocalOnly?.boolValue != true {
                        context.delete(cached)
                    }
                } else {
                    cached.isBookmarked = NSNumber(value: true)
                    if let data = try? JSONEncoder().encode(drift) {
                        cached.driftData = data
                    }
                }
            } else {
                let cached = CachedDrift(context: context)
                cached.id = drift.id
                cached.isBookmarked = NSNumber(value: true)
                cached.isLocalOnly = NSNumber(value: false)
                if let data = try? JSONEncoder().encode(drift) {
                    cached.driftData = data
                }
            }
            try context.save()
            loadBookmarks()
        } catch {
            print("Error toggling bookmark: \(error)")
        }
    }
    
    func clearExpired() {
        let fetchRequest: NSFetchRequest<CachedDrift> = CachedDrift.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "isBookmarked == %@", NSNumber(value: true))
        
        do {
            let results = try context.fetch(fetchRequest)
            let decoder = JSONDecoder()
            for cached in results {
                guard let data = cached.driftData,
                      let drift = try? decoder.decode(Drift.self, from: data) else { continue }
                if drift.status == .ended {
                    if cached.isLocalOnly?.boolValue == true {
                        cached.isBookmarked = NSNumber(value: false)
                    } else {
                        context.delete(cached)
                    }
                }
            }
            try context.save()
            loadBookmarks()
        } catch {
            print("Error clearing expired bookmarks: \(error)")
        }
    }
}
