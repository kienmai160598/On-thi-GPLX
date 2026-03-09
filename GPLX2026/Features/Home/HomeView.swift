import SwiftUI

struct HomeView: View {
    @AppStorage("appPrimaryColor") private var primaryColorKey = "default"
    @State private var activeExam: ExamScreen?

    private var accentColor: Color {
        Color.primaryColor(for: primaryColorKey)
    }

    var body: some View {
        TabView {
            Tab("Trang chủ", systemImage: "house") {
                NavigationStack {
                    HomeTab()
                }
                .tint(accentColor)
            }

            Tab("Lý thuyết", systemImage: "book") {
                NavigationStack {
                    TheoryTab()
                }
                .tint(accentColor)
            }

            Tab("Sa hình", systemImage: "map") {
                NavigationStack {
                    SimulationTab()
                }
                .tint(accentColor)
            }

            Tab("Video TH", systemImage: "play.circle") {
                NavigationStack {
                    HazardTab()
                }
                .tint(accentColor)
            }
        }
        .tint(accentColor)
        .environment(\.openExam) { screen in activeExam = screen }
        .fullScreenCover(item: $activeExam) { exam in
            NavigationStack {
                exam.destination
            }
            .environment(\.popToRoot) { activeExam = nil }
            .environment(\.openExam) { newScreen in activeExam = newScreen }
            .tint(accentColor)
        }
    }
}

#Preview {
    HomeView()
}
