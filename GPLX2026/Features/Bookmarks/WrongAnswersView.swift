import SwiftUI

struct WrongAnswersView: View {
    @Environment(QuestionStore.self) private var questionStore
    @Environment(ProgressStore.self) private var progressStore
    @Environment(LayoutMetrics.self) private var metrics
    @Environment(\.openExam) private var openExam

    var body: some View {
        let wrongByTopic = questionStore.wrongAnswersByTopic(wrongIds: progressStore.wrongAnswers)
        let totalWrong = progressStore.wrongAnswers.count

        ScrollView {
            if wrongByTopic.isEmpty {
                EmptyState(icon: "checkmark.circle.fill", message: "Không có câu sai nào!", iconColor: .appSuccess)
            } else {
                AdaptiveGrid(spacing: 12) {
                    ForEach(wrongByTopic, id: \.topic.key) { group in
                        WrongTopicCard(topic: group.topic, questions: group.questions)
                    }
                }
                .padding(.horizontal, metrics.contentPadding)
                .padding(.bottom, 24)
            }
        }
        .screenHeader("Câu sai theo chủ đề")
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
