import SwiftUI

// MARK: - Tab model

enum SidebarTab: String, CaseIterable, Identifiable {
    case home       = "Trang chủ"
    case practice   = "Luyện tập"
    case exam       = "Thi thử"
    case simulation = "Mô phỏng"
    case settings   = "Cài đặt"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .home:       "house"
        case .practice:   "book"
        case .exam:       "list.clipboard"
        case .simulation: "play.rectangle"
        case .settings:   "gearshape"
        }
    }

    var filledIcon: String {
        switch self {
        case .home:       "house.fill"
        case .practice:   "book.fill"
        case .exam:       "list.clipboard.fill"
        case .simulation: "play.rectangle.fill"
        case .settings:   "gearshape.fill"
        }
    }
}

// MARK: - HomeView

struct HomeView: View {
    @Environment(LayoutMetrics.self) private var metrics
    @Environment(ThemeStore.self) private var themeStore
    @State private var activeExam: ExamScreen?
    @State private var pendingExam: ExamScreen?
    @State private var selectedTab: SidebarTab = .home
    @State private var router = NotificationRouter.shared
    @State private var tabBarVisibility = TabBarVisibility()
    @AppStorage(AppConstants.StorageKey.themeMode) private var themeMode: String = "system"

    private var accentColor: Color { themeStore.primaryColor }

    /// Color scheme from the in-app theme setting. Full-screen covers are a
    /// separate presentation context and do NOT inherit the root's
    /// `.preferredColorScheme`, so we re-apply it to the cover (otherwise the
    /// Settings/Search covers ignore the Sáng/Tối toggle).
    private var preferredColorScheme: ColorScheme? {
        switch themeMode {
        case "light": return .light
        case "dark": return .dark
        default: return nil
        }
    }

    var body: some View {
        Group {
            if metrics.isIPadLayout {
                iPadLayout
            } else {
                iPhoneLayout
            }
        }
        .environment(\.openExam) { screen in
            // Start the landscape rotation as the cover presents so the player
            // doesn't appear in portrait and then flip.
            if case .hazardTest = screen { OrientationManager.shared.forceToLandscape() }
            activeExam = screen
        }
        .environment(tabBarVisibility)
        .onChange(of: selectedTab) { _, _ in
            tabBarVisibility.collapsed = false
        }
        .onAppear { applyNotificationDestination(router.pendingDestination) }
        .onChange(of: router.pendingDestination) { _, destination in
            applyNotificationDestination(destination)
        }
        .fullScreenCover(item: $activeExam, onDismiss: {
            // Restore portrait AFTER the cover's dismiss animation finishes.
            // (HazardTestView.onDisappear fires mid-animation and is rejected by
            // the system, so portrait was never restored on exit.)
            OrientationManager.shared.lock()
            if let next = pendingExam {
                pendingExam = nil
                if case .hazardTest = next { OrientationManager.shared.forceToLandscape() }
                Task { @MainActor in self.activeExam = next }
            }
        }) { exam in
            NavigationStack {
                exam.destination
            }
            .environment(\.popToRoot) {
                pendingExam = nil   // prevent onDismiss from re-presenting a stale pending exam
                activeExam = nil
            }
            .environment(\.openExam) { newScreen in
                pendingExam = newScreen
                activeExam = nil
            }
            .tint(accentColor)
            .preferredColorScheme(preferredColorScheme)
        }
    }

    // MARK: - iPhone: custom frosted tab bar

    private var iPhoneLayout: some View {
        // Native Liquid Glass tab bar (iOS 26): it reserves the bottom safe area
        // automatically, and `tabBarMinimizeBehavior(.onScrollDown)` collapses it
        // on scroll-down (Reddit-style) and restores it on scroll-up.
        TabView(selection: $selectedTab) {
            // Icons/labels come from SidebarTab so iPhone and the iPad sidebar
            // stay in sync; the system fills the selected tab's symbol.
            Tab(SidebarTab.home.rawValue, systemImage: SidebarTab.home.icon, value: SidebarTab.home) {
                NavigationStack { HomeTab() }.tint(accentColor)
            }
            Tab(SidebarTab.practice.rawValue, systemImage: SidebarTab.practice.icon, value: SidebarTab.practice) {
                NavigationStack { PracticeTab() }.tint(accentColor)
            }
            Tab(SidebarTab.exam.rawValue, systemImage: SidebarTab.exam.icon, value: SidebarTab.exam) {
                NavigationStack { ExamTab() }.tint(accentColor)
            }
            Tab(SidebarTab.simulation.rawValue, systemImage: SidebarTab.simulation.icon, value: SidebarTab.simulation) {
                NavigationStack { MoPhongTab() }.tint(accentColor)
            }
        }
        .tint(accentColor)
        .modifier(TabBarMinimizeOnScroll())
    }

    @ViewBuilder
    private var tabRoot: some View {
        switch selectedTab {
        case .home:       HomeTab()
        case .practice:   PracticeTab()
        case .exam:       ExamTab()
        case .simulation: MoPhongTab()
        case .settings:   SettingsView()
        }
    }

    // MARK: - iPad: NavigationSplitView

    private var iPadLayout: some View {
        NavigationSplitView {
            List(SidebarTab.allCases, selection: Binding<SidebarTab?>(
                get: { selectedTab },
                set: { selectedTab = $0 ?? .home }
            )) { tab in
                Label(tab.rawValue, systemImage: tab.icon)
                    .tag(tab)
            }
            .navigationTitle("GPLX 2026")
        } detail: {
            NavigationStack {
                tabRoot
            }
            .id(selectedTab)   // reset navigation stack on tab switch so stale pushed views don't persist
            .tint(accentColor)
        }
        .tint(accentColor)
    }

    // MARK: - Notification deep-link

    private func applyNotificationDestination(_ destination: NotificationDestination?) {
        guard let destination else { return }
        switch destination {
        case .practice: selectedTab = .practice
        case .exam:     selectedTab = .exam
        }
        router.pendingDestination = nil
    }
}

/// Applies the iOS 26 Liquid Glass tab-bar scroll-minimize behavior (Reddit-style
/// collapse on scroll-down) when running on iOS 26+. No-op on iOS 18–25.
private struct TabBarMinimizeOnScroll: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 26.0, *) {
            content.tabBarMinimizeBehavior(.onScrollDown)
        } else {
            content
        }
    }
}

#Preview {
    HomeView()
}
