import SwiftUI

// MARK: - Filter Enums

private enum MasteryFilter: String, CaseIterable {
    case tatCa      = "Tất cả"
    case dangOn     = "Đang ôn"
    case chuaThuoc  = "Chưa thuộc"
    case daThuoc    = "Đã thuộc"

    var label: String { rawValue }
}

// MARK: - Screen-private sub-views

/// Full-width primary CTA button, filled with the configured accent color.
private struct PrimaryCTAButton: View {
    @Environment(ThemeStore.self) private var themeStore
    let icon: String
    let label: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            content
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private var content: some View {
        let inner = HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.appSans(size: 16, weight: .bold))
                .foregroundStyle(themeStore.onPrimaryColor)
            Text(label)
                .font(.appSans(size: 14.5, weight: .bold))
                .foregroundStyle(themeStore.onPrimaryColor)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 52)

        // Liquid Glass accent fill on iOS 26+, solid accent on earlier systems.
        if #available(iOS 26.0, *) {
            inner
                .glassEffect(.regular.interactive().tint(themeStore.primaryColor), in: .rect(cornerRadius: 25))
                .contentShape(Rectangle())
        } else {
            inner
                .background(themeStore.primaryColor, in: RoundedRectangle(cornerRadius: 25, style: .continuous))
                .contentShape(Rectangle())
        }
    }
}

/// Single topic row card (flat white/translucent, gold accuracy pill or neutral "Chưa làm")
private struct TopicRowCard: View {
    let title: String
    let questionCount: Int
    /// nil = unattempted, present = accuracy 0…1
    let accuracy: Double?
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(alignment: .center, spacing: 12) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(title)
                        .font(.appSans(size: 16, weight: .bold))
                        .foregroundStyle(Color.appTextDark)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)

                    HStack(spacing: 6) {
                        CountPill("\(questionCount) câu")
                        AccuracyPill(accuracy: accuracy)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                CircularActionButton(icon: "play.fill", size: 44)
            }
            .padding(12)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .background(Color.cardBg, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
    }
}

// MARK: - PracticeTab

struct PracticeTab: View {
    @Environment(QuestionStore.self) private var questionStore
    @Environment(ProgressStore.self) private var progressStore
    @Environment(LayoutMetrics.self) private var metrics
    @Environment(\.openExam) private var openExam

    @State private var selectedMasteryFilter: MasteryFilter = .tatCa

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // In-content page header (design: 32pt bold, no nav bar title)
                pageHeader

                // Hero recommendation card
                heroCard

                // Câu hỏi section
                questionSection
            }
            .padding(.horizontal, metrics.contentPadding)
            .padding(.top, 8)
            .padding(.bottom, 32)
            .glassContainer()
        }
        .screenHeader("Luyện tập", titleDisplayMode: .large)
        .tracksTabBarCollapse()
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                SearchToolbarButton()
            }
            ToolbarItem(placement: .topBarTrailing) {
                HistoryToolbarButton { PracticeHistoryView() }
            }
            ToolbarItem(placement: .topBarTrailing) {
                NavPlayButton(label: "Bắt đầu luyện tập") {
                    let allTopics = questionStore.topics
                    let resume = allTopics.first { $0.key == progressStore.lastTopicKey }
                    let key = resume?.key ?? allTopics.first?.key ?? AppConstants.TopicKey.allQuestions
                    let idx = resume != nil ? progressStore.lastQuestionIndex : 0
                    openExam(.questionView(topicKey: key, startIndex: idx))
                }
            }
        }
    }

    // MARK: - Page Header (subtitle below the native large title)

    private var pageHeader: some View {
        TabPageSubtitle("Chọn phần để bắt đầu ôn")
    }

    // MARK: - Hero Card

    private var heroCard: some View {
        let lastKey = progressStore.lastTopicKey
        let allTopics = questionStore.topics
        let resumeTopic = allTopics.first { $0.key == lastKey }
        let heroTopic = resumeTopic ?? allTopics.first

        let eyebrow = resumeTopic != nil ? "TIẾP TỤC HỌC" : "BẮT ĐẦU NGAY"
        let heroTitle = heroTopic?.name ?? "Câu hỏi ôn tập"
        let heroKey = resumeTopic?.key ?? allTopics.first?.key ?? AppConstants.TopicKey.allQuestions
        let startIndex = resumeTopic != nil ? progressStore.lastQuestionIndex : 0

        // Metadata tags (design: question count + resume position)
        var tags: [String] = []
        if let count = heroTopic?.questionCount, count > 0 {
            tags.append("\(count) câu")
        }
        if resumeTopic != nil {
            tags.append("Tiếp câu \(startIndex + 1)")
        }

        return LightFeatureCard(
            eyebrow: eyebrow,
            title: heroTitle,
            tags: tags,
            icon: "play.fill"
        ) {
            Haptics.impact(.medium)
            openExam(.questionView(topicKey: heroKey, startIndex: startIndex))
        }
    }

    // MARK: - Sa hình card
    // Rendered with the shared topic-card design so every item in the Câu hỏi
    // list looks the same (was a collapsible "Đề 1…N" set list). Opens the full
    // Sa hình practice; the accuracy pill reflects the most recent run.
    // Tình huống (hazard perception) lives in the Mô phỏng tab, not here.

    private var saHinhCard: some View {
        let saHinh = questionStore.topics.first { $0.topicIds.contains(6) }
        let title = saHinh?.name ?? "Sa hình & Tình huống"
        let count = questionStore.simulationQuestions.count
        let accuracy = progressStore.simulationHistory.first?.accuracy

        return TopicRowCard(
            title: title,
            questionCount: count,
            accuracy: accuracy
        ) {
            openExam(.simulationExam(mode: .fullPractice))
        }
    }

    // MARK: - Câu hỏi Section

    @ViewBuilder
    private var questionSection: some View {
        let allTopics = questionStore.topics
        let topicStats = progressStore.weakTopics(topics: allTopics)
            .filter { !$0.topic.topicIds.contains(6) }   // Sa hình (topic 6) handled by the merged card below
            .sorted { $0.topic.topicIds.first ?? 0 < $1.topic.topicIds.first ?? 0 }
        let totalCount = allTopics.reduce(0) { $0 + $1.questionCount }
        let filteredStats = applyMasteryFilter(topicStats)

        VStack(alignment: .leading, spacing: 14) {
            // Section header
            ContentSectionHeader("Câu hỏi")

            // Mastery sub-filter (Tất cả / Đang ôn / Chưa thuộc / Đã thuộc)
            PillFilterBar(items: MasteryFilter.allCases, label: \.label, selection: $selectedMasteryFilter, style: .compact)

            // Primary CTA button (accent-filled)
            PrimaryCTAButton(icon: "play.circle.fill", label: "Ôn tập \(totalCount) câu · Đề tổng hợp") {
                Haptics.impact(.medium)
                openExam(.questionView(topicKey: AppConstants.TopicKey.allQuestions, startIndex: 0))
            }

            // Topic list — Sa hình joins as the same card design as the others.
            VStack(spacing: 10) {
                ForEach(filteredStats, id: \.topic.id) { topicCard($0) }
                saHinhCard
            }
        }
    }

    /// One topic row using the shared card design. Opens the question practice.
    private func topicCard(_ item: TopicStatItem) -> some View {
        let accuracy: Double? = item.attempted > 0 ? item.accuracy : nil
        return TopicRowCard(
            title: item.topic.name,
            questionCount: item.total,
            accuracy: accuracy
        ) {
            openExam(.questionView(topicKey: item.topic.key, startIndex: 0))
        }
    }

    // MARK: - Mastery Filtering

    private typealias TopicStatItem = (topic: Topic, accuracy: Double, correct: Int, attempted: Int, total: Int)

    private func applyMasteryFilter(_ stats: [TopicStatItem]) -> [TopicStatItem] {
        switch selectedMasteryFilter {
        case .tatCa:
            return stats
        case .dangOn:
            // Partially attempted (> 0 answered, accuracy < 1.0)
            return stats.filter { $0.attempted > 0 && $0.accuracy < 1.0 }
        case .chuaThuoc:
            // Attempted but accuracy below 80%
            return stats.filter { $0.attempted > 0 && $0.accuracy < 0.8 }
        case .daThuoc:
            // Accuracy at or above 80%
            return stats.filter { $0.attempted > 0 && $0.accuracy >= 0.8 }
        }
    }

}
