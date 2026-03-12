import UIKit

@MainActor
final class OrientationManager {
    static let shared = OrientationManager()
    static let isIPad = UIDevice.current.userInterfaceIdiom == .pad
    private init() {}

    /// iPad: always allow rotation. iPhone: portrait by default.
    var allowedOrientations: UIInterfaceOrientationMask = isIPad ? .all : .portrait

    func unlock() {
        allowedOrientations = .allButUpsideDown
    }

    func forceToLandscape() {
        guard !Self.isIPad else { return }
        allowedOrientations = .landscape
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            let prefs = UIWindowScene.GeometryPreferences.iOS(interfaceOrientations: .landscapeRight)
            windowScene.requestGeometryUpdate(prefs) { _ in }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.allowedOrientations = .allButUpsideDown
        }
    }

    func forceToPortrait() {
        guard !Self.isIPad else { return }
        allowedOrientations = .portrait
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            let prefs = UIWindowScene.GeometryPreferences.iOS(interfaceOrientations: .portrait)
            windowScene.requestGeometryUpdate(prefs) { _ in }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.allowedOrientations = .allButUpsideDown
        }
    }

    /// Lock to portrait (iPhone only — iPad stays free)
    func lock() {
        guard !Self.isIPad else { return }
        allowedOrientations = .portrait
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            let prefs = UIWindowScene.GeometryPreferences.iOS(interfaceOrientations: .portrait)
            windowScene.requestGeometryUpdate(prefs)
        }
    }
}
