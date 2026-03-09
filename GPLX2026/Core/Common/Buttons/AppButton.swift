import SwiftUI

struct AppButton: View {
    var icon: String? = nil
    let label: String
    var style: Style = .primary
    var height: CGFloat = 52
    var cornerRadius: CGFloat = 26

    @Environment(\.isEnabled) private var isEnabled
    @AppStorage("appPrimaryColor") private var primaryColorKey = "default"

    private var primary: Color { Color.primaryColor(for: primaryColorKey) }

    enum Style {
        case primary
        case secondary
    }

    var body: some View {
        if #available(iOS 26.0, *) {
            buttonContent
                .foregroundStyle(isEnabled ? primary : Color.appTextLight)
                .glassEffect(.regular.interactive(), in: .rect(cornerRadius: cornerRadius))
        } else if style == .primary {
            buttonContent
                .foregroundStyle(isEnabled ? Color.appOnPrimary : Color.appTextLight)
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
                    .font(.system(size: 14, weight: .semibold))
            }
            Text(label)
                .font(.system(size: 15, weight: .bold))
        }
        .frame(maxWidth: .infinity)
        .frame(height: height)
        .contentShape(Rectangle())
    }
}
