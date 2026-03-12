import SwiftUI

struct IconBox: View {
    let icon: String
    let color: Color
    var size: CGFloat = 40
    var cornerRadius: CGFloat = 8
    var iconFontSize: CGFloat = 18
    var iconWeight: Font.Weight = .regular

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(color.opacity(0.12))
                .frame(width: size, height: size)
            Image(systemName: icon)
                .font(.appSans(size: iconFontSize, weight: iconWeight))
                .foregroundStyle(color)
                .symbolRenderingMode(.hierarchical)
        }
    }
}
