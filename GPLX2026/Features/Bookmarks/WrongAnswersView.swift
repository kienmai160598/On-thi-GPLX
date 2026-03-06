import SwiftUI

struct WrongAnswersView: View {
    @Environment(QuestionStore.self) private var questionStore
    @Environment(ProgressStore.self) private var progressStore
    @Environment(\.openExam) private var openExam

    var body: some View {
        let wrongByTopic = questionStore.wrongAnswersByTopic(wrongIds: progressStore.wrongAnswers)
        let totalWrong = progressStore.wrongAnswers.count

        ScrollView {
            if wrongByTopic.isEmpty {
                EmptyState(icon: "checkmark.circle", message: "Không có câu sai nào!", iconColor: .appSuccess)
            } else {
                VStack(alignment: .leading, spacing: 0) {
                    // MARK: - Practice all button
                    if totalWrong > 1 {
                        Button { openExam(.questionView(topicKey: AppConstants.TopicKey.wrongAnswers, startIndex: 0)) } label: {
                            AppButton(label: "Luyện tất cả (\(totalWrong) câu)")
                        }
                        .buttonStyle(.plain)
                        .padding(.bottom, 16)
                    }

                    // MARK: - Topic sections
                    ForEach(wrongByTopic, id: \.topic.key) { group in
                        WrongTopicCard(topic: group.topic, questions: group.questions)
                            .padding(.bottom, 8)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
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
        HStack(spacing: 12) {
            // Icon
            IconBox(icon: topic.sfSymbol, color: .appPrimary)

            // Name + count
            VStack(alignment: .leading, spacing: 4) {
                Text(topic.name)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(Color.appTextDark)
                    .lineLimit(1)
                Text("\(questions.count) câu sai")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(Color.appError)
            }

            Spacer()

            // Practice button
            Button { openExam(.questionView(topicKey: topic.key, startIndex: 0)) } label: {
                Text("Luyện")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(Color.appOnPrimary)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.appPrimary)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .glassCard()
    }
}
