import SwiftUI

// MARK: - PracticeHistoryView
//
// Dedicated "Lịch sử luyện tập" screen (design node R1OGvn). The design shows
// per-topic practice activity with a summary (sessions / questions / accuracy).
// The app tracks per-question correctness but not practice sessions or per-topic
// timestamps, so this adapts to existing data: rows are the attempted topics
// (name, câu count, accuracy, quality band) sorted by how much they've been
// practiced, and the summary is derived from those aggregates. Tapping a row
// resumes practising that topic.

struct PracticeHistoryView: View {
    @Environment(QuestionStore.self) private var questionStore
    @Environment(ProgressStore.self) private var progressStore
    @Environment(LayoutMetrics.self) private var metrics
    @Environment(\.openExam) private var openExam

    private typealias TopicStat = (topic: Topic, accuracy: Double, correct: Int, attempted: Int, total: Int)

    var body: some View {
        let stats = progressStore.weakTopics(topics: questionStore.topics)
            .filter { $0.attempted > 0 }
            .sorted { $0.attempted > $1.attempted }

        ScrollView {
            if stats.isEmpty {
                EmptyState(icon: "book", message: "Chưa có hoạt động luyện tập nào.")
            } else {
                VStack(alignment: .leading, spacing: 14) {
                    summary(stats)

                    SectionTitle(title: "Hoạt động gần đây")

                    VStack(spacing: 10) {
                        ForEach(stats, id: \.topic.key) { item in
                            Button {
                                openExam(.questionView(topicKey: item.topic.key, startIndex: 0))
                            } label: {
                                row(item)
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
        .screenHeader("Lịch sử luyện tập", titleDisplayMode: .inline)
    }

    // MARK: - Pieces

    private func summary(_ stats: [TopicStat]) -> some View {
        let totalAnswered = stats.reduce(0) { $0 + $1.attempted }
        let totalCorrect = stats.reduce(0) { $0 + $1.correct }
        let accuracyPct = totalAnswered > 0
            ? Int((Double(totalCorrect) / Double(totalAnswered) * 100).rounded())
            : 0
        return HistorySummaryCard(stats: [
            .init(value: "\(stats.count)", label: "Chủ đề"),
            .init(value: compactCount(totalAnswered), label: "Câu đã ôn"),
            .init(value: "\(accuracyPct)%", label: "Chính xác", color: .appSuccess)
        ])
    }

    private func row(_ item: TopicStat) -> some View {
        let quality = HistoryQuality.practice(item.accuracy)
        let percent = Int((item.accuracy * 100).rounded())
        return HistoryItemRow(
            icon: item.topic.icon,
            iconColor: item.topic.color,
            title: item.topic.name,
            meta: "\(item.attempted) câu · \(item.correct) đúng",
            value: "\(percent)%",
            valueColor: quality.color,
            status: quality.label
        )
    }

    /// "1.2K" for large counts, plain for small ones.
    private func compactCount(_ count: Int) -> String {
        count >= 1000 ? String(format: "%.1fK", Double(count) / 1000) : "\(count)"
    }
}
