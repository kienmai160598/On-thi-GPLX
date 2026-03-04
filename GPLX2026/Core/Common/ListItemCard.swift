import SwiftUI

struct ListItemCard<Trailing: View>: View {
    @AppStorage("appPrimaryColor") private var primaryColorKey = "default"
    let icon: String
    let title: String
    var subtitle: String? = nil
    var iconSize: CGFloat = 36
    var iconCornerRadius: CGFloat = 9
    var iconFontSize: CGFloat = 16
    @ViewBuilder var trailing: () -> Trailing

    var body: some View {
        HStack(spacing: 12) {
            IconBox(icon: icon, color: Color.primaryColor(for: primaryColorKey), size: iconSize, cornerRadius: iconCornerRadius, iconFontSize: iconFontSize)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(Color.appTextDark)
                    .lineLimit(1)

                if let subtitle {
                    Text(subtitle)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(Color.appTextMedium)
                        .lineLimit(1)
                }
            }

            Spacer()

            trailing()
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .glassCard()
    }
}

extension ListItemCard where Trailing == EmptyView {
    init(icon: String, title: String, subtitle: String? = nil, iconSize: CGFloat = 36, iconCornerRadius: CGFloat = 9, iconFontSize: CGFloat = 16) {
        self.icon = icon
        self.title = title
        self.subtitle = subtitle
        self.iconSize = iconSize
        self.iconCornerRadius = iconCornerRadius
        self.iconFontSize = iconFontSize
        self.trailing = { EmptyView() }
    }
}
