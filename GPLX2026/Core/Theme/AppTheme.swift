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
    static let textLight     = adaptive(light: 0xA3A3A3, dark: 0x525252)

    static let appTextDark   = textDark
    static let appTextMedium = textMedium
    static let appTextLight  = textLight

    // ── Background ─────────────────────────────────────────────────────

    static let scaffoldBg    = adaptive(light: 0xEEECE6, dark: 0x2F2B26)
    static let appScaffoldBg = scaffoldBg
    static let appBgColor    = scaffoldBg
    static let cardBg        = adaptive(light: 0xFAF9F7, dark: 0x3D3935)
    static let statsBg       = adaptive(light: 0xF0EDE8, dark: 0x2F2B26)

    // ── Semantic ───────────────────────────────────────────────────────

    static let appSuccess    = adaptive(light: 0x22C55E, dark: 0x4ADE80)
    static let appWarning    = adaptive(light: 0xF59E0B, dark: 0xFBBF24)
    static let appError      = adaptive(light: 0xEF4444, dark: 0xF87171)

    // ── Neutral helpers ────────────────────────────────────────────────

    static let appDivider    = adaptive(light: 0xE5E5E5, dark: 0x262626)

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

    static let diemLietBg    = adaptive(light: 0xFEF2F2, dark: 0x1C1010)
    static let diemLietBadge = appError
}

// MARK: - GlassContainer (re-injects @Observable environments)

@available(iOS 26.0, *)
private struct GlassContainerModifier: ViewModifier {
    @Environment(LayoutMetrics.self) private var metrics
    @Environment(QuestionStore.self) private var questionStore
    @Environment(ProgressStore.self) private var progressStore
    @Environment(ThemeStore.self) private var themeStore

    func body(content: Content) -> some View {
        GlassEffectContainer { content }
            .environment(metrics)
            .environment(questionStore)
            .environment(progressStore)
            .environment(themeStore)
    }
}

// MARK: - GlassCard ViewModifier

struct GlassCard: ViewModifier {
    var cornerRadius: CGFloat = 20
    var interactive: Bool = true

    func body(content: Content) -> some View {
        if #available(iOS 26.0, *) {
            if interactive {
                content
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .contentShape(Rectangle())
                    .glassEffect(.regular.interactive(), in: .rect(cornerRadius: cornerRadius))
            } else {
                content
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .contentShape(Rectangle())
                    .glassEffect(.regular, in: .rect(cornerRadius: cornerRadius))
            }
        } else {
            content
                .frame(maxWidth: .infinity, alignment: .leading)
                .contentShape(Rectangle())
                .background(Color.cardBg)
                .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
        }
    }
}

extension View {
    func glassCard(cornerRadius: CGFloat = 20, interactive: Bool = true) -> some View {
        modifier(GlassCard(cornerRadius: cornerRadius, interactive: interactive))
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

    /// Constrain content to readable width on iPad (centered)
    func iPadReadable(maxWidth: CGFloat = 700) -> some View {
        frame(maxWidth: maxWidth)
            .frame(maxWidth: .infinity)
    }
}

// MARK: - Exam Screen Routing

enum ExamScreen: Identifiable {
    case mockExam(examSetId: Int? = nil)
    case simulationExam(mode: SimulationExamView.Mode)
    case hazardTest(mode: HazardTestView.Mode)
    case questionView(topicKey: String, startIndex: Int)

    var id: String {
        switch self {
        case .mockExam(let id): "mock-\(id ?? -1)"
        case .simulationExam(let mode): "sim-\(mode)"
        case .hazardTest(let mode): "hazard-\(mode)"
        case .questionView(let key, let idx): "q-\(key)-\(idx)"
        }
    }

    @ViewBuilder
    var destination: some View {
        switch self {
        case .mockExam(let id): MockExamView(examSetId: id)
        case .simulationExam(let mode): SimulationExamView(mode: mode)
        case .hazardTest(let mode): HazardTestView(mode: mode)
        case .questionView(let key, let idx): QuestionView(topicKey: key, startIndex: idx)
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
    func screenHeader(_ title: String) -> some View {
        self
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.large)
            .toolbarBackgroundVisibility(.hidden, for: .navigationBar)
            .background {
                ZStack {
                    Color.scaffoldBg.ignoresSafeArea()
                    AnimatedBackground()
                }
            }
    }
}

// MARK: - GlassBackground ViewModifier

struct GlassBackground: ViewModifier {
    func body(content: Content) -> some View {
        ZStack {
            Color.scaffoldBg.ignoresSafeArea()
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


