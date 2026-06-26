import SwiftUI
import UIKit

// MARK: - Enable Swipe-Back When Nav Bar Is Hidden

extension UINavigationController: @retroactive UIGestureRecognizerDelegate {
    override open func viewDidLoad() {
        super.viewDidLoad()
        interactivePopGestureRecognizer?.delegate = self
    }

    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        viewControllers.count > 1
    }
}

// MARK: - App Color Palette (Black & White – Neutral)

extension Color {

    // ── Hex initializer ────────────────────────────────────────────────

    init(hex: UInt32, opacity: Double = 1.0) {
        self.init(
            red:   Double((hex >> 16) & 0xFF) / 255.0,
            green: Double((hex >>  8) & 0xFF) / 255.0,
            blue:  Double( hex        & 0xFF) / 255.0,
            opacity: opacity
        )
    }

    /// Adaptive color that switches between light/dark hex values.
    static func adaptive(light: UInt32, dark: UInt32) -> Color {
        Color(UIColor { traits in
            let hex = traits.userInterfaceStyle == .dark ? dark : light
            return UIColor(
                red: CGFloat((hex >> 16) & 0xFF) / 255.0,
                green: CGFloat((hex >> 8) & 0xFF) / 255.0,
                blue: CGFloat(hex & 0xFF) / 255.0,
                alpha: 1.0
            )
        })
    }

    // ── Primary ────────────────────────────────────────────────────────────

    static let appPrimary   = adaptive(light: 0xD4714E, dark: 0xE8956F)  // Warm terracotta
    static let appOnPrimary = Color.white
    static let primaryDark  = adaptive(light: 0x0A0A0A, dark: 0xFFFFFF)

    // ── Text ───────────────────────────────────────────────────────────

    static let textDark      = adaptive(light: 0x171717, dark: 0xF5F5F5)
    static let textMedium    = adaptive(light: 0x737373, dark: 0xA3A3A3)
    static let textLight     = adaptive(light: 0xA3A3A3, dark: 0x78716C)

    static let appTextDark   = textDark
    static let appTextMedium = textMedium
    static let appTextLight  = textLight

    // ── Background ─────────────────────────────────────────────────────

    static let scaffoldBg    = adaptive(light: 0xEEECE6, dark: 0x1C1917)
    static let appScaffoldBg = scaffoldBg
    static let appBgColor    = scaffoldBg
    static let cardBg        = adaptive(light: 0xFAF9F7, dark: 0x292524)
    static let statsBg       = adaptive(light: 0xF0EDE8, dark: 0x231F1C)
    /// Frosted card fill: a translucent surface over the app background so cards
    /// read as glass (design uses white ~80%). Adaptive for dark mode.
    static let cardTranslucent = adaptive(light: 0xFFFFFF, dark: 0x2C2A28).opacity(0.85)
    /// Hairline border that defines a card edge without adding visual weight.
    static let cardBorder      = adaptive(light: 0x000000, dark: 0xFFFFFF).opacity(0.08)

    /// Warm-neutral gradient stops for the app-wide background. `scaffoldBg`
    /// stays the middle stop so cards/components keep matching the mid-tone.
    static let scaffoldGradientTop    = adaptive(light: 0xFBF8F0, dark: 0x332D28)
    static let scaffoldGradientBottom = adaptive(light: 0xDAD3C4, dark: 0x0E0B0A)

    // ── Semantic ───────────────────────────────────────────────────────

    static let appSuccess    = adaptive(light: 0x22C55E, dark: 0x4ADE80)
    static let appWarning    = adaptive(light: 0xF59E0B, dark: 0xFBBF24)
    static let appError      = adaptive(light: 0xEF4444, dark: 0xF87171)

    // ── Amber selection (the design's "selected / active" wash) ──────────
    // Recurring across onboarding, settings, and exam-set tiles for a chosen
    // option, distinct from the terracotta primary.
    static let amberWash     = adaptive(light: 0xFFE9B0, dark: 0x3A2E14)
    static let amberInk      = adaptive(light: 0x7A4A00, dark: 0xF3C97A)
    static let amberBorder   = adaptive(light: 0xE8B53D, dark: 0x6E5526)

    // ── Ink (prominent charcoal CTA + dark toggle) ──────────────────────
    // The onboarding design uses a near-black surface for the primary CTA and
    // the "on" toggle. It inverts to near-white in dark mode so the control
    // and its label stay high-contrast in both appearances.
    static let appInk        = adaptive(light: 0x171717, dark: 0xF5F5F5)
    static let appOnInk      = adaptive(light: 0xFFFFFF, dark: 0x171717)

    // ── Neutral icon-box wash (pairs with `appTextDark` glyphs) ─────────
    // Warm light-gray fill for the non-accented icon boxes in onboarding; the
    // amber boxes use `amberWash` + `amberInk` instead.
    static let neutralWash   = adaptive(light: 0xF4F2EE, dark: 0x2C2A28)

    // ── Neutral helpers ────────────────────────────────────────────────

    static let appDivider    = adaptive(light: 0xE5E5E5, dark: 0x44403C)

    /// Disabled / unanswered state color. Meets WCAG AA contrast (≥ 3:1 for large text,
    /// ≥ 4.5:1 for normal text) against both light and dark backgrounds.
    static let appDisabled   = adaptive(light: 0x737373, dark: 0x6B6B6B)

    // ── Topic Colors ────────────────────────────────────────────────────

    static let topicQuyDinh  = adaptive(light: 0x3B82F6, dark: 0x60A5FA)  // Blue
    static let topicKyThuat  = adaptive(light: 0x8B5CF6, dark: 0xA78BFA)  // Violet
    static let topicCauTao   = adaptive(light: 0xF59E0B, dark: 0xFBBF24)  // Amber
    static let topicBienBao  = adaptive(light: 0xEF4444, dark: 0xF87171)  // Red
    static let topicSaHinh   = adaptive(light: 0x10B981, dark: 0x34D399)  // Emerald

    // ── Accents (grayscale aliases) ───────────────────────────────────

    static let accentGreen   = adaptive(light: 0x525252, dark: 0x8E8E8E)
    static let accentRose    = adaptive(light: 0x4A4A4A, dark: 0xB0B0B0)

    // ── Diem Liet ──────────────────────────────────────────────────────

    static let diemLietBg    = adaptive(light: 0xFEF2F2, dark: 0x2C1515)
    static let diemLietBadge = appError
}

// MARK: - GlassContainer (re-injects @Observable environments)

@available(iOS 26.0, *)
private struct GlassContainerModifier: ViewModifier {
    @Environment(LayoutMetrics.self) private var metrics
    @Environment(QuestionStore.self) private var questionStore
    @Environment(ProgressStore.self) private var progressStore
    @Environment(ThemeStore.self) private var themeStore
    @Environment(HazardVideoCache.self) private var hazardVideoCache

    func body(content: Content) -> some View {
        GlassEffectContainer { content }
            .environment(metrics)
            .environment(questionStore)
            .environment(progressStore)
            .environment(themeStore)
            .environment(hazardVideoCache)
    }
}

// MARK: - GlassCard ViewModifier

struct GlassCard: ViewModifier {
    var cornerRadius: CGFloat = 20
    /// Retained for source compatibility with existing call sites; flat cards
    /// have no interactive glass so it is ignored.
    var interactive: Bool = true
    /// When set, the card uses an attention background: a soft wash of `tint`
    /// over the neutral fill plus a faint matching border, so cards that need
    /// the user's attention stand out from ordinary flat cards.
    var tint: Color? = nil

    func body(content: Content) -> some View {
        // Translucent "glass" card: a frosted fill over the app background plus a
        // hairline border. Attention cards add a tinted wash + matching border.
        content
            .frame(maxWidth: .infinity, alignment: .leading)
            .contentShape(Rectangle())
            .background {
                let shape = RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                shape.fill(Color.cardTranslucent)
                    .overlay {
                        if let tint {
                            shape.fill(tint.opacity(0.14))
                            shape.strokeBorder(tint.opacity(0.40), lineWidth: 1)
                        } else {
                            shape.strokeBorder(Color.cardBorder, lineWidth: 1)
                        }
                    }
            }
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
    }
}

extension View {
    func glassCard(cornerRadius: CGFloat = 20, interactive: Bool = true, tint: Color? = nil) -> some View {
        modifier(GlassCard(cornerRadius: cornerRadius, interactive: interactive, tint: tint))
    }

    @ViewBuilder
    func glassContainer() -> some View {
        if #available(iOS 26.0, *) {
            // GlassEffectContainer strips @Observable environments — re-inject via modifier
            modifier(GlassContainerModifier())
        } else {
            self
        }
    }

}

// MARK: - Exam Screen Routing

enum ExamScreen: Identifiable {
    case mockExam(examSetId: Int? = nil)
    case simulationExam(mode: SimulationExamView.Mode)
    case hazardTest(mode: HazardTestView.Mode)
    case questionView(topicKey: String, startIndex: Int)
    case dailyChallenge
    /// Settings & search open full-screen (same presentation as a question), so
    /// they hide the tab bar and slide up over the content.
    case settings
    case search

    var id: String {
        switch self {
        case .mockExam(let id): "mock-\(id ?? -1)"
        case .simulationExam(let mode): "sim-\(mode)"
        case .hazardTest(let mode): "hazard-\(mode)"
        case .questionView(let key, let idx): "q-\(key)-\(idx)"
        case .dailyChallenge: "daily-challenge"
        case .settings: "settings"
        case .search: "search"
        }
    }

    @ViewBuilder @MainActor
    var destination: some View {
        switch self {
        case .mockExam(let id): MockExamView(examSetId: id)
        case .simulationExam(let mode): SimulationExamView(mode: mode)
        case .hazardTest(let mode): HazardTestView(mode: mode)
        case .questionView(let key, let idx): QuestionView(topicKey: key, startIndex: idx)
        case .dailyChallenge: DailyChallengeView()
        case .settings: SettingsView()
        case .search: QuestionSearchView()
        }
    }
}

private struct OpenExamKey: EnvironmentKey {
    nonisolated(unsafe) static let defaultValue: (ExamScreen) -> Void = { _ in }
}

private struct PopToRootKey: EnvironmentKey {
    nonisolated(unsafe) static let defaultValue: () -> Void = {}
}

extension EnvironmentValues {
    var openExam: (ExamScreen) -> Void {
        get { self[OpenExamKey.self] }
        set { self[OpenExamKey.self] = newValue }
    }

    var popToRoot: () -> Void {
        get { self[PopToRootKey.self] }
        set { self[PopToRootKey.self] = newValue }
    }
}

// MARK: - Screen Header

extension View {
    /// Unified navigation bar setup for every screen in the app.
    /// Ensures every screen gets the Apple system blur backdrop on the navigation bar.
    /// - Parameters:
    ///   - title: The navigation bar title text.
    ///   - titleDisplayMode: `.large` (default) for top-level tabs, `.inline` for detail/exam screens.
    ///   - hideBackButton: Whether to hide the system back button (default `false`).
    func screenHeader(
        _ title: String,
        titleDisplayMode: NavigationBarItem.TitleDisplayMode = .large,
        hideBackButton: Bool = false
    ) -> some View {
        self
            .navigationTitle(title)
            .screenHeaderStyle(titleDisplayMode: titleDisplayMode, hideBackButton: hideBackButton)
    }

    /// Applies only the navigation bar style (blur backdrop, background, display mode)
    /// without setting a title. Use when the title is set separately (e.g. by the caller).
    func screenHeaderStyle(
        titleDisplayMode: NavigationBarItem.TitleDisplayMode = .inline,
        hideBackButton: Bool = false
    ) -> some View {
        self
            .navigationBarTitleDisplayMode(titleDisplayMode)
            .navigationBarBackButtonHidden(hideBackButton)
            .toolbarBackgroundVisibility(.automatic, for: .navigationBar)
            .background {
                ZStack {
                    ScaffoldBackground()
                    AnimatedBackground()
                }
            }
    }
}

// MARK: - Scaffold Background (app-wide gradient)

/// The app's full-screen background: a light, vertical gradient that rises from
/// a soft wash of the user's accent at the bottom to a clean neutral at the top.
/// Single source of truth so every screen shares the same backdrop, and it
/// follows the configured accent colour automatically.
struct ScaffoldBackground: View {
    @Environment(ThemeStore.self) private var themeStore
    /// Optional override for the accent tint. Defaults to the user's configured
    /// accent so the whole app's backdrop follows the chosen colour.
    var glow: Color? = nil

    var body: some View {
        let accent = glow ?? themeStore.primaryColor
        ZStack {
            // Light neutral base keeps every screen bright and matches the cards.
            Color.scaffoldBg

            // Accent wash: strongest at the bottom, fading out toward the top.
            LinearGradient(
                colors: [accent.opacity(0.18), accent.opacity(0.05), .clear],
                startPoint: .bottom,
                endPoint: .top
            )
        }
        .ignoresSafeArea()
    }
}

// MARK: - GlassBackground ViewModifier

struct GlassBackground: ViewModifier {
    func body(content: Content) -> some View {
        ZStack {
            ScaffoldBackground()
            AnimatedBackground()
            content
        }
    }
}

extension View {
    func glassBackground() -> some View {
        modifier(GlassBackground())
    }
}

// MARK: - Section Filter (Dropdown)

struct SectionRow: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    var filledIcon: Bool = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                Image(systemName: icon)
                    .font(.appSans(size: 20))
                    .foregroundStyle(filledIcon ? .white : color)
                    .frame(width: 44, height: 44)
                    .background(filledIcon ? color : color.opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: 8))

                VStack(alignment: .leading, spacing: 3) {
                    Text(title)
                        .font(.appSerif(size: 16, weight: .bold))
                        .foregroundStyle(Color.appTextDark)
                    Text(subtitle)
                        .font(.appSans(size: 13))
                        .foregroundStyle(Color.appTextMedium)
                }

                Spacer(minLength: 4)

                Image(systemName: "chevron.right")
                    .font(.appSans(size: 12, weight: .medium))
                    .foregroundStyle(Color.appTextLight)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 12)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}


