import SwiftUI
import Observation

/// Holds the user-selected accent ("primary") color and exposes the resolved
/// colors used throughout the app. The choice is persisted; "default" keeps the
/// app's terracotta brand so existing users see no change.
@Observable
@MainActor
final class ThemeStore {
    private let defaults: UserDefaults

    var accentKey: String {
        didSet { defaults.set(accentKey, forKey: AppConstants.StorageKey.primaryColor) }
    }

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        self.accentKey = defaults.string(forKey: AppConstants.StorageKey.primaryColor) ?? "default"
    }

    var primaryColor: Color {
        switch accentKey {
        case "yellow": Color(hex: 0xFFC233)
        case "green":  Color(hex: 0x43A047)
        case "blue":   Color(hex: 0x3D7BE0)
        default:       .appPrimary
        }
    }

    /// Foreground used on top of `primaryColor`. The yellow accent needs dark
    /// text for legible contrast; the others read well on white.
    var onPrimaryColor: Color {
        accentKey == "yellow" ? Color(hex: 0x1A1A1A) : .appOnPrimary
    }
}
