import SwiftUI

// MARK: - ExamLoadingView

struct ExamLoadingView: View {
    var body: some View {
        VStack {
            ProgressView()
                .tint(Color.appPrimary)
            Text("Đang tạo đề thi...")
                .font(.subheadline)
                .foregroundStyle(Color.appTextMedium)
                .padding(.top, 8)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
