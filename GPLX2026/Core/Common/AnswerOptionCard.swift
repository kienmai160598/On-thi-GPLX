import SwiftUI

struct AnswerOptionCard: View {
    let letter: String
    let text: String
    var isSelected: Bool = false
    var isConfirmed: Bool = false
    var isCorrect: Bool = false

    var body: some View {
        HStack(spacing: 12) {
            Text(letter)
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(letterColor)
                .frame(width: 32)

            Text(text)
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(Color.appTextDark)
                .multilineTextAlignment(.leading)
                .lineSpacing(2)

            Spacer()

            statusIcon
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 16)
        .background(bgColor)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .glassCard()
    }

    private var letterColor: Color {
        if isConfirmed && isCorrect { return .appSuccess }
        if isConfirmed && isSelected && !isCorrect { return .appError }
        if isSelected { return .appPrimary }
        return .appTextMedium
    }

    private var bgColor: Color {
        if isSelected && !isConfirmed { return .appPrimary.opacity(0.08) }
        guard isConfirmed else { return .clear }
        if isCorrect { return .appSuccess.opacity(0.08) }
        if isSelected && !isCorrect { return .appError.opacity(0.08) }
        return .clear
    }

    @ViewBuilder
    private var statusIcon: some View {
        if isConfirmed && isCorrect {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 16))
                .foregroundStyle(Color.appSuccess)
        } else if isConfirmed && isSelected && !isCorrect {
            Image(systemName: "xmark.circle.fill")
                .font(.system(size: 16))
                .foregroundStyle(Color.appError)
        }
    }
}
