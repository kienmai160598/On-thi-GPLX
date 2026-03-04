import SwiftUI

struct RuleRow: View {
    let icon: String
    let iconColor: Color
    let text: String

    var body: some View {
        HStack(spacing: 12) {
            IconBox(icon: icon, color: iconColor, size: 32, cornerRadius: 8, iconFontSize: 14)

            Text(text)
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(Color.appTextDark)
                .lineSpacing(2)
        }
    }
}
