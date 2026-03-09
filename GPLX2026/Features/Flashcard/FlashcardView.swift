import SwiftUI

struct FlashcardView: View {
    @Environment(QuestionStore.self) private var questionStore
    @Environment(ProgressStore.self) private var progressStore
    @Environment(\.dismiss) private var dismiss

    let topicKey: String

    @State private var currentIndex = 0
    @State private var isFlipped = false
    @State private var knownCount = 0
    @State private var unknownCount = 0
    @State private var isFinished = false
    @State private var unknownQuestionNos: Set<Int> = []
    @State private var activeQuestions: [Question]?
    @State private var dragOffset: CGSize = .zero

    private var questions: [Question] {
        activeQuestions ?? questionStore.questions(forTopicKey: topicKey)
    }

    private var totalQuestions: Int { questions.count }

    private var swipeProgress: Double {
        min(abs(dragOffset.width) / 150.0, 1.0)
    }

    private var isSwipingRight: Bool { dragOffset.width > 0 }

    var body: some View {
        Group {
            if questions.isEmpty {
                EmptyState(icon: "rectangle.on.rectangle.slash", message: "Không có câu hỏi")
            } else if isFinished {
                finishedView
            } else {
                flashcardContent
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarTitleDisplayMode(.inline)
        .background {
            ZStack {
                Color.scaffoldBg.ignoresSafeArea()
                AnimatedBackground()
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button { dismiss() } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 15, weight: .semibold))
                }
            }

            ToolbarItem(placement: .principal) {
                HStack(spacing: 8) {
                    Text("Lật thẻ")
                        .font(.system(size: 17, weight: .semibold))
                }
            }

            ToolbarItem(placement: .navigationBarTrailing) {
                QuestionGridButton(
                    current: currentIndex + 1,
                    total: totalQuestions,
                    answeredIndices: Set(0..<currentIndex)
                ) { index in
                    withAnimation(.easeInOut(duration: 0.25)) {
                        isFlipped = false
                        dragOffset = .zero
                        currentIndex = index
                    }
                }
            }
        }
    }

    // MARK: - Flashcard Content

    @ViewBuilder
    private var flashcardContent: some View {
        let question = questions[currentIndex]
        let correctAnswer = question.answers.first(where: \.correct)

        VStack(spacing: 0) {
            // Score counters
            HStack(spacing: 0) {
                HStack(spacing: 6) {
                    Image(systemName: "xmark")
                        .font(.system(size: 12, weight: .bold))
                    Text("\(unknownCount)")
                        .font(.system(size: 16, weight: .heavy).monospacedDigit())
                        .contentTransition(.numericText())
                }
                .foregroundStyle(Color.appError)
                .frame(maxWidth: .infinity)

                Text("\(currentIndex + 1)/\(totalQuestions)")
                    .font(.system(size: 14, weight: .semibold).monospacedDigit())
                    .foregroundStyle(Color.appTextMedium)
                    .contentTransition(.numericText())

                HStack(spacing: 6) {
                    Text("\(knownCount)")
                        .font(.system(size: 16, weight: .heavy).monospacedDigit())
                        .contentTransition(.numericText())
                    Image(systemName: "checkmark")
                        .font(.system(size: 12, weight: .bold))
                }
                .foregroundStyle(Color.appSuccess)
                .frame(maxWidth: .infinity)
            }
            .padding(.horizontal, 24)
            .padding(.top, 8)
            .animation(.snappy, value: knownCount)
            .animation(.snappy, value: unknownCount)

            Spacer()

            // Swipe card area
            ZStack {
                // Swipe direction indicators (behind card)
                HStack(spacing: 0) {
                    // Left = unknown
                    VStack(spacing: 6) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 36))
                        Text("Chưa biết")
                            .font(.system(size: 14, weight: .bold))
                    }
                    .foregroundStyle(Color.appError)
                    .opacity(!isSwipingRight && isFlipped ? swipeProgress : 0)
                    .frame(maxWidth: .infinity)

                    Spacer().frame(width: 120)

                    // Right = known
                    VStack(spacing: 6) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 36))
                        Text("Đã biết")
                            .font(.system(size: 14, weight: .bold))
                    }
                    .foregroundStyle(Color.appSuccess)
                    .opacity(isSwipingRight && isFlipped ? swipeProgress : 0)
                    .frame(maxWidth: .infinity)
                }

                // The card itself
                ZStack {
                    if !isFlipped {
                        frontCard(question: question)
                    } else {
                        backCard(question: question, correctAnswer: correctAnswer)
                    }
                }
                .onTapGesture { flipCard() }
                .offset(x: dragOffset.width)
                .rotationEffect(.degrees(Double(dragOffset.width) / 25.0))
                .opacity(1.0 - abs(dragOffset.width) / 600.0)
                .gesture(swipeGesture)
            }
            .padding(.horizontal, 20)

            Spacer()

            // Bottom hint
            VStack(spacing: 8) {
                if isFlipped {
                    HStack(spacing: 24) {
                        HStack(spacing: 4) {
                            Image(systemName: "arrow.left")
                                .font(.system(size: 11, weight: .bold))
                            Text("Chưa biết")
                                .font(.system(size: 13, weight: .medium))
                        }
                        .foregroundStyle(Color.appError.opacity(0.6))

                        HStack(spacing: 4) {
                            Text("Đã biết")
                                .font(.system(size: 13, weight: .medium))
                            Image(systemName: "arrow.right")
                                .font(.system(size: 11, weight: .bold))
                        }
                        .foregroundStyle(Color.appSuccess.opacity(0.6))
                    }
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
                } else {
                    HStack(spacing: 6) {
                        Image(systemName: "hand.tap")
                            .font(.system(size: 12))
                        Text("Nhấn thẻ để xem đáp án")
                            .font(.system(size: 13, weight: .medium))
                    }
                    .foregroundStyle(Color.appTextLight)
                    .transition(.opacity)
                }
            }
            .animation(.easeOut(duration: 0.2), value: isFlipped)
            .padding(.bottom, 20)
        }
    }

    // MARK: - Swipe Gesture

    private var swipeGesture: some Gesture {
        DragGesture()
            .onChanged { drag in
                guard isFlipped else { return }
                dragOffset = drag.translation
            }
            .onEnded { drag in
                guard isFlipped else { return }
                if drag.translation.width > 120 {
                    swipeRight()
                } else if drag.translation.width < -120 {
                    swipeLeft()
                } else {
                    withAnimation(.spring(duration: 0.4, bounce: 0.3)) {
                        dragOffset = .zero
                    }
                }
            }
    }

    private func swipeRight() {
        Haptics.notification(.success)
        knownCount += 1
        recordAnswer(correct: true)
        withAnimation(.easeOut(duration: 0.25)) {
            dragOffset = CGSize(width: 500, height: dragOffset.height)
        }
        advanceAfterSwipe()
    }

    private func swipeLeft() {
        Haptics.selection()
        unknownCount += 1
        unknownQuestionNos.insert(questions[currentIndex].no)
        recordAnswer(correct: false)
        withAnimation(.easeOut(duration: 0.25)) {
            dragOffset = CGSize(width: -500, height: dragOffset.height)
        }
        advanceAfterSwipe()
    }

    private func advanceAfterSwipe() {
        Task { @MainActor in
            try? await Task.sleep(for: .milliseconds(250))
            dragOffset = .zero
            isFlipped = false
            withAnimation(.easeInOut(duration: 0.25)) {
                if currentIndex + 1 >= totalQuestions {
                    isFinished = true
                } else {
                    currentIndex += 1
                }
            }
        }
    }

    // MARK: - Front Card

    @ViewBuilder
    private func frontCard(question: Question) -> some View {
        ScrollView {
            VStack(spacing: 16) {
                Spacer().frame(height: 8)

                if question.hasImage {
                    QuestionImage(imageName: question.image)
                        .frame(maxHeight: 200)
                }

                Text(question.text)
                    .font(.system(size: 18 * AppFontScale.current, weight: .semibold))
                    .foregroundStyle(Color.appTextDark)
                    .multilineTextAlignment(.center)
                    .lineSpacing(5)

                Spacer().frame(height: 8)
            }
            .padding(.horizontal, 24)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .overlay(alignment: .bottom) {
            LinearGradient(colors: [.clear, Color.cardBg.opacity(0.8)], startPoint: .top, endPoint: .bottom)
                .frame(height: 40)
                .allowsHitTesting(false)
        }
        .glassCard()
        .transition(.asymmetric(
            insertion: .scale(scale: 0.95).combined(with: .opacity),
            removal: .scale(scale: 0.95).combined(with: .opacity)
        ))
    }

    // MARK: - Back Card

    @ViewBuilder
    private func backCard(question: Question, correctAnswer: Answer?) -> some View {
        ScrollView {
            VStack(spacing: 14) {
                Spacer().frame(height: 12)

                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 40))
                    .foregroundStyle(Color.appSuccess)

                if let answer = correctAnswer {
                    Text(answer.text)
                        .font(.system(size: 17 * AppFontScale.current, weight: .bold))
                        .foregroundStyle(Color.appSuccess)
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                }

                if !question.tip.isEmpty {
                    ExplanationBox(content: question.tip, labelFontSize: 12, contentFontSize: 13)
                }

                Spacer().frame(height: 8)
            }
            .padding(.horizontal, 20)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        // Swipe stamp overlays
        .overlay {
            if isFlipped && swipeProgress > 0.1 {
                ZStack {
                    if isSwipingRight {
                        Text("ĐÃ BIẾT")
                            .font(.system(size: 36, weight: .black))
                            .foregroundStyle(Color.appSuccess)
                            .rotationEffect(.degrees(-15))
                            .padding(6)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.appSuccess, lineWidth: 4)
                                    .rotationEffect(.degrees(-15))
                            )
                    } else {
                        Text("CHƯA BIẾT")
                            .font(.system(size: 32, weight: .black))
                            .foregroundStyle(Color.appError)
                            .rotationEffect(.degrees(15))
                            .padding(6)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.appError, lineWidth: 4)
                                    .rotationEffect(.degrees(15))
                            )
                    }
                }
                .opacity(swipeProgress)
            }
        }
        .glassCard()
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(
                    swipeProgress > 0.1
                        ? (isSwipingRight ? Color.appSuccess : Color.appError).opacity(swipeProgress * 0.6)
                        : Color.clear,
                    lineWidth: 3
                )
        )
        .transition(.asymmetric(
            insertion: .scale(scale: 0.95).combined(with: .opacity),
            removal: .scale(scale: 0.95).combined(with: .opacity)
        ))
    }

    // MARK: - Finished View

    private var finishedView: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "party.popper.fill")
                .font(.system(size: 72))
                .foregroundStyle(Color.appPrimary)

            VStack(spacing: 8) {
                Text("Hoàn thành!")
                    .font(.system(size: 32, weight: .heavy))
                    .foregroundStyle(Color.appTextDark)

                Text("\(totalQuestions) thẻ đã xong")
                    .font(.system(size: 16))
                    .foregroundStyle(Color.appTextMedium)
            }

            HStack(spacing: 0) {
                StatItem(value: "\(knownCount)", label: "Đã biết", valueColor: .appSuccess, valueFontSize: 28)

                Rectangle()
                    .fill(Color.appDivider)
                    .frame(width: 1, height: 44)

                StatItem(value: "\(unknownCount)", label: "Chưa biết", valueColor: .appError, valueFontSize: 28)
            }
            .padding(20)
            .glassCard()

            Spacer().frame(height: 12)

            VStack(spacing: 12) {
                if unknownCount > 0 {
                    Button { retryUnknown() } label: {
                        AppButton(label: "Luyện lại \(unknownCount) câu chưa biết")
                    }
                }
                Button { resetFlashcards() } label: {
                    AppButton(label: "Làm lại tất cả", style: unknownCount > 0 ? .secondary : .primary)
                }
                Button { dismiss() } label: {
                    AppButton(label: "Quay lại", style: .secondary)
                }
            }

            Spacer()
        }
        .padding(.horizontal, 20)
    }

    // MARK: - Actions

    private func flipCard() {
        Haptics.impact(.light)
        withAnimation(.easeInOut(duration: 0.25)) {
            isFlipped.toggle()
        }
    }

    private func recordAnswer(correct: Bool) {
        let question = questions[currentIndex]
        let topicKey = Topic.keyForTopicId(question.topic)
        progressStore.recordQuestionAnswer(topicKey: topicKey, questionNo: question.no, correct: correct)
    }

    private func retryUnknown() {
        let allQs = questionStore.questions(forTopicKey: topicKey)
        activeQuestions = allQs.filter { unknownQuestionNos.contains($0.no) }
        currentIndex = 0
        isFlipped = false
        knownCount = 0
        unknownCount = 0
        unknownQuestionNos.removeAll()
        isFinished = false
        dragOffset = .zero
    }

    private func resetFlashcards() {
        activeQuestions = nil
        currentIndex = 0
        isFlipped = false
        knownCount = 0
        unknownCount = 0
        unknownQuestionNos.removeAll()
        isFinished = false
        dragOffset = .zero
    }
}
