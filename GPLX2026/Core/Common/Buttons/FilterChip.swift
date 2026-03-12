import SwiftUI

struct FilterChip: View {
    @Environment(ThemeStore.self) private var themeStore
    let label: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            chipContent
        }
        .buttonStyle(.plain)
    }

    private var chipText: some View {
        Text(label)
            .font(.appSans(size: 13, weight: isSelected ? .bold : .medium))
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
    }

    @ViewBuilder
    private var chipContent: some View {
        if #available(iOS 26.0, *) {
            chipText
                .foregroundStyle(isSelected ? themeStore.primaryColor : Color.appTextMedium)
                .glassEffect(.regular.interactive(), in: .capsule)
        } else {
            chipText
                .foregroundStyle(isSelected ? themeStore.onPrimaryColor : Color.appTextMedium)
                .background(isSelected ? themeStore.primaryColor : Color.appDivider)
                .clipShape(Capsule())
        }
    }
}
