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
                                let idx = topicQs.firstIndex(where: { progress[$0.no] == nil }) ?? 0
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
                                let idx = topicQs.firstIndex(where: { progress[$0.no] == nil }) ?? 0
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
            .iPadReadable()
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
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .stroke(Color.appDivider, lineWidth: 3)
                Circle()
                    .trim(from: 0, to: item.accuracy)
                    .stroke(accentColor, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                Image(systemName: item.topic.sfSymbol)
                    .font(.appSans(size: 16))
                    .foregroundStyle(accentColor)
            }
            .frame(width: 44, height: 44)

            VStack(alignment: .leading, spacing: 4) {
                Text(item.topic.name)
                    .font(.appSans(size: 15, weight: .semibold))
                    .foregroundStyle(Color.appTextDark)

                Text(item.attempted > 0
                    ? "\(item.correct)/\(item.attempted) đúng · \(Int(item.accuracy * 100))%"
                    : "0/\(item.total) câu · Chưa bắt đầu")
                    .font(.appSans(size: 13))
                    .foregroundStyle(Color.appTextMedium)
            }

            Spacer(minLength: 4)

            Text("Ôn tập")
                .font(.appSans(size: 13, weight: .medium))
                .foregroundStyle(themeStore.primaryColor)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .glassCard()
    }
}
