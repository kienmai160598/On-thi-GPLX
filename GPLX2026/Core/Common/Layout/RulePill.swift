import SwiftUI

struct RulePill: View {
    @Environment(ThemeStore.self) private var themeStore
    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: 5) {
            Image(systemName: icon)
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(themeStore.primaryColor)
                .symbolRenderingMode(.hierarchical)
            Text(text)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(Color.appTextDark)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(themeStore.primaryColor.opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}
