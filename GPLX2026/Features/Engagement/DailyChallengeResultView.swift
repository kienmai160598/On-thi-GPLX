import SwiftUI

struct DailyChallengeResultView: View {
    @Environment(LayoutMetrics.self) private var metrics
    @Environment(ProgressStore.self) private var progressStore
    @Environment(ThemeStore.self) private var themeStore
    @Environment(\.popToRoot) private var popToRoot

    let questions: [Question]
    let answers: [Int: Int]
    let timeUsedSeconds: Int
    let result: ExamResult

    private var correctCount: Int { result.score }

    private var scoreDetails: some View {
        VStack(spacing: 0) {
            ScoreRow(label: "Câu đúng", value: "\(correctCount)/\(questions.count)", color: Color.appSuccess)
            Divider().padding(.horizontal, 16)
            ScoreRow(label: "Câu sai", value: "\(questions.count - correctCount)/\(questions.count)", color: Color.appError)
            Divider().padding(.horizontal, 16)

            let minutes = timeUsedSeconds / 60
            let seconds = timeUsedSeconds % 60
            ScoreRow(label: "Thời gian", value: String(format: "%02d:%02d", minutes, seconds), color: Color.appTextMedium)
            Divider().padding(.horizontal, 16)

            ScoreRow(
                label: "Chuỗi thử thách",
                value: "\(progressStore.dailyChallengeStreak) ngày",
                color: themeStore.primaryColor
            )
        }
        .padding(.vertical, 4)
        .glassCard()
    }

    var body: some View {
        ScrollView {
            VStack(spacing: metrics.isIPadLayout ? 16 : 24) {
                Spacer().frame(height: metrics.isIPadLayout ? 4 : 8)

                if metrics.isIPadLayout {
                    HStack(alignment: .top, spacing: metrics.gridSpacing) {
                        ResultHero(
                            isPassed: true,
                            score: correctCount,
                            total: questions.count,
                            subtitle: "Thử thách hôm nay hoàn thành!"
                        )
                        scoreDetails
                    }
                } else {
                    ResultHero(
                        isPassed: true,
                        score: correctCount,
                        total: questions.count,
                        subtitle: "Thử thách hôm nay hoàn thành!"
                    )
                    scoreDetails
                }

                SectionTitle(title: "Xem lại đáp án")

                AdaptiveGrid {
                    ForEach(Array(questions.enumerated()), id: \.element.no) { index, question in
                        let selectedId = answers[index]
                        let isCorrect = selectedId != nil && question.answers.contains(where: { $0.id == selectedId && $0.correct })
                        QuestionReviewRow(
                            question: question,
                            status: selectedId == nil ? .unanswered : isCorrect ? .correct : .wrong,
                            selectedAnswerId: selectedId
                        )
                        .glassCard()
                    }
                }
            }
            .padding(.horizontal, metrics.contentPadding)
            .padding(.bottom, 32)
        }
        .safeAreaInset(edge: .bottom) {
            Button { popToRoot() } label: {
                AppButton(icon: "checkmark", label: "Hoàn thành", height: metrics.buttonHeight)
            }
            .padding(.horizontal, metrics.contentPadding)
            .padding(.bottom, 4)
        }
        .screenHeader("Kết quả thử thách", hideBackButton: true)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button { popToRoot() } label: {
                    Image(systemName: "checkmark")
                        .font(.appSans(size: 15, weight: .semibold))
                }
            }
        }
    }
}
