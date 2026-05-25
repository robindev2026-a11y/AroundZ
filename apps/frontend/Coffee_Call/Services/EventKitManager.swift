import Foundation
import EventKit
import Combine

class EventKitManager {
    static let shared = EventKitManager()
    private let eventStore = EKEventStore()

    private init() {}

    func requestCalendarAccess(completion: @escaping (Bool, Error?) -> Void) {
        if #available(iOS 17.0, *) {
            eventStore.requestWriteOnlyAccessToEvents(completion: completion)
        } else {
            eventStore.requestAccess(to: .event, completion: completion)
        }
    }

    func addDriftToCalendar(drift: Drift, completion: @escaping (Bool, Error?) -> Void) {
        requestCalendarAccess { [weak self] granted, error in
            guard let self = self else { return }

            if !granted || error != nil {
                DispatchQueue.main.async {
                    completion(false, error)
                }
                return
            }

            let event = EKEvent(eventStore: self.eventStore)
            event.title = "CoffeeCall: \(drift.title)"
            event.notes = "Drift Category: \(drift.category.rawValue.capitalized)\nMeeting Point: \(drift.meetingPoint)\n\n\(drift.description)"
            event.location = drift.location

            guard let (startDate, endDate) = self.resolveDriftDates(for: drift) else {
                DispatchQueue.main.async {
                    completion(false, NSError(domain: "EventKitManager", code: 1, userInfo: [NSLocalizedDescriptionKey: "Invalid drift time formatting."]))
                }
                return
            }

            event.startDate = startDate
            event.endDate = endDate
            event.calendar = self.eventStore.defaultCalendarForNewEvents

            do {
                try self.eventStore.save(event, span: .thisEvent)
                DispatchQueue.main.async {
                    completion(true, nil)
                }
            } catch let saveError {
                DispatchQueue.main.async {
                    completion(false, saveError)
                }
            }
        }
    }

    private func resolveDriftDates(for drift: Drift) -> (Date, Date)? {
        // Time format is like "6:30 PM", date is "Today", "Tomorrow", or a specific date.
        // For MVP, we will try to resolve Today/Tomorrow based on current time.

        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"

        guard let startParsed = formatter.date(from: drift.time),
              let endParsed = formatter.date(from: drift.endTime) else {
            return nil
        }

        let calendar = Calendar.current
        let now = Date()

        var baseDate = now
        if drift.date.lowercased() == "tomorrow" {
            baseDate = calendar.date(byAdding: .day, value: 1, to: now) ?? now
        } else if drift.date.lowercased() != "today" && drift.date.lowercased() != "now" {
            // Attempt to parse custom date if needed, fallback to today for MVP
            baseDate = now
        }

        let startComponents = calendar.dateComponents([.hour, .minute], from: startParsed)
        let endComponents = calendar.dateComponents([.hour, .minute], from: endParsed)

        guard let finalStart = calendar.date(bySettingHour: startComponents.hour ?? 0, minute: startComponents.minute ?? 0, second: 0, of: baseDate),
              let finalEnd = calendar.date(bySettingHour: endComponents.hour ?? 0, minute: endComponents.minute ?? 0, second: 0, of: baseDate) else {
            return nil
        }

        // Handle case where end time wraps around past midnight
        var resolvedEnd = finalEnd
        if resolvedEnd < finalStart {
            resolvedEnd = calendar.date(byAdding: .day, value: 1, to: resolvedEnd) ?? resolvedEnd
        }

        return (finalStart, resolvedEnd)
    }
}
