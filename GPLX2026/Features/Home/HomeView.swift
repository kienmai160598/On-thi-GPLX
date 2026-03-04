import SwiftUI

struct HomeView: View {
    @AppStorage("selectedTab") private var selectedTab = 0
    @AppStorage("appPrimaryColor") private var primaryColorKey = "default"
    @State private var examStackId = 0
    @State private var simStackId = 0
    private var accentColor: Color {
        Color.primaryColor(for: primaryColorKey)
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            Tab("Trang chủ", systemImage: "house", value: 0) {
                NavigationStack {
                    HomeTab()
                }
                .tint(accentColor)
            }

            Tab("Ôn tập", systemImage: "books.vertical", value: 1) {
                NavigationStack {
                    StudyMenuView()
                }
                .tint(accentColor)
            }

            Tab("Thi thử", systemImage: "doc.text", value: 2) {
                NavigationStack {
                    MockExamTab()
                }
                .id(examStackId)
                .environment(\.popToRoot) { examStackId += 1 }
                .tint(accentColor)
            }

            Tab("Mô phỏng", systemImage: "play.rectangle", value: 3) {
                NavigationStack {
                    SimulationTab()
                }
                .id(simStackId)
                .environment(\.popToRoot) { simStackId += 1 }
                .tint(accentColor)
            }
        }
        .tint(accentColor)
        .toolbarBackground(.ultraThinMaterial, for: .tabBar)
    }
}

#Preview {
    HomeView()
}
