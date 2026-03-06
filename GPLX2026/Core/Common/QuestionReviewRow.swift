import SwiftUI

struct QuestionReviewRow: View {
    let question: Question
    let status: AnswerStatus

    @State private var isExpanded = false

    private var correctAnswer: Answer {
        question.answers.first(where: \.correct) ?? question.answers.first ?? Answer(id: -1, text: "—", correct: false)
    }

    private var statusColor: Color {
        switch status {
        case .correct: Color.appSuccess
        case .wrong: Color.appError
        case .unanswered: Color.appTextLight
        }
    }

    private var statusIcon: String {
        switch status {
        case .correct: "checkmark"
        case .wrong: "xmark"
        case .unanswered: "minus"
        }
    }

    var body: some View {
        Button {
            withAnimation(.easeOut(duration: 0.25)) {
                isExpanded.toggle()
            }
        } label: {
            VStack(alignment: .leading, spacing: 0) {
                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: statusIcon)
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(statusColor)
                        .frame(width: 28, height: 28)
                        .background(statusColor.opacity(0.12))
                        .clipShape(Circle())

                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 6) {
                            Text("Câu \(question.no)")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundStyle(Color.appTextMedium)

                            if question.isDiemLiet {
                                StatusBadge(text: "Điểm liệt", color: .appError, fontSize: 9, hPadding: 5, vPadding: 2)
                            }
                        }

                        Text(question.text)
                            .font(.system(size: 14))
                            .foregroundStyle(Color.appTextDark)
                            .lineLimit(isExpanded ? nil : 2)
                            .lineSpacing(2)
                            .multilineTextAlignment(.leading)

                        if !isExpanded && status == .wrong {
                            Text("Đáp án: \(correctAnswer.text)")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundStyle(Color.appSuccess)
                                .lineLimit(1)
                        }
                    }

                    Spacer(minLength: 4)

                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(Color.appTextLight)
                        .rotationEffect(.degrees(isExpanded ? 90 : 0))
                        .animation(.easeOut(duration: 0.2), value: isExpanded)
                }

                if isExpanded {
                    VStack(alignment: .leading, spacing: 6) {
                        ForEach(question.answers, id: \.id) { answer in
                            HStack(alignment: .top, spacing: 8) {
                                Image(systemName: answer.correct ? "checkmark.circle.fill" : "circle")
                                    .font(.system(size: 14))
                                    .foregroundStyle(answer.correct ? Color.appSuccess : Color.appTextLight)

                                Text(answer.text)
                                    .font(.system(size: 13, weight: answer.correct ? .semibold : .regular))
                                    .foregroundStyle(answer.correct ? Color.appSuccess : Color.appTextDark)
                                    .lineSpacing(2)
                                    .multilineTextAlignment(.leading)
                            }
                        }

                        if !question.tip.isEmpty {
                            ExplanationBox(content: question.tip, labelFontSize: 12, contentFontSize: 13)
                                .padding(.top, 8)
                        }
                    }
                    .padding(.leading, 40)
                    .padding(.top, 10)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}
