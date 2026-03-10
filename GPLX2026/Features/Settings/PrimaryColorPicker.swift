import SwiftUI

// MARK: - Primary Color Picker

struct PrimaryColorPicker: View {
    @Binding var selected: String

    static let colors: [(key: String, color: Color, label: String)] = [
        ("default", .adaptive(light: 0x27272A, dark: 0xE4E4E7), "Than chì"),
        ("blue", Color(hex: 0x007AFF), "Xanh dương"),
        ("indigo", Color(hex: 0x5856D6), "Chàm"),
    ]

    var body: some View {
        HStack(spacing: 12) {
            ForEach(Self.colors, id: \.key) { item in
                let isSelected = selected == item.key

                Button {
                    Haptics.selection()
                    withAnimation(.easeOut(duration: 0.2)) {
                        selected = item.key
                    }
                } label: {
                    VStack(spacing: 6) {
                        swatch(item: item, isSelected: isSelected)
                            .frame(height: 48)

                        Text(item.label)
                            .font(.system(size: 11, weight: isSelected ? .bold : .medium))
                            .foregroundStyle(isSelected ? Color.appTextDark : Color.appTextLight)
                    }
                    .frame(maxWidth: .infinity)
                }
                .accessibilityLabel(item.label)
                .accessibilityAddTraits(isSelected ? .isSelected : [])
            }
        }
    }

    @ViewBuilder
    private func swatch(item: (key: String, color: Color, label: String), isSelected: Bool) -> some View {
        let shape = RoundedRectangle(cornerRadius: 12, style: .continuous)

        if #available(iOS 26.0, *) {
            shape
                .fill(item.color)
                .overlay {
                    if isSelected {
                        shape.strokeBorder(.white, lineWidth: 2.5)
                    }
                }
                .glassEffect(.regular.interactive(), in: .rect(cornerRadius: 12))
        } else {
            shape
                .fill(item.color)
                .overlay {
                    if isSelected {
                        shape
                            .strokeBorder(.white, lineWidth: 2.5)
                            .shadow(color: item.color.opacity(0.5), radius: 6)
                    }
                }
        }
    }
}
