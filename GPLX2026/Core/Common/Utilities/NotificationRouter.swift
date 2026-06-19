import Foundation

// MARK: - Notification Destination

/// Where a tapped reminder should deep-link to.
enum NotificationDestination: String {
    case practice
    case exam
}

// MARK: - NotificationRouter

/// Shared sink for notification taps. `AppDelegate` (the
/// `UNUserNotificationCenterDelegate`) writes the destination here; the root
/// view observes `pendingDestination` and switches the selected tab.
///
/// A singleton mirrors the existing `OrientationManager.shared` pattern and
/// lets `AppDelegate` — which is created before the SwiftUI environment — reach
/// the same instance the views observe.
@MainActor
@Observable
final class NotificationRouter {
    static let shared = NotificationRouter()

    /// Set when a reminder is tapped; cleared by the view once it has navigated.
    var pendingDestination: NotificationDestination?

    private init() {}

    /// Record a tap routed via `userInfo[NotificationManager.routeKey]`.
    func handle(routeRawValue: String?) {
        guard let raw = routeRawValue,
              let destination = NotificationDestination(rawValue: raw) else { return }
        pendingDestination = destination
    }
}
