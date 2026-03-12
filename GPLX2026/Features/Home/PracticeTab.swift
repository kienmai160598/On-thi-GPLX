import SwiftUI

struct PracticeTab: View {
    @Environment(QuestionStore.self) private var questionStore
    @Environment(ProgressStore.self) private var progressStore
    @Environment(LayoutMetrics.self) private var metrics
    @Environment(\.openExam) private var openExam

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                questionSection
                hazardSection
            }
            .padding(.horizontal, metrics.contentPadding)
            .frame(maxWidth: metrics.isWide ? 900 : .infinity)
            .frame(maxWidth: .infinity)
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

        VStack(alignment: .leading, spacing: 12) {
            SectionTitle(title: "Câu hỏi")

            Button {
                openExam(.questionView(topicKey: AppConstants.TopicKey.allQuestions, startIndex: 0))
            } label: {
                AppButton(icon: "play.fill", label: "Ôn tập \(totalCount) câu", height: metrics.buttonHeight)
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
                                    .font(.appSans(size: 15, weight: .semibold))
                                    .foregroundStyle(Color.appTextDark)
                                    .lineLimit(1)
                                Text(item.correct > 0
                                    ? "\(item.correct)/\(item.total) đúng"
                                    : "\(item.total) câu")
                                    .font(.appSans(size: 13))
                                    .foregroundStyle(Color.appTextMedium)
                            }

                            Spacer(minLength: 4)

                            Image(systemName: "chevron.right")
                                .font(.appSans(size: 12, weight: .medium))
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
        VStack(alignment: .leading, spacing: 12) {
            SectionTitle(title: "Tình huống nguy hiểm")

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
                                    .font(.appSans(size: 15, weight: .bold))
                                    .foregroundStyle(Color.appTextDark)
                                Text(hasPractice
                                    ? "\(Int(chapterScore * 100))% · \(chapter.range.count) tình huống"
                                    : "\(chapter.name) · \(chapter.range.count) tình huống")
                                    .font(.appSans(size: 13))
                                    .foregroundStyle(Color.appTextMedium)
                            }

                            Spacer(minLength: 4)

                            Image(systemName: "chevron.right")
                                .font(.appSans(size: 12, weight: .medium))
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
