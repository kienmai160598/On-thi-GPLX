import SwiftUI

struct AppButton: View {
    var icon: String? = nil
    let label: String
    var style: Style = .primary
    var height: CGFloat = 52

    @Environment(\.isEnabled) private var isEnabled
    @Environment(ThemeStore.self) private var themeStore

    private var primary: Color { themeStore.primaryColor }
    private var cornerRadius: CGFloat { height / 2 }

    enum Style {
        case primary
        case secondary
    }

    var body: some View {
        if #available(iOS 26.0, *) {
            if style == .primary {
                buttonContent
                    .foregroundStyle(isEnabled ? themeStore.onPrimaryColor : Color.appTextLight)
                    .background(
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .fill(isEnabled ? primary : Color.appDivider)
                    )
                    .glassEffect(.regular.interactive(), in: .rect(cornerRadius: cornerRadius))
            } else {
                buttonContent
                    .foregroundStyle(isEnabled ? primary : Color.appTextLight)
                    .glassEffect(.regular.interactive(), in: .rect(cornerRadius: cornerRadius))
            }
        } else if style == .primary {
            buttonContent
                .foregroundStyle(isEnabled ? themeStore.onPrimaryColor : Color.appTextLight)
                .background(isEnabled ? primary : Color.appDivider)
                .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
        } else {
            buttonContent
                .foregroundStyle(isEnabled ? primary : Color.appTextLight)
                .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
                .overlay(
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .stroke(isEnabled ? primary : Color.appDivider, lineWidth: 1.5)
                )
        }
    }

    private var buttonContent: some View {
        HStack(spacing: 6) {
            if let icon {
                Image(systemName: icon)
                    .font(.appSans(size: 14, weight: .semibold))
            }
            Text(label)
                .font(.appSans(size: 15, weight: .bold))
        }
        .frame(maxWidth: .infinity)
        .frame(height: height)
        .contentShape(Rectangle())
    }
}
