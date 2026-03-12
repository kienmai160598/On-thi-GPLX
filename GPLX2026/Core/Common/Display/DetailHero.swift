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
                    .frame(width: 96, height: 96)
                Image(systemName: icon)
                    .font(.appSerif(size: 44))
                    .foregroundStyle(iconColor)
            }

            VStack(spacing: 6) {
                Text(title)
                    .font(.appSerif(size: 36, weight: .bold))
                    .foregroundStyle(Color.appTextDark)
                    .contentTransition(.numericText())
                    .animation(.snappy, value: title)
                Text(subtitle)
                    .font(.appSans(size: 15))
                    .foregroundStyle(Color.appTextMedium)
            }

            if let desc = description {
                Text(desc)
                    .font(.appSans(size: 14))
                    .foregroundStyle(Color.appTextLight)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
            }

            if let badge {
                StatusBadge(text: badge.text, color: badge.color, fontSize: 13)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 28)
        .glassCard()
    }
}
