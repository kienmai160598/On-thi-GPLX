import SwiftUI

/// Small capsule chip for card metadata (duration, count, category) — the
/// pill tags in the design mockup. Subtle filled style that reads on a
/// neutral card.
struct TagPill: View {
    let text: String
    var color: Color? = nil

    var body: some View {
        Text(text)
            .font(.appSans(size: 12, weight: .medium))
            .foregroundStyle(color ?? Color.appTextMedium)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background((color ?? Color.appTextMedium).opacity(0.10), in: Capsule())
            .lineLimit(1)
            .fixedSize()
    }
}
