import SwiftUI

// MARK: - ExamHistoryView
//
// Dedicated "Lịch sử thi thử" screen (design node gZOQO): a three-stat summary
// (lượt thi / đạt / cao nhất), then the full list of exam attempts as tappable
// rows that push the per-attempt detail. A toolbar trash button clears history.

struct ExamHistoryView: View {
    @Environment(ProgressStore.self) private var progressStore
    @Environment(LayoutMetrics.self) private var metrics

    @State private var showClearConfirm = false

    var body: some View {
        let history = progressStore.examHistory

        ScrollView {
            if history.isEmpty {
                EmptyState(icon: "list.clipboard", message: "Chưa có lượt thi nào.")
            } else {
                VStack(alignment: .leading, spacing: 14) {
                    summary(history)

                    SectionTitle(title: "Tất cả lượt thi · \(history.count)")

                    VStack(spacing: 10) {
                        ForEach(history) { result in
                            NavigationLink {
                                ExamHistoryDetailView(result: result)
                            } label: {
                                row(result)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .padding(.horizontal, metrics.contentPadding)
                .padding(.top, 8)
                .padding(.bottom, 32)
            }
        }
        .screenHeader("Lịch sử thi thử", titleDisplayMode: .inline)
        .toolbar {
            if !history.isEmpty {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { showClearConfirm = true } label: {
                        Image(systemName: "trash")
                    }
                    .tint(.appError)
                    .accessibilityLabel("Xoá lịch sử thi thử")
                }
            }
        }
        .confirmationDialog("Xoá lịch sử thi thử?", isPresented: $showClearConfirm, titleVisibility: .visible) {
            Button("Xoá tất cả", role: .destructive) { progressStore.clearExamHistory() }
            Button("Huỷ", role: .cancel) {}
        } message: {
            Text("Toàn bộ kết quả thi thử sẽ bị xoá vĩnh viễn.")
        }
    }

    // MARK: - Pieces

    private func summary(_ history: [ExamResult]) -> some View {
        let passedCount = history.filter(\.passed).count
        let bestScore = history.map(\.score).max() ?? 0
        let totalQ = history.first?.totalQuestions ?? LicenseType.current.questionsPerExam
        return HistorySummaryCard(stats: [
            .init(value: "\(history.count)", label: "Lượt thi"),
            .init(value: "\(passedCount)", label: "Đạt", color: .appSuccess),
            .init(value: "\(bestScore)/\(totalQ)", label: "Cao nhất")
        ])
    }

    private func row(_ result: ExamResult) -> some View {
        let color: Color = result.passed ? .appSuccess : .appError
        let title = result.examSetId.map { "Đề cố định \($0)" } ?? "Đề ngẫu nhiên"
        return HistoryItemRow(
            icon: result.passed ? "checkmark.circle.fill" : "xmark.circle.fill",
            iconColor: color,
            title: title,
            meta: HistoryDate.string(from: result.date),
            value: "\(result.score)/\(result.totalQuestions)",
            valueColor: color,
            status: result.passed ? "Đạt" : "Trượt",
            showsIcon: false
        )
    }
}
