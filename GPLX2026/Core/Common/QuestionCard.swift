import SwiftUI

struct QuestionCard: View {
    let label: String
    let question: Question
    var showDiemLietBadge: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 8) {
                Text(label)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(Color.appPrimary)

                if showDiemLietBadge && question.isDiemLiet {
                    StatusBadge(text: "Điểm liệt", color: .appError, fontSize: 11)
                }
            }

            Text(question.text)
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(Color.appTextDark)
                .lineSpacing(5)

            if question.hasImage {
                QuestionImage(imageName: question.image)
            }
        }
        .padding(20)
        .glassCard()
    }
}
