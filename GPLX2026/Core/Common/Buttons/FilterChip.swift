import SwiftUI

struct FilterChip: View {
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
            .font(.system(size: 13, weight: isSelected ? .bold : .medium))
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
    }

    @ViewBuilder
    private var chipContent: some View {
        if #available(iOS 26.0, *) {
            chipText
                .foregroundStyle(isSelected ? Color.appPrimary : Color.appTextMedium)
                .glassEffect(.regular.interactive(), in: .capsule)
        } else {
            chipText
                .foregroundStyle(isSelected ? Color.appOnPrimary : Color.appTextMedium)
                .background(isSelected ? Color.appPrimary : Color.appDivider)
                .clipShape(Capsule())
        }
    }
}
