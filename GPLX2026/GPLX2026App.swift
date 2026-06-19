import SwiftUI
import UIKit
import UserNotifications

// MARK: - App Typography (Be Vietnam Pro)
//
// Be Vietnam Pro is a humanist sans designed for Vietnamese — clear diacritics
// and high screen legibility. It's the single UI family (titles use heavier
// weights). Numbers/timers stay on the system monospaced face.
//
// 1. appSerif → Be Vietnam Pro: titles, headings, display text
// 2. appSans  → Be Vietnam Pro: body, UI labels, buttons (default)
// 3. appMono  → system monospaced (SF Mono): numbers, scores, timers, data

extension Font {
    /// Maps a SwiftUI weight to the matching bundled Be Vietnam Pro face.
    private static func beVietnamPro(_ weight: Weight) -> String {
        switch weight {
        case .ultraLight, .thin, .light: "BeVietnamPro-Light"
        case .medium:                    "BeVietnamPro-Medium"
        case .semibold:                  "BeVietnamPro-SemiBold"
        case .bold, .heavy, .black:      "BeVietnamPro-Bold"
        default:                         "BeVietnamPro-Regular"
        }
    }

    /// Titles, headings, hero text.
    static func appSerif(size: CGFloat, weight: Weight = .regular) -> Font {
        .custom(beVietnamPro(weight), fixedSize: size)
    }

    /// Body, labels, buttons (default UI font).
    static func appSans(size: CGFloat, weight: Weight = .regular) -> Font {
        .custom(beVietnamPro(weight), fixedSize: size)
    }

    /// Mono: numbers, scores, timers.
    static func appMono(size: CGFloat, weight: Weight = .regular) -> Font {
        .system(size: size, weight: weight, design: .monospaced)
    }

    /// Legacy alias — maps to appSans.
    static func fira(size: CGFloat, weight: Weight = .regular) -> Font {
        appSans(size: size, weight: weight)
    }
}

final class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        configureNavBarAppearance()
        UNUserNotificationCenter.current().delegate = self
        return true
    }

    func application(
        _ application: UIApplication,
        supportedInterfaceOrientationsFor window: UIWindow?
    ) -> UIInterfaceOrientationMask {
        OrientationManager.shared.allowedOrientations
    }

    // MARK: - UNUserNotificationCenterDelegate

    /// Show reminders even while the app is in the foreground (otherwise iOS
    /// suppresses them).
    nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .sound, .badge])
    }

    /// Deep-link the tapped reminder to the relevant screen.
    nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let route = response.notification.request.content.userInfo[NotificationManager.routeKey] as? String
        Task { @MainActor in
            NotificationRouter.shared.handle(routeRawValue: route)
        }
        completionHandler()
    }

    private func configureNavBarAppearance() {
        // Be Vietnam Pro to match `Font.appSerif` headings.
        func makeFont(_ name: String, size: CGFloat, fallback: UIFont.Weight) -> UIFont {
            UIFont(name: name, size: size) ?? .systemFont(ofSize: size, weight: fallback)
        }

        let largeTitleFont = makeFont("BeVietnamPro-Bold", size: 34, fallback: .bold)
        let inlineTitleFont = makeFont("BeVietnamPro-SemiBold", size: 17, fallback: .semibold)

        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.largeTitleTextAttributes = [.font: largeTitleFont]
        appearance.titleTextAttributes = [.font: inlineTitleFont]

        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
    }
}

@main
struct GPLX2026App: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @State private var questionStore = QuestionStore()
    @State private var progressStore = ProgressStore()
    @State private var hazardVideoCache = HazardVideoCache()
    @State private var themeStore = ThemeStore()
    @State private var layoutMetrics = LayoutMetrics()
    @AppStorage(AppConstants.StorageKey.themeMode) private var themeMode: String = "system"
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @AppStorage(AppConstants.StorageKey.dailyReminderEnabled) private var dailyReminderEnabled = false
    @AppStorage(AppConstants.StorageKey.dailyReminderHour) private var dailyReminderHour = 20
    @AppStorage(AppConstants.StorageKey.examCountdownEnabled) private var examCountdownEnabled = false
    @AppStorage(AppConstants.StorageKey.dailyGoalNudgeEnabled) private var dailyGoalNudgeEnabled = false
    @Environment(\.scenePhase) private var scenePhase
    @State private var splashFinished = false

    private var colorScheme: ColorScheme? {
        switch themeMode {
        case "light": return .light
        case "dark": return .dark
        default: return nil
        }
    }

    var body: some Scene {
        WindowGroup {
            ZStack {
                // Content is always mounted underneath
                Group {
                    if hasCompletedOnboarding {
                        ContentView()
                    } else {
                        OnboardingView()
                    }
                }

                // Splash overlays on top, fades away to reveal content
                if !splashFinished {
                    SplashView(isFinished: $splashFinished)
                        .task {
                            await questionStore.loadQuestions()
                            // Initial reminder sync once data is loaded so the
                            // daily-reminder copy reflects real progress.
                            await syncReminders()
                        }
                        .transition(.opacity)
                        .zIndex(1)
                }
            }
            .trackLayoutMetrics()
            .environment(questionStore)
            .environment(progressStore)
            .environment(hazardVideoCache)
            .environment(themeStore)
            .environment(layoutMetrics)
            .animation(.easeInOut(duration: 0.5), value: hasCompletedOnboarding)
            .animation(.easeOut(duration: 0.3), value: splashFinished)
            .preferredColorScheme(colorScheme)
            .animation(.easeInOut(duration: 0.3), value: themeMode)
            .font(.appSans(size: 16))
            .environment(\.locale, Locale(identifier: "vi"))
            .onChange(of: scenePhase) { _, phase in
                // Re-sync on every foreground: refreshes reminder copy, picks
                // up revoked permission, and re-arms the goal nudge for today.
                if phase == .active {
                    Task { await syncReminders() }
                }
            }
        }
    }

    /// Reconcile scheduled reminders with current settings and authorization.
    /// If permission was revoked in iOS Settings, turn the toggles off so the
    /// UI stays honest.
    @MainActor
    private func syncReminders() async {
        if await NotificationManager.authorizationStatus() == .denied {
            if dailyReminderEnabled { dailyReminderEnabled = false }
            if examCountdownEnabled { examCountdownEnabled = false }
            if dailyGoalNudgeEnabled { dailyGoalNudgeEnabled = false }
        }
        await NotificationManager.syncReminders(
            dailyEnabled: dailyReminderEnabled,
            hour: dailyReminderHour,
            examCountdownEnabled: examCountdownEnabled,
            dailyGoalNudgeEnabled: dailyGoalNudgeEnabled,
            progressStore: progressStore,
            questionStore: questionStore
        )
    }
}
