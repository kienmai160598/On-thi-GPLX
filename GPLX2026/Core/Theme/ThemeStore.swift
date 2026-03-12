import SwiftUI
import Observation

@Observable
final class ThemeStore {

    var primaryColor: Color { .appPrimary }
    var onPrimaryColor: Color { .appOnPrimary }

    init(defaults: UserDefaults = .standard) {}
}
