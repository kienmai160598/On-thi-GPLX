import SwiftUI

struct TopicsView: View {
    @Environment(QuestionStore.self) private var questionStore
    @Environment(ProgressStore.self) private var progressStore

    @State private var selectedTopicKey: String? = nil

    private var displayQuestions: [Question] {
        if let key = selectedTopicKey {
            return questionStore.questionsForTopic(key: key)
        }
        return questionStore.allQuestions
    }

    private var filterIcon: String {
        selectedTopicKey != nil ? "line.3.horizontal.decrease.circle.fill" : "line.3.horizontal.decrease.circle"
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                ForEach(Array(displayQuestions.enumerated()), id: \.element.no) { index, question in
                    if index > 0 {
                        Divider().padding(.leading, 60)
                    }

                    let topicKey = TopicInfo.keyForTopicId(question.topic)
                    let answerStatus = progressStore.answerStatus(topicKey: topicKey, questionNo: question.no)
                    let navTopicKey = selectedTopicKey ?? topicKey
                    let navIndex: Int = {
                        if selectedTopicKey != nil { return index }
                        return questionStore.allQuestions.firstIndex(where: { $0.no == question.no }) ?? 0
                    }()

                    NavigationLink(destination: QuestionView(topicKey: navTopicKey, startIndex: navIndex)) {
                        HStack(spacing: 12) {
                            Text("\(question.no)")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(Color.appTextMedium)
                                .frame(width: 28, alignment: .center)

                            Text(question.text)
                                .font(.system(size: 15))
                                .foregroundStyle(Color.appTextDark)
                                .lineLimit(2)
                                .multilineTextAlignment(.leading)
                                .lineSpacing(2)

                            Spacer(minLength: 8)

                            switch answerStatus {
                            case .correct:
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 16))
                                    .foregroundStyle(Color.appSuccess)
                            case .wrong:
                                Image(systemName: "xmark.circle.fill")
                                    .font(.system(size: 16))
                                    .foregroundStyle(Color.appError)
                            case .unanswered:
                                EmptyView()
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                    }
                    .buttonStyle(.plain)
                }

                Spacer().frame(height: 20)
            }
        }
        .screenHeader("Chủ đề")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button {
                        selectedTopicKey = nil
                    } label: {
                        if selectedTopicKey == nil {
                            Label("Tất cả (\(questionStore.allQuestions.count))", systemImage: "checkmark")
                        } else {
                            Text("Tất cả (\(questionStore.allQuestions.count))")
                        }
                    }

                    ForEach(questionStore.topics, id: \.id) { topic in
                        Button {
                            selectedTopicKey = topic.key
                        } label: {
                            if selectedTopicKey == topic.key {
                                Label("\(topic.shortName) (\(topic.questionCount))", systemImage: "checkmark")
                            } else {
                                Text("\(topic.shortName) (\(topic.questionCount))")
                            }
                        }
                    }
                } label: {
                    Image(systemName: filterIcon)
                        .foregroundStyle(Color.appTextDark)
                }
            }
        }
    }
}
