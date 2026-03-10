import SwiftUI

struct InlinePill: View {
    @Environment(ThemeStore.self) private var themeStore
    let label: String

    init(_ label: String) {
        self.label = label
    }

    var body: some View {
        if #available(iOS 26.0, *) {
            pillText
                .foregroundStyle(themeStore.primaryColor)
                .glassEffect(.regular.interactive(), in: .capsule)
        } else {
            pillText
                .foregroundStyle(themeStore.onPrimaryColor)
                .background(themeStore.primaryColor)
                .clipShape(Capsule())
        }
    }

    private var pillText: some View {
        Text(label)
            .font(.system(size: 13, weight: .bold))
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
    }
}
