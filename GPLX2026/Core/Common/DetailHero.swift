import SwiftUI

struct DetailHero: View {
    let icon: String
    let iconColor: Color
    let title: String
    let subtitle: String
    var description: String? = nil
    var badge: (text: String, color: Color)? = nil

    var body: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(iconColor.opacity(0.1))
                    .frame(width: 80, height: 80)
                Image(systemName: icon)
                    .font(.system(size: 36))
                    .foregroundStyle(iconColor)
            }

            VStack(spacing: 4) {
                Text(title)
                    .font(.system(size: 28, weight: .heavy).monospacedDigit())
                    .foregroundStyle(Color.appTextDark)
                    .contentTransition(.numericText())
                    .animation(.snappy, value: title)
                Text(subtitle)
                    .font(.system(size: 14))
                    .foregroundStyle(Color.appTextMedium)
            }

            if let desc = description {
                Text(desc)
                    .font(.system(size: 13))
                    .foregroundStyle(Color.appTextLight)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
            }

            if let badge {
                StatusBadge(text: badge.text, color: badge.color, fontSize: 12)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .glassCard()
    }
}
