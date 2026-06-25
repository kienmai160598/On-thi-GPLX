import XCTest
import SwiftUI
@testable import GPLX2026

@MainActor
final class ThemeStoreTests: XCTestCase {

    private func makeDefaults() -> UserDefaults {
        let suite = "ThemeStoreTests-\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suite)!
        defaults.removePersistentDomain(forName: suite)
        return defaults
    }

    func testDefaultsToBrandWhenNothingStored() {
        let store = ThemeStore(defaults: makeDefaults())
        XCTAssertEqual(store.accentKey, "default")
        XCTAssertEqual(store.primaryColor, Color.appPrimary)
        XCTAssertEqual(store.onPrimaryColor, Color.appOnPrimary)
    }

    func testReadsStoredAccentKeyOnInit() {
        let defaults = makeDefaults()
        defaults.set("green", forKey: AppConstants.StorageKey.primaryColor)
        let store = ThemeStore(defaults: defaults)
        XCTAssertEqual(store.accentKey, "green")
    }

    func testSettingAccentKeyPersistsAcrossInstances() {
        let defaults = makeDefaults()
        let store = ThemeStore(defaults: defaults)
        store.accentKey = "blue"
        XCTAssertEqual(defaults.string(forKey: AppConstants.StorageKey.primaryColor), "blue")

        let reloaded = ThemeStore(defaults: defaults)
        XCTAssertEqual(reloaded.accentKey, "blue")
    }

    func testYellowAccentUsesDarkForeground() {
        let store = ThemeStore(defaults: makeDefaults())
        store.accentKey = "yellow"
        XCTAssertEqual(store.onPrimaryColor, Color(hex: 0x1A1A1A))

        store.accentKey = "blue"
        XCTAssertEqual(store.onPrimaryColor, Color.appOnPrimary)
    }

    func testEachAccentResolvesToADistinctColor() {
        let store = ThemeStore(defaults: makeDefaults())
        var colors: [Color] = []
        for key in ["default", "yellow", "green", "blue"] {
            store.accentKey = key
            colors.append(store.primaryColor)
        }
        // All four accents should be visually distinct.
        for i in colors.indices {
            for j in (i + 1)..<colors.count {
                XCTAssertNotEqual(colors[i], colors[j], "Accents \(i) and \(j) should differ")
            }
        }
    }
}
