import SwiftUI

struct WeakTopicsView: View {
    @Environment(QuestionStore.self) private var questionStore
    @Environment(ProgressStore.self) private var progressStore

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                let allTopics = progressStore.weakTopics(topics: questionStore.topics)
                let weakList = allTopics.filter { $0.attempted > 0 && $0.accuracy < 0.8 }
                let strongList = allTopics.filter { $0.attempted > 0 && $0.accuracy >= 0.8 }
                let notStarted = allTopics.filter { $0.attempted == 0 }

                // MARK: - Weak topics
                if !weakList.isEmpty {
                    SectionTitle(title: "Cần ôn thêm")
                        .padding(.bottom, 8)
                        .staggered(0)

                    ForEach(Array(weakList.enumerated()), id: \.element.topic.id) { i, item in
                        NavigationLink(destination: QuestionView(topicKey: item.topic.key, startIndex: 0)) {
                            TopicAccuracyRow(item: item)
                        }
                        .buttonStyle(.plain)
                        .padding(.bottom, 8)
                        .staggered(1 + i)
                    }
                    .padding(.bottom, 12)
                }

                // MARK: - Strong topics
                if !strongList.isEmpty {
                    SectionTitle(title: "Đã tốt")
                        .padding(.bottom, 8)
                        .staggered(6)

                    ForEach(Array(strongList.enumerated()), id: \.element.topic.id) { i, item in
                        NavigationLink(destination: QuestionView(topicKey: item.topic.key, startIndex: 0)) {
                            TopicAccuracyRow(item: item)
                        }
                        .buttonStyle(.plain)
                        .padding(.bottom, 8)
                        .staggered(7 + i)
                    }
                    .padding(.bottom, 12)
                }

                // MARK: - Not started
                if !notStarted.isEmpty {
                    SectionTitle(title: "Chưa bắt đầu")
                        .padding(.bottom, 8)
                        .staggered(12)

                    ForEach(Array(notStarted.enumerated()), id: \.element.topic.id) { i, item in
                        NavigationLink(destination: QuestionView(topicKey: item.topic.key, startIndex: 0)) {
                            ListItemCard(
                                icon: item.topic.sfSymbol,
                                title: item.topic.name,
                                subtitle: "0/\(item.total) câu"
                            )
                        }
                        .buttonStyle(.plain)
                        .padding(.bottom, 8)
                        .staggered(13 + i)
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
            .padding(.bottom, 20)
        }
        .screenHeader("Phân tích điểm yếu")
    }
}

// MARK: - Topic Accuracy Row

private struct TopicAccuracyRow: View {
    let item: (topic: Topic, accuracy: Double, correct: Int, attempted: Int, total: Int)

    private var accentColor: Color {
        item.accuracy < 0.5 ? .appError : item.accuracy < 0.8 ? .appWarning : .appSuccess
    }

    var body: some View {
        HStack(spacing: 14) {
            IconBox(
                icon: item.topic.sfSymbol,
                color: accentColor,
                size: 40,
                cornerRadius: 10,
                iconFontSize: 17
            )

            VStack(alignment: .leading, spacing: 4) {
                Text(item.topic.name)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Color.appTextDark)

                // Progress bar
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 3)
                            .fill(Color.appDivider)
                            .frame(height: 6)

                        RoundedRectangle(cornerRadius: 3)
                            .fill(accentColor)
                            .frame(width: geo.size.width * item.accuracy, height: 6)
                    }
                }
                .frame(height: 6)

                Text("\(item.correct)/\(item.attempted) đúng \u{2022} \(Int(item.accuracy * 100))%")
                    .font(.system(size: 12))
                    .foregroundStyle(Color.appTextMedium)
            }

            Spacer(minLength: 4)

            Text("Ôn tập")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(Color.appPrimary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .glassCard()
    }
}
