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

    // MARK: - Stat card (frosted material)

    private var scoreDetails: some View {
        VStack(spacing: 0) {
            ScoreRow(
                label: "Câu đúng",
                value: "\(correctCount)/\(questions.count)",
                color: Color.appSuccess
            )
            Divider().padding(.horizontal, 16)

            ScoreRow(
                label: "Câu sai",
                value: "\(questions.count - correctCount)/\(questions.count)",
                color: Color.appError
            )
            Divider().padding(.horizontal, 16)

            let minutes = timeUsedSeconds / 60
            let seconds = timeUsedSeconds % 60
            ScoreRow(
                label: "Thời gian",
                value: String(format: "%02d:%02d", minutes, seconds),
                color: Color.appTextMedium
            )
            Divider().padding(.horizontal, 16)

            // Streak row with fire accent
            HStack {
                HStack(spacing: 8) {
                    IconBox(
                        icon: "flame.fill",
                        color: Color.appWarning,
                        size: 28,
                        cornerRadius: 8,
                        iconFontSize: 14
                    )
                    Text("Chuỗi thử thách")
                        .font(.appMono(size: 15, weight: .medium))
                        .foregroundStyle(Color.appTextMedium)
                }
                Spacer()
                Text("\(progressStore.dailyChallengeStreak) ngày")
                    .font(.appMono(size: 15, weight: .bold))
                    .foregroundStyle(Color.appWarning)
                    .contentTransition(.numericText())
                    .animation(.snappy, value: progressStore.dailyChallengeStreak)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
        }
        .padding(.vertical, 4)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }

    // MARK: - Body

    var body: some View {
        ScrollView {
            VStack(spacing: metrics.isIPadLayout ? 16 : 24) {
                Spacer().frame(height: metrics.isIPadLayout ? 4 : 8)

                if metrics.isIPadLayout {
                    HStack(alignment: .top, spacing: metrics.gridSpacing) {
                        ResultHero(
                            isPassed: result.passed,
                            score: correctCount,
                            total: questions.count,
                            subtitle: result.passed
                                ? "Thử thách hôm nay hoàn thành!"
                                : "Cố gắng hơn vào ngày mai nhé!"
                        )
                        scoreDetails
                    }
                } else {
                    ResultHero(
                        isPassed: result.passed,
                        score: correctCount,
                        total: questions.count,
                        subtitle: result.passed
                            ? "Thử thách hôm nay hoàn thành!"
                            : "Cố gắng hơn vào ngày mai nhé!"
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
                        .background(.ultraThinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
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
                .accessibilityLabel("Hoàn thành")
            }
        }
    }
}
