import SwiftUI

struct WeakTopicsView: View {
    @Environment(QuestionStore.self) private var questionStore
    @Environment(ProgressStore.self) private var progressStore
    @Environment(\.openExam) private var openExam

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                let allTopics = progressStore.weakTopics(topics: questionStore.topics)
                let weakList = allTopics.filter { $0.attempted > 0 && $0.accuracy < 0.8 }
                let strongList = allTopics.filter { $0.attempted > 0 && $0.accuracy >= 0.8 }
                let notStarted = allTopics.filter { $0.attempted == 0 }

                if !weakList.isEmpty {
                    SectionTitle(title: "Cần ôn thêm")
                        .padding(.bottom, 10)

                    VStack(spacing: 10) {
                        ForEach(Array(weakList.enumerated()), id: \.element.topic.id) { _, item in
                            Button {
                                let progress = progressStore.topicProgress(for: item.topic.key)
                                let topicQs = questionStore.questionsForTopic(key: item.topic.key)
                                let idx = topicQs.firstIndex(where: { progress[$0.no] != true }) ?? 0
                                openExam(.questionView(topicKey: item.topic.key, startIndex: idx))
                            } label: {
                                TopicAccuracyRow(item: item)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.bottom, 10)
                }

                if !strongList.isEmpty {
                    SectionTitle(title: "Đã tốt")
                        .padding(.bottom, 10)

                    VStack(spacing: 10) {
                        ForEach(Array(strongList.enumerated()), id: \.element.topic.id) { _, item in
                            Button {
                                let progress = progressStore.topicProgress(for: item.topic.key)
                                let topicQs = questionStore.questionsForTopic(key: item.topic.key)
                                let idx = topicQs.firstIndex(where: { progress[$0.no] != true }) ?? 0
                                openExam(.questionView(topicKey: item.topic.key, startIndex: idx))
                            } label: {
                                TopicAccuracyRow(item: item)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.bottom, 10)
                }

                if !notStarted.isEmpty {
                    SectionTitle(title: "Chưa bắt đầu")
                        .padding(.bottom, 10)

                    VStack(spacing: 10) {
                        ForEach(Array(notStarted.enumerated()), id: \.element.topic.id) { _, item in
                            Button {
                                openExam(.questionView(topicKey: item.topic.key, startIndex: 0))
                            } label: {
                                TopicAccuracyRow(item: item)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }

                if weakList.isEmpty && notStarted.isEmpty {
                    EmptyState(
                        icon: "checkmark.circle.fill",
                        message: "Tuyệt vời! Tất cả chủ đề đều trên 80%",
                        iconColor: .appSuccess
                    )
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 24)
        }
        .screenHeader("Phân tích điểm yếu")
    }
}

// MARK: - Topic Accuracy Row

private struct TopicAccuracyRow: View {
    @Environment(ThemeStore.self) private var themeStore
    let item: (topic: Topic, accuracy: Double, correct: Int, attempted: Int, total: Int)

    private var accentColor: Color {
        item.accuracy < 0.5 ? .appError : item.accuracy < 0.8 ? .appWarning : .appSuccess
    }

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 10) {
                Text(item.topic.name)
                    .font(.appSans(size: 16, weight: .bold))
                    .foregroundStyle(Color.appTextDark)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)

                HStack(spacing: 6) {
                    if item.attempted > 0 {
                        TagPill(text: "\(Int(item.accuracy * 100))% đúng", color: accentColor)
                        TagPill(text: "\(item.correct)/\(item.attempted) câu")
                    } else {
                        TagPill(text: "\(item.total) câu")
                        TagPill(text: "Chưa bắt đầu")
                    }
                }
            }

            Spacer(minLength: 8)

            CircularActionButton(icon: "play.fill")
        }
        .padding(16)
        .glassCard()
    }
}
