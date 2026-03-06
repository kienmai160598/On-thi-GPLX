import SwiftUI

struct AnswerOptionCard: View {
    let letter: String
    let text: String
    var isSelected: Bool = false
    var isConfirmed: Bool = false
    var isCorrect: Bool = false

    var body: some View {
        HStack(spacing: 12) {
            // Letter indicator
            Text(letter)
                .font(.system(size: 16, weight: .heavy))
                .foregroundStyle(letterColor)
                .frame(width: 36, height: 36)
                .background(letterBgColor)
                .clipShape(RoundedRectangle(cornerRadius: 10))

            Text(text)
                .font(.system(size: 15 * AppFontScale.current, weight: .medium))
                .foregroundStyle(Color.appTextDark)
                .multilineTextAlignment(.leading)
                .lineSpacing(3)

            Spacer()

            statusIcon
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(bgColor)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .glassCard()
    }

    private var letterColor: Color {
        if isConfirmed && isCorrect { return .white }
        if isConfirmed && isSelected && !isCorrect { return .white }
        if isSelected { return .appPrimary }
        return .appTextMedium
    }

    private var letterBgColor: Color {
        if isConfirmed && isCorrect { return .appSuccess }
        if isConfirmed && isSelected && !isCorrect { return .appError }
        if isSelected { return .appPrimary.opacity(0.12) }
        return .appDivider.opacity(0.5)
    }

    private var bgColor: Color {
        if isSelected && !isConfirmed { return .appPrimary.opacity(0.06) }
        guard isConfirmed else { return .clear }
        if isCorrect { return .appSuccess.opacity(0.06) }
        if isSelected && !isCorrect { return .appError.opacity(0.06) }
        return .clear
    }

    @ViewBuilder
    private var statusIcon: some View {
        if isConfirmed && isCorrect {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 18))
                .foregroundStyle(Color.appSuccess)
        } else if isConfirmed && isSelected && !isCorrect {
            Image(systemName: "xmark.circle.fill")
                .font(.system(size: 18))
                .foregroundStyle(Color.appError)
        }
    }
}
