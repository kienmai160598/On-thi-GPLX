import SwiftUI

// MARK: - ExamLoadingView

struct ExamLoadingView: View {
    @Environment(ThemeStore.self) private var themeStore
    var body: some View {
        VStack {
            ProgressView()
                .tint(themeStore.primaryColor)
            Text("Đang tạo đề thi...")
                .font(.subheadline)
                .foregroundStyle(Color.appTextMedium)
                .padding(.top, 8)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
