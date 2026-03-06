import SwiftUI

struct TopicsView: View {
    @Environment(QuestionStore.self) private var questionStore
    @Environment(ProgressStore.self) private var progressStore

    var initialTopicKey: String? = nil
    @State private var selectedTopicKey: String? = nil

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 0) {
                if let key = selectedTopicKey {
                    let questions = questionStore.questionsForTopic(key: key)
                    let topic = questionStore.topics.first(where: { $0.key == key })

                    TopicSectionHeader(
                        topic: topic,
                        questions: questions,
                        progressStore: progressStore
                    )

                    QuestionReviewList(
                        questions: questions,
                        topicKey: key,
                        progressStore: progressStore
                    )
                } else {
                    ForEach(questionStore.topics, id: \.id) { topic in
                        let questions = questionStore.questionsForTopic(key: topic.key)

                        if !questions.isEmpty {
                            TopicSectionHeader(
                                topic: topic,
                                questions: questions,
                                progressStore: progressStore
                            )

                            QuestionReviewList(
                                questions: questions,
                                topicKey: topic.key,
                                progressStore: progressStore
                            )
                            .padding(.bottom, 12)
                        }
                    }
                }
            }
            .padding(.horizontal, 20)

            Spacer().frame(height: 20)
        }
        .onAppear {
            if selectedTopicKey == nil, let key = initialTopicKey {
                selectedTopicKey = key
            }
        }
        .screenHeader("Học theo chủ đề")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button {
                        withAnimation { selectedTopicKey = nil }
                    } label: {
                        Label("Tất cả (\(questionStore.allQuestions.count))", systemImage: selectedTopicKey == nil ? "checkmark" : "")
                    }
                    ForEach(questionStore.topics, id: \.id) { topic in
                        Button {
                            withAnimation { selectedTopicKey = topic.key }
                        } label: {
                            Label(
                                "\(topic.shortName) (\(topic.questionCount))",
                                systemImage: selectedTopicKey == topic.key ? "checkmark" : ""
                            )
                        }
                    }
                } label: {
                    Image(systemName: selectedTopicKey != nil ? "line.3.horizontal.decrease.circle.fill" : "line.3.horizontal.decrease.circle")
                        .foregroundStyle(.primary)
                }
            }
        }
    }

}

// MARK: - Topic Section Header

private struct TopicSectionHeader: View {
    let topic: Topic?
    let questions: [Question]
    let progressStore: ProgressStore

    private var progress: (correct: Int, wrong: Int, total: Int) {
        guard let topic else { return (0, 0, questions.count) }
        let prog = progressStore.topicProgress(for: topic.key)
        let correct = prog.values.filter { $0 }.count
        let wrong = prog.values.filter { !$0 }.count
        return (correct, wrong, questions.count)
    }

    var body: some View {
        HStack(alignment: .bottom) {
            VStack(alignment: .leading, spacing: 2) {
                if let topic {
                    Text(topic.name)
                        .font(.system(size: 16, weight: .heavy))
                        .foregroundStyle(Color.appTextDark)
                }
                Text("\(progress.correct)/\(progress.total) đã đúng")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(Color.appTextMedium)
            }
            Spacer()
            if progress.wrong > 0 {
                Text("\(progress.wrong) sai")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(Color.appError)
            }
        }
        .padding(.bottom, 8)
        .padding(.top, 4)
    }
}

// MARK: - Question List

private struct QuestionReviewList: View {
    let questions: [Question]
    let topicKey: String
    let progressStore: ProgressStore

    var body: some View {
        LazyVStack(spacing: 8) {
            ForEach(questions, id: \.no) { question in
                let qTopicKey = Topic.keyForTopicId(question.topic)
                let status = progressStore.answerStatus(topicKey: qTopicKey, questionNo: question.no)

                QuestionReviewRow(question: question, status: status)
                    .glassCard()
            }
        }
    }
}
