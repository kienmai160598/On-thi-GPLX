import SwiftUI

struct NumberBadge: View {
    let number: Int
    let color: Color
    var size: CGFloat = 28
    var fontSize: CGFloat = 12
    var cornerRadius: CGFloat = 8
    var isCircle: Bool = false

    var body: some View {
        Text("\(number)")
            .font(.appMono(size: fontSize, weight: .bold))
            .foregroundStyle(color)
            .frame(width: size, height: size)
            .background(color.opacity(0.1))
            .clipShape(isCircle ? AnyShape(Circle()) : AnyShape(RoundedRectangle(cornerRadius: cornerRadius)))
    }
}
