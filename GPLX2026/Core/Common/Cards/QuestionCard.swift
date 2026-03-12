import SwiftUI

struct QuestionCard: View {
    @Environment(ThemeStore.self) private var themeStore
    let label: String
    let question: Question
    var showDiemLietBadge: Bool = false

    private var fontScale: CGFloat { AppFontScale.current }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 8) {
                Text(label)
                    .font(.appSans(size: 14, weight: .semibold))
                    .foregroundStyle(themeStore.primaryColor)

                if showDiemLietBadge && question.isDiemLiet {
                    StatusBadge(text: "Điểm liệt", color: .appError, fontSize: 11)
                }
            }

            Text(question.text)
                .font(.appSans(size: 17 * fontScale, weight: .semibold))
                .foregroundStyle(Color.appTextDark)
                .lineSpacing(5)

            if question.hasImage {
                QuestionImage(imageName: question.image)
            }
        }
        .padding(12)
        .glassCard()
    }
}
