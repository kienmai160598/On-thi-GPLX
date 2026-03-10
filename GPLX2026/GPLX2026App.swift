import SwiftUI
import UIKit

final class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        supportedInterfaceOrientationsFor window: UIWindow?
    ) -> UIInterfaceOrientationMask {
        OrientationManager.shared.allowedOrientations
    }
}

@main
struct GPLX2026App: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @State private var questionStore = QuestionStore()
    @State private var progressStore = ProgressStore()
    @State private var hazardVideoCache = HazardVideoCache()
    @State private var themeStore = ThemeStore()
    @AppStorage(AppConstants.StorageKey.themeMode) private var themeMode: String = "system"
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false

    private var colorScheme: ColorScheme? {
        switch themeMode {
        case "light": return .light
        case "dark": return .dark
        default: return nil
        }
    }

    var body: some Scene {
        WindowGroup {
            Group {
                if hasCompletedOnboarding {
                    ContentView()
                        .environment(questionStore)
                        .environment(progressStore)
                        .environment(hazardVideoCache)
                        .environment(themeStore)
                        .task {
                            questionStore.loadQuestions()
                        }
                        .transition(.opacity)
                } else {
                    OnboardingView()
                        .environment(themeStore)
                        .transition(.opacity)
                }
            }
            .animation(.easeInOut(duration: 0.5), value: hasCompletedOnboarding)
            .preferredColorScheme(colorScheme)
            .animation(.easeInOut(duration: 0.3), value: themeMode)
            .environment(\.locale, Locale(identifier: "vi"))
        }
    }
}
