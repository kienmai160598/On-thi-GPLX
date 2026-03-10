import SwiftUI

struct QuestionReviewRow: View {
    @Environment(ThemeStore.self) private var themeStore
    let question: Question
    let status: AnswerStatus
    var showStatusIcon: Bool = true
    var selectedAnswerId: Int? = nil
    var timeUsedBadge: String? = nil
    var onNavigate: (() -> Void)? = nil

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
                    if showStatusIcon {
                        Image(systemName: statusIcon)
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(statusColor)
                            .frame(width: 28, height: 28)
                            .background(statusColor.opacity(0.12))
                            .clipShape(Circle())
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 6) {
                            Text("Câu \(question.no)")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundStyle(Color.appTextMedium)

                            if question.isDiemLiet {
                                StatusBadge(text: "Điểm liệt", color: .appError, fontSize: 9, hPadding: 5, vPadding: 2)
                            }

                            if let badge = timeUsedBadge {
                                StatusBadge(text: badge, color: .appWarning, fontSize: 9, hPadding: 5, vPadding: 2)
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
                                Image(systemName: answerIcon(answer))
                                    .font(.system(size: 14))
                                    .foregroundStyle(answerColor(answer))

                                Text(answer.text)
                                    .font(.system(size: 13, weight: answer.correct ? .semibold : .regular))
                                    .foregroundStyle(answerColor(answer))
                                    .lineSpacing(2)
                                    .multilineTextAlignment(.leading)
                            }
                        }

                        if !question.tip.isEmpty {
                            ExplanationBox(content: question.tip, labelFontSize: 12, contentFontSize: 13)
                                .padding(.top, 8)
                        }

                        if let onNavigate {
                            Button(action: onNavigate) {
                                HStack(spacing: 6) {
                                    Image(systemName: "pencil.line")
                                        .font(.system(size: 12))
                                    Text("Luyện câu này")
                                        .font(.system(size: 13, weight: .semibold))
                                }
                                .foregroundStyle(themeStore.primaryColor)
                                .padding(.top, 4)
                            }
                        }
                    }
                    .padding(.leading, showStatusIcon ? 40 : 0)
                    .padding(.top, 10)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    // MARK: - Answer styling

    private func answerIcon(_ answer: Answer) -> String {
        if answer.correct {
            return "checkmark.circle.fill"
        } else if selectedAnswerId == answer.id {
            return "xmark.circle.fill"
        }
        return "circle"
    }

    private func answerColor(_ answer: Answer) -> Color {
        if answer.correct {
            return .appSuccess
        } else if selectedAnswerId == answer.id {
            return .appError
        }
        return .appTextLight
    }
}
