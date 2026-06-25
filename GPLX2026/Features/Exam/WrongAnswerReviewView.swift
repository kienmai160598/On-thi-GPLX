import SwiftUI

// MARK: - WrongAnswerReviewView
//
// Dedicated "Câu sai" screen (design node eaw6o): lists the questions answered
// incorrectly in an exam, each as a card showing the topic tag, the question,
// the user's wrong choice ("Bạn chọn", red) and the correct answer ("Đáp án
// đúng", green). Reached from the exam result's "Câu sai" detail row.

struct WrongAnswerReviewView: View {
    @Environment(LayoutMetrics.self) private var metrics

    let questions: [Question]
    let answers: [Int: Int]

    /// Questions that were not answered correctly (wrong or skipped), paired with
    /// the index used to look up the chosen answer.
    private var wrongItems: [(index: Int, question: Question)] {
        questions.enumerated().compactMap { index, question in
            let selectedId = answers[index]
            let isCorrect = selectedId != nil && question.answers.contains { $0.id == selectedId && $0.correct }
            return isCorrect ? nil : (index, question)
        }
    }

    var body: some View {
        let items = wrongItems

        ScrollView {
            if items.isEmpty {
                EmptyState(icon: "checkmark.circle.fill", message: "Bạn không trả lời sai câu nào!", iconColor: .appSuccess)
            } else {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Ôn lại các câu bạn trả lời sai để chắc kiến thức.")
                        .font(.appSans(size: 13, weight: .medium))
                        .foregroundStyle(Color.appTextMedium)
                        .lineSpacing(3)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    ForEach(items, id: \.question.no) { item in
                        WrongAnswerCard(question: item.question, selectedAnswerId: answers[item.index])
                    }
                }
                .padding(.horizontal, metrics.contentPadding)
                .padding(.top, 8)
                .padding(.bottom, 32)
            }
        }
        .screenHeader("Câu sai", titleDisplayMode: .inline)
        .toolbar {
            if !items.isEmpty {
                ToolbarItem(placement: .topBarTrailing) {
                    Text("\(items.count) câu")
                        .font(.appSans(size: 12, weight: .bold))
                        .foregroundStyle(Color.appError)
                }
            }
        }
    }
}

// MARK: - WrongAnswerCard

private struct WrongAnswerCard: View {
    let question: Question
    let selectedAnswerId: Int?

    private var correctAnswer: Answer {
        question.answers.first(where: \.correct) ?? question.answers.first ?? Answer(id: -1, text: "—", correct: false)
    }

    private var selectedAnswer: Answer? {
        guard let id = selectedAnswerId else { return nil }
        return question.answers.first { $0.id == id }
    }

    private var topicName: String {
        Topic.all.first { $0.topicIds.contains(question.topic) }?.shortName ?? "Khác"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Text("Câu \(question.no)")
                    .font(.appSans(size: 14, weight: .heavy))
                    .foregroundStyle(Color.appTextDark)
                if question.isDiemLiet {
                    tag("Điểm liệt", color: .appError)
                } else {
                    tag(topicName, color: .appTextMedium)
                }
                Spacer(minLength: 0)
            }

            Text(question.text)
                .font(.appSans(size: 14, weight: .semibold))
                .foregroundStyle(Color.appTextDark)
                .lineSpacing(3)
                .frame(maxWidth: .infinity, alignment: .leading)

            Rectangle()
                .fill(Color.appDivider.opacity(0.6))
                .frame(height: 1)

            answerLine(icon: "xmark.circle.fill", color: .appError,
                       text: "Bạn chọn: \(selectedAnswer?.text ?? "Chưa trả lời")")
            answerLine(icon: "checkmark.circle.fill", color: .appSuccess,
                       text: "Đáp án đúng: \(correctAnswer.text)")
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 14)
        .glassCard(cornerRadius: 20)
    }

    private func tag(_ text: String, color: Color) -> some View {
        Text(text)
            .font(.appSans(size: 10.5, weight: .bold))
            .foregroundStyle(color)
            .padding(.vertical, 3)
            .padding(.horizontal, 8)
            .background(color.opacity(0.12), in: Capsule())
    }

    private func answerLine(icon: String, color: Color, text: String) -> some View {
        HStack(alignment: .top, spacing: 7) {
            Image(systemName: icon)
                .font(.appSans(size: 14))
                .foregroundStyle(color)
            Text(text)
                .font(.appSans(size: 12.5, weight: .semibold))
                .foregroundStyle(color)
                .lineSpacing(2)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}
