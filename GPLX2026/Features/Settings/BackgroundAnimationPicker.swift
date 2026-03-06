import SwiftUI

struct BackgroundAnimationPicker: View {
    @Binding var selected: String
    var primaryColorKey: String

    private static let options: [(key: String, label: String, icon: String)] = [
        ("none", "Tắt", "xmark"),
        ("bubbles", "Bong bóng", "bubbles.and.sparkles"),
        ("waves", "Sóng", "water.waves"),
        ("mesh", "Lưới", "circle.grid.3x3"),
    ]

    private var accentColor: Color { Color.primaryColor(for: primaryColorKey) }

    var body: some View {
        HStack(spacing: 10) {
            ForEach(Self.options, id: \.key) { option in
                let isSelected = selected == option.key

                Button {
                    Haptics.selection()
                    withAnimation(.easeOut(duration: 0.2)) {
                        selected = option.key
                    }
                } label: {
                    VStack(spacing: 8) {
                        Image(systemName: option.icon)
                            .font(.system(size: 22))
                            .foregroundStyle(isSelected ? accentColor : Color.appTextMedium)
                        Text(option.label)
                            .font(.system(size: 12, weight: isSelected ? .bold : .medium))
                            .foregroundStyle(isSelected ? accentColor : Color.appTextMedium)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                }
                .glassCard()
                .overlay {
                    if isSelected {
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(accentColor, lineWidth: 2)
                    }
                }
            }
        }
    }
}
