import SwiftUI

struct MockExamView: View {
    @Environment(QuestionStore.self) private var questionStore
    @Environment(ProgressStore.self) private var progressStore
    @Environment(\.dismiss) private var dismiss
    let examSetId: Int?

    @State private var questions: [Question] = []
    @State private var currentIndex = 0
    @State private var answers: [Int: Int] = [:]
    @State private var remainingSeconds = AppConstants.Exam.totalTimeSeconds
    @State private var showSubmitDialog = false
    @State private var showExitDialog = false
    @State private var navigateToResult = false
    @State private var examResult: ExamResult?
    @State private var timer: Timer?

    init(examSetId: Int? = nil) {
        self.examSetId = examSetId
    }

    private var timerText: String {
        let m = remainingSeconds / 60
        let s = remainingSeconds % 60
        return String(format: "%02d:%02d", m, s)
    }

    private var isUrgent: Bool { remainingSeconds <= AppConstants.Exam.urgencyThresholdSeconds }
    private var isLast: Bool { currentIndex + 1 >= questions.count }

    var body: some View {
        Group {
            if questions.isEmpty {
                ExamLoadingView()
            } else {
                examContent
            }
        }
        .examToolbar(
            timerText: timerText,
            isUrgent: isUrgent,
            isBookmarked: !questions.isEmpty && progressStore.isBookmarked(questionNo: questions[currentIndex].no),
            showExitDialog: $showExitDialog,
            onToggleBookmark: { progressStore.toggleBookmark(questionNo: questions[currentIndex].no) },
            onDismiss: { dismiss() }
        )
        .task {
            startExam()
        }
        .onDisappear {
            timer?.invalidate()
        }
        .alert("Nộp bài?", isPresented: $showSubmitDialog) {
            Button("Quay lại", role: .cancel) {}
            Button("Nộp bài") { submitExam() }
        } message: {
            let unanswered = questions.count - answers.count
            if unanswered > 0 {
                Text("Bạn còn \(unanswered) câu chưa trả lời.\nBạn có chắc muốn nộp bài?")
            } else {
                Text("Bạn đã trả lời hết.\nNộp bài ngay?")
            }
        }
        .navigationDestination(isPresented: $navigateToResult) {
            if let result = examResult {
                ExamResultView(
                    questions: questions,
                    answers: answers,
                    timeUsedSeconds: result.timeUsedSeconds,
                    examResult: result
                )
            }
        }
    }

    // MARK: - Exam Content

    @ViewBuilder
    private var examContent: some View {
        let question = questions[currentIndex]
        let shuffledAnswers = question.shuffledAnswers

        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    QuestionCard(label: "Câu \(currentIndex + 1)", question: question, showDiemLietBadge: true)
                        .padding(.bottom, 20)

                    AnswerTileList(
                        answers: shuffledAnswers,
                        selectedAnswerId: answers[currentIndex],
                        onSelect: { answer in
                            Haptics.selection()
                            answers[currentIndex] = answer.id
                        }
                    )
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)
            }
            .id(currentIndex)

            ExamBottomBar(
                currentIndex: currentIndex,
                totalCount: questions.count,
                answeredIndices: Set(answers.keys),
                nextLabel: isLast ? "Nộp bài" : "Câu tiếp",
                onPrev: {
                    withAnimation(.easeOut(duration: 0.25)) {
                        currentIndex -= 1
                    }
                },
                onNext: {
                    if isLast {
                        showSubmitDialog = true
                    } else {
                        withAnimation(.easeOut(duration: 0.25)) {
                            currentIndex += 1
                        }
                    }
                },
                onSelectIndex: { index in
                    withAnimation(.easeOut(duration: 0.25)) {
                        currentIndex = index
                    }
                }
            )
        }
    }

    // MARK: - Exam Logic

    private func startExam() {
        if let setId = examSetId {
            questions = questionStore.examSetQuestions(setId: setId)
        } else {
            questions = questionStore.randomExamQuestions()
        }
        startTimer()
    }

    private func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if remainingSeconds <= 1 {
                timer?.invalidate()
                submitExam()
            } else {
                remainingSeconds -= 1
            }
        }
    }

    private func submitExam() {
        timer?.invalidate()
        Haptics.notification(.success)

        let result = ExamResult.calculate(
            questions: questions,
            answers: answers,
            timeUsedSeconds: AppConstants.Exam.totalTimeSeconds - remainingSeconds
        )
        examResult = result
        progressStore.recordExamResult(result)

        if let setId = examSetId {
            progressStore.addCompletedExamSet(setId)
        }

        for (i, q) in questions.enumerated() {
            let selectedId = answers[i]
            let correct = selectedId != nil && q.answers.contains(where: { $0.id == selectedId && $0.correct })
            let topicKey = Topic.keyForTopicId(q.topic)
            progressStore.recordQuestionAnswer(topicKey: topicKey, questionNo: q.no, correct: correct)
        }

        navigateToResult = true
    }
}
