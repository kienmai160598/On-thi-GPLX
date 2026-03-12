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
        HStack(spacing: 14) {
            IconBox(icon: topic.sfSymbol, color: .appError, size: 44, cornerRadius: 8, iconFontSize: 18)

            VStack(alignment: .leading, spacing: 4) {
                Text(topic.name)
                    .font(.appSans(size: 15, weight: .bold))
                    .foregroundStyle(Color.appTextDark)
                    .lineLimit(1)
                Text("\(questions.count) câu sai")
                    .font(.appSans(size: 13, weight: .medium))
                    .foregroundStyle(Color.appError)
            }

            Spacer()

            Button { openExam(.questionView(topicKey: "\(AppConstants.TopicKey.wrongAnswers):\(topic.key)", startIndex: 0)) } label: {
                InlinePill("Luyện")
            }
            .buttonStyle(.plain)
        }
        .padding(12)
        .glassCard()
    }
}
