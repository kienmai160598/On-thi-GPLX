import SwiftUI

struct TopicDetailView: View {
    let item: (topic: Topic, accuracy: Double, correct: Int, attempted: Int, total: Int)
    @Environment(\.dismiss) private var dismiss
    @Environment(\.openExam) private var openExam

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

        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Hero: icon + name + badge + description
                VStack(spacing: 16) {
                    IconBox(
                        icon: item.topic.sfSymbol,
                        color: .appPrimary,
                        size: 72,
                        cornerRadius: 18,
                        iconFontSize: 32
                    )

                    VStack(spacing: 8) {
                        Text(item.topic.name)
                            .font(.system(size: 22, weight: .heavy))
                            .foregroundStyle(Color.appTextDark)

                        Text(item.topic.topicDescription)
                            .font(.system(size: 14))
                            .foregroundStyle(Color.appTextMedium)
                            .multilineTextAlignment(.center)
                    }

                    StatusBadge(text: status.label, color: status.color, fontSize: 13)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 24)
                .glassCard()

                // Stats
                ExamStatsRow(items: [
                    (value: "\(item.correct)", label: "Đúng"),
                    (value: "\(max(item.attempted - item.correct, 0))", label: "Sai"),
                    (value: "\(item.total - item.attempted)", label: "Chưa làm"),
                    (value: "\(item.total)", label: "Tổng"),
                ])

                // Progress bar
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Tiến độ")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(Color.appTextDark)
                        Spacer()
                        Text("\(item.correct)/\(item.total) câu đúng")
                            .font(.system(size: 12).monospacedDigit())
                            .foregroundStyle(Color.appTextMedium)
                            .contentTransition(.numericText())
                    }

                    ProgressBarView(
                        fraction: item.total > 0 ? Double(item.correct) / Double(item.total) : 0,
                        color: status.color,
                        height: 10,
                        cornerRadius: 5
                    )
                }
                .padding(16)
                .glassCard()

                // Action button
                Button { openExam(.questionView(topicKey: item.topic.key, startIndex: 0)) } label: {
                    AppButton(icon: "play.fill", label: "Ôn tập chủ đề này")
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 32)
        }
        .navigationTitle(item.topic.shortName)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                CloseButton { dismiss() }
            }
        }
    }
}
