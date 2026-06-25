import SwiftUI

/// Small colored dot + label used in the exam / question-grid sidebar legends
/// (đang làm / đã xong / chưa làm). Shared by BaseExamView and QuestionView.
struct SidebarLegendDot: View {
    let color: Color
    let label: String

    var body: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
            Text(label)
                .font(.appSans(size: 12))
                .foregroundStyle(Color.appTextMedium)
        }
    }
}
