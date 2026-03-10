import SwiftUI
import Observation

@Observable
final class ThemeStore {

    var primaryColorKey: String {
        didSet { defaults.set(primaryColorKey, forKey: AppConstants.StorageKey.primaryColor) }
    }

    var primaryColor: Color { Color.primaryColor(for: primaryColorKey) }

    var onPrimaryColor: Color {
        if primaryColorKey == "default" {
            return Color.adaptive(light: 0xFAFAFA, dark: 0x1A1A1A)
        }
        return .white
    }

    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        self.primaryColorKey = defaults.string(forKey: AppConstants.StorageKey.primaryColor) ?? "default"
    }
}
