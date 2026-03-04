import SwiftUI

struct QuestionView: View {
    @Environment(QuestionStore.self) private var questionStore
    @Environment(ProgressStore.self) private var progressStore
    @Environment(\.dismiss) private var dismiss

    let topicKey: String
    let startIndex: Int

    @State private var currentIndex: Int
    @State private var selectedAnswerId: Int?
    @State private var isConfirmed = false
    @State private var correctCount = 0
    @State private var showResultDialog = false

    init(topicKey: String, startIndex: Int) {
        self.topicKey = topicKey
        self.startIndex = startIndex
        _currentIndex = State(initialValue: startIndex)
    }

    private var questions: [Question] {
        questionStore.questions(forTopicKey: topicKey)
    }

    private var topicName: String {
        switch topicKey {
        case "all_questions": return "Tất cả câu hỏi"
        case "diem_liet": return "Câu điểm liệt"
        case "bookmarks": return "Đánh dấu"
        case "wrong_answers": return "Câu sai"
        default: return questionStore.topic(forKey: topicKey)?.name ?? topicKey
        }
    }

    private var hasSelected: Bool { selectedAnswerId != nil }

    var body: some View {
        let allQuestions = questions
        if allQuestions.isEmpty || currentIndex >= allQuestions.count {
            emptyState
        } else {
            questionContent(allQuestions: allQuestions)
        }
    }

    // MARK: - Empty State

    @ViewBuilder
    private var emptyState: some View {
        VStack {
            Text("Không có câu hỏi")
                .foregroundStyle(Color.appTextMedium)
        }
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Question Content

    @ViewBuilder
    private func questionContent(allQuestions: [Question]) -> some View {
        let question = allQuestions[currentIndex]
        let shuffledAnswers = question.shuffledAnswers
        let isBookmarked = progressStore.isBookmarked(questionNo: question.no)
        let isLast = currentIndex + 1 >= allQuestions.count
        let isSpecial = topicKey.contains("diem_liet") || topicKey.contains("bookmarks") || topicKey.contains("wrong_answers")

        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                QuestionCard(label: "Câu \(question.no):", question: question)
                    .padding(.bottom, 20)

                AnswerTileList(
                    answers: shuffledAnswers,
                    selectedAnswerId: selectedAnswerId,
                    isConfirmed: isConfirmed,
                    showCorrectness: true,
                    onSelect: { selectAnswer($0) }
                )

                // MARK: - Tip after confirm
                if isConfirmed && !question.tip.isEmpty {
                    ExplanationBox(content: question.tip)
                        .padding(.top, 4)
                        .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 12)
        }
        .id(currentIndex)
        .safeAreaInset(edge: .bottom) {
            HStack(spacing: 10) {
                if !isSpecial {
                    NavigationLink(destination: MemoryTipsView(topicKey: topicKey)) {
                        AppIconButton(icon: "lightbulb", size: 52)
                    }
                }

                Button {
                    Haptics.selection()
                    if isConfirmed {
                        if isLast {
                            showResultDialog = true
                        } else {
                            nextQuestion()
                        }
                    } else if hasSelected {
                        confirmAnswer(question: question)
                    }
                } label: {
                    AppButton(label: isConfirmed ? (isLast ? "Xem kết quả" : "Câu tiếp theo") : "Xác nhận")
                }
                .disabled(!hasSelected)

                QuestionGridButton(
                    current: currentIndex + 1,
                    total: allQuestions.count,
                    answeredIndices: answeredIndices(for: allQuestions)
                ) { index in
                    withAnimation(.easeOut(duration: 0.25)) {
                        currentIndex = index
                        selectedAnswerId = nil
                        isConfirmed = false
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(.ultraThinMaterial)
        }
        .background(Color.scaffoldBg.ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
        .hidesTabBar()
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button { dismiss() } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(Color.appTextDark)
                }
            }

            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    Haptics.impact(.light)
                    progressStore.toggleBookmark(questionNo: question.no)
                } label: {
                    Image(systemName: isBookmarked ? "bookmark.fill" : "bookmark")
                        .font(.system(size: 16))
                        .foregroundStyle(isBookmarked ? Color.appPrimary : Color.appTextDark)
                }
            }
        }
        .alert("Kết quả", isPresented: $showResultDialog) {
            Button("Quay lại") { dismiss() }
            Button("Làm lại") { resetQuiz() }
        } message: {
            Text("\(correctCount) / \(allQuestions.count) câu đúng")
        }
        .onDisappear {
            progressStore.saveLastPosition(topicKey: topicKey, index: currentIndex)
        }
    }

    // MARK: - Actions

    private func selectAnswer(_ answer: Answer) {
        guard !isConfirmed else { return }
        Haptics.selection()
        withAnimation(.easeOut(duration: 0.25)) {
            if selectedAnswerId == answer.id {
                selectedAnswerId = nil
            } else {
                selectedAnswerId = answer.id
            }
        }
    }

    private func confirmAnswer(question: Question) {
        guard !isConfirmed, let answerId = selectedAnswerId else { return }
        let answer = question.answers.first(where: { $0.id == answerId })
        let isCorrect = answer?.correct ?? false
        withAnimation(.easeOut(duration: 0.25)) {
            isConfirmed = true
        }
        if isCorrect { correctCount += 1 }
        Haptics.notification(isCorrect ? .success : .error)

        let tKey = TopicInfo.keyForTopicId(question.topic)
        progressStore.recordQuestionAnswer(topicKey: tKey, questionNo: question.no, correct: isCorrect)
    }

    private func nextQuestion() {
        withAnimation(.easeOut(duration: 0.25)) {
            currentIndex += 1
            selectedAnswerId = nil
            isConfirmed = false
        }
        progressStore.saveLastPosition(topicKey: topicKey, index: currentIndex)
    }

    private func resetQuiz() {
        currentIndex = 0
        selectedAnswerId = nil
        isConfirmed = false
        correctCount = 0
    }

    private func answeredIndices(for questions: [Question]) -> Set<Int> {
        // Load topic progress once per topic key to avoid N+1 JSON decodes
        var progressCache: [String: [Int: Bool]] = [:]
        var result = Set<Int>()
        for (i, q) in questions.enumerated() {
            let tk = TopicInfo.keyForTopicId(q.topic)
            if progressCache[tk] == nil {
                progressCache[tk] = progressStore.topicProgress(for: tk)
            }
            if progressCache[tk]?[q.no] != nil {
                result.insert(i)
            }
        }
        return result
    }
}
