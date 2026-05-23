import SwiftUI
import Combine
import FirebaseCore
import FirebaseAuth


final class CreateDriftViewModel: ObservableObject {
    // Enums moved to Domain/Models/DriftEnums.swift – UI helpers live in DesignSystem extensions

    // Enums moved to shared domain

    // Enums moved to shared domain

    // Enums moved to shared domain

    // Enums moved to shared domain

    @Published var selectedActivity: ActivityType = .coffee
    @Published var planTitle: String = ""
    @Published var descriptionText: String = ""
    @Published var scheduledDate: Date
    @Published var selectedCapacityCount: Int = 3
    @Published var isOpenToAllCapacity: Bool = false
    @Published var selectedJoinMode: JoinMode = .open
    @Published var approximateLocation: String = AppStrings.Create.sampleLocation
    // Alias for capacity used in drift model
    var capacity: Int { selectedCapacityCount }
    @Published var customActivityText: String = ""
    @Published var hookText: String = ""
    @Published var selectedVibe: VibeOption? = nil
    @Published var notesText: String = ""
    @Published var optionalDetailsExpanded: Bool = false
    @Published var isActivityGridExpanded: Bool = false
    @Published var isCreating: Bool = false

    let maxTitleCount = 60
    private let initialScheduledDate: Date
    private let driftsService: DriftsServiceProtocol
    private var cancellables = Set<AnyCancellable>()

    init(driftsService: DriftsServiceProtocol? = nil) {
        if let driftsService = driftsService {
            self.driftsService = driftsService
        } else {
            let isFirebaseEnabled = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist") != nil
            self.driftsService = isFirebaseEnabled ? FirebaseDriftsService() : MockDriftsService()
        }
        let now = Date()
        initialScheduledDate = now
        _scheduledDate = Published(initialValue: now)
    }

    init(editing drift: Drift, driftsService: DriftsServiceProtocol? = nil) {
        if let driftsService = driftsService {
            self.driftsService = driftsService
        } else {
            let isFirebaseEnabled = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist") != nil
            self.driftsService = isFirebaseEnabled ? FirebaseDriftsService() : MockDriftsService()
        }

        let seededDate = Self.parseScheduledDate(date: drift.date, time: drift.time) ?? Date()
        initialScheduledDate = seededDate
        _scheduledDate = Published(initialValue: seededDate)

        selectedActivity = Self.activityType(for: drift.category)
        planTitle = drift.title
        approximateLocation = drift.location
        selectedCapacityCount = min(max(drift.capacity, 1), 50)
        isOpenToAllCapacity = drift.capacity >= 50
        hookText = drift.hook ?? ""
        notesText = drift.notes ?? ""
        selectedVibe = Self.vibeOption(for: drift.vibeTags)
    }
    
    // Helper to combine separate date and time pickers into a single Date
    private func combineDateTime(date: Date, time: Date) -> Date {
        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([.year, .month, .day], from: date)
        let timeComponents = calendar.dateComponents([.hour, .minute, .second], from: time)
        var combined = DateComponents()
        combined.year = dateComponents.year
        combined.month = dateComponents.month
        combined.day = dateComponents.day
        combined.hour = timeComponents.hour
        combined.minute = timeComponents.minute
        combined.second = timeComponents.second
        return calendar.date(from: combined) ?? date
    }

    var titleCount: Int {
        min(planTitle.count, maxTitleCount)
    }

    var canPost: Bool {
        !planTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        && selectedVibe != nil
        && (selectedActivity != .custom || !customActivityText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        && !isCreating
    }

    var hasUnsavedChanges: Bool {
        selectedActivity != .coffee
        || !planTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        || scheduledDate != initialScheduledDate
        || selectedCapacityCount != 3
        || isOpenToAllCapacity
        || selectedJoinMode != .open
        || !customActivityText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        || !hookText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        || selectedVibe != nil
        || !notesText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        || optionalDetailsExpanded
    }

    func setActivity(_ activity: ActivityType) {
        selectedActivity = activity
        if activity == .custom {
            isActivityGridExpanded = true
        }
    }

    func toggleActivityGridExpansion() {
        withAnimation(CoffeeAnimation.springGentle) {
            isActivityGridExpanded.toggle()
        }
    }

    func setCapacityCount(_ count: Int) {
        selectedCapacityCount = min(max(count, 1), 50)
    }

    func setOpenToAllCapacity(_ isOpen: Bool) {
        isOpenToAllCapacity = isOpen
    }

    func setJoinMode(_ mode: JoinMode) {
        selectedJoinMode = mode
    }

    func create(completion: @escaping (Drift) -> Void) {
        guard canPost else { return }
        isCreating = true

        let drift = buildDrift()
        driftsService.createDrift(drift)
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: { [weak self] completionResult in
                guard let self = self else { return }
                self.isCreating = false
                if case .failure(let error) = completionResult {
                    print("Error creating drift: \(error)")
                }
            }, receiveValue: {
                completion(drift)
            })
            .store(in: &cancellables)
    }

    func update(original drift: Drift, completion: @escaping (Drift) -> Void) {
        guard canPost else { return }
        isCreating = true

        let updated = buildUpdatedDrift(from: drift)
        driftsService.updateDrift(updated)
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: { [weak self] completionResult in
                guard let self = self else { return }
                self.isCreating = false
                if case .failure(let error) = completionResult {
                    print("Error updating drift: \(error)")
                }
            }, receiveValue: {
                completion(updated)
            })
            .store(in: &cancellables)
    }

    func buildDrift() -> Drift {
        let capacityValue = isOpenToAllCapacity ? 50 : selectedCapacityCount
        let vibeTags = selectedVibe.map { [$0.title] } ?? []
        
        let isFirebaseEnabled = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist") != nil
        
        let creatorName = isFirebaseEnabled ? (UserDefaults.standard.string(forKey: "profile_name") ?? "") : AppConstants.MockData.userName
        let creatorInitials = isFirebaseEnabled ? (UserDefaults.standard.string(forKey: "profile_initials") ?? "") : AppConstants.MockData.userInitials
        let creatorUid = isFirebaseEnabled ? (Auth.auth().currentUser?.uid ?? "") : ""
        
        let host = Host(
            name: creatorName,
            role: AppStrings.Create.hostRole,
            imageUrl: nil,
            isVerified: true,
            hostedCount: isFirebaseEnabled ? 0 : 4,
            joinedCount: isFirebaseEnabled ? 0 : 12,
            completedCount: isFirebaseEnabled ? 0 : 16,
            verified: true,
            otherActiveDrifts: [],
            pastDrifts: isFirebaseEnabled ? [] : ["Walk in Indiranagar", "Coffee chat"],
            interests: isFirebaseEnabled ? [] : ["Walks", "Coffee", "Movies"],
            firestoreUID: creatorUid
        )

        return Drift(
            title: planTitle.trimmingCharacters(in: .whitespacesAndNewlines),
            description: driftDescription,
            location: approximateLocation,
            meetingPoint: AppStrings.Create.locationCardNote,
            time: Self.timeFormatter.string(from: scheduledDate),
            endTime: Self.endTimeFormatter.string(from: scheduledDate.addingTimeInterval(60 * 60)),
            date: Self.dateFormatter.string(from: scheduledDate),
            distance: 1.2,
            status: .open,
            category: categoryForSelectedActivity,
            hook: cleanedText(hookText),
            host: host,
            peopleGoing: 1,
            spotsLeft: max(capacityValue - 1, 0),
            capacity: capacityValue,
            vibeTags: vibeTags,
            whatToBring: [],
            notes: cleanedText(notesText),
            participantInitials: [creatorInitials],
            imageUrl: nil,
            isMine: true,
            latitude: LocationService.shared.currentLocation?.coordinate.latitude,
            longitude: LocationService.shared.currentLocation?.coordinate.longitude
        )
    }

    func buildUpdatedDrift(from original: Drift) -> Drift {
        let capacityValue = isOpenToAllCapacity ? 50 : selectedCapacityCount
        let vibeTags = selectedVibe.map { [$0.title] } ?? []
        let scheduledEndDate = scheduledDate.addingTimeInterval(60 * 60)

        let updatedSpotsLeft: Int?
        if original.spotsLeft != nil {
            updatedSpotsLeft = max(capacityValue - original.peopleGoing, 0)
        } else {
            updatedSpotsLeft = nil
        }

        return Drift(
            id: original.id,
            title: planTitle.trimmingCharacters(in: .whitespacesAndNewlines),
            description: driftDescription,
            location: approximateLocation,
            meetingPoint: original.meetingPoint,
            time: Self.timeFormatter.string(from: scheduledDate),
            endTime: Self.endTimeFormatter.string(from: scheduledEndDate),
            date: Self.dateFormatter.string(from: scheduledDate),
            distance: original.distance,
            status: original.status,
            category: categoryForSelectedActivity,
            hook: cleanedText(hookText),
            host: original.host,
            peopleGoing: original.peopleGoing,
            spotsLeft: updatedSpotsLeft,
            capacity: capacityValue,
            vibeTags: vibeTags,
            whatToBring: original.whatToBring,
            notes: cleanedText(notesText),
            participantInitials: original.participantInitials,
            imageUrl: original.imageUrl,
            pendingRequests: original.pendingRequests,
            isMine: original.isMine,
            lastMessage: original.lastMessage,
            lastMessageTime: original.lastMessageTime,
            unreadCount: original.unreadCount,
            latitude: original.latitude,
            longitude: original.longitude
        )
    }

    private var driftDescription: String {
        let parts = [hookText, customActivityText, notesText].compactMap { cleanedText($0) }
        return parts.isEmpty ? planTitle.trimmingCharacters(in: .whitespacesAndNewlines) : parts.joined(separator: " • ")
    }

    private var categoryForSelectedActivity: DriftCategory {
        switch selectedActivity {
        case .coffee: return .coffee
        case .walk: return .walk
        case .food: return .food
        case .movie: return .movie
        case .study: return .study
        case .fitness: return .yoga
        case .games: return .gaming
        case .music: return .music
        case .sports: return .event
        case .drinks: return .event
        case .custom: return .event
        }
    }

    private func cleanedText(_ value: String) -> String? {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }

    private static func parseScheduledDate(date: String, time: String) -> Date? {
        let calendar = Calendar.current

        let resolvedDatePart: Date? = {
            if let parsed = dateFormatter.date(from: date) {
                return parsed
            }

            if date == "Today" {
                return calendar.startOfDay(for: Date())
            }

            if date == "Tomorrow" {
                return calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: Date()))
            }

            return nil
        }()

        guard let datePart = resolvedDatePart,
              let timePart = timeFormatter.date(from: time) else {
            return nil
        }
        let dateComponents = calendar.dateComponents([.year, .month, .day], from: datePart)
        let timeComponents = calendar.dateComponents([.hour, .minute], from: timePart)

        var mergedComponents = DateComponents()
        mergedComponents.year = dateComponents.year
        mergedComponents.month = dateComponents.month
        mergedComponents.day = dateComponents.day
        mergedComponents.hour = timeComponents.hour
        mergedComponents.minute = timeComponents.minute

        return calendar.date(from: mergedComponents)
    }

    private static func activityType(for category: DriftCategory) -> ActivityType {
        switch category {
        case .coffee: return .coffee
        case .walk: return .walk
        case .food: return .food
        case .movie: return .movie
        case .study: return .study
        case .gaming: return .games
        case .music: return .music
        case .yoga: return .fitness
        case .event: return .sports
        }
    }

    private static func vibeOption(for tags: [String]) -> VibeOption? {
        guard let tag = tags.first else { return nil }
        return VibeOption.allCases.first(where: { $0.title == tag })
    }

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()

    private static let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter
    }()

    private static let endTimeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter
    }()
}
