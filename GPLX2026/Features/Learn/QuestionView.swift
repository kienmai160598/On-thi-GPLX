import SwiftUI

struct QuestionView: View {
    @Environment(QuestionStore.self) private var questionStore
    @Environment(ProgressStore.self) private var progressStore
    @Environment(ThemeStore.self) private var themeStore
    @Environment(\.dismiss) private var dismiss
    @Environment(\.openExam) private var openExam
    @Environment(LayoutMetrics.self) private var metrics

    let topicKey: String
    let startIndex: Int

    @State private var currentIndex: Int
    @State private var selectedAnswerId: Int?
    @State private var isConfirmed = false
    @State private var correctCount = 0
    @State private var answeredInSession: Set<Int> = []
    @State private var showResultSheet = false
    @State private var showExitConfirmation = false
    @State private var canAdvance = true
    @State private var sessionQuestions: [Question] = []

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

    private var liveQuestions: [Question] {
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
        let allQuestions = sessionQuestions
        Group {
            if allQuestions.isEmpty || currentIndex >= allQuestions.count {
                emptyState
            } else {
                questionContent(allQuestions: allQuestions)
            }
        }
        .task { loadQuestions() }
    }

    private func loadQuestions() {
        if sessionQuestions.isEmpty {
            sessionQuestions = liveQuestions
        }
    }

    // MARK: - Empty State

    @ViewBuilder
    private var emptyState: some View {
        EmptyState(icon: "text.page.slash", message: "Không có câu hỏi")
            .screenHeader(topicName, titleDisplayMode: .inline, hideBackButton: true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button { dismiss() } label: {
                        Image(systemName: "chevron.left")
                            .font(.appSans(size: 16, weight: .semibold))
                            .foregroundStyle(Color.appTextDark)
                    }
                }
            }
    }

    // MARK: - Question Content

    @ViewBuilder
    private func questionContent(allQuestions: [Question]) -> some View {
        let question = allQuestions[currentIndex]
        let shuffledAnswers = question.shuffledAnswers
        let isBookmarked = progressStore.isBookmarked(questionNo: question.no)
        let isLast = currentIndex + 1 >= allQuestions.count
        let isSpecial = topicKey == AppConstants.TopicKey.diemLiet || topicKey == AppConstants.TopicKey.bookmarks || topicKey == AppConstants.TopicKey.wrongAnswers || topicKey.hasPrefix(AppConstants.TopicKey.wrongAnswers + ":")

        Group {
            if metrics.isWide {
                // iPad landscape: 3-panel (question / answers / topic progress sidebar)
                GeometryReader { geo in
                    let pad = metrics.contentPadding
                    let gap = metrics.gridSpacing
                    let available = geo.size.width - pad * 2 - gap * 2
                    let leftWidth = available * 0.40
                    let centerWidth = available * 0.35
                    let rightWidth = available * 0.25

                    HStack(alignment: .top, spacing: gap) {
                        // Left: question + explanation
                        ScrollView {
                            VStack(alignment: .leading, spacing: 0) {
                                QuestionCard(label: "Câu \(question.no):", question: question)

                                if isConfirmed && !question.tip.isEmpty {
                                    ExplanationBox(content: question.tip)
                                        .padding(.top, 12)
                                        .transition(.opacity.combined(with: .move(edge: .top)))
                                }
                            }
                            .padding(.vertical, pad)
                        }
                        .frame(width: leftWidth)

                        // Center: answers
                        ScrollView {
                            AnswerTileList(
                                answers: shuffledAnswers,
                                selectedAnswerId: selectedAnswerId,
                                isConfirmed: isConfirmed,
                                showCorrectness: true,
                                onSelect: { selectAnswer($0) }
                            )
                            .padding(.vertical, pad)
                        }
                        .frame(width: centerWidth)

                        // Right: topic progress sidebar
                        topicProgressSidebar(allQuestions: allQuestions)
                            .frame(width: rightWidth)
                    }
                    .padding(.horizontal, pad)
                }
                .id(currentIndex)
            } else if metrics.isMedium {
                // iPad portrait: 2-panel (55/45 question/answers)
                GeometryReader { geo in
                    let pad = metrics.contentPadding
                    let gap = metrics.gridSpacing
                    let available = geo.size.width - pad * 2 - gap
                    let leftWidth = available * 0.55
                    let rightWidth = available * 0.45

                    HStack(alignment: .top, spacing: gap) {
                        // Left: question + explanation
                        ScrollView {
                            VStack(alignment: .leading, spacing: 0) {
                                QuestionCard(label: "Câu \(question.no):", question: question)

                                if isConfirmed && !question.tip.isEmpty {
                                    ExplanationBox(content: question.tip)
                                        .padding(.top, 12)
                                        .transition(.opacity.combined(with: .move(edge: .top)))
                                }
                            }
                            .padding(.vertical, pad)
                        }
                        .frame(width: leftWidth)

                        // Right: answers
                        ScrollView {
                            AnswerTileList(
                                answers: shuffledAnswers,
                                selectedAnswerId: selectedAnswerId,
                                isConfirmed: isConfirmed,
                                showCorrectness: true,
                                onSelect: { selectAnswer($0) }
                            )
                            .padding(.vertical, pad)
                        }
                        .frame(width: rightWidth)
                    }
                    .padding(.horizontal, pad)
                }
                .id(currentIndex)
            } else {
                // iPhone: existing vertical layout
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
                .transition(.opacity)
                .animation(.easeInOut(duration: 0.3), value: currentIndex)
            }
        }
        .safeAreaInset(edge: .bottom) {
            let tipsTopicKey = Topic.keyForTopicId(question.topic)
            let hasTips = !questionStore.memoryTips(forTopicKey: tipsTopicKey).isEmpty

            ExamBottomBar(
                currentIndex: currentIndex,
                totalCount: allQuestions.count,
                answeredIndices: answeredIndices(for: allQuestions),
                nextLabel: isConfirmed ? (isLast ? "Xem kết quả" : "Câu tiếp") : "Xác nhận",
                isNextDisabled: isConfirmed ? !canAdvance : !hasSelected,
                showPrev: currentIndex > 0,
                onPrev: { prevQuestion() },
                onNext: {
                    if isConfirmed {
                        if isLast {
                            showResultSheet = true
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
                        canAdvance = true
                    }
                },
                leadingWidget: !isSpecial && hasTips ? AnyView(
                    NavigationLink(destination: MemoryTipsView(topicKey: tipsTopicKey)) {
                        AppIconButton(icon: "lightbulb", size: metrics.buttonHeight)
                    }
                ) : nil
            )
        }
        .screenHeaderStyle(titleDisplayMode: .inline, hideBackButton: true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    if answeredInSession.isEmpty {
                        dismiss()
                    } else {
                        showExitConfirmation = true
                    }
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.appSans(size: 16, weight: .semibold))
                        .foregroundStyle(Color.appTextDark)
                }
            }

            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    Haptics.impact(.light)
                    progressStore.toggleBookmark(questionNo: question.no)
                } label: {
                    Image(systemName: isBookmarked ? "bookmark.fill" : "bookmark")
                        .font(.appSans(size: 16))
                        .foregroundStyle(isBookmarked ? themeStore.primaryColor : Color.appTextDark)
                }
            }
        }
        .alert("Thoát ôn tập?", isPresented: $showExitConfirmation) {
            Button("Tiếp tục", role: .cancel) {}
            Button("Thoát", role: .destructive) { dismiss() }
        } message: {
            Text("Tiến trình đã được lưu tự động.")
        }
        .fullScreenCover(isPresented: $showResultSheet) {
            studyResultSheet(totalCount: allQuestions.count)
        }
        .onDisappear {
            progressStore.saveLastPosition(topicKey: topicKey, index: currentIndex)
        }
    }

    // MARK: - Study Result Sheet

    @ViewBuilder
    private func studyResultSheet(totalCount: Int) -> some View {
        let wrongCount = totalCount - correctCount
        let pct = totalCount > 0 ? correctCount * 100 / totalCount : 0

        NavigationStack {
            ScrollView {
                VStack(spacing: metrics.isIPadLayout ? 16 : 24) {
                    Spacer().frame(height: metrics.isIPadLayout ? 4 : 8)

                    if metrics.isIPadLayout {
                        HStack(alignment: .top, spacing: metrics.gridSpacing) {
                            ResultHero(
                                isPassed: pct >= 70,
                                score: correctCount,
                                total: totalCount,
                                subtitle: pct >= 70
                                    ? "Chúc mừng! Bạn đã hoàn thành \(pct)% câu hỏi"
                                    : "Bạn đã hoàn thành \(pct)% — hãy ôn thêm nhé"
                            )

                            VStack(spacing: 0) {
                                ScoreRow(label: "Câu đúng", value: "\(correctCount)/\(totalCount)", color: Color.appSuccess)
                                Divider().padding(.horizontal, 16)
                                ScoreRow(label: "Câu sai", value: "\(wrongCount)/\(totalCount)", color: Color.appError)
                            }
                            .padding(.vertical, 4)
                            .glassCard()
                        }
                    } else {
                        ResultHero(
                            isPassed: pct >= 70,
                            score: correctCount,
                            total: totalCount,
                            subtitle: pct >= 70
                                ? "Chúc mừng! Bạn đã hoàn thành \(pct)% câu hỏi"
                                : "Bạn đã hoàn thành \(pct)% — hãy ôn thêm nhé"
                        )

                        VStack(spacing: 0) {
                            ScoreRow(label: "Câu đúng", value: "\(correctCount)/\(totalCount)", color: Color.appSuccess)
                            Divider().padding(.horizontal, 16)
                            ScoreRow(label: "Câu sai", value: "\(wrongCount)/\(totalCount)", color: Color.appError)
                        }
                        .padding(.vertical, 4)
                        .glassCard()
                    }

                    VStack(spacing: 12) {
                        if wrongCount > 0 {
                            Button {
                                showResultSheet = false
                                let scopedKey = topicKey.hasPrefix(AppConstants.TopicKey.wrongAnswers) ? topicKey : AppConstants.TopicKey.wrongAnswers + ":" + topicKey
                                openExam(.questionView(topicKey: scopedKey, startIndex: 0))
                            } label: {
                                Text("Luyện \(wrongCount) câu sai")
                                    .font(.appSans(size: 16, weight: .semibold))
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 14)
                                    .background(Color.appWarning.opacity(0.15))
                                    .foregroundStyle(Color.appWarning)
                                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                            }
                        }

                        Button {
                            showResultSheet = false
                            resetQuiz()
                        } label: {
                            AppButton(label: "Làm lại", height: metrics.buttonHeight)
                        }

                        Button {
                            showResultSheet = false
                            dismiss()
                        } label: {
                            AppButton(label: "Hoàn thành", style: .secondary, height: metrics.buttonHeight)
                        }
                    }
                    .padding(.top, 8)
                }
                .padding(.horizontal, metrics.contentPadding)
                .padding(.bottom, 32)
            }
            .screenHeader("Kết quả ôn tập")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showResultSheet = false
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.appSans(size: 20))
                            .symbolRenderingMode(.hierarchical)
                            .foregroundStyle(Color.appTextMedium)
                    }
                }
            }
        }
    }

    // MARK: - Topic Progress Sidebar (isWide only)

    @ViewBuilder
    private func topicProgressSidebar(allQuestions: [Question]) -> some View {
        let answered = answeredIndices(for: allQuestions)

        VStack(spacing: 12) {
            // Topic name + progress
            VStack(spacing: 4) {
                Text(topicName)
                    .font(.appSans(size: 14, weight: .semibold))
                    .foregroundStyle(Color.appTextDark)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)

                Text("Câu \(currentIndex + 1)/\(allQuestions.count)")
                    .font(.appSans(size: 12, weight: .medium))
                    .foregroundStyle(Color.appTextMedium)
            }
            .padding(.top, 12)

            // Legend
            HStack(spacing: 12) {
                sidebarLegendDot(color: themeStore.primaryColor, label: "Đang làm")
                sidebarLegendDot(color: .appSuccess, label: "Đã xong")
                sidebarLegendDot(color: Color.appDisabled, label: "Chưa làm")
            }

            // Grid
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 6), count: 5), spacing: 6) {
                ForEach(0..<allQuestions.count, id: \.self) { index in
                    Button {
                        Haptics.selection()
                        withAnimation(.easeOut(duration: 0.25)) {
                            currentIndex = index
                            selectedAnswerId = nil
                            isConfirmed = false
                            canAdvance = true
                        }
                    } label: {
                        let isCurrent = index == currentIndex
                        let isAnswered = answered.contains(index)
                        Text("\(index + 1)")
                            .font(.appSans(size: 13, weight: .semibold))
                            .foregroundStyle(
                                isCurrent ? themeStore.onPrimaryColor :
                                isAnswered ? Color.appSuccess :
                                Color.appTextMedium
                            )
                            .frame(maxWidth: .infinity, minHeight: 36)
                            .background(
                                isCurrent ? themeStore.primaryColor :
                                isAnswered ? Color.appSuccess.opacity(0.12) :
                                Color.appDisabled
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 6))
                    }
                }
            }

            Spacer()
        }
        .padding(.horizontal, 8)
        .padding(.bottom, 12)
    }

    private func sidebarLegendDot(color: Color, label: String) -> some View {
        HStack(spacing: 4) {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
            Text(label)
                .font(.appSans(size: 12))
                .foregroundStyle(Color.appTextMedium)
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
            canAdvance = false
        }
        // Only count toward session score if not already answered in this session
        if !answeredInSession.contains(question.no) {
            answeredInSession.insert(question.no)
            if isCorrect { correctCount += 1 }
        }
        Haptics.notification(isCorrect ? .success : .error)

        let tKey = Topic.keyForTopicId(question.topic)
        progressStore.recordQuestionAnswer(topicKey: tKey, questionNo: question.no, correct: isCorrect)

        Task { @MainActor in
            try? await Task.sleep(for: .seconds(0.3))
            withAnimation(.easeOut(duration: 0.25)) {
                canAdvance = true
            }
        }
    }

    private func prevQuestion() {
        guard currentIndex > 0 else { return }
        withAnimation(.easeOut(duration: 0.25)) {
            currentIndex -= 1
            selectedAnswerId = nil
            isConfirmed = false
            canAdvance = true
        }
    }

    private func nextQuestion() {
        withAnimation(.easeOut(duration: 0.25)) {
            currentIndex += 1
            selectedAnswerId = nil
            isConfirmed = false
            canAdvance = true
        }
        progressStore.saveLastPosition(topicKey: topicKey, index: currentIndex)
    }

    private func resetQuiz() {
        sessionQuestions = liveQuestions
        currentIndex = 0
        selectedAnswerId = nil
        isConfirmed = false
        correctCount = 0
        canAdvance = true
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
