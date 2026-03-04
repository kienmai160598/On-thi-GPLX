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
    @State private var scenarioSecondsRemaining = 60
    @State private var showExitDialog = false
    @State private var navigateToResult = false
    @State private var simulationResult: SimulationResult?
    @State private var scenarioTimer: Timer?
    @State private var isAutoAdvancing = false
    @State private var selectedAnswerId: Int?
    @State private var isRevealed = false

    private let scenarioTimeLimit = 60

    // MARK: - Computed

    private var isUrgent: Bool { scenarioSecondsRemaining <= 10 }
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
            startSimulation()
        }
        .onDisappear {
            scenarioTimer?.invalidate()
        }
        .alert("Thoát bài thi?", isPresented: $showExitDialog) {
            Button("Tiếp tục", role: .cancel) {}
            Button("Thoát", role: .destructive) { dismiss() }
        } message: {
            Text("Bài thi sẽ không được lưu.")
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

    // MARK: - Timer View (liquid glass)

    @ViewBuilder
    private var timerView: some View {
        let content = HStack(spacing: 6) {
            Image(systemName: "timer")
                .font(.system(size: 14))
                .foregroundStyle(isUrgent ? Color.appError : Color.appTextMedium)
            Text("\(scenarioSecondsRemaining)s")
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

        ZStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    // MARK: - Question card
                    VStack(alignment: .leading, spacing: 12) {
                        HStack(spacing: 8) {
                            Text("Câu \(currentIndex + 1)")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundStyle(Color.appPrimary)

                            if question.isDiemLiet {
                                StatusBadge(text: "Điểm liệt", color: .appError, fontSize: 10)
                            }
                        }

                        Text(question.text)
                            .font(.system(size: 17, weight: .bold))
                            .foregroundStyle(Color.appTextDark)
                            .lineSpacing(4)

                        if question.hasImage {
                            AsyncImage(url: URL(string: question.imageUrl)) { phase in
                                switch phase {
                                case .success(let image):
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .clipShape(RoundedRectangle(cornerRadius: 10))
                                case .failure:
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(Color.appDivider)
                                        .frame(height: 180)
                                        .overlay {
                                            Image(systemName: "photo")
                                                .foregroundStyle(Color.appTextLight)
                                        }
                                default:
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(Color.appDivider.opacity(0.5))
                                        .frame(height: 180)
                                        .overlay { ProgressView().tint(Color.appPrimary) }
                                }
                            }
                        }
                    }
                    .padding(16)
                    .glassCard()
                    .padding(.bottom, 20)

                    // MARK: - Answer tiles
                    ForEach(Array(shuffledAnswers.enumerated()), id: \.element.id) { index, answer in
                        let letter = ["A", "B", "C", "D"][min(index, 3)]
                        let isSelected = selectedAnswerId == answer.id

                        Button {
                            handleAnswerSelection(answer: answer, question: question)
                        } label: {
                            AnswerOptionCard(
                                letter: letter,
                                text: answer.text,
                                isSelected: isSelected,
                                isConfirmed: isRevealed,
                                isCorrect: answer.correct
                            )
                        }
                        .disabled(isRevealed)
                        .padding(.bottom, 8)
                    }

                    // MARK: - Tip after reveal
                    if isRevealed && !question.tip.isEmpty {
                        ExplanationBox(content: question.tip)
                            .padding(.top, 4)
                    }

                    Spacer().frame(height: 100)
                }
                .padding(.horizontal, 20)
            }
            .id(currentIndex)

            // MARK: - Bottom bar
            VStack {
                Spacer()
                HStack(spacing: 10) {
                    Button {
                        Haptics.selection()
                        if currentIndex > 0 {
                            withAnimation(.easeOut(duration: 0.25)) {
                                currentIndex -= 1
                                selectedAnswerId = nil
                                isRevealed = false
                                isAutoAdvancing = false
                            }
                            startScenarioTimer()
                        }
                    } label: {
                        AppButton(label: "Trước", style: .secondary, height: 48, cornerRadius: 24)
                    }
                    .disabled(currentIndex == 0)

                    Button {
                        Haptics.selection()
                        if isRevealed {
                            advanceOrFinish()
                        } else if selectedAnswerId != nil {
                            confirmAnswer(answer: selectedAnswerId!, question: question)
                        }
                    } label: {
                        AppButton(
                            label: isRevealed ? (isLast ? "Xem kết quả" : "Câu tiếp") : "Xác nhận",
                            height: 48,
                            cornerRadius: 24
                        )
                    }
                    .disabled(selectedAnswerId == nil && !isRevealed)

                    QuestionGridButton(
                        current: currentIndex + 1,
                        total: questions.count,
                        answeredIndices: Set(answers.keys)
                    ) { index in
                        withAnimation(.easeOut(duration: 0.25)) {
                            currentIndex = index
                            selectedAnswerId = nil
                            isRevealed = false
                            isAutoAdvancing = false
                        }
                        startScenarioTimer()
                    }
                }
                .padding(.horizontal, 16)
            }
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

        let topicKey = TopicInfo.keyForTopicId(question.topic)
        progressStore.recordQuestionAnswer(topicKey: topicKey, questionNo: question.no, correct: isCorrect)
    }

    private func handleTimeout() {
        scenarioTimer?.invalidate()
        timePerScenario[currentIndex] = scenarioTimeLimit
        Haptics.notification(.warning)

        isRevealed = true

        let question = questions[currentIndex]
        let topicKey = TopicInfo.keyForTopicId(question.topic)
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
                isAutoAdvancing = false
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
