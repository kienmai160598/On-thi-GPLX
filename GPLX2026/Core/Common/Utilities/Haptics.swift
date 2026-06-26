import UIKit

enum Haptics {
    static var isEnabled: Bool {
        UserDefaults.standard.object(forKey: AppConstants.StorageKey.hapticsEnabled) as? Bool ?? true
    }

    // Feedback generators are @MainActor UIKit APIs; haptics are always fired
    // from main-actor UI closures, so isolate these to the main actor.
    @MainActor
    static func selection() {
        guard isEnabled else { return }
        UISelectionFeedbackGenerator().selectionChanged()
    }

    @MainActor
    static func impact(_ style: UIImpactFeedbackGenerator.FeedbackStyle = .light) {
        guard isEnabled else { return }
        UIImpactFeedbackGenerator(style: style).impactOccurred()
    }

    @MainActor
    static func notification(_ type: UINotificationFeedbackGenerator.FeedbackType) {
        guard isEnabled else { return }
        UINotificationFeedbackGenerator().notificationOccurred(type)
    }
}
