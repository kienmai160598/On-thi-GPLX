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
    @State private var answeredInSession: Set<Int> = []
    @State private var showResultDialog = false

    init(topicKey: String, startIndex: Int) {
        self.topicKey = topicKey
        self.startIndex = startIndex
        _currentIndex = State(initialValue: startIndex)
    }

    private var filterIds: Set<Int>? {
        switch topicKey {
        case AppConstants.TopicKey.bookmarks: return progressStore.bookmarks
        case AppConstants.TopicKey.wrongAnswers: return progressStore.wrongAnswers
        case let key where key.hasPrefix(AppConstants.TopicKey.wrongAnswers + ":"): return progressStore.wrongAnswers
        default: return nil
        }
    }

    private var questions: [Question] {
        questionStore.questions(forTopicKey: topicKey, filterIds: filterIds)
    }

    private var topicName: String {
        switch topicKey {
        case AppConstants.TopicKey.allQuestions: return "Tất cả câu hỏi"
        case AppConstants.TopicKey.diemLiet: return "Câu điểm liệt"
        case AppConstants.TopicKey.bookmarks: return "Đánh dấu"
        case AppConstants.TopicKey.wrongAnswers: return "Câu sai"
        case let key where key.hasPrefix(AppConstants.TopicKey.wrongAnswers + ":"):
            let scopedKey = String(key.dropFirst(AppConstants.TopicKey.wrongAnswers.count + 1))
            return "Câu sai — \(questionStore.topic(forKey: scopedKey)?.name ?? scopedKey)"
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
        EmptyState(icon: "text.page.slash", message: "Không có câu hỏi")
            .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Question Content

    @ViewBuilder
    private func questionContent(allQuestions: [Question]) -> some View {
        let question = allQuestions[currentIndex]
        let shuffledAnswers = question.shuffledAnswers
        let isBookmarked = progressStore.isBookmarked(questionNo: question.no)
        let isLast = currentIndex + 1 >= allQuestions.count
        let isSpecial = topicKey == AppConstants.TopicKey.diemLiet || topicKey == AppConstants.TopicKey.bookmarks || topicKey == AppConstants.TopicKey.wrongAnswers || topicKey.hasPrefix(AppConstants.TopicKey.wrongAnswers + ":")

        VStack(spacing: 0) {
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

                    if isConfirmed && !question.tip.isEmpty {
                        ExplanationBox(content: question.tip)
                            .padding(.top, 4)
                            .transition(.opacity.combined(with: .move(edge: .top)))
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
            }
            .id(currentIndex)

            let tipsTopicKey = Topic.keyForTopicId(question.topic)
            let hasTips = !questionStore.memoryTips(forTopicKey: tipsTopicKey).isEmpty

            ExamBottomBar(
                currentIndex: currentIndex,
                totalCount: allQuestions.count,
                answeredIndices: answeredIndices(for: allQuestions),
                nextLabel: isConfirmed ? (isLast ? "Xem kết quả" : "Câu tiếp") : "Xác nhận",
                isNextDisabled: !hasSelected,
                showPrev: false,
                onPrev: {},
                onNext: {
                    if isConfirmed {
                        if isLast {
                            showResultDialog = true
                        } else {
                            nextQuestion()
                        }
                    } else if hasSelected {
                        confirmAnswer(question: question)
                    }
                },
                onSelectIndex: { index in
                    withAnimation(.easeOut(duration: 0.25)) {
                        currentIndex = index
                        selectedAnswerId = nil
                        isConfirmed = false
                    }
                },
                leadingWidget: !isSpecial && hasTips ? AnyView(
                    NavigationLink(destination: MemoryTipsView(topicKey: tipsTopicKey)) {
                        AppIconButton(icon: "lightbulb", size: 48)
                    }
                ) : nil
            )
        }
        .background(Color.scaffoldBg.ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
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
            Button("Xem lại") {
                currentIndex = 0
                selectedAnswerId = nil
                isConfirmed = false
            }
            Button("Làm lại") { resetQuiz() }
            Button("Hoàn thành") { dismiss() }
        } message: {
            let pct = allQuestions.count > 0 ? correctCount * 100 / allQuestions.count : 0
            Text("\(correctCount)/\(allQuestions.count) câu đúng (\(pct)%)")
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
        // Only count toward session score if not already answered in this session
        if !answeredInSession.contains(question.no) {
            answeredInSession.insert(question.no)
            if isCorrect { correctCount += 1 }
        }
        Haptics.notification(isCorrect ? .success : .error)

        let tKey = Topic.keyForTopicId(question.topic)
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
        answeredInSession.removeAll()
    }

    private func answeredIndices(for questions: [Question]) -> Set<Int> {
        var progressCache: [String: [Int: Bool]] = [:]
        var result = Set<Int>()
        for (i, q) in questions.enumerated() {
            let tk = Topic.keyForTopicId(q.topic)
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
