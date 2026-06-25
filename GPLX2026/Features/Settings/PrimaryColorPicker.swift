import SwiftUI

// MARK: - Primary Color Picker

/// Inline accent-color swatches (design "Màu nhấn" row): four colored circles in
/// a pill; the selected one carries a white ring. Bound to `ThemeStore.accentKey`.
struct PrimaryColorPicker: View {
    @Binding var selected: String

    static let colors: [(key: String, color: Color, label: String)] = [
        ("default", Color(hex: 0xD4714E), "Cam đất"),
        ("yellow",  Color(hex: 0xFFC233), "Vàng"),
        ("green",   Color(hex: 0x43A047), "Xanh lá"),
        ("blue",    Color(hex: 0x3D7BE0), "Xanh dương"),
    ]

    var body: some View {
        HStack(spacing: 8) {
            ForEach(Self.colors, id: \.key) { item in
                let isSelected = selected == item.key
                Button {
                    Haptics.selection()
                    withAnimation(.easeOut(duration: 0.2)) { selected = item.key }
                } label: {
                    Circle()
                        .fill(item.color)
                        .frame(width: 24, height: 24)
                        .overlay(Circle().strokeBorder(Color.white, lineWidth: isSelected ? 2 : 0))
                        .overlay(Circle().strokeBorder(Color.black.opacity(0.10), lineWidth: 0.5))
                        .shadow(color: isSelected ? item.color.opacity(0.5) : .clear, radius: 3)
                }
                .buttonStyle(.plain)
                .accessibilityLabel(item.label)
                .accessibilityAddTraits(isSelected ? .isSelected : [])
            }
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 8)
        .background(Color(hex: 0x0F0F12, opacity: 0.06), in: Capsule())
    }
}
