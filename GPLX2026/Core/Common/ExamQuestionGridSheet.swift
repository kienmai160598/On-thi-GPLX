import SwiftUI

struct ExamQuestionGridSheet: View {
    @Environment(\.dismiss) private var dismiss

    let totalQuestions: Int
    let answeredIndices: Set<Int>
    let currentIndex: Int
    let onSelect: (Int) -> Void

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 8), count: 7)

    private var answeredCount: Int { answeredIndices.count }

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Câu \(currentIndex + 1)/\(totalQuestions)")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(Color.appTextDark)
                Spacer()
                Button("Xong") { dismiss() }
                    .font(.system(size: 16, weight: .medium))
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 10)

            // Progress summary
            HStack(spacing: 16) {
                legendItem(color: .appPrimary, label: "Đang làm")
                legendItem(color: .appSuccess, label: "Đã trả lời (\(answeredCount))")
                legendItem(color: Color.appDivider.opacity(0.3), textColor: .appTextMedium, label: "Chưa")
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 10)

            Divider().padding(.horizontal, 20)

            // Grid
            ScrollView {
                LazyVGrid(columns: columns, spacing: 8) {
                    ForEach(0..<totalQuestions, id: \.self) { index in
                        Button {
                            Haptics.selection()
                            onSelect(index)
                        } label: {
                            Text("\(index + 1)")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(foregroundColor(for: index))
                                .frame(width: 40, height: 40)
                                .background(backgroundColor(for: index))
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                    }
                }
                .padding(20)
            }
        }
    }

    private func foregroundColor(for index: Int) -> Color {
        if index == currentIndex { return Color.appOnPrimary }
        if answeredIndices.contains(index) { return Color.appSuccess }
        return Color.appTextMedium
    }

    private func backgroundColor(for index: Int) -> Color {
        if index == currentIndex { return Color.appPrimary }
        if answeredIndices.contains(index) { return Color.appSuccess.opacity(0.12) }
        return Color.appDivider.opacity(0.3)
    }

    private func legendItem(color: Color, textColor: Color? = nil, label: String) -> some View {
        HStack(spacing: 6) {
            RoundedRectangle(cornerRadius: 4)
                .fill(color)
                .frame(width: 14, height: 14)
            Text(label)
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(textColor ?? color)
        }
    }
}
