import SwiftUI

struct ListItemCard<Trailing: View>: View {
    @Environment(ThemeStore.self) private var themeStore
    let icon: String
    let title: String
    var subtitle: String? = nil
    var iconSize: CGFloat = 36
    var iconCornerRadius: CGFloat = 8
    var iconFontSize: CGFloat = 16
    var iconColor: Color? = nil
    var showCard: Bool = true
    @ViewBuilder var trailing: () -> Trailing

    private var cardContent: some View {
        HStack(spacing: 12) {
            IconBox(icon: icon, color: iconColor ?? themeStore.primaryColor, size: iconSize, cornerRadius: iconCornerRadius, iconFontSize: iconFontSize)

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.appSans(size: 15, weight: .bold))
                    .foregroundStyle(Color.appTextDark)
                    .lineLimit(1)

                if let subtitle {
                    Text(subtitle)
                        .font(.appSans(size: 13, weight: .medium))
                        .foregroundStyle(Color.appTextMedium)
                        .lineLimit(1)
                }
            }

            Spacer()

            trailing()
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 12)
    }

    var body: some View {
        if showCard {
            cardContent.glassCard()
        } else {
            cardContent
        }
    }
}

extension ListItemCard where Trailing == EmptyView {
    init(icon: String, title: String, subtitle: String? = nil, iconSize: CGFloat = 36, iconCornerRadius: CGFloat = 8, iconFontSize: CGFloat = 16, iconColor: Color? = nil, showCard: Bool = true) {
        self.icon = icon
        self.title = title
        self.subtitle = subtitle
        self.iconSize = iconSize
        self.iconCornerRadius = iconCornerRadius
        self.iconFontSize = iconFontSize
        self.iconColor = iconColor
        self.showCard = showCard
        self.trailing = { EmptyView() }
    }
}
