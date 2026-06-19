import SwiftUI

// MARK: - Sidebar Tab (iPad)

enum SidebarTab: String, CaseIterable, Identifiable {
    case home     = "Trang chủ"
    case practice = "Luyện tập"
    case exam     = "Thi thử"
    case settings = "Cài đặt"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .home:     "house"
        case .practice: "book"
        case .exam:     "list.clipboard.fill"
        case .settings: "gearshape"
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

    private var accentColor: Color {
        themeStore.primaryColor
    }

    var body: some View {
        Group {
            if metrics.isIPadLayout {
                iPadLayout
            } else {
                iPhoneLayout
            }
        }
        .environment(\.openExam) { screen in activeExam = screen }
        .onAppear { applyNotificationDestination(router.pendingDestination) }
        .onChange(of: router.pendingDestination) { _, destination in
            applyNotificationDestination(destination)
        }
        .fullScreenCover(item: $activeExam, onDismiss: {
            if let next = pendingExam {
                pendingExam = nil
                DispatchQueue.main.async {
                    activeExam = next
                }
            }
        }) { exam in
            NavigationStack {
                exam.destination
            }
            .environment(\.popToRoot) { activeExam = nil }
            .environment(\.openExam) { newScreen in
                pendingExam = newScreen
                activeExam = nil
            }
            .tint(accentColor)
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
                selectedTabContent
            }
            .tint(accentColor)
        }
        .tint(accentColor)
    }

    // MARK: - iPhone: TabView

    private var iPhoneLayout: some View {
        TabView(selection: $selectedTab) {
            Tab("Trang chủ", systemImage: "house", value: SidebarTab.home) {
                NavigationStack {
                    HomeTab()
                }
                .tint(accentColor)
            }

            Tab("Luyện tập", systemImage: "book", value: SidebarTab.practice) {
                NavigationStack {
                    PracticeTab()
                }
                .tint(accentColor)
            }

            Tab("Thi thử", systemImage: "list.clipboard.fill", value: SidebarTab.exam) {
                NavigationStack {
                    ExamTab()
                }
                .tint(accentColor)
            }
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

    // MARK: - Tab Content (iPad detail)

    @ViewBuilder
    private var selectedTabContent: some View {
        switch selectedTab {
        case .home:     HomeTab()
        case .practice: PracticeTab()
        case .exam:     ExamTab()
        case .settings: SettingsView()
        }
    }
}

#Preview {
    HomeView()
}
