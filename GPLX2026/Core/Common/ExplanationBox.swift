import SwiftUI

struct ExplanationBox: View {
    let content: String
    var label: String = "Giải thích:"
    var labelFontSize: CGFloat = 13
    var contentFontSize: CGFloat = 14

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.system(size: labelFontSize, weight: .bold))
                .foregroundStyle(Color.appTextDark)
            Text(content)
                .font(.system(size: contentFontSize))
                .foregroundStyle(Color.appTextMedium)
                .lineSpacing(3)
                .multilineTextAlignment(.leading)
        }
        .padding(14)
        .glassCard(cornerRadius: 12)
    }
}
