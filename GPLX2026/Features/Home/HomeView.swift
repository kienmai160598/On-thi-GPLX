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

            Tab("Ôn tập", systemImage: "books.vertical") {
                NavigationStack {
                    StudyMenuView()
                }
                .tint(accentColor)
            }

            Tab("Thi thử", systemImage: "doc.text") {
                NavigationStack {
                    MockExamTab()
                }
                .tint(accentColor)
            }

            Tab("Thực hành", systemImage: "car.side") {
                NavigationStack {
                    SimulationTab()
                }
                .tint(accentColor)
            }

            Tab(role: .search) {
                NavigationStack {
                    QuestionSearchView()
                }
                .tint(accentColor)
            }
        }
        .tint(accentColor)
        .environment(\.openExam) { screen in activeExam = screen }
        .fullScreenCover(item: $activeExam) { screen in
            NavigationStack {
                screen.destination
            }
            .environment(\.popToRoot) { activeExam = nil }
            .tint(accentColor)
        }
    }
}

#Preview {
    HomeView()
}
