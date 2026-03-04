import SwiftUI

struct StatItem: View {
    let value: String
    let label: String
    var valueColor: Color = Color.appTextDark
    var valueFontSize: CGFloat = 24

    var body: some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.system(size: valueFontSize, weight: .heavy))
                .foregroundStyle(valueColor)
            Text(label)
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(Color.appTextMedium)
        }
        .frame(maxWidth: .infinity)
    }
}
