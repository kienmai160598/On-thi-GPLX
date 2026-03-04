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
                        let isSelected = answers[currentIndex] == answer.id

                        Button {
                            Haptics.selection()
                            answers[currentIndex] = answer.id
                        } label: {
                            AnswerOptionCard(
                                letter: letter,
                                text: answer.text,
                                isSelected: isSelected
                            )
                        }
                        .padding(.bottom, 8)
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
            }
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

// MARK: - Question Grid Sheet

struct ExamQuestionGridSheet: View {
    @Environment(\.dismiss) private var dismiss

    let totalQuestions: Int
    let answeredIndices: Set<Int>
    let currentIndex: Int
    let onSelect: (Int) -> Void

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 8), count: 7)

    private var answeredCount: Int { answeredIndices.count }

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Câu \(currentIndex + 1)/\(totalQuestions)")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(Color.appTextDark)
                Spacer()
                Button("Xong") { dismiss() }
                    .font(.system(size: 16, weight: .medium))
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 10)

            // Progress summary
            HStack(spacing: 16) {
                legendItem(color: .appPrimary, label: "Đang làm")
                legendItem(color: .appSuccess, label: "Đã trả lời (\(answeredCount))")
                legendItem(color: Color.appDivider.opacity(0.3), textColor: .appTextMedium, label: "Chưa")
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 10)

            Divider().padding(.horizontal, 20)

            // Grid
            ScrollView {
                LazyVGrid(columns: columns, spacing: 8) {
                    ForEach(0..<totalQuestions, id: \.self) { index in
                        Button {
                            Haptics.selection()
                            onSelect(index)
                        } label: {
                            Text("\(index + 1)")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(foregroundColor(for: index))
                                .frame(width: 40, height: 40)
                                .background(backgroundColor(for: index))
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                    }
                }
                .padding(20)
            }
        }
    }

    private func foregroundColor(for index: Int) -> Color {
        if index == currentIndex { return Color.appOnPrimary }
        if answeredIndices.contains(index) { return Color.appSuccess }
        return Color.appTextMedium
    }

    private func backgroundColor(for index: Int) -> Color {
        if index == currentIndex { return Color.appPrimary }
        if answeredIndices.contains(index) { return Color.appSuccess.opacity(0.12) }
        return Color.appDivider.opacity(0.3)
    }

    private func legendItem(color: Color, textColor: Color? = nil, label: String) -> some View {
        HStack(spacing: 6) {
            RoundedRectangle(cornerRadius: 4)
                .fill(color)
                .frame(width: 14, height: 14)
            Text(label)
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(textColor ?? color)
        }
    }
}
