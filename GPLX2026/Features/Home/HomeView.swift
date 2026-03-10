import SwiftUI

struct HomeView: View {
    @AppStorage(AppConstants.StorageKey.primaryColor) private var primaryColorKey = "default"
    @State private var activeExam: ExamScreen?
    @State private var pendingExam: ExamScreen?

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
}

#Preview {
    HomeView()
}
