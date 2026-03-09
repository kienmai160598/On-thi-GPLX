import SwiftUI

struct ExplanationBox: View {
    let content: String
    var label: String = "Giải thích:"
    var labelFontSize: CGFloat = 13
    var contentFontSize: CGFloat = 14

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 6) {
                Image(systemName: "lightbulb.fill")
                    .font(.system(size: 12))
                    .foregroundStyle(Color.appWarning)
                Text(label)
                    .font(.system(size: labelFontSize, weight: .bold))
                    .foregroundStyle(Color.appTextDark)
            }
            Text(content)
                .font(.system(size: contentFontSize))
                .foregroundStyle(Color.appTextMedium)
                .lineSpacing(4)
                .multilineTextAlignment(.leading)
        }
        .padding(16)
        .glassCard(cornerRadius: 12)
    }
}
