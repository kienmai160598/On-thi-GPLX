import SwiftUI

struct SimulationExamView: View {
    @Environment(QuestionStore.self) private var questionStore
    @Environment(ProgressStore.self) private var progressStore
    @Environment(\.dismiss) private var dismiss

    let mode: Mode

    enum Mode {
        case random
        case fullPractice
    }

    // MARK: - State

    @State private var questions: [Question] = []
    @State private var currentIndex = 0
    @State private var answers: [Int: Int] = [:]
    @State private var timePerScenario: [Int: Int] = [:]
    @State private var scenarioSecondsRemaining = AppConstants.Simulation.scenarioTimeSeconds
    @State private var showExitDialog = false
    @State private var navigateToResult = false
    @State private var simulationResult: SimulationResult?
    @State private var scenarioTimer: Timer?
    @State private var selectedAnswerId: Int?
    @State private var isRevealed = false

    private let scenarioTimeLimit: Int = AppConstants.Simulation.scenarioTimeSeconds

    // MARK: - Computed

    private var isUrgent: Bool { scenarioSecondsRemaining <= AppConstants.Simulation.urgencyThresholdSeconds }
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
            timerText: "\(scenarioSecondsRemaining)s",
            isUrgent: isUrgent,
            isBookmarked: !questions.isEmpty && progressStore.isBookmarked(questionNo: questions[currentIndex].no),
            showExitDialog: $showExitDialog,
            onToggleBookmark: { progressStore.toggleBookmark(questionNo: questions[currentIndex].no) },
            onDismiss: { dismiss() }
        )
        .task {
            startSimulation()
        }
        .onDisappear {
            scenarioTimer?.invalidate()
        }
        .navigationDestination(isPresented: $navigateToResult) {
            if let result = simulationResult {
                SimulationResultView(
                    questions: questions,
                    answers: answers,
                    timePerScenario: timePerScenario,
                    simulationResult: result
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
                        selectedAnswerId: selectedAnswerId,
                        isConfirmed: isRevealed,
                        showCorrectness: true,
                        onSelect: { handleAnswerSelection(answer: $0, question: question) }
                    )

                    // MARK: - Tip after reveal
                    if isRevealed && !question.tip.isEmpty {
                        ExplanationBox(content: question.tip)
                            .padding(.top, 4)
                            .transition(.opacity.combined(with: .move(edge: .top)))
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)
            }
            .id(currentIndex)

            ExamBottomBar(
                currentIndex: currentIndex,
                totalCount: questions.count,
                answeredIndices: Set(answers.keys),
                nextLabel: isRevealed ? (isLast ? "Xem kết quả" : "Câu tiếp") : "Xác nhận",
                isNextDisabled: selectedAnswerId == nil && !isRevealed,
                onPrev: {
                    if currentIndex > 0 {
                        withAnimation(.easeOut(duration: 0.25)) {
                            currentIndex -= 1
                            selectedAnswerId = nil
                            isRevealed = false
                        }
                        startScenarioTimer()
                    }
                },
                onNext: {
                    if isRevealed {
                        advanceOrFinish()
                    } else if selectedAnswerId != nil {
                        confirmAnswer(answer: selectedAnswerId!, question: question)
                    }
                },
                onSelectIndex: { index in
                    withAnimation(.easeOut(duration: 0.25)) {
                        currentIndex = index
                        selectedAnswerId = nil
                        isRevealed = false
                    }
                    startScenarioTimer()
                }
            )
        }
    }

    // MARK: - Logic

    private func startSimulation() {
        switch mode {
        case .random:
            questions = questionStore.randomSimulationQuestions(count: 20)
        case .fullPractice:
            questions = questionStore.allSimulationQuestions()
        }
        startScenarioTimer()
    }

    private func startScenarioTimer() {
        scenarioSecondsRemaining = scenarioTimeLimit
        scenarioTimer?.invalidate()
        scenarioTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if scenarioSecondsRemaining <= 1 {
                handleTimeout()
            } else {
                scenarioSecondsRemaining -= 1
            }
        }
    }

    private func handleAnswerSelection(answer: Answer, question: Question) {
        guard !isRevealed else { return }
        Haptics.selection()
        selectedAnswerId = answer.id
    }

    private func confirmAnswer(answer answerId: Int, question: Question) {
        guard !isRevealed else { return }

        answers[currentIndex] = answerId
        timePerScenario[currentIndex] = scenarioTimeLimit - scenarioSecondsRemaining

        isRevealed = true
        scenarioTimer?.invalidate()

        let isCorrect = question.answers.contains(where: { $0.id == answerId && $0.correct })
        Haptics.notification(isCorrect ? .success : .error)

        let topicKey = Topic.keyForTopicId(question.topic)
        progressStore.recordQuestionAnswer(topicKey: topicKey, questionNo: question.no, correct: isCorrect)
    }

    private func handleTimeout() {
        scenarioTimer?.invalidate()
        timePerScenario[currentIndex] = scenarioTimeLimit
        Haptics.notification(.warning)

        isRevealed = true

        let question = questions[currentIndex]
        let topicKey = Topic.keyForTopicId(question.topic)
        progressStore.recordQuestionAnswer(topicKey: topicKey, questionNo: question.no, correct: false)
    }

    private func advanceOrFinish() {
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
        scenarioTimer?.invalidate()
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
