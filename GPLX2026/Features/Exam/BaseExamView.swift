import SwiftUI

struct BaseExamView: View {
    @Environment(QuestionStore.self) private var questionStore
    @Environment(ProgressStore.self) private var progressStore
    @Environment(\.dismiss) private var dismiss

    enum Mode {
        case mockExam(examSetId: Int?)
        case simulation(SimulationExamView.Mode)
    }

    let mode: Mode

    // MARK: - State

    @State private var questions: [Question] = []
    @State private var currentIndex = 0
    @State private var answers: [Int: Int] = [:]
    @State private var timePerScenario: [Int: Int] = [:]
    @State private var remainingSeconds = 0
    @State private var deadline: Date?
    @State private var showSubmitDialog = false
    @State private var showExitDialog = false
    @State private var navigateToResult = false
    @State private var timer: Timer?
    @State private var selectedAnswerId: Int?
    @State private var isRevealed = false
    @State private var examResult: ExamResult?
    @State private var simulationResult: SimulationResult?

    // MARK: - Computed

    private var isMockExam: Bool {
        if case .mockExam = mode { return true }
        return false
    }

    private var timerText: String {
        if isMockExam {
            let m = remainingSeconds / 60
            let s = remainingSeconds % 60
            return String(format: "%02d:%02d", m, s)
        }
        return "\(remainingSeconds)s"
    }

    private var isUrgent: Bool {
        isMockExam
            ? remainingSeconds <= AppConstants.Exam.urgencyThresholdSeconds
            : remainingSeconds <= AppConstants.Simulation.urgencyThresholdSeconds
    }

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
        .task { startExam() }
        .onDisappear { timer?.invalidate(); deadline = nil }
        .alert("Nộp bài?", isPresented: $showSubmitDialog) {
            Button("Quay lại", role: .cancel) {}
            Button("Nộp bài") { submitMockExam() }
        } message: {
            let unanswered = questions.count - answers.count
            if unanswered > 0 {
                Text("Bạn còn \(unanswered) câu chưa trả lời.\nBạn có chắc muốn nộp bài?")
            } else {
                Text("Bạn đã trả lời hết.\nNộp bài ngay?")
            }
        }
        .navigationDestination(isPresented: $navigateToResult) {
            resultDestination
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

                    if isMockExam {
                        AnswerTileList(
                            answers: shuffledAnswers,
                            selectedAnswerId: answers[currentIndex],
                            onSelect: { answer in
                                Haptics.selection()
                                answers[currentIndex] = answer.id
                            }
                        )
                    } else {
                        AnswerTileList(
                            answers: shuffledAnswers,
                            selectedAnswerId: selectedAnswerId,
                            isConfirmed: isRevealed,
                            showCorrectness: true,
                            onSelect: { handleSimulationAnswerSelection(answer: $0) }
                        )

                        if isRevealed && !question.tip.isEmpty {
                            ExplanationBox(content: question.tip)
                                .padding(.top, 4)
                                .transition(.opacity.combined(with: .move(edge: .top)))
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
            }
            .id(currentIndex)

            ExamBottomBar(
                currentIndex: currentIndex,
                totalCount: questions.count,
                answeredIndices: Set(answers.keys),
                nextLabel: nextLabel,
                isNextDisabled: !isMockExam && selectedAnswerId == nil && !isRevealed,
                onPrev: handlePrev,
                onNext: handleNext,
                onSelectIndex: { index in
                    withAnimation(.easeOut(duration: 0.25)) {
                        currentIndex = index
                        if !isMockExam { restoreStateForCurrentIndex() }
                    }
                }
            )
        }
    }

    private var nextLabel: String {
        if isMockExam {
            return isLast ? "Nộp bài" : "Câu tiếp"
        }
        return isRevealed ? (isLast ? "Xem kết quả" : "Câu tiếp") : "Xác nhận"
    }

    @ViewBuilder
    private var resultDestination: some View {
        if let result = examResult {
            ExamResultView(
                questions: questions,
                answers: answers,
                timeUsedSeconds: result.timeUsedSeconds,
                examResult: result
            )
        } else if let result = simulationResult {
            SimulationResultView(
                questions: questions,
                answers: answers,
                timePerScenario: timePerScenario,
                simulationResult: result
            )
        }
    }

    // MARK: - Navigation

    private func handlePrev() {
        if isMockExam {
            withAnimation(.easeOut(duration: 0.25)) { currentIndex -= 1 }
        } else if currentIndex > 0 {
            withAnimation(.easeOut(duration: 0.25)) {
                currentIndex -= 1
                restoreStateForCurrentIndex()
            }
        }
    }

    private func handleNext() {
        if isMockExam {
            if isLast {
                showSubmitDialog = true
            } else {
                withAnimation(.easeOut(duration: 0.25)) { currentIndex += 1 }
            }
        } else {
            if isRevealed {
                advanceOrFinishSimulation()
            } else if let answerId = selectedAnswerId {
                confirmSimulationAnswer(answerId: answerId, question: questions[currentIndex])
            }
        }
    }

    // MARK: - Start

    private func startExam() {
        switch mode {
        case .mockExam(let setId):
            if let setId {
                questions = questionStore.examSetQuestions(setId: setId)
            } else {
                questions = questionStore.randomExamQuestions()
            }
            remainingSeconds = AppConstants.Exam.totalTimeSeconds
            startGlobalTimer()

        case .simulation(let simMode):
            switch simMode {
            case .random:
                questions = questionStore.randomSimulationQuestions(count: 20)
            case .fullPractice:
                questions = questionStore.allSimulationQuestions()
            }
            remainingSeconds = AppConstants.Simulation.scenarioTimeSeconds
            startScenarioTimer()
        }
    }

    // MARK: - Mock Exam Timer

    private func startGlobalTimer() {
        timer?.invalidate()
        deadline = Date().addingTimeInterval(TimeInterval(remainingSeconds))
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            Task { @MainActor in
                guard let deadline else { return }
                let remaining = max(0, Int(deadline.timeIntervalSinceNow))
                remainingSeconds = remaining
                if remaining <= 0 {
                    timer?.invalidate()
                    submitMockExam()
                }
            }
        }
    }

    private func submitMockExam() {
        timer?.invalidate()
        Haptics.notification(.success)

        guard case .mockExam(let examSetId) = mode else { return }

        let result = ExamResult.calculate(
            questions: questions,
            answers: answers,
            timeUsedSeconds: AppConstants.Exam.totalTimeSeconds - remainingSeconds,
            examSetId: examSetId
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

    // MARK: - Simulation Timer

    private func startScenarioTimer() {
        remainingSeconds = AppConstants.Simulation.scenarioTimeSeconds
        deadline = Date().addingTimeInterval(TimeInterval(remainingSeconds))
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            Task { @MainActor in
                guard let deadline else { return }
                let remaining = max(0, Int(deadline.timeIntervalSinceNow))
                remainingSeconds = remaining
                if remaining <= 0 {
                    handleSimulationTimeout()
                }
            }
        }
    }

    private func handleSimulationAnswerSelection(answer: Answer) {
        guard !isRevealed else { return }
        Haptics.selection()
        selectedAnswerId = answer.id
    }

    private func confirmSimulationAnswer(answerId: Int, question: Question) {
        guard !isRevealed else { return }

        answers[currentIndex] = answerId
        timePerScenario[currentIndex] = AppConstants.Simulation.scenarioTimeSeconds - remainingSeconds

        isRevealed = true
        timer?.invalidate()

        let isCorrect = question.answers.contains(where: { $0.id == answerId && $0.correct })
        Haptics.notification(isCorrect ? .success : .error)

        let topicKey = Topic.keyForTopicId(question.topic)
        progressStore.recordQuestionAnswer(topicKey: topicKey, questionNo: question.no, correct: isCorrect)
    }

    private func handleSimulationTimeout() {
        timer?.invalidate()
        timePerScenario[currentIndex] = AppConstants.Simulation.scenarioTimeSeconds
        Haptics.notification(.warning)

        isRevealed = true

        let question = questions[currentIndex]
        let topicKey = Topic.keyForTopicId(question.topic)
        progressStore.recordQuestionAnswer(topicKey: topicKey, questionNo: question.no, correct: false)
    }

    private func restoreStateForCurrentIndex() {
        if let savedAnswer = answers[currentIndex] {
            selectedAnswerId = savedAnswer
            isRevealed = true
            timer?.invalidate()
        } else {
            selectedAnswerId = nil
            isRevealed = false
            startScenarioTimer()
        }
    }

    private func advanceOrFinishSimulation() {
        if isLast {
            finishSimulation()
        } else {
            withAnimation(.easeOut(duration: 0.25)) {
                currentIndex += 1
                selectedAnswerId = nil
                isRevealed = false
            }
            startScenarioTimer()
        }
    }

    private func finishSimulation() {
        timer?.invalidate()
        Haptics.notification(.success)

        let result = SimulationResult.calculate(
            questions: questions,
            answers: answers,
            timePerScenario: timePerScenario
        )
        simulationResult = result
        progressStore.recordSimulationResult(result)

        navigateToResult = true
    }
}
