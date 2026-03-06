import SwiftUI

// MARK: - Primary Color Picker

struct PrimaryColorPicker: View {
    @Binding var selected: String

    static let colors: [(key: String, color: Color, label: String)] = [
        ("default", .adaptive(light: 0x171717, dark: 0xFAFAFA), "Mặc định"),
        ("blue", Color(hex: 0x007AFF), "Blue"),
        ("cyan", Color(hex: 0x00BCD4), "Cyan"),
        ("mint", Color(hex: 0x64FFDA), "Mint"),
        ("teal", Color(hex: 0x2DD4BF), "Teal"),
        ("violet", Color(hex: 0x7C4DFF), "Violet"),
        ("purple", Color(hex: 0xAA00FF), "Purple"),
        ("indigo", Color(hex: 0x5856D6), "Indigo"),
        ("rose", Color(hex: 0xF43F5E), "Rose"),
        ("chartreuse", Color(hex: 0xA3E635), "Lime"),
    ]

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 12), count: 5)

    var body: some View {
        LazyVGrid(columns: columns, spacing: 12) {
            ForEach(Self.colors, id: \.key) { item in
                Button {
                    Haptics.selection()
                    withAnimation(.easeOut(duration: 0.2)) {
                        selected = item.key
                    }
                } label: {
                    colorSwatch(item: item)
                }
            }
        }
    }

    @ViewBuilder
    private func colorSwatch(item: (key: String, color: Color, label: String)) -> some View {
        let isSelected = selected == item.key

        if #available(iOS 26.0, *) {
            RoundedRectangle(cornerRadius: 12)
                .fill(item.color)
                .frame(height: 48)
                .glassEffect(.regular.interactive(), in: .rect(cornerRadius: 12))
                .overlay {
                    if isSelected {
                        sunshineOverlay(color: item.color)
                    }
                }
        } else {
            RoundedRectangle(cornerRadius: 12)
                .fill(item.color)
                .frame(height: 48)
                .overlay {
                    if isSelected {
                        sunshineOverlay(color: item.color)
                    }
                }
        }
    }

    @ViewBuilder
    private func sunshineOverlay(color: Color) -> some View {
        RoundedRectangle(cornerRadius: 12)
            .strokeBorder(color, lineWidth: 3)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(color.opacity(0.15))
            )
            .shadow(color: color.opacity(0.6), radius: 8, x: 0, y: 0)
            .shadow(color: color.opacity(0.3), radius: 16, x: 0, y: 0)
    }
}

// MARK: - Hex Color Helper

private extension Color {
    init(hex: UInt32) {
        self.init(
            red: Double((hex >> 16) & 0xFF) / 255.0,
            green: Double((hex >> 8) & 0xFF) / 255.0,
            blue: Double(hex & 0xFF) / 255.0
        )
    }
}
