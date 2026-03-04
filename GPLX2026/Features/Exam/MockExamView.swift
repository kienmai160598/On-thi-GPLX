import SwiftUI

struct MockExamView: View {
    @Environment(QuestionStore.self) private var questionStore
    @Environment(ProgressStore.self) private var progressStore
    @Environment(\.dismiss) private var dismiss
    let examSetId: Int?

    @State private var questions: [Question] = []
    @State private var currentIndex = 0
    @State private var answers: [Int: Int] = [:]  // questionIndex -> answerId
    @State private var remainingSeconds = 25 * 60
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

    private var isUrgent: Bool { remainingSeconds <= 300 }
    private var isLast: Bool { currentIndex + 1 >= questions.count }
    private var answeredCount: Int { answers.count }

    var body: some View {
        Group {
            if questions.isEmpty {
                VStack {
                    ProgressView()
                        .tint(Color.appPrimary)
                    Text("Đang tạo đề thi...")
                        .font(.subheadline)
                        .foregroundStyle(Color.appTextMedium)
                        .padding(.top, 8)
                }
            } else {
                examContent
            }
        }
        .background(Color.scaffoldBg.ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
        .navigationBarTitleDisplayMode(.inline)
        .hidesTabBar()
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    showExitDialog = true
                } label: {
                    Image(systemName: "xmark")
                }
            }

            ToolbarItem(placement: .principal) {
                timerView
            }

            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    Haptics.impact(.light)
                    progressStore.toggleBookmark(questionNo: questions[currentIndex].no)
                } label: {
                    let isBookmarked = !questions.isEmpty && progressStore.isBookmarked(questionNo: questions[currentIndex].no)
                    Image(systemName: isBookmarked ? "bookmark.fill" : "bookmark")
                }
            }
        }
        .task {
            startExam()
        }
        .onDisappear {
            timer?.invalidate()
        }
        .alert("Thoát bài thi?", isPresented: $showExitDialog) {
            Button("Tiếp tục", role: .cancel) {}
            Button("Thoát", role: .destructive) { dismiss() }
        } message: {
            Text("Bài thi sẽ không được lưu.")
        }
        .alert("Nộp bài?", isPresented: $showSubmitDialog) {
            Button("Quay lại", role: .cancel) {}
            Button("Nộp bài") { submitExam() }
        } message: {
            let unanswered = questions.count - answeredCount
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

    // MARK: - Timer View (liquid glass)

    @ViewBuilder
    private var timerView: some View {
        let content = HStack(spacing: 6) {
            Image(systemName: "timer")
                .font(.system(size: 14))
                .foregroundStyle(isUrgent ? Color.appError : Color.appTextMedium)
            Text(timerText)
                .font(.system(size: 16, weight: .bold).monospacedDigit())
                .foregroundStyle(isUrgent ? Color.appError : Color.appTextDark)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 6)

        if #available(iOS 26.0, *) {
            content
                .glassEffect(.regular.interactive(), in: .capsule)
        } else {
            content
                .background(isUrgent ? Color.appError.opacity(0.1) : Color.appDivider.opacity(0.3))
                .clipShape(Capsule())
        }
    }

    // MARK: - Exam Content

    @ViewBuilder
    private var examContent: some View {
        let question = questions[currentIndex]
        let shuffledAnswers = question.shuffledAnswers

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
        .safeAreaInset(edge: .bottom) {
            HStack(spacing: 10) {
                Button {
                    Haptics.selection()
                    if currentIndex > 0 {
                        withAnimation(.easeOut(duration: 0.25)) {
                            currentIndex -= 1
                        }
                    }
                } label: {
                    AppButton(label: "Trước", style: .secondary, height: 48, cornerRadius: 24)
                }
                .disabled(currentIndex == 0)

                Button {
                    Haptics.selection()
                    if isLast {
                        showSubmitDialog = true
                    } else {
                        withAnimation(.easeOut(duration: 0.25)) {
                            currentIndex += 1
                        }
                    }
                } label: {
                    AppButton(label: isLast ? "Nộp bài" : "Câu tiếp", height: 48, cornerRadius: 24)
                }

                QuestionGridButton(
                    current: currentIndex + 1,
                    total: questions.count,
                    answeredIndices: Set(answers.keys)
                ) { index in
                    withAnimation(.easeOut(duration: 0.25)) {
                        currentIndex = index
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(.ultraThinMaterial)
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

        // Calculate results and save
        let result = ExamResult.calculate(
            questions: questions,
            answers: answers,
            timeUsedSeconds: (25 * 60) - remainingSeconds
        )
        examResult = result
        progressStore.recordExamResult(result)

        if let setId = examSetId {
            progressStore.addCompletedExamSet(setId)
        }

        // Record each answer for topic progress using the same correctness logic
        for (i, q) in questions.enumerated() {
            let selectedId = answers[i]
            let correct = selectedId != nil && q.answers.contains(where: { $0.id == selectedId && $0.correct })
            let topicKey = TopicInfo.keyForTopicId(q.topic)
            progressStore.recordQuestionAnswer(topicKey: topicKey, questionNo: q.no, correct: correct)
        }

        navigateToResult = true
    }
}

