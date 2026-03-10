import SwiftUI

struct ExamResultView: View {
    @Environment(\.popToRoot) private var popToRoot
    @Environment(\.openExam) private var openExam

    let questions: [Question]
    let answers: [Int: Int]
    let timeUsedSeconds: Int
    let examResult: ExamResult
    var isFromHistory: Bool = false

    private var correctCount: Int { examResult.score }
    private var wrongDiemLietCount: Int { examResult.wrongDiemLiet }
    private var isPassed: Bool { examResult.passed }

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
                        label: "Điểm liệt sai",
                        value: "\(wrongDiemLietCount)",
                        color: wrongDiemLietCount > 0 ? Color.appError : Color.appSuccess
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
                    ScoreRow(
                        label: "Yêu cầu đạt",
                        value: "≥ \(LicenseType.current.passThreshold) & 0 ĐL sai",
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
                            selectedAnswerId: selectedId
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
                VStack(spacing: 8) {
                    if questions.count - correctCount > 0 {
                        Button {
                            openExam(.questionView(topicKey: AppConstants.TopicKey.wrongAnswers, startIndex: 0))
                        } label: {
                            AppButton(icon: "arrow.trianglehead.2.clockwise", label: "Luyện \(questions.count - correctCount) câu sai", style: .secondary, height: 48)
                        }
                    }

                    HStack(spacing: 10) {
                        Button {
                            openExam(.mockExam(examSetId: examResult.examSetId))
                        } label: {
                            AppButton(icon: "arrow.counterclockwise", label: "Thi lại", style: .secondary, height: 48)
                        }

                        Button { popToRoot() } label: {
                            AppButton(icon: "checkmark", label: "Hoàn thành", height: 48)
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 4)
            }
        }
        .navigationBarBackButtonHidden(!isFromHistory)
        .screenHeader(isFromHistory ? "Chi tiết bài thi" : "Kết quả thi")
        .onAppear {
            if !isFromHistory {
                ReviewHelper.requestIfFirstPass(passed: examResult.passed)
            }
        }
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

