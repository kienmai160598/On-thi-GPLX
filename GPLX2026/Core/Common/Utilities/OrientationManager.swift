import UIKit

@MainActor
final class OrientationManager {
    static let shared = OrientationManager()
    private init() {}

    var allowedOrientations: UIInterfaceOrientationMask = .portrait

    func unlock() {
        allowedOrientations = .allButUpsideDown
    }

    func forceToLandscape() {
        allowedOrientations = .landscape
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            let geometryPreferences = UIWindowScene.GeometryPreferences.iOS(interfaceOrientations: .landscapeRight)
            windowScene.requestGeometryUpdate(geometryPreferences) { _ in }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.allowedOrientations = .allButUpsideDown
        }
    }

    func forceToPortrait() {
        allowedOrientations = .portrait
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            let geometryPreferences = UIWindowScene.GeometryPreferences.iOS(interfaceOrientations: .portrait)
            windowScene.requestGeometryUpdate(geometryPreferences) { _ in }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.allowedOrientations = .allButUpsideDown
        }
    }

    func lock() {
        allowedOrientations = .portrait
        // Force rotation back to portrait
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            let geometryPreferences = UIWindowScene.GeometryPreferences.iOS(interfaceOrientations: .portrait)
            windowScene.requestGeometryUpdate(geometryPreferences)
        }
    }
}
