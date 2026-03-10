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
                .clipShape(RoundedRectangle(cornerRadius: 8))

            Text(text)
                .font(.system(size: 15 * AppFontScale.current, weight: .medium))
                .foregroundStyle(Color.appTextDark)
                .multilineTextAlignment(.leading)
                .lineSpacing(3)

            Spacer()

            statusIcon
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 12)
        .background(bgColor)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(alignment: .leading) {
            if let borderColor = leftBorderColor {
                RoundedRectangle(cornerRadius: 2)
                    .fill(borderColor)
                    .frame(width: 4)
                    .padding(.vertical, 8)
            }
        }
        .glassCard()
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(letter). \(text)")
        .accessibilityValue(accessibilityStatus)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    private var accessibilityStatus: String {
        if !isConfirmed && !isSelected { return "" }
        if !isConfirmed && isSelected { return "Đã chọn" }
        if isCorrect { return "Đúng" }
        if isSelected && !isCorrect { return "Sai" }
        return ""
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
        if isCorrect { return .appSuccess.opacity(0.10) }
        if isSelected && !isCorrect { return .appError.opacity(0.10) }
        return .clear
    }

    private var leftBorderColor: Color? {
        guard isConfirmed else { return nil }
        if isCorrect { return .appSuccess }
        if isSelected && !isCorrect { return .appError }
        return nil
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
