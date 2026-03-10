import SwiftUI

struct TopicsView: View {
    @Environment(QuestionStore.self) private var questionStore
    @Environment(ProgressStore.self) private var progressStore
    @Environment(\.openExam) private var openExam

    var initialTopicKey: String? = nil
    @State private var selectedTopicKey: String? = nil

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                if let key = selectedTopicKey {
                    let questions = questionStore.questionsForTopic(key: key)
                    let topic = questionStore.topics.first(where: { $0.key == key })

                    TopicCard(
                        topic: topic,
                        questions: questions,
                        progressStore: progressStore,
                        onTapQuestion: { openQuestion(topicKey: key, index: $0) }
                    )
                } else {
                    ForEach(questionStore.topics, id: \.id) { topic in
                        let questions = questionStore.questionsForTopic(key: topic.key)

                        if !questions.isEmpty {
                            TopicCard(
                                topic: topic,
                                questions: questions,
                                progressStore: progressStore,
                                onTapQuestion: { openQuestion(topicKey: topic.key, index: $0) }
                            )
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 24)
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
                        Label {
                            Text("Tất cả (\(questionStore.allQuestions.count))")
                        } icon: {
                            if selectedTopicKey == nil { Image(systemName: "checkmark") }
                        }
                    }
                    ForEach(questionStore.topics, id: \.id) { topic in
                        Button {
                            withAnimation { selectedTopicKey = topic.key }
                        } label: {
                            Label {
                                Text("\(topic.shortName) (\(topic.questionCount))")
                            } icon: {
                                if selectedTopicKey == topic.key { Image(systemName: "checkmark") }
                            }
                        }
                    }
                } label: {
                    Image(systemName: selectedTopicKey != nil ? "line.3.horizontal.decrease.circle.fill" : "line.3.horizontal.decrease.circle")
                        .foregroundStyle(.primary)
                }
            }
        }
    }

    private func openQuestion(topicKey: String, index: Int) {
        openExam(.questionView(topicKey: topicKey, startIndex: index))
    }
}

// MARK: - Topic Card (header + question number grid)

private struct TopicCard: View {
    let topic: Topic?
    let questions: [Question]
    let progressStore: ProgressStore
    var onTapQuestion: (Int) -> Void = { _ in }

    private var progress: (correct: Int, wrong: Int, total: Int) {
        guard let topic else { return (0, 0, questions.count) }
        let prog = progressStore.topicProgress(for: topic.key)
        let correct = prog.values.filter { $0 }.count
        let wrong = prog.values.filter { !$0 }.count
        return (correct, wrong, questions.count)
    }

    private var fraction: Double {
        progress.total > 0 ? Double(progress.correct) / Double(progress.total) : 0
    }

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 6), count: 7)

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack(spacing: 12) {
                if let topic {
                    IconBox(icon: topic.icon, color: topic.color, size: 40, cornerRadius: 8, iconFontSize: 18)

                    VStack(alignment: .leading, spacing: 3) {
                        Text(topic.name)
                            .font(.system(size: 16, weight: .heavy))
                            .foregroundStyle(Color.appTextDark)

                        HStack(spacing: 8) {
                            Text("\(progress.correct)/\(progress.total) đã đúng")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundStyle(Color.appTextMedium)

                            if progress.wrong > 0 {
                                Text("· \(progress.wrong) sai")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundStyle(Color.appError)
                            }
                        }
                    }

                    Spacer(minLength: 4)

                    Text("\(Int(fraction * 100))%")
                        .font(.system(size: 15, weight: .bold).monospacedDigit())
                        .foregroundStyle(fraction >= 1.0 ? Color.appSuccess : Color.appTextMedium)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)

            // Progress bar
            ProgressBarView(
                fraction: fraction,
                color: topic?.color ?? .appPrimary,
                height: 3,
                cornerRadius: 0
            )

            // Question number grid
            LazyVGrid(columns: columns, spacing: 6) {
                ForEach(Array(questions.enumerated()), id: \.element.no) { index, question in
                    let qTopicKey = Topic.keyForTopicId(question.topic)
                    let status = progressStore.answerStatus(topicKey: qTopicKey, questionNo: question.no)

                    Button { onTapQuestion(index) } label: {
                        QuestionNumberCell(
                            number: question.no,
                            status: status,
                            isDiemLiet: question.isDiemLiet
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 12)
        }
        .glassCard()
    }
}

// MARK: - Question Number Cell

private struct QuestionNumberCell: View {
    let number: Int
    let status: AnswerStatus
    let isDiemLiet: Bool

    private var bgColor: Color {
        switch status {
        case .correct: return .appSuccess
        case .wrong: return .appError
        case .unanswered: return .appDivider
        }
    }

    private var fgColor: Color {
        switch status {
        case .correct, .wrong: return .white
        case .unanswered: return .appTextDark
        }
    }

    var body: some View {
        Text("\(number)")
            .font(.system(size: 13, weight: status == .unanswered ? .medium : .bold).monospacedDigit())
            .foregroundStyle(fgColor)
            .frame(maxWidth: .infinity)
            .frame(height: 40)
            .background(bgColor.opacity(status == .unanswered ? 0.4 : 0.85))
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            .overlay {
                if isDiemLiet {
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .strokeBorder(Color.appError.opacity(0.6), lineWidth: 1.5)
                }
            }
    }
}
