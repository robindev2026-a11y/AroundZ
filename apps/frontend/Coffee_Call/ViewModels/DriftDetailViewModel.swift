import SwiftUI
import Combine
import FirebaseAuth
import FirebaseFirestore
import UserNotifications

struct ParticipantDetail: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let initials: String
    let interests: [String]
    let joinTimeDescription: String
}

class DriftDetailViewModel: ObservableObject {
    @Published var drift: Drift
    @Published var joinStatus: JoinStatus = .notJoined
    @Published var participants: [ParticipantDetail] = []
    @Published var savedDrifts: [Drift] = []
    @Published var showingRequestSentConfirmation = false
    @Published var isReminderSet = false
    
    private var cancellables = Set<AnyCancellable>()
    
    enum JoinStatus {
        case notJoined
        case requested
        case joined
        case full
        case ended
    }
    
    var canAccessChat: Bool {
        joinStatus == .joined
    }
    
    private let driftsService: DriftsServiceProtocol
    
    init(drift: Drift, initialJoinStatus: JoinStatus? = nil, driftsService: DriftsServiceProtocol? = nil) {
        if let driftsService = driftsService {
            self.driftsService = driftsService
        } else {
            let isFirebaseEnabled = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist") != nil
            self.driftsService = isFirebaseEnabled ? FirebaseDriftsService() : MockDriftsService()
        }
        // Build rich mock details for the host to display in the Host Context Card
        let hostName = drift.host.name
        let mockOtherActive = [
            Drift(
                title: "Walk in Indiranagar",
                description: "Morning stroll followed by filter coffee.",
                location: "Indiranagar, Bangalore",
                meetingPoint: "Cult Fit entrance",
                time: "7:00 AM",
                endTime: "8:00 AM",
                date: "Tomorrow",
                distance: 1.5,
                status: .open,
                category: .walk,
                hook: "Morning energy 🚶‍♂️",
                host: Host(name: hostName, role: drift.host.role, imageUrl: drift.host.imageUrl, isVerified: drift.host.isVerified),
                peopleGoing: 2,
                spotsLeft: 3,
                capacity: 5,
                vibeTags: ["Fresh", "Early birds"],
                whatToBring: ["Comfortable footwear"],
                participantInitials: ["SR", "AP"],
                imageUrl: nil
            ),
            Drift(
                title: "Specialty Coffee Tasting",
                description: "Let's explore some local light roasts.",
                location: "Koramangala, Bangalore",
                meetingPoint: "Third Wave Coffee",
                time: "4:00 PM",
                endTime: "5:00 PM",
                date: "Saturday",
                distance: 3.2,
                status: .open,
                category: .coffee,
                hook: "For coffee nerds ☕",
                host: Host(name: hostName, role: drift.host.role, imageUrl: drift.host.imageUrl, isVerified: drift.host.isVerified),
                peopleGoing: 1,
                spotsLeft: 4,
                capacity: 5,
                vibeTags: ["Educational", "Casual"],
                whatToBring: ["An open palate"],
                participantInitials: ["KT"],
                imageUrl: nil
            )
        ]
        
        let richHost = Host(
            id: drift.host.id,
            name: drift.host.name,
            role: drift.host.role,
            imageUrl: drift.host.imageUrl,
            isVerified: drift.host.isVerified,
            hostedCount: 4,
            joinedCount: 12,
            completedCount: 16,
            verified: true,
            otherActiveDrifts: mockOtherActive,
            pastDrifts: ["Walk in Indiranagar", "Coffee chat"],
            interests: ["Walks", "Coffee", "Movies"],
            firestoreUID: drift.host.firestoreUID
        )
        
        var updatedDrift = drift
        updatedDrift.host = richHost
        self.drift = updatedDrift

        // Participants: fetch live from Firestore when Firebase is enabled.
        // Fall back to mock people in offline/preview mode.
        if isFirebaseEnabled {
            self.participants = [] // will be populated by fetchParticipants()
            fetchParticipants()
            fetchHostOtherActiveDrifts()
        } else {
            self.participants = [
                ParticipantDetail(name: "Liam", initials: "LJ", interests: ["Walks", "Coffee", "Music"], joinTimeDescription: "Joined today 2:14 PM"),
                ParticipantDetail(name: "Maya", initials: "MM", interests: ["Coffee", "Walks", "Music"], joinTimeDescription: "Joined today 1:45 PM"),
                ParticipantDetail(name: "Sarah", initials: "SJ", interests: ["Walks", "Coffee", "Music"], joinTimeDescription: "Joined today 12:30 PM"),
                ParticipantDetail(name: "Dev", initials: "DG", interests: ["Music", "Coffee", "Walks"], joinTimeDescription: "Joined today 11:15 AM")
            ]
        }
        
        if let initialJoinStatus {
            self.joinStatus = initialJoinStatus
        } else if drift.status == .ended {
            self.joinStatus = .ended
        } else if drift.isMine {
            self.joinStatus = .joined
        } else if drift.spotsLeft == 0 {
            self.joinStatus = .full
        } else {
            self.joinStatus = .notJoined
        }
        
        setupBookmarkSubscription()
        checkReminderStatus()
    }
    
    private func setupBookmarkSubscription() {
        BookmarkManager.shared.$savedDrifts
            .receive(on: RunLoop.main)
            .assign(to: \.savedDrifts, on: self)
            .store(in: &cancellables)
    }
    
    func requestToJoin() {
        let currentUid = Auth.auth().currentUser?.uid ?? ""

        // Use real profile data from UserDefaults (written by ProfileViewModel on save/fetch).
        // Falls back to MockData only if UserDefaults has nothing (offline preview mode).
        let currentUserName = UserDefaults.standard.string(forKey: "profile_name")
            ?? AppConstants.MockData.userName
        let currentUserInitials = UserDefaults.standard.string(forKey: "profile_initials")
            ?? AppConstants.MockData.userInitials
        let currentUserRole = "Member"

        let formatter = DateFormatter()
        formatter.timeStyle = .short
        let timestamp = formatter.string(from: Date())

        let joinRequest = JoinRequest(
            userId: currentUid,
            userName: currentUserName,
            userInitials: currentUserInitials,
            userRole: currentUserRole,
            message: "Hey, I'd love to join your drift!",
            timestamp: timestamp
        )

        driftsService.requestToJoin(driftId: drift.id, request: joinRequest)
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: { completionResult in
                if case .failure(let error) = completionResult {
                    print("Error requesting to join: \(error)")
                }
            }, receiveValue: { [weak self] in
                guard let self = self else { return }
                withAnimation(.spring()) {
                    self.joinStatus = .requested
                    self.showingRequestSentConfirmation = true
                }
            })
            .store(in: &cancellables)
    }

    // MARK: - Firebase Participants Fetch
    private var isFirebaseEnabled: Bool {
        Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist") != nil
    }

    func fetchParticipants() {
        guard isFirebaseEnabled else { return }
        let db = Firestore.firestore()
        let postId = drift.id.uuidString

        db.collection("acceptances")
            .whereField("postId", isEqualTo: postId)
            .getDocuments { [weak self] snapshot, error in
                guard let self = self, let docs = snapshot?.documents, error == nil else { return }

                let group = DispatchGroup()
                var fetched: [ParticipantDetail] = []

                for doc in docs {
                    let data = doc.data()
                    guard let acceptorId = data["acceptorId"] as? String else { continue }

                    group.enter()
                    db.collection("users").document(acceptorId).getDocument { userSnap, _ in
                        defer { group.leave() }
                        let userData = userSnap?.data() ?? [:]
                        let name = userData["name"] as? String ?? "Someone"
                        let parts = name.components(separatedBy: " ")
                        let initials = parts.compactMap { $0.first }.map { String($0) }.joined().uppercased()
                        let interests = userData["interestTags"] as? [String] ?? []

                        var joinTimeDesc = "Joined recently"
                        if let ts = data["acceptedAt"] as? Timestamp {
                            let fmt = DateFormatter()
                            fmt.timeStyle = .short
                            joinTimeDesc = "Joined \(fmt.string(from: ts.dateValue()))"
                        }

                        fetched.append(ParticipantDetail(
                            name: name,
                            initials: initials,
                            interests: interests,
                            joinTimeDescription: joinTimeDesc
                        ))
                    }
                }

                group.notify(queue: .main) { [weak self] in
                    self?.participants = fetched
                }
            }
    }
    
    func fetchHostOtherActiveDrifts() {
        guard isFirebaseEnabled else { return }
        let creatorId = drift.host.firestoreUID
        guard !creatorId.isEmpty else { return }
        
        let db = Firestore.firestore()
        db.collection("posts")
            .whereField("creatorId", isEqualTo: creatorId)
            .getDocuments { [weak self] snapshot, error in
                guard let self = self, let docs = snapshot?.documents, error == nil else { return }
                
                let currentUid = Auth.auth().currentUser?.uid
                let fetchedDrifts: [Drift] = docs.compactMap { doc -> Drift? in
                    // Let's skip the current drift!
                    if doc.documentID == self.drift.id.uuidString { return nil }
                    
                    let data = doc.data()
                    let isActive = data["isActive"] as? Bool ?? true
                    if !isActive { return nil }
                    
                    let id = UUID.fromString(doc.documentID)
                    let title = data["title"] as? String ?? ""
                    let description = data["description"] as? String ?? ""
                    let location = data["location"] as? String ?? ""
                    let meetingPoint = data["meetingPoint"] as? String ?? ""
                    let time = data["time"] as? String ?? ""
                    let endTime = data["endTime"] as? String ?? ""
                    let date = data["date"] as? String ?? ""
                    let distance = data["distance"] as? Double ?? 1.2
                    
                    let statusStr = data["status"] as? String ?? "OPEN"
                    let status: DriftStatus
                    switch statusStr.uppercased() {
                    case "OPEN": status = .open
                    case "STARTING SOON": status = .startingSoon
                    case "TONIGHT": status = .tonight
                    case "ENDED": status = .ended
                    default: status = .open
                    }
                    
                    let categoryStr = data["category"] as? String ?? "coffee"
                    let category = DriftCategory(rawValue: categoryStr.lowercased()) ?? .coffee
                    let hook = data["hook"] as? String
                    
                    let hostName = data["creatorName"] as? String ?? "Host"
                    
                    let host = Host(
                        id: UUID.fromString(creatorId),
                        name: hostName,
                        role: "Host",
                        imageUrl: data["creatorImageUrl"] as? String,
                        isVerified: data["creatorVerified"] as? Bool ?? false,
                        firestoreUID: creatorId
                    )
                    
                    let peopleGoing = data["participantCount"] as? Int ?? 1
                    let capacity = data["capacity"] as? Int ?? 5
                    let spotsLeft = data["spotsLeft"] as? Int ?? (capacity - peopleGoing)
                    
                    let vibeTags = data["vibeTags"] as? [String] ?? []
                    let whatToBring = data["whatToBring"] as? [String] ?? []
                    let participantInitials = data["participantInitials"] as? [String] ?? []
                    let imageUrl = data["imageUrl"] as? String
                    
                    let isMine = (creatorId == currentUid)
                    
                    return Drift(
                        id: id,
                        title: title,
                        description: description,
                        location: location,
                        meetingPoint: meetingPoint,
                        time: time,
                        endTime: endTime,
                        date: date,
                        distance: distance,
                        status: status,
                        category: category,
                        hook: hook,
                        host: host,
                        peopleGoing: peopleGoing,
                        spotsLeft: spotsLeft,
                        capacity: capacity,
                        vibeTags: vibeTags,
                        whatToBring: whatToBring,
                        participantInitials: participantInitials,
                        imageUrl: imageUrl,
                        isMine: isMine
                    )
                }
                
                DispatchQueue.main.async {
                    var updatedHost = self.drift.host
                    let newHost = Host(
                        id: updatedHost.id,
                        name: updatedHost.name,
                        role: updatedHost.role,
                        imageUrl: updatedHost.imageUrl,
                        isVerified: updatedHost.isVerified,
                        hostedCount: updatedHost.hostedCount,
                        joinedCount: updatedHost.joinedCount,
                        completedCount: updatedHost.completedCount,
                        verified: updatedHost.verified,
                        otherActiveDrifts: fetchedDrifts,
                        pastDrifts: updatedHost.pastDrifts,
                        interests: updatedHost.interests,
                        firestoreUID: updatedHost.firestoreUID
                    )
                    self.drift.host = newHost
                }
            }
    }
    
    var isBookmarked: Bool {
        savedDrifts.contains(where: { $0.id == drift.id || ($0.title == drift.title && $0.host.name == drift.host.name) })
    }
    
    func saveDrift() {
        BookmarkManager.shared.toggleBookmark(drift)
    }
    
    func shareDrift() {
        let inviteText = AppStrings.Drifts.Detail.inviteText(
            title: drift.title,
            date: drift.date,
            time: drift.time,
            location: drift.location
        )
        UIApplication.shareText(inviteText)
    }
    
    func checkReminderStatus() {
        let identifier = "drift_reminder_\(drift.id.uuidString)"
        UNUserNotificationCenter.current().getPendingNotificationRequests { [weak self] requests in
            let exists = requests.contains(where: { $0.identifier == identifier })
            DispatchQueue.main.async {
                self?.isReminderSet = exists
            }
        }
    }
    
    func setReminder() {
        let identifier = "drift_reminder_\(drift.id.uuidString)"
        if isReminderSet {
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
            isReminderSet = false
            return
        }
        
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound]) { [weak self] granted, error in
            guard let self = self, granted, error == nil else { return }
            
            self.scheduleNotification()
        }
    }
    
    private func scheduleNotification() {
        let identifier = "drift_reminder_\(drift.id.uuidString)"
        let meetupDate = resolveDriftDateTime()
        let calendar = Calendar.current
        
        // Calculate trigger date: 2 hours before meetupDate
        let triggerDate = calendar.date(byAdding: .hour, value: -2, to: meetupDate) ?? meetupDate
        
        // If triggerDate is in the past, trigger immediately (e.g. 5 seconds from now)
        var timeInterval = triggerDate.timeIntervalSinceNow
        if timeInterval <= 0 {
            timeInterval = 5 // trigger in 5 seconds
        }
        
        let content = UNMutableNotificationContent()
        content.title = "Reminder: \(drift.title)"
        if meetupDate.timeIntervalSinceNow > 2 * 3600 {
            content.body = "Your meetup starts in 2 hours at \(drift.location)."
        } else {
            content.body = "Your meetup starts soon (at \(drift.time)) at \(drift.location)."
        }
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInterval, repeats: false)
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { [weak self] error in
            if let error = error {
                print("Failed to schedule notification: \(error.localizedDescription)")
            } else {
                DispatchQueue.main.async {
                    self?.isReminderSet = true
                }
            }
        }
    }
    
    func resolveDriftDateTime() -> Date {
        let calendar = Calendar.current
        let now = Date()
        
        var baseDate = now
        let dateStr = drift.date.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        
        if dateStr == "today" {
            baseDate = now
        } else if dateStr == "tomorrow" {
            if let tomorrow = calendar.date(byAdding: .day, value: 1, to: now) {
                baseDate = tomorrow
            }
        } else {
            // Check for weekday names
            let weekdayMap: [String: Int] = [
                "sunday": 1, "monday": 2, "tuesday": 3, "wednesday": 4,
                "thursday": 5, "friday": 6, "saturday": 7
            ]
            
            if let targetWeekday = weekdayMap[dateStr] {
                let currentWeekday = calendar.component(.weekday, from: now)
                var daysToAdd = targetWeekday - currentWeekday
                if daysToAdd < 0 {
                    daysToAdd += 7
                } else if daysToAdd == 0 {
                    // Check if time has already passed today
                    // If it has, schedule for next week
                    if let timeComps = parseTime(drift.time) {
                        var targetComps = calendar.dateComponents([.year, .month, .day], from: now)
                        targetComps.hour = timeComps.hour
                        targetComps.minute = timeComps.minute
                        targetComps.second = 0
                        if let targetDateToday = calendar.date(from: targetComps), targetDateToday < now {
                            daysToAdd = 7
                        }
                    }
                }
                if let nextDate = calendar.date(byAdding: .day, value: daysToAdd, to: now) {
                    baseDate = nextDate
                }
            } else {
                // Absolute date parser fallback e.g. "May 25", "25 May", etc.
                let formats = ["MMMM d, yyyy", "MMMM d", "d MMMM", "yyyy-MM-dd"]
                let fmt = DateFormatter()
                fmt.locale = Locale(identifier: "en_US_POSIX")
                for format in formats {
                    fmt.dateFormat = format
                    if let parsedDate = fmt.date(from: drift.date) {
                        baseDate = parsedDate
                        // Ensure year is set correctly if not parsed
                        if !format.contains("yyyy") {
                            var comps = calendar.dateComponents([.month, .day], from: parsedDate)
                            comps.year = calendar.component(.year, from: now)
                            if let mergedDate = calendar.date(from: comps) {
                                baseDate = mergedDate
                            }
                        }
                        break
                    }
                }
            }
        }
        
        // Merge time component
        if let timeComps = parseTime(drift.time) {
            var comps = calendar.dateComponents([.year, .month, .day], from: baseDate)
            comps.hour = timeComps.hour
            comps.minute = timeComps.minute
            comps.second = 0
            if let finalDate = calendar.date(from: comps) {
                return finalDate
            }
        }
        
        return now
    }
    
    private func parseTime(_ timeStr: String) -> (hour: Int, minute: Int)? {
        let cleaned = timeStr.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        if let date = formatter.date(from: cleaned.uppercased()) {
            let comps = Calendar.current.dateComponents([.hour, .minute], from: date)
            return (comps.hour ?? 0, comps.minute ?? 0)
        }
        formatter.dateFormat = "HH:mm"
        if let date = formatter.date(from: cleaned) {
            let comps = Calendar.current.dateComponents([.hour, .minute], from: date)
            return (comps.hour ?? 0, comps.minute ?? 0)
        }
        
        // Fallback manual parsing if formatters fail
        let parts = cleaned.components(separatedBy: ":")
        if parts.count == 2 {
            let hourStr = parts[0].trimmingCharacters(in: CharacterSet.decimalDigits.inverted)
            if let hour = Int(hourStr) {
                var finalHour = hour
                let minPart = parts[1]
                let minStr = String(minPart.prefix(2)).trimmingCharacters(in: CharacterSet.decimalDigits.inverted)
                if let min = Int(minStr) {
                    if minPart.contains("pm") && finalHour < 12 {
                        finalHour += 12
                    } else if minPart.contains("am") && finalHour == 12 {
                        finalHour = 0
                    }
                    return (finalHour, min)
                }
            }
        }
        return nil
    }
}
