import SwiftUI

struct FlashcardView: View {
    @Environment(QuestionStore.self) private var questionStore
    @Environment(\.dismiss) private var dismiss

    let topicKey: String

    @State private var currentIndex = 0
    @State private var isFlipped = false
    @State private var knownCount = 0
    @State private var unknownCount = 0
    @State private var isFinished = false

    private var questions: [Question] {
        questionStore.questions(forTopicKey: topicKey)
    }

    private var totalQuestions: Int { questions.count }

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
                Text("Flashcard")
                    .font(.system(size: 17, weight: .semibold))
            }
        }
    }

    // MARK: - Flashcard Content

    @ViewBuilder
    private var flashcardContent: some View {
        let question = questions[currentIndex]
        let correctAnswer = question.answers.first(where: \.correct)
        let progress = Double(currentIndex + 1) / Double(totalQuestions)

        VStack(spacing: 0) {
            // Progress indicator
            VStack(spacing: 6) {
                ProgressBarView(fraction: progress, height: 4, cornerRadius: 2)
                Text("\(currentIndex + 1) / \(totalQuestions)")
                    .font(.system(size: 13, weight: .semibold).monospacedDigit())
                    .foregroundStyle(Color.appTextMedium)
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)

            Spacer()

            // Card with simple flip transition
            ZStack {
                if !isFlipped {
                    frontCard(question: question)
                        .transition(.asymmetric(
                            insertion: .scale(scale: 0.92).combined(with: .opacity),
                            removal: .scale(scale: 0.92).combined(with: .opacity)
                        ))
                } else {
                    backCard(question: question, correctAnswer: correctAnswer)
                        .transition(.asymmetric(
                            insertion: .scale(scale: 0.92).combined(with: .opacity),
                            removal: .scale(scale: 0.92).combined(with: .opacity)
                        ))
                }
            }
            .onTapGesture { flipCard() }
            .padding(.horizontal, 20)

            Spacer()
        }
        .safeAreaInset(edge: .bottom) {
            VStack(spacing: 6) {
                if !isFlipped {
                    Text("Lật thẻ để trả lời")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(Color.appTextLight)
                        .transition(.opacity)
                }

                ExamBottomBar(
                    currentIndex: currentIndex,
                    totalCount: totalQuestions,
                    answeredIndices: Set(0..<currentIndex),
                    nextLabel: "Đã biết",
                    prevLabel: "Chưa biết",
                    prevIcon: "xmark",
                    isNextDisabled: !isFlipped,
                    isPrevDisabled: !isFlipped,
                    showPrev: true,
                    onPrev: { markUnknown() },
                    onNext: { markKnown() },
                    onSelectIndex: { _ in }
                )
            }
        }
    }

    // MARK: - Front Card

    @ViewBuilder
    private func frontCard(question: Question) -> some View {
        VStack(spacing: 20) {
            Spacer()

            if question.hasImage {
                QuestionImage(imageName: question.image)
                    .frame(maxHeight: 200)
            }

            Text(question.text)
                .font(.system(size: 18 * AppFontScale.current, weight: .semibold))
                .foregroundStyle(Color.appTextDark)
                .multilineTextAlignment(.center)
                .lineSpacing(5)

            Spacer().frame(height: 12)

            HStack(spacing: 6) {
                Image(systemName: "hand.tap")
                    .font(.system(size: 14))
                Text("Nhấn để xem đáp án")
                    .font(.system(size: 14, weight: .medium))
            }
            .foregroundStyle(Color.appTextLight)

            Spacer()
        }
        .padding(28)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .glassCard()
    }

    // MARK: - Back Card

    @ViewBuilder
    private func backCard(question: Question, correctAnswer: Answer?) -> some View {
        VStack(spacing: 16) {
            Spacer()

            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 48))
                .foregroundStyle(Color.appSuccess)

            Text("Đáp án đúng:")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(Color.appTextMedium)

            if let answer = correctAnswer {
                Text(answer.text)
                    .font(.system(size: 18 * AppFontScale.current, weight: .bold))
                    .foregroundStyle(Color.appSuccess)
                    .multilineTextAlignment(.center)
                    .lineSpacing(5)
            }

            if !question.tip.isEmpty {
                ExplanationBox(content: question.tip, labelFontSize: 12, contentFontSize: 13)
                    .padding(.top, 8)
            }

            Spacer()
        }
        .padding(28)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .glassCard()
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
                Button { resetFlashcards() } label: {
                    AppButton(label: "Làm lại")
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

    private func markKnown() {
        guard isFlipped else { return }
        Haptics.notification(.success)
        knownCount += 1
        advanceCard()
    }

    private func markUnknown() {
        guard isFlipped else { return }
        Haptics.selection()
        unknownCount += 1
        advanceCard()
    }

    private func advanceCard() {
        isFlipped = false

        if currentIndex + 1 >= totalQuestions {
            withAnimation {
                isFinished = true
            }
        } else {
            currentIndex += 1
        }
    }

    private func resetFlashcards() {
        currentIndex = 0
        isFlipped = false
        knownCount = 0
        unknownCount = 0
        isFinished = false
    }
}
