import SwiftUI

struct ExamQuestionGridSheet: View {
    @Environment(ThemeStore.self) private var themeStore
    @Environment(LayoutMetrics.self) private var metrics
    @Environment(\.dismiss) private var dismiss

    let totalQuestions: Int
    let answeredIndices: Set<Int>
    var bookmarkedIndices: Set<Int> = []
    let currentIndex: Int
    let onSelect: (Int) -> Void

    /// Bookmarked cells (warm amber) — distinct from answered/unanswered.
    private let bookmarkColor = Color(hex: 0xF59E0B)

    private var columns: [GridItem] {
        Array(repeating: GridItem(.flexible(), spacing: 10), count: metrics.gridColumns)
    }
    private let pad: CGFloat = 20

    // Partition the cells so each falls into exactly one legend bucket.
    // Priority: current > bookmarked > answered > unanswered.
    private var bookmarkedExcludingCurrent: Set<Int> {
        bookmarkedIndices.subtracting([currentIndex])
    }
    private var answeredExcludingOthers: Set<Int> {
        answeredIndices.subtracting(bookmarkedIndices).subtracting([currentIndex])
    }
    private var unansweredCount: Int {
        max(0, totalQuestions - 1 - bookmarkedExcludingCurrent.count - answeredExcludingOthers.count)
    }

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
                        .accessibilityLabel(gridCellLabel(for: index))
                    }
                }
                .padding(.horizontal, pad)
                .padding(.top, pad)
                .padding(.bottom, pad)
            }
            .scrollBounceBehavior(.basedOnSize)

            // ── Continue CTA (pinned) ────────────────────────
            Button {
                Haptics.selection()
                dismiss()
            } label: {
                AppButton(label: "Tiếp tục làm bài", height: 52)
            }
            .padding(.horizontal, pad)
            .padding(.top, 8)
            .padding(.bottom, 12)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Legend

    private var legend: some View {
        HStack(spacing: 16) {
            legendItem(color: themeStore.primaryColor, count: 1, label: "Đang làm")
            legendItem(color: .appSuccess, count: answeredExcludingOthers.count, label: "Đã xong")
            legendItem(color: bookmarkColor, count: bookmarkedExcludingCurrent.count, label: "Đánh dấu")
            legendItem(color: Color.appDisabled, textColor: .appTextMedium, count: unansweredCount, label: "Chưa làm")
            Spacer(minLength: 0)
        }
    }

    // MARK: - Grid Cell

    private func gridCell(index: Int) -> some View {
        Text("\(index + 1)")
            .font(.appSans(size: 15, weight: .semibold))
            .foregroundStyle(foregroundColor(for: index))
            .frame(maxWidth: .infinity, minHeight: metrics.gridCellSize)
            .background(backgroundColor(for: index))
            .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    // MARK: - Colors (priority: current > bookmarked > answered > unanswered)

    private func foregroundColor(for index: Int) -> Color {
        if index == currentIndex { return themeStore.onPrimaryColor }
        if bookmarkedIndices.contains(index) { return bookmarkColor }
        if answeredIndices.contains(index) { return Color.appSuccess }
        return Color.appTextMedium
    }

    private func backgroundColor(for index: Int) -> Color {
        if index == currentIndex { return themeStore.primaryColor }
        if bookmarkedIndices.contains(index) { return bookmarkColor.opacity(0.15) }
        if answeredIndices.contains(index) { return Color.appSuccess.opacity(0.12) }
        return Color.appDisabled
    }

    // MARK: - Accessibility

    private func gridCellLabel(for index: Int) -> String {
        let stateLabel: String
        if index == currentIndex {
            stateLabel = "đang làm"
        } else if bookmarkedIndices.contains(index) {
            stateLabel = answeredIndices.contains(index) ? "đã trả lời, đã đánh dấu" : "đã đánh dấu"
        } else if answeredIndices.contains(index) {
            stateLabel = "đã trả lời"
        } else {
            stateLabel = "chưa trả lời"
        }
        return "Câu \(index + 1), \(stateLabel)"
    }

    // MARK: - Legend Item

    private func legendItem(color: Color, textColor: Color? = nil, count: Int, label: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("\(count)")
                .font(.appSerif(size: 18, weight: .bold))
                .foregroundStyle(textColor ?? color)
            Text(label)
                .font(.appSans(size: 12))
                .foregroundStyle(Color.appTextMedium)
        }
    }
}
