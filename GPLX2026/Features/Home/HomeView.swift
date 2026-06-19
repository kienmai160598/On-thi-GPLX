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
    @State private var selectedTab: SidebarTab? = .home

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
            List(SidebarTab.allCases, selection: $selectedTab) { tab in
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
        TabView {
            Tab("Trang chủ", systemImage: "house") {
                NavigationStack {
                    HomeTab()
                }
                .tint(accentColor)
            }

            Tab("Luyện tập", systemImage: "book") {
                NavigationStack {
                    PracticeTab()
                }
                .tint(accentColor)
            }

            Tab("Thi thử", systemImage: "list.clipboard.fill") {
                NavigationStack {
                    ExamTab()
                }
                .tint(accentColor)
            }
        }
        .tint(accentColor)
    }

    // MARK: - Tab Content (iPad detail)

    @ViewBuilder
    private var selectedTabContent: some View {
        switch selectedTab {
        case .home:     HomeTab()
        case .practice: PracticeTab()
        case .exam:     ExamTab()
        case .settings: SettingsView()
        case .none:     HomeTab()
        }
    }
}

#Preview {
    HomeView()
}
