import Foundation

/// Represents an in-app notification.
///
/// **TODO: FUTURE ARCHITECTURE (MARKED)**
/// Currently, this is generated dynamically from the active `Drift`'s `pendingRequests`
/// for the MVP so we don't have to maintain a separate Firebase collection.
///
/// **Future Phase:**
/// Create a dedicated `notifications` collection in Firebase. When a user requests to join,
/// a Cloud Function (or the client) should write a Notification document for the host.
/// When the host accepts, write a Notification document for the sender.
/// This model should then conform to `Codable` and be fetched via `NotificationService`.
struct AppNotification: Identifiable, Hashable {
    let id: UUID
    let driftId: UUID
    let title: String
    let message: String
    let timestamp: String
    let isRead: Bool
    let type: NotificationType

    enum NotificationType {
        case joinRequest
        case accepted
        case general
    }
}
