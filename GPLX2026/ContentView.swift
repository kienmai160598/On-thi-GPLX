import SwiftUI

struct ContentView: View {
    @Environment(QuestionStore.self) private var questionStore
    @Environment(ThemeStore.self) private var themeStore

    var body: some View {
        Group {
            if questionStore.isLoading {
                ZStack {
                    Color.scaffoldBg.ignoresSafeArea()
                    VStack(spacing: 16) {
                        ProgressView()
                            .tint(themeStore.primaryColor)
                        Text("Đang tải dữ liệu...")
                            .font(.subheadline)
                            .foregroundStyle(Color.appTextMedium)
                    }
                }
            } else {
                HomeView()
            }
        }
    }
}
