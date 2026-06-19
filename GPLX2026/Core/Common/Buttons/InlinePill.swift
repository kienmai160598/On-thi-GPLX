import SwiftUI

struct InlinePill: View {
    @Environment(ThemeStore.self) private var themeStore
    let label: String

    init(_ label: String) {
        self.label = label
    }

    var body: some View {
        pillText
            .foregroundStyle(themeStore.onPrimaryColor)
            .background(themeStore.primaryColor)
            .clipShape(Capsule())
    }

    private var pillText: some View {
        Text(label)
            .font(.appSans(size: 13, weight: .medium))
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
    }
}
