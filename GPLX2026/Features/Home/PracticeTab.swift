import SwiftUI

struct PracticeTab: View {
    @Environment(QuestionStore.self) private var questionStore
    @Environment(ProgressStore.self) private var progressStore
    @Environment(\.openExam) private var openExam

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                questionSection
                hazardSection
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
            .padding(.bottom, 32)
        }
        .glassContainer()
        .screenHeader("Luyện tập")
    }

    // MARK: - Câu hỏi Section

    @ViewBuilder
    private var questionSection: some View {
        let allTopics = questionStore.topics
        let topicStats = progressStore.weakTopics(topics: allTopics)
            .sorted { $0.topic.topicIds.first ?? 0 < $1.topic.topicIds.first ?? 0 }
        let totalCount = allTopics.reduce(0) { $0 + $1.questionCount }
        let totalCorrect = topicStats.reduce(0) { $0 + $1.correct }
        let overallAccuracy = totalCount > 0 ? Double(totalCorrect) / Double(totalCount) : 0
        let masteredTopics = topicStats.filter { $0.total > 0 && Double($0.correct) / Double($0.total) >= 0.8 }.count

        // Find weakest attempted topic
        let weakest = topicStats
            .filter { $0.correct > 0 && $0.total > 0 && Double($0.correct) / Double($0.total) < 0.8 }
            .min { Double($0.correct) / Double($0.total) < Double($1.correct) / Double($1.total) }

        VStack(alignment: .leading, spacing: 12) {
            SectionTitle(title: "Câu hỏi")

            MiniMetricCard(
                fraction: overallAccuracy,
                stats: [
                    (value: "\(totalCorrect)/\(totalCount)", label: "Đã đúng"),
                    (value: "\(masteredTopics)/\(topicStats.count)", label: "Hoàn thành")
                ]
            )

            // Smart "Ôn câu yếu" button — only shows if there's a weak topic
            if let weak = weakest {
                let accuracy = Int(Double(weak.correct) / Double(weak.total) * 100)
                Button {
                    openExam(.questionView(topicKey: weak.topic.key, startIndex: 0))
                } label: {
                    AppButton(
                        icon: "arrow.counterclockwise",
                        label: "Ôn câu yếu: \(weak.topic.name) (\(accuracy)%)",
                        height: 48,
                        cornerRadius: 14
                    )
                }
            }

            // Topic list with color-coded progress rings
            VStack(spacing: 0) {
                ForEach(Array(topicStats.enumerated()), id: \.element.topic.id) { index, item in
                    let topicAccuracy = item.total > 0 ? Double(item.correct) / Double(item.total) : 0
                    let ringColor = topicRingColor(accuracy: topicAccuracy, attempted: item.correct > 0)

                    Button {
                        openExam(.questionView(topicKey: item.topic.key, startIndex: 0))
                    } label: {
                        HStack(spacing: 14) {
                            TopicIconRing(
                                icon: item.topic.icon,
                                fraction: topicAccuracy,
                                color: ringColor
                            )

                            VStack(alignment: .leading, spacing: 3) {
                                Text(item.topic.name)
                                    .font(.system(size: 15, weight: .semibold))
                                    .foregroundStyle(Color.appTextDark)
                                    .lineLimit(1)
                                Text(item.correct > 0
                                    ? "\(item.correct)/\(item.total) đúng"
                                    : "\(item.total) câu")
                                    .font(.system(size: 13))
                                    .foregroundStyle(Color.appTextMedium)
                            }

                            Spacer(minLength: 4)

                            Image(systemName: "chevron.right")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundStyle(Color.appTextLight)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 12)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)

                    if index < topicStats.count - 1 {
                        Divider().padding(.leading, 68)
                    }
                }
            }
            .glassCard()
        }
    }

    // MARK: - Tình huống Section

    @ViewBuilder
    private var hazardSection: some View {
        let totalSituations = HazardSituation.all.count
        let practicedCount = progressStore.hazardPracticedCount
        let avgScore = progressStore.averageHazardScore

        VStack(alignment: .leading, spacing: 12) {
            SectionTitle(title: "Tình huống nguy hiểm")

            MiniMetricCard(
                fraction: avgScore,
                stats: [
                    (value: "\(practicedCount)/\(totalSituations)", label: "Đã luyện"),
                    (value: practicedCount > 0 ? "\(Int(avgScore * 100))%" : "--", label: "Điểm TB")
                ]
            )

            // Chapter list with progress rings
            VStack(spacing: 0) {
                ForEach(Array(HazardSituation.chapters.enumerated()), id: \.element.id) { index, chapter in
                    let chapterScore = progressStore.chapterAverageScore(chapterId: chapter.id)
                    let hasPractice = progressStore.chapterHasPractice(chapterId: chapter.id)

                    Button { openExam(.hazardTest(mode: .chapter(chapter.id))) } label: {
                        HStack(spacing: 14) {
                            TopicIconRing(
                                icon: chapterIcon(chapter.id),
                                fraction: chapterScore,
                                color: .appPrimary
                            )

                            VStack(alignment: .leading, spacing: 2) {
                                Text("Chương \(chapter.id)")
                                    .font(.system(size: 15, weight: .bold))
                                    .foregroundStyle(Color.appTextDark)
                                Text(hasPractice
                                    ? "\(Int(chapterScore * 100))% · \(chapter.range.count) tình huống"
                                    : "\(chapter.name) · \(chapter.range.count) tình huống")
                                    .font(.system(size: 13))
                                    .foregroundStyle(Color.appTextMedium)
                            }

                            Spacer(minLength: 4)

                            Image(systemName: "chevron.right")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundStyle(Color.appTextLight)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 12)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)

                    if index < HazardSituation.chapters.count - 1 {
                        Divider().padding(.leading, 68)
                    }
                }
            }
            .glassCard()
        }
    }

    // MARK: - Helpers

    private func topicRingColor(accuracy: Double, attempted: Bool) -> Color {
        guard attempted else { return .appPrimary }
        if accuracy >= 0.8 { return .appSuccess }
        if accuracy >= 0.5 { return .appWarning }
        return .appError
    }

    private func chapterIcon(_ id: Int) -> String {
        switch id {
        case 1: return "building.2.fill"
        case 2: return "road.lanes"
        case 3: return "car.rear.road.lane"
        case 4: return "mountain.2.fill"
        case 5: return "car.2.fill"
        case 6: return "exclamationmark.triangle.fill"
        default: return "play.rectangle.fill"
        }
    }
}
