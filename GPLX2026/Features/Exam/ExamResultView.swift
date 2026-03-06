import SwiftUI

struct ExamResultView: View {
    @Environment(\.popToRoot) private var popToRoot

    let questions: [Question]
    let answers: [Int: Int]
    let timeUsedSeconds: Int
    let examResult: ExamResult
    var isFromHistory: Bool = false

    private var correctCount: Int { examResult.score }
    private var wrongDiemLietCount: Int { examResult.wrongDiemLiet }
    private var isPassed: Bool { examResult.passed }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                Spacer().frame(height: 8)

                // MARK: - Result Hero
                ResultHero(
                    isPassed: isPassed,
                    score: correctCount,
                    total: questions.count,
                    subtitle: isPassed
                        ? "Chúc mừng bạn đã vượt qua!"
                        : "Hãy ôn tập thêm và thử lại nhé"
                )

                // MARK: - Score details
                VStack(spacing: 0) {
                    ScoreRow(label: "Câu đúng", value: "\(correctCount)/\(questions.count)", color: Color.appSuccess)
                    Divider().padding(.horizontal, 16)
                    ScoreRow(label: "Câu sai", value: "\(questions.count - correctCount)/\(questions.count)", color: Color.appError)
                    Divider().padding(.horizontal, 16)
                    ScoreRow(
                        label: "Điểm liệt sai",
                        value: "\(wrongDiemLietCount)",
                        color: wrongDiemLietCount > 0 ? Color.appError : Color.appSuccess
                    )
                    Divider().padding(.horizontal, 16)

                    let minutes = timeUsedSeconds / 60
                    let seconds = timeUsedSeconds % 60
                    ScoreRow(
                        label: "Thời gian",
                        value: String(format: "%02d:%02d", minutes, seconds),
                        color: Color.appTextMedium
                    )
                    Divider().padding(.horizontal, 16)
                    ScoreRow(
                        label: "Yêu cầu đạt",
                        value: "\u{2265} 32 & 0 ĐL sai",
                        color: Color.appTextMedium
                    )
                }
                .padding(.vertical, 4)
                .glassCard()

                // MARK: - Review
                SectionTitle(title: "Xem lại đáp án")

                LazyVStack(spacing: 8) {
                    ForEach(Array(questions.enumerated()), id: \.element.no) { index, question in
                        ReviewRow(
                            index: index,
                            question: question,
                            selectedAnswerId: answers[index]
                        )
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 32)
        }
        .navigationBarBackButtonHidden(!isFromHistory)
        .screenHeader(isFromHistory ? "Chi tiết bài thi" : "Kết quả thi")
        .toolbar {
            if !isFromHistory {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button { popToRoot() } label: {
                        Image(systemName: "checkmark")
                            .font(.system(size: 15, weight: .semibold))
                    }
                }
            }
        }
    }
}

// MARK: - Result Hero

private struct ResultHero: View {
    let isPassed: Bool
    let score: Int
    let total: Int
    let subtitle: String

    @State private var animateRing = false

    private var statusColor: Color { isPassed ? .appSuccess : .appError }
    private var fraction: Double { total > 0 ? Double(score) / Double(total) : 0 }

    var body: some View {
        VStack(spacing: 20) {
            // Animated score ring
            ZStack {
                Circle()
                    .stroke(Color.appDivider, lineWidth: 10)

                Circle()
                    .trim(from: 0, to: animateRing ? fraction : 0)
                    .stroke(statusColor, style: StrokeStyle(lineWidth: 10, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .animation(.spring(duration: 1.0, bounce: 0.15), value: animateRing)

                VStack(spacing: 2) {
                    Text("\(score)")
                        .font(.system(size: 44, weight: .heavy).monospacedDigit())
                        .foregroundStyle(Color.appTextDark)
                        .contentTransition(.numericText())
                    Text("/\(total) câu")
                        .font(.system(size: 14))
                        .foregroundStyle(Color.appTextMedium)
                }
            }
            .frame(width: 140, height: 140)

            StatusBadge(
                text: isPassed ? "ĐẠT" : "TRƯỢT",
                color: statusColor,
                fontSize: 16
            )

            Text(subtitle)
                .font(.system(size: 15))
                .foregroundStyle(Color.appTextMedium)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 28)
        .glassCard()
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                animateRing = true
            }
        }
    }
}

// MARK: - Review Row

private struct ReviewRow: View {
    let index: Int
    let question: Question
    let selectedAnswerId: Int?

    @State private var isExpanded = false

    private var correctAnswer: Answer {
        question.answers.first(where: \.correct) ?? question.answers.first ?? Answer(id: -1, text: "—", correct: false)
    }

    private var isCorrect: Bool {
        selectedAnswerId == correctAnswer.id
    }

    private var isUnanswered: Bool {
        selectedAnswerId == nil
    }

    private var statusColor: Color {
        isUnanswered ? Color.appWarning : isCorrect ? Color.appSuccess : Color.appError
    }

    var body: some View {
        Button {
            withAnimation(.easeOut(duration: 0.25)) {
                isExpanded.toggle()
            }
        } label: {
            VStack(alignment: .leading, spacing: 0) {
                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: isUnanswered ? "minus" : isCorrect ? "checkmark" : "xmark")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(statusColor)
                        .frame(width: 28, height: 28)
                        .background(statusColor.opacity(0.12))
                        .clipShape(Circle())

                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 6) {
                            Text("Câu \(index + 1)")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundStyle(Color.appTextMedium)

                            if question.isDiemLiet {
                                StatusBadge(text: "ĐL", color: .appError, fontSize: 9, hPadding: 5, vPadding: 2)
                            }
                        }

                        Text(question.text)
                            .font(.system(size: 14))
                            .foregroundStyle(Color.appTextDark)
                            .lineLimit(isExpanded ? nil : 2)
                            .lineSpacing(2)
                            .multilineTextAlignment(.leading)

                        if !isExpanded && !isCorrect {
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
                                Image(systemName: answer.correct ? "checkmark.circle.fill" :
                                        selectedAnswerId == answer.id ? "xmark.circle.fill" :
                                        "circle")
                                    .font(.system(size: 14))
                                    .foregroundStyle(
                                        answer.correct ? Color.appSuccess :
                                        selectedAnswerId == answer.id ? Color.appError :
                                        Color.appTextLight
                                    )

                                Text(answer.text)
                                    .font(.system(size: 13, weight: answer.correct ? .semibold : .regular))
                                    .foregroundStyle(
                                        answer.correct ? Color.appSuccess :
                                        selectedAnswerId == answer.id ? Color.appError :
                                        Color.appTextDark
                                    )
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
        }
        .glassCard()
    }
}
