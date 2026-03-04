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

    // ── Primary (dynamic) ────────────────────────────────────────────────

    static var appPrimary: Color {
        primaryColor(for: UserDefaults.standard.string(forKey: "appPrimaryColor") ?? "default")
    }

    static var appOnPrimary: Color {
        let key = UserDefaults.standard.string(forKey: "appPrimaryColor") ?? "default"
        if key == "default" { return adaptive(light: 0xFAFAFA, dark: 0x0A0A0A) }
        return .white
    }

    static let primaryDark = adaptive(light: 0x0A0A0A, dark: 0xFFFFFF)

    static func primaryColor(for key: String) -> Color {
        switch key {
        case "blue":   return .blue
        case "indigo": return .indigo
        case "purple": return .purple
        case "pink":   return .pink
        case "red":    return .red
        case "orange": return .orange
        case "green":  return .green
        case "teal":   return .teal
        default:       return adaptive(light: 0x171717, dark: 0xFAFAFA)
        }
    }

    // ── Text ───────────────────────────────────────────────────────────

    static let textDark      = adaptive(light: 0x171717, dark: 0xF5F5F5)
    static let textMedium    = adaptive(light: 0x737373, dark: 0xA3A3A3)
    static let textLight     = adaptive(light: 0xA3A3A3, dark: 0x525252)

    static let appTextDark   = textDark
    static let appTextMedium = textMedium
    static let appTextLight  = textLight

    // ── Background ─────────────────────────────────────────────────────

    static let scaffoldBg    = adaptive(light: 0xF8F6F1, dark: 0x0A0A0A)
    static let appScaffoldBg = scaffoldBg
    static let appBgColor    = scaffoldBg
    static let cardBg        = adaptive(light: 0xFFFFFF, dark: 0x171717)
    static let statsBg       = adaptive(light: 0xF5F5F5, dark: 0x0F0F0F)

    // ── Semantic ───────────────────────────────────────────────────────

    static let appSuccess    = adaptive(light: 0x22C55E, dark: 0x4ADE80)
    static let appWarning    = adaptive(light: 0xF59E0B, dark: 0xFBBF24)
    static let appError      = adaptive(light: 0xEF4444, dark: 0xF87171)

    // ── Neutral helpers ────────────────────────────────────────────────

    static let appDivider    = adaptive(light: 0xE5E5E5, dark: 0x262626)

    // ── Topic Colors (grayscale) ──────────────────────────────────────

    static let topicQuyDinh  = adaptive(light: 0x262626, dark: 0xD4D4D4)
    static let topicKyThuat  = adaptive(light: 0x404040, dark: 0xA3A3A3)
    static let topicCauTao   = adaptive(light: 0x525252, dark: 0x8E8E8E)
    static let topicBienBao  = adaptive(light: 0x333333, dark: 0xC0C0C0)
    static let topicSaHinh   = adaptive(light: 0x4A4A4A, dark: 0xB0B0B0)

    // ── Accents (grayscale aliases) ───────────────────────────────────

    static let accentTerra   = appPrimary
    static let accentGreen   = adaptive(light: 0x525252, dark: 0x8E8E8E)
    static let accentRose    = adaptive(light: 0x4A4A4A, dark: 0xB0B0B0)

    // ── Diem Liet ──────────────────────────────────────────────────────

    static let diemLietBg    = adaptive(light: 0xFEF2F2, dark: 0x1C1010)
    static let diemLietBadge = appError
}

// MARK: - GlassCard ViewModifier

struct GlassCard: ViewModifier {
    var cornerRadius: CGFloat = 16

    func body(content: Content) -> some View {
        if #available(iOS 26.0, *) {
            content
                .frame(maxWidth: .infinity, alignment: .leading)
                .contentShape(Rectangle())
                .glassEffect(.regular.interactive(), in: .rect(cornerRadius: cornerRadius))
        } else {
            content
                .frame(maxWidth: .infinity, alignment: .leading)
                .contentShape(Rectangle())
                .background(.regularMaterial)
                .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
        }
    }
}

extension View {
    func glassCard(cornerRadius: CGFloat = 16) -> some View {
        modifier(GlassCard(cornerRadius: cornerRadius))
    }
}

// MARK: - Pop to Root Environment

private struct PopToRootKey: EnvironmentKey {
    nonisolated(unsafe) static let defaultValue: () -> Void = {}
}

extension EnvironmentValues {
    var popToRoot: () -> Void {
        get { self[PopToRootKey.self] }
        set { self[PopToRootKey.self] = newValue }
    }
}

// MARK: - Tab Bar Visibility

extension View {
    func hidesTabBar() -> some View {
        self.toolbar(.hidden, for: .tabBar)
    }
}

// MARK: - Screen Header

extension View {
    func screenHeader(_ title: String) -> some View {
        self
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.large)
            .background(Color.scaffoldBg.ignoresSafeArea())
    }
}

// MARK: - Staggered Appearance

struct StaggeredItem: ViewModifier {
    let index: Int
    @State private var isVisible = false

    func body(content: Content) -> some View {
        content
            .opacity(isVisible ? 1 : 0)
            .offset(y: isVisible ? 0 : 16)
            .scaleEffect(isVisible ? 1 : 0.96, anchor: .top)
            .animation(.spring(duration: 0.4, bounce: 0.15).delay(Double(index) * 0.04), value: isVisible)
            .onAppear { isVisible = true }
    }
}

extension View {
    func staggered(_ index: Int) -> some View {
        self
    }
}

// MARK: - GlassBackground ViewModifier

struct GlassBackground: ViewModifier {
    func body(content: Content) -> some View {
        ZStack {
            Color.scaffoldBg.ignoresSafeArea()
            content
        }
    }
}

extension View {
    func glassBackground() -> some View {
        modifier(GlassBackground())
    }
}

