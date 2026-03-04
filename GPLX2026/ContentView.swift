import SwiftUI

struct ContentView: View {
    @Environment(QuestionStore.self) private var questionStore

    var body: some View {
        Group {
            if questionStore.isLoading {
                ZStack {
                    Color.scaffoldBg.ignoresSafeArea()
                    VStack(spacing: 16) {
                        ProgressView()
                            .tint(Color.appPrimary)
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
