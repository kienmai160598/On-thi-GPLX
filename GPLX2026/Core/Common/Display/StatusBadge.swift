import SwiftUI

struct StatusBadge: View {
    let text: String
    let color: Color
    var fontSize: CGFloat = 12
    var hPadding: CGFloat = 8
    var vPadding: CGFloat = 3
    var useRoundedRect: Bool = false
    var cornerRadius: CGFloat = 8

    var body: some View {
        Text(text)
            .font(.appSans(size: fontSize, weight: .bold))
            .foregroundStyle(color)
            .padding(.horizontal, hPadding)
            .padding(.vertical, vPadding)
            .background(color.opacity(0.12))
            .clipShape(useRoundedRect ? AnyShape(RoundedRectangle(cornerRadius: cornerRadius)) : AnyShape(Capsule()))
    }
}
