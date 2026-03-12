import SwiftUI
import UIKit

// MARK: - App Typography (3-Font System)
//
// 1. appSerif  → AnthropicSerif: titles, headings, display text
// 2. appSans   → AnthropicSans:  body, UI labels, buttons (default)
// 3. appMono   → SF Mono:        numbers, scores, timers, data

extension Font {
    private static let serifName = "AnthropicSerifVariable-TextLight"
    private static let sansName  = "AnthropicSansVariable-TextLight"

    // Shared helper: build a variable Anthropic font with weight + optical size
    // Weight curve is softened vs CSS standard for smoother iOS rendering
    private static func anthropic(_ baseName: String, size: CGFloat, weight: Weight) -> Font? {
        guard UIFont(name: baseName, size: size) != nil else { return nil }
        let w: Int = switch weight {
        case .ultraLight, .thin: 300
        case .light: 320
        case .medium: 440
        case .semibold: 510
        case .bold: 590
        case .heavy, .black: 680
        default: 370  // regular — slightly lighter than CSS 400
        }
        let uiFont = UIFont(name: baseName, size: size)!
        let desc = uiFont.fontDescriptor.addingAttributes([
            .init(rawValue: "NSCTFontUIUsageAttribute"): "",
            kCTFontVariationAttribute as UIFontDescriptor.AttributeName: [
                0x77676874: w,
                0x6F70737A: min(max(Int(size), 16), 48)
            ]
        ])
        return Font(UIFont(descriptor: desc, size: size))
    }

    /// Serif: titles, headings, hero text → AnthropicSerif → Georgia → system serif
    static func appSerif(size: CGFloat, weight: Weight = .regular) -> Font {
        if let f = anthropic(serifName, size: size, weight: weight) { return f }
        return .system(size: size, weight: weight, design: .serif)
    }

    /// Sans: body, labels, buttons → AnthropicSans → system default
    static func appSans(size: CGFloat, weight: Weight = .regular) -> Font {
        if let f = anthropic(sansName, size: size, weight: weight) { return f }
        return .system(size: size, weight: weight)
    }

    /// Mono: numbers, scores, timers → SF Mono
    static func appMono(size: CGFloat, weight: Weight = .regular) -> Font {
        .system(size: size, weight: weight, design: .monospaced)
    }

    /// Legacy alias — maps to appSans
    static func fira(size: CGFloat, weight: Weight = .regular) -> Font {
        appSans(size: size, weight: weight)
    }
}

final class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        configureNavBarAppearance()
        return true
    }

    func application(
        _ application: UIApplication,
        supportedInterfaceOrientationsFor window: UIWindow?
    ) -> UIInterfaceOrientationMask {
        OrientationManager.shared.allowedOrientations
    }

    private func configureNavBarAppearance() {
        let serifName = "AnthropicSerifVariable-TextLight"

        func makeFont(size: CGFloat, weight: Int) -> UIFont {
            guard let base = UIFont(name: serifName, size: size) else {
                return .systemFont(ofSize: size, weight: weight > 500 ? .semibold : .regular)
            }
            let desc = base.fontDescriptor.addingAttributes([
                .init(rawValue: "NSCTFontUIUsageAttribute"): "",
                kCTFontVariationAttribute as UIFontDescriptor.AttributeName: [
                    0x77676874: weight,
                    0x6F70737A: min(max(Int(size), 16), 48)
                ]
            ])
            return UIFont(descriptor: desc, size: size)
        }

        let largeTitleFont = makeFont(size: 34, weight: 590)
        let inlineTitleFont = makeFont(size: 17, weight: 510)

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
            .trackLayoutMetrics()
            .environment(themeStore)
            .environment(layoutMetrics)
            .animation(.easeInOut(duration: 0.5), value: hasCompletedOnboarding)
            .preferredColorScheme(colorScheme)
            .animation(.easeInOut(duration: 0.3), value: themeMode)
            .font(.appSans(size: 16))
            .environment(\.locale, Locale(identifier: "vi"))
        }
    }
}
