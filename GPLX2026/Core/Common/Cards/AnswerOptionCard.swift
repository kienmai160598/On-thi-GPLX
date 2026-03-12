import SwiftUI

struct AnswerOptionCard: View {
    @Environment(LayoutMetrics.self) private var metrics

    let letter: String
    let text: String
    var isSelected: Bool = false
    var isConfirmed: Bool = false
    var isCorrect: Bool = false

    var body: some View {
        HStack(spacing: 12) {
            // Letter indicator
            Text(letter)
                .font(.appSans(size: metrics.isWide ? 18 : 16, weight: .bold))
                .foregroundStyle(letterColor)
                .frame(width: metrics.isWide ? 44 : 36, height: metrics.isWide ? 44 : 36)
                .background(letterBgColor)
                .clipShape(RoundedRectangle(cornerRadius: 8))

            Text(text)
                .font(.appSans(size: 15 * AppFontScale.current * metrics.fontScale, weight: .medium))
                .foregroundStyle(Color.appTextDark)
                .multilineTextAlignment(.leading)
                .lineSpacing(3)

            Spacer()

            statusIcon
        }
        .padding(.horizontal, metrics.isWide ? 16 : 12)
        .padding(.vertical, metrics.isWide ? 16 : 12)
        .background(bgColor)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(alignment: .leading) {
            if let borderColor = leftBorderColor {
                RoundedRectangle(cornerRadius: 2)
                    .fill(borderColor)
                    .frame(width: metrics.isWide ? 5 : 4)
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
                .font(.appSans(size: metrics.isWide ? 22 : 18))
                .foregroundStyle(Color.appSuccess)
        } else if isConfirmed && isSelected && !isCorrect {
            Image(systemName: "xmark.circle.fill")
                .font(.appSans(size: metrics.isWide ? 22 : 18))
                .foregroundStyle(Color.appError)
        }
    }
}
