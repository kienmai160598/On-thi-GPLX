import SwiftUI

@main
struct GPLX2026App: App {
    @State private var questionStore = QuestionStore()
    @State private var progressStore = ProgressStore()
    @State private var hazardVideoCache = HazardVideoCache()
    @AppStorage("appThemeMode") private var themeMode: String = "system"
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
                        .task {
                            questionStore.loadQuestions()
                        }
                        .transition(.opacity)
                } else {
                    OnboardingView()
                        .transition(.opacity)
                }
            }
            .animation(.easeInOut(duration: 0.5), value: hasCompletedOnboarding)
            .preferredColorScheme(colorScheme)
        }
    }
}
