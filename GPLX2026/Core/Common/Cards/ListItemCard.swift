import SwiftUI

struct ListItemCard<Trailing: View>: View {
    @AppStorage("appPrimaryColor") private var primaryColorKey = "default"
    let icon: String
    let title: String
    var subtitle: String? = nil
    var iconSize: CGFloat = 36
    var iconCornerRadius: CGFloat = 9
    var iconFontSize: CGFloat = 16
    var iconColor: Color? = nil
    var showCard: Bool = true
    @ViewBuilder var trailing: () -> Trailing

    private var cardContent: some View {
        HStack(spacing: 12) {
            IconBox(icon: icon, color: iconColor ?? Color.primaryColor(for: primaryColorKey), size: iconSize, cornerRadius: iconCornerRadius, iconFontSize: iconFontSize)

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(Color.appTextDark)
                    .lineLimit(1)

                if let subtitle {
                    Text(subtitle)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(Color.appTextMedium)
                        .lineLimit(1)
                }
            }

            Spacer()

            trailing()
        }
        .padding(.horizontal, 14)
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
    init(icon: String, title: String, subtitle: String? = nil, iconSize: CGFloat = 36, iconCornerRadius: CGFloat = 9, iconFontSize: CGFloat = 16, iconColor: Color? = nil, showCard: Bool = true) {
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
