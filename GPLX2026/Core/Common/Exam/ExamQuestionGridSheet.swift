import SwiftUI

struct ExamQuestionGridSheet: View {
    @Environment(\.dismiss) private var dismiss

    let totalQuestions: Int
    let answeredIndices: Set<Int>
    let currentIndex: Int
    let onSelect: (Int) -> Void

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 10), count: 6)
    private let pad: CGFloat = 20

    private var answeredCount: Int { answeredIndices.count }
    private var unansweredCount: Int { totalQuestions - answeredCount }

    var body: some View {
        VStack(spacing: 0) {
          
            // ── Legend ───────────────────────────────────────
            legend
                .padding(.horizontal, pad)
                .padding(.bottom, 16)
                .padding(.top, 30)

            Divider().padding(.horizontal, pad)

            // ── Grid ────────────────────────────────────────
            ScrollView {
                LazyVGrid(columns: columns, spacing: 10) {
                    ForEach(0..<totalQuestions, id: \.self) { index in
                        Button {
                            Haptics.selection()
                            onSelect(index)
                        } label: {
                            gridCell(index: index)
                        }
                    }
                }
                .padding(pad)
            }
        }
    }

    // MARK: - Legend

    private var legend: some View {
        HStack(spacing: 20) {
            legendItem(color: .appPrimary, count: 1, label: "Đang làm")
            legendItem(color: .appSuccess, count: answeredCount, label: "Đã xong")
            legendItem(color: Color.appTextLight.opacity(0.25), textColor: .appTextMedium, count: unansweredCount, label: "Chưa làm")
            Spacer()
        }
    }

    // MARK: - Grid Cell

    private func gridCell(index: Int) -> some View {
        Text("\(index + 1)")
            .font(.system(size: 15, weight: .semibold))
            .foregroundStyle(foregroundColor(for: index))
            .frame(maxWidth: .infinity, minHeight: 44)
            .background(backgroundColor(for: index))
            .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - Colors

    private func foregroundColor(for index: Int) -> Color {
        if index == currentIndex { return Color.appOnPrimary }
        if answeredIndices.contains(index) { return Color.appSuccess }
        return Color.appTextMedium
    }

    private func backgroundColor(for index: Int) -> Color {
        if index == currentIndex { return Color.appPrimary }
        if answeredIndices.contains(index) { return Color.appSuccess.opacity(0.12) }
        return Color.appTextLight.opacity(0.25)
    }

    // MARK: - Legend Item

    private func legendItem(color: Color, textColor: Color? = nil, count: Int, label: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("\(count)")
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(textColor ?? color)
            Text(label)
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(Color.appTextMedium)
        }
    }
}
