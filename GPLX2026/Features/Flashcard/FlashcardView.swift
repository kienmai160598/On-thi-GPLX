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
    @State private var flipDegrees: Double = 0

    private var questions: [Question] {
        questionStore.questions(forTopicKey: topicKey)
    }

    private var totalQuestions: Int { questions.count }

    var body: some View {
        Group {
            if questions.isEmpty {
                VStack(spacing: 12) {
                    Text("Không có câu hỏi")
                        .font(.system(size: 16))
                        .foregroundStyle(Color.appTextMedium)
                }
            } else if isFinished {
                finishedView
            } else {
                flashcardContent
            }
        }
        .screenHeader("Flashcard")
    }

    // MARK: - Flashcard Content

    @ViewBuilder
    private var flashcardContent: some View {
        let question = questions[currentIndex]
        let correctAnswer = question.answers.first(where: \.correct)
        let progress = Double(currentIndex + 1) / Double(totalQuestions)

        ZStack {
            // Flashcard with 3D flip
            VStack {
                Spacer()

                ZStack {
                    // Determine which side to show based on flip angle
                    if flipDegrees < 90 {
                        frontCard(question: question)
                    } else {
                        backCard(question: question, correctAnswer: correctAnswer)
                            .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
                    }
                }
                .rotation3DEffect(.degrees(flipDegrees), axis: (x: 0, y: 1, z: 0))
                .onTapGesture { flipCard() }
                .padding(.horizontal, 20)

                Spacer()
            }

            // MARK: - Bottom bar
            VStack {
                Spacer()
                HStack(spacing: 8) {
                    Button {
                        markUnknown()
                    } label: {
                        AppButton(icon: "xmark", label: "Chưa biết", style: .secondary, height: 48, cornerRadius: 24)
                    }
                    .disabled(!isFlipped)

                    Text("\(currentIndex + 1)/\(totalQuestions)")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(Color.appTextMedium)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .glassCard()

                    Button {
                        markKnown()
                    } label: {
                        AppButton(icon: "checkmark", label: "Đã biết", height: 48, cornerRadius: 24)
                    }
                    .disabled(!isFlipped)
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 10)
            }
        }
    }

    // MARK: - Front Card

    @ViewBuilder
    private func frontCard(question: Question) -> some View {
        VStack(spacing: 16) {
            Spacer()

            if question.hasImage {
                AsyncImage(url: URL(string: question.imageUrl)) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxHeight: 200)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    default:
                        EmptyView()
                    }
                }
            }

            Text(question.text)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(Color.appTextDark)
                .multilineTextAlignment(.center)
                .lineSpacing(4)

            Spacer().frame(height: 8)

            Text("Nhấn để xem đáp án")
                .font(.system(size: 13))
                .foregroundStyle(Color.appTextLight)

            Spacer()
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .glassCard()
    }

    // MARK: - Back Card

    @ViewBuilder
    private func backCard(question: Question, correctAnswer: Answer?) -> some View {
        VStack(spacing: 12) {
            Spacer()

            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 40))
                .foregroundStyle(Color.appSuccess)

            Text("Đáp án đúng:")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(Color.appTextMedium)

            if let answer = correctAnswer {
                Text(answer.text)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(Color.appSuccess)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
            }

            if !question.tip.isEmpty {
                ExplanationBox(content: question.tip, labelFontSize: 12, contentFontSize: 13)
                    .padding(.top, 8)
            }

            Spacer()
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .glassCard()
    }

    // MARK: - Finished View

    private var finishedView: some View {
        VStack(spacing: 16) {
            Spacer()

            Image(systemName: "party.popper.fill")
                .font(.system(size: 56))
                .foregroundStyle(Color.appPrimary)

            Text("Hoàn thành!")
                .font(.system(size: 24, weight: .heavy))
                .foregroundStyle(Color.appTextDark)

            HStack(spacing: 0) {
                StatItem(value: "\(knownCount)", label: "Đã biết", valueColor: .appSuccess, valueFontSize: 28)

                Rectangle()
                    .fill(Color.appDivider)
                    .frame(width: 1, height: 40)

                StatItem(value: "\(unknownCount)", label: "Chưa biết", valueColor: .appError, valueFontSize: 28)
            }
            .padding(16)
            .glassCard()

            Spacer().frame(height: 8)

            Button {
                resetFlashcards()
            } label: {
                AppButton(label: "Làm lại")
            }

            Button {
                dismiss()
            } label: {
                AppButton(label: "Quay lại", style: .secondary)
            }

            Spacer()
        }
        .padding(.horizontal, 20)
    }

    // MARK: - Actions

    private func flipCard() {
        Haptics.impact(.light)
        withAnimation(.easeInOut(duration: 0.4)) {
            if isFlipped {
                flipDegrees = 0
            } else {
                flipDegrees = 180
            }
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
        flipDegrees = 0
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
        flipDegrees = 0
    }
}
