import SwiftUI

struct WrongAnswersView: View {
    @Environment(QuestionStore.self) private var questionStore
    @Environment(ProgressStore.self) private var progressStore
    @Environment(ThemeStore.self) private var themeStore
    @Environment(LayoutMetrics.self) private var metrics
    @Environment(\.openExam) private var openExam

    var body: some View {
        let wrongByTopic = questionStore.wrongAnswersByTopic(wrongIds: progressStore.wrongAnswers)

        ScrollView {
            if wrongByTopic.isEmpty {
                EmptyState(icon: "checkmark.circle.fill", message: "Không có câu sai nào!", iconColor: .appSuccess)
            } else {
                VStack(spacing: 12) {
                    prioritizedReviewButton

                    AdaptiveGrid(spacing: 12) {
                        ForEach(wrongByTopic, id: \.topic.key) { group in
                            WrongTopicCard(topic: group.topic, questions: group.questions)
                        }
                    }
                }
                .padding(.horizontal, metrics.contentPadding)
                .padding(.top, 4)
                .padding(.bottom, 24)
            }
        }
        .screenHeader("Câu sai theo chủ đề")
    }

    /// Surfaces the spaced-repetition engine: opens the wrong answers ordered by
    /// review priority (never-reviewed first, then oldest). Shows how many are due today.
    private var prioritizedReviewButton: some View {
        let dueCount = progressStore.wrongAnswersDueForReview().count
        return Button {
            openExam(.questionView(topicKey: AppConstants.TopicKey.wrongAnswersPriority, startIndex: 0))
        } label: {
            HStack(spacing: 12) {
                Image(systemName: "brain.head.profile")
                    .font(.appSans(size: 18, weight: .semibold))
                    .foregroundStyle(themeStore.primaryColor)
                    .frame(width: 44, height: 44)
                    .background(themeStore.primaryColor.opacity(0.12), in: RoundedRectangle(cornerRadius: 12, style: .continuous))

                VStack(alignment: .leading, spacing: 2) {
                    Text("Ôn theo ưu tiên")
                        .font(.appSans(size: 16, weight: .bold))
                        .foregroundStyle(Color.appTextDark)
                    Text(dueCount > 0 ? "\(dueCount) câu cần ôn hôm nay" : "Ôn lại câu sai theo thứ tự ưu tiên")
                        .font(.appSans(size: 13))
                        .foregroundStyle(Color.appTextMedium)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.appSans(size: 13, weight: .semibold))
                    .foregroundStyle(Color.appTextLight)
            }
            .padding(14)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .glassCard()
        .accessibilityLabel(dueCount > 0 ? "Ôn theo ưu tiên, \(dueCount) câu cần ôn hôm nay" : "Ôn theo ưu tiên")
    }
}

// MARK: - Wrong Topic Card

private struct WrongTopicCard: View {
    @Environment(\.openExam) private var openExam
    let topic: Topic
    let questions: [Question]

    var body: some View {
        Button { openExam(.questionView(topicKey: "\(AppConstants.TopicKey.wrongAnswers):\(topic.key)", startIndex: 0)) } label: {
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 10) {
                    Text(topic.name)
                        .font(.appSans(size: 16, weight: .bold))
                        .foregroundStyle(Color.appTextDark)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)

                    HStack(spacing: 6) {
                        TagPill(text: "\(questions.count) câu sai", color: .appError)
                    }
                }

                Spacer(minLength: 8)

                CircularActionButton(icon: "play.fill")
            }
            .padding(16)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .glassCard()
    }
}
