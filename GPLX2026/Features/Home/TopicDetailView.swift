import SwiftUI

struct TopicDetailView: View {
    let item: (topic: Topic, accuracy: Double, correct: Int, attempted: Int, total: Int)
    @Environment(\.dismiss) private var dismiss
    @Environment(\.openExam) private var openExam
    @Environment(QuestionStore.self) private var questionStore
    @Environment(ProgressStore.self) private var progressStore

    private var statusInfo: (label: String, color: Color) {
        if item.attempted == 0 {
            return ("Chưa học", .appTextLight)
        } else if item.accuracy >= 0.8 {
            return ("Tốt", .appSuccess)
        } else if item.accuracy >= 0.5 {
            return ("Cần ôn", .appWarning)
        } else {
            return ("Yếu", .appError)
        }
    }

    var body: some View {
        let status = statusInfo
        let fraction = item.total > 0 ? Double(item.correct) / Double(item.total) : 0

        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Hero with animated ring
                VStack(spacing: 20) {
                    ZStack {
                        Circle()
                            .stroke(Color.appDivider, lineWidth: 8)
                        Circle()
                            .trim(from: 0, to: fraction)
                            .stroke(status.color, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                            .rotationEffect(.degrees(-90))
                            .animation(.spring(duration: 0.8, bounce: 0.15), value: fraction)

                        Image(systemName: item.topic.sfSymbol)
                            .font(.system(size: 32))
                            .foregroundStyle(status.color)
                    }
                    .frame(width: 100, height: 100)

                    VStack(spacing: 8) {
                        Text(item.topic.name)
                            .font(.system(size: 24, weight: .heavy))
                            .foregroundStyle(Color.appTextDark)

                        Text(item.topic.topicDescription)
                            .font(.system(size: 14))
                            .foregroundStyle(Color.appTextMedium)
                            .multilineTextAlignment(.center)
                    }

                    StatusBadge(text: status.label, color: status.color, fontSize: 13)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 28)
                .glassCard()

                // Stats
                ExamStatsRow(items: [
                    (value: "\(item.correct)", label: "Đúng"),
                    (value: "\(max(item.attempted - item.correct, 0))", label: "Sai"),
                    (value: "\(item.total - item.attempted)", label: "Chưa làm"),
                    (value: "\(item.total)", label: "Tổng"),
                ])

                // Progress
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Text("Tiến độ")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(Color.appTextDark)
                        Spacer()
                        Text("\(item.correct)/\(item.total) câu đúng")
                            .font(.system(size: 13).monospacedDigit())
                            .foregroundStyle(Color.appTextMedium)
                            .contentTransition(.numericText())
                    }

                    ProgressBarView(
                        fraction: fraction,
                        color: status.color,
                        height: 10,
                        cornerRadius: 5
                    )
                }
                .padding(16)
                .glassCard()

                // CTA
                VStack(spacing: 12) {
                    Button {
                        let progress = progressStore.topicProgress(for: item.topic.key)
                        let topicQs = questionStore.questionsForTopic(key: item.topic.key)
                        let idx = topicQs.firstIndex(where: { progress[$0.no] == nil }) ?? 0
                        openExam(.questionView(topicKey: item.topic.key, startIndex: idx))
                    } label: {
                        AppButton(icon: "play.fill", label: "Ôn tập chủ đề này")
                    }
                    .buttonStyle(.plain)

                    Button { openExam(.flashcard(topicKey: item.topic.key)) } label: {
                        AppButton(icon: "rectangle.on.rectangle.angled", label: "Flashcard", style: .secondary)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 32)
        }
        .navigationTitle(item.topic.shortName)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button { dismiss() } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(Color.appTextDark)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}
