import SwiftUI

struct SimulationResultView: View {
    @Environment(\.popToRoot) private var popToRoot
    @Environment(\.openExam) private var openExam

    let questions: [Question]
    let answers: [Int: Int]
    let timePerScenario: [Int: Int]
    let simulationResult: SimulationResult
    var isFromHistory: Bool = false

    private var correctCount: Int { simulationResult.score }
    private var timedOutCount: Int { simulationResult.timedOutCount }
    private var isPassed: Bool { simulationResult.passed }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                Spacer().frame(height: 8)

                // MARK: - Result Hero
                ResultHero(
                    isPassed: isPassed,
                    score: correctCount,
                    total: questions.count,
                    subtitle: isPassed
                        ? "Chúc mừng bạn đã vượt qua!"
                        : "Hãy ôn tập thêm và thử lại nhé"
                )

                // MARK: - Score details
                VStack(spacing: 0) {
                    ScoreRow(label: "Câu đúng", value: "\(correctCount)/\(questions.count)", color: Color.appSuccess)
                    Divider().padding(.horizontal, 16)
                    ScoreRow(label: "Câu sai", value: "\(questions.count - correctCount)/\(questions.count)", color: Color.appError)
                    Divider().padding(.horizontal, 16)
                    ScoreRow(
                        label: "Hết thời gian",
                        value: "\(timedOutCount)",
                        color: timedOutCount > 0 ? Color.appWarning : Color.appSuccess
                    )
                    Divider().padding(.horizontal, 16)

                    let minutes = simulationResult.totalTimeUsedSeconds / 60
                    let seconds = simulationResult.totalTimeUsedSeconds % 60
                    ScoreRow(
                        label: "Thời gian",
                        value: String(format: "%02d:%02d", minutes, seconds),
                        color: Color.appTextMedium
                    )
                    Divider().padding(.horizontal, 16)
                    ScoreRow(
                        label: "Yêu cầu đạt",
                        value: "\u{2265} 70% (\(Int(Double(questions.count) * 0.7))/\(questions.count))",
                        color: Color.appTextMedium
                    )
                }
                .padding(.vertical, 4)
                .glassCard()

                // MARK: - Review
                SectionTitle(title: "Xem lại đáp án")

                LazyVStack(spacing: 8) {
                    ForEach(Array(questions.enumerated()), id: \.element.no) { index, question in
                        let selectedId = answers[index]
                        let isCorrect = selectedId != nil && question.answers.contains(where: { $0.id == selectedId && $0.correct })
                        QuestionReviewRow(
                            question: question,
                            status: selectedId == nil ? .unanswered : isCorrect ? .correct : .wrong,
                            selectedAnswerId: selectedId,
                            timeUsedBadge: selectedId == nil ? "Hết giờ" : nil
                        )
                        .glassCard()
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 32)
        }
        .safeAreaInset(edge: .bottom) {
            if !isFromHistory {
                HStack(spacing: 10) {
                    Button {
                        popToRoot()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            openExam(.simulationExam(mode: .random))
                        }
                    } label: {
                        AppButton(icon: "arrow.counterclockwise", label: "Thi lại", style: .secondary, height: 48, cornerRadius: 24)
                    }

                    Button { popToRoot() } label: {
                        AppButton(icon: "checkmark", label: "Hoàn thành", height: 48, cornerRadius: 24)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(.ultraThinMaterial)
            }
        }
        .navigationBarBackButtonHidden(!isFromHistory)
        .screenHeader(isFromHistory ? "Chi tiết mô phỏng" : "Kết quả mô phỏng")
        .toolbar {
            if !isFromHistory {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button { popToRoot() } label: {
                        Image(systemName: "checkmark")
                            .font(.system(size: 15, weight: .semibold))
                    }
                }
            }
        }
    }
}

