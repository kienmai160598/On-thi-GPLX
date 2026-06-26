import SwiftUI

// MARK: - AnswerReviewView
//
// Dedicated answer-review list (design node eaw6o), reached from the exam
// result's "Câu đúng / Câu sai / Điểm liệt" detail rows. Each question is a card
// showing the topic tag, the question, the user's choice ("Bạn chọn") and — when
// they got it wrong — the correct answer ("Đáp án đúng"). The `mode` only changes
// which questions are listed and the screen's title/intro/count.

struct AnswerReviewView: View {
    enum Mode {
        case correct, wrong, diemLiet
    }

    @Environment(LayoutMetrics.self) private var metrics

    let questions: [Question]
    let answers: [Int: Int]
    let mode: Mode

    private func isCorrect(index: Int, question: Question) -> Bool {
        let selectedId = answers[index]
        return selectedId != nil && question.answers.contains { $0.id == selectedId && $0.correct }
    }

    /// Questions matching the mode, paired with the index used to look up the
    /// chosen answer.
    private var items: [(index: Int, question: Question)] {
        questions.enumerated().compactMap { index, question in
            switch mode {
            case .correct:  return isCorrect(index: index, question: question) ? (index, question) : nil
            case .wrong:    return isCorrect(index: index, question: question) ? nil : (index, question)
            case .diemLiet: return question.isDiemLiet ? (index, question) : nil
            }
        }
    }

    private var title: String {
        switch mode {
        case .correct:  return "Câu đúng"
        case .wrong:    return "Câu sai"
        case .diemLiet: return "Điểm liệt"
        }
    }

    private var intro: String {
        switch mode {
        case .correct:  return "Xem lại các câu bạn đã trả lời đúng."
        case .wrong:    return "Ôn lại các câu bạn trả lời sai để chắc kiến thức."
        case .diemLiet: return "Các câu điểm liệt — chỉ cần sai một câu là trượt."
        }
    }

    private var emptyMessage: String {
        switch mode {
        case .correct:  return "Bạn chưa trả lời đúng câu nào."
        case .wrong:    return "Bạn không trả lời sai câu nào!"
        case .diemLiet: return "Đề này không có câu điểm liệt."
        }
    }

    private var emptyIcon: String {
        mode == .wrong ? "checkmark.circle.fill" : "tray"
    }

    private func countColor(_ items: [(index: Int, question: Question)]) -> Color {
        switch mode {
        case .correct:
            return .appSuccess
        case .wrong:
            return .appError
        case .diemLiet:
            let anyWrong = items.contains { !isCorrect(index: $0.index, question: $0.question) }
            return anyWrong ? .appError : .appSuccess
        }
    }

    var body: some View {
        let items = items

        ScrollView {
            if items.isEmpty {
                EmptyState(icon: emptyIcon, message: emptyMessage, iconColor: mode == .wrong ? .appSuccess : .appTextLight)
            } else {
                VStack(alignment: .leading, spacing: 12) {
                    Text(intro)
                        .font(.appSans(size: 13, weight: .medium))
                        .foregroundStyle(Color.appTextMedium)
                        .lineSpacing(3)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    ForEach(items, id: \.question.no) { item in
                        AnswerReviewCard(
                            question: item.question,
                            selectedAnswerId: answers[item.index],
                            isCorrect: isCorrect(index: item.index, question: item.question)
                        )
                    }
                }
                .padding(.horizontal, metrics.contentPadding)
                .padding(.top, 8)
                .padding(.bottom, 32)
            }
        }
        .screenHeader(title, titleDisplayMode: .inline)
        .toolbar {
            if !items.isEmpty {
                ToolbarItem(placement: .topBarTrailing) {
                    Text("\(items.count) câu")
                        .font(.appSans(size: 12, weight: .bold))
                        .foregroundStyle(countColor(items))
                }
            }
        }
    }
}

// MARK: - AnswerReviewCard

private struct AnswerReviewCard: View {
    let question: Question
    let selectedAnswerId: Int?
    let isCorrect: Bool

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

            // "Bạn chọn" — green check when right, red x when wrong/skipped.
            answerLine(
                icon: isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill",
                color: isCorrect ? .appSuccess : .appError,
                text: "Bạn chọn: \(selectedAnswer?.text ?? "Chưa trả lời")"
            )
            // The correct answer is only worth repeating when they missed it.
            if !isCorrect {
                answerLine(icon: "checkmark.circle.fill", color: .appSuccess,
                           text: "Đáp án đúng: \(correctAnswer.text)")
            }
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
