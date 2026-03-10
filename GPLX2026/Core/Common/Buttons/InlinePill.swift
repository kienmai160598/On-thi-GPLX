import SwiftUI

struct InlinePill: View {
    let label: String

    init(_ label: String) {
        self.label = label
    }

    var body: some View {
        if #available(iOS 26.0, *) {
            pillText
                .foregroundStyle(Color.appPrimary)
                .glassEffect(.regular.interactive(), in: .capsule)
        } else {
            pillText
                .foregroundStyle(Color.appOnPrimary)
                .background(Color.appPrimary)
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
