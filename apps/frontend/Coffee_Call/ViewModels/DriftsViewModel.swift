import SwiftUI
import Combine
import CoreLocation

class DriftsViewModel: ObservableObject {
    var title: String { AppStrings.Drifts.title }
    var subtitle: String? {
        selectedMode == .discover ? AppStrings.Drifts.subtitle : "Your active plans"
    }
    
    @Published var drifts: [Drift] = []
    @Published var selectedMode: DriftMode = .discover
    @Published var selectedTimeState: TimeState = .all
    @Published var selectedCategory: DriftCategory? = nil {
        didSet {
            guard !isSyncingFilters else { return }
            isSyncingFilters = true
            if let selectedCategory {
                selectedCategories = [interestForCategory(selectedCategory)]
            } else {
                selectedCategories = []
            }
            isSyncingFilters = false
        }
    }
    
    // Search properties (ISSUE-007)
    @Published var searchQuery: String = ""
    @Published var debouncedSearchQuery: String = ""
    @Published var isSearchActive: Bool = false
    
    // Filter Sheet properties (ISSUE-006)
    @Published var isFilterSheetPresented: Bool = false
    @Published var selectedDistance: Double = 10.0 {
        didSet {
            if selectedDistanceRadius != selectedDistance {
                selectedDistanceRadius = selectedDistance
            }
        }
    }
    
    // Tactile Drifts Filter Panel properties (Step 4.1)
    @Published var selectedDistanceRadius: Double = 10.0 {
        didSet {
            if selectedDistance != selectedDistanceRadius {
                selectedDistance = selectedDistanceRadius
            }
        }
    }
    @Published var selectedCategories: Set<String> = [] {
        didSet {
            guard !isSyncingFilters else { return }
            isSyncingFilters = true
            if selectedCategories.count == 1, let first = selectedCategories.first {
                selectedCategory = categoryForInterest(first)
            } else {
                selectedCategory = nil
            }
            isSyncingFilters = false
        }
    }
    @Published var selectedTimeframe: String = "All"
    
    var activeFilterCount: Int {
        var count = 0
        if selectedDistanceRadius < 10.0 { count += 1 }
        if selectedTimeframe != "All" { count += 1 }
        if !selectedCategories.isEmpty || selectedCategory != nil { count += 1 }
        return count
    }
    
    private let driftsService: DriftsServiceProtocol
    private let createdDriftStore = CreatedDriftStore.shared
    private var cancellables = Set<AnyCancellable>()
    private var baseDrifts: [Drift] = []
    private var isSyncingFilters = false
    
    enum DriftMode: String, CaseIterable {
        case discover = "Discover"
        case mine = "Mine"
    }
    
    enum TimeState: String, CaseIterable {
        case all = "All"
        case openNow = "Open now"
        case startingSoon = "Starting soon"
        case tonight = "Tonight"
        
        var icon: String {
            switch self {
            case .all: return "square.grid.2x2.fill"
            case .openNow: return "bolt.fill"
            case .startingSoon: return "clock.fill"
            case .tonight: return "moon.fill"
            }
        }
    }
    
    init(driftsService: DriftsServiceProtocol? = nil) {
        if let driftsService = driftsService {
            self.driftsService = driftsService
        } else {
            let isFirebaseEnabled = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist") != nil
            self.driftsService = isFirebaseEnabled ? FirebaseDriftsService() : MockDriftsService()
        }
        
        // Setup Search Debouncer (ISSUE-007)
        $searchQuery
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .removeDuplicates()
            .assign(to: \.debouncedSearchQuery, on: self)
            .store(in: &cancellables)
        
        // Listen to dynamic handoff filters from DiscoveryScreen (ISSUE-008)
        NavigationManager.shared.$activeInterestFilter
            .sink { [weak self] interest in
                if let interest {
                    self?.selectedMode = .discover
                    self?.selectedCategory = self?.categoryForInterest(interest)
                    
                    // Add interest to the new selectedCategories set for consistency
                    self?.selectedCategories = [interest]
                    
                    // Reset global state immediately after consumption
                    DispatchQueue.main.async {
                        NavigationManager.shared.activeInterestFilter = nil
                    }
                }
            }
            .store(in: &cancellables)

        createdDriftStore.$createdDrifts
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.mergeDrifts()
            }
            .store(in: &cancellables)
            
        LocationService.shared.$currentLocation
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.mergeDrifts()
            }
            .store(in: &cancellables)
            
        loadDrifts()
    }
    
    func loadDrifts() {
        driftsService.fetchDrifts()
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: { _ in }, receiveValue: { [weak self] drifts in
                self?.baseDrifts = drifts
                self?.mergeDrifts()
            })
            .store(in: &cancellables)
    }

    private func mergeDrifts() {
        var merged: [Drift] = []
        let userLocation = LocationService.shared.currentLocationModel
        for var drift in createdDriftStore.createdDrifts + baseDrifts {
            if !merged.contains(where: { $0.id == drift.id }) {
                if let lat = drift.latitude, let lng = drift.longitude, let userLoc = userLocation {
                    let distance = haversineDistance(lat1: userLoc.latitude, lon1: userLoc.longitude, lat2: lat, lon2: lng)
                    drift.distance = distance
                }
                merged.append(drift)
            }
        }
        drifts = merged
    }
    
    var filteredDrifts: [Drift] {
        drifts.filter { drift in
            // 1. Filter by Mode (Discover vs Mine)
            if selectedMode == .mine && !drift.isMine { return false }
            if selectedMode == .discover && drift.isMine { return false }
            
            // 2. Filter by Time State / Timeframe
            let matchesTime: Bool
            if selectedTimeframe != "All" {
                switch selectedTimeframe {
                case "Today":
                    matchesTime = (drift.date.lowercased() == "today")
                case "Tomorrow":
                    matchesTime = (drift.date.lowercased() == "tomorrow")
                case "This Weekend":
                    matchesTime = (drift.date.lowercased() == "this weekend")
                default:
                    matchesTime = true
                }
            } else {
                switch selectedTimeState {
                case .all: matchesTime = true
                case .openNow: matchesTime = (drift.status == .open)
                case .startingSoon: matchesTime = (drift.status == .startingSoon)
                case .tonight: matchesTime = (drift.status == .tonight)
                }
            }
            if !matchesTime { return false }
            
            // 3. Filter by Category Chip & Selected Categories Set
            if !selectedCategories.isEmpty {
                let matchesCategory = selectedCategories.contains { selectedCatStr in
                    if let mappedCat = categoryForInterest(selectedCatStr) {
                        return drift.category == mappedCat
                    }
                    return false
                }
                if !matchesCategory { return false }
            } else if let selectedCategory, drift.category != selectedCategory {
                return false
            }
            
            // 4. Filter by Distance Slider refinement
            if drift.distance > selectedDistanceRadius {
                return false
            }
            
            // 5. Filter by Debounced Search Text
            if isSearchActive && !debouncedSearchQuery.trimmingCharacters(in: .whitespaces).isEmpty {
                let query = debouncedSearchQuery.lowercased()
                let matchesTitle = drift.title.lowercased().contains(query)
                let matchesDesc = drift.description.lowercased().contains(query)
                let matchesLoc = drift.location.lowercased().contains(query)
                let matchesCat = drift.category.rawValue.lowercased().contains(query)
                if !(matchesTitle || matchesDesc || matchesLoc || matchesCat) {
                    return false
                }
            }
            
            return true
        }
    }
    
    private func categoryForInterest(_ interest: String) -> DriftCategory? {
        switch interest.lowercased() {
        case "coffee": return .coffee
        case "walks", "walk": return .walk
        case "movies", "movie": return .movie
        case "food": return .food
        case "music": return .music
        case "gaming": return .gaming
        case "books", "study": return .study
        case "workout", "yoga": return .yoga
        default: return nil
        }
    }
    
    private func interestForCategory(_ category: DriftCategory) -> String {
        switch category {
        case .coffee: return "Coffee"
        case .walk: return "Walks"
        case .movie: return "Movies"
        case .food: return "Food"
        case .music: return "Music"
        case .gaming: return "Gaming"
        case .study: return "Books"
        case .yoga: return "Workout"
        default: return category.rawValue.capitalized
        }
    }
}
