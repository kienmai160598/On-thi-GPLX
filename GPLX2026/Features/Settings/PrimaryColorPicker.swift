import SwiftUI

// MARK: - Primary Color Picker

struct PrimaryColorPicker: View {
    @Binding var selected: String

    static let colors: [(key: String, color: Color, label: String)] = [
        ("default", .adaptive(light: 0x171717, dark: 0xFAFAFA), "Mặc định"),
        ("blue", Color(hex: 0x007AFF), "Xanh dương"),
        ("cyan", Color(hex: 0x00BCD4), "Xanh lam"),
        ("mint", Color(hex: 0x64FFDA), "Bạc hà"),
        ("teal", Color(hex: 0x2DD4BF), "Ngọc"),
        ("violet", Color(hex: 0x7C4DFF), "Tím"),
        ("purple", Color(hex: 0xAA00FF), "Tím đậm"),
        ("indigo", Color(hex: 0x5856D6), "Chàm"),
        ("rose", Color(hex: 0xF43F5E), "Hồng"),
        ("chartreuse", Color(hex: 0xA3E635), "Chanh"),
    ]

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 12), count: 5)

    var body: some View {
        LazyVGrid(columns: columns, spacing: 12) {
            ForEach(Self.colors, id: \.key) { item in
                let isSelected = selected == item.key

                Button {
                    Haptics.selection()
                    withAnimation(.easeOut(duration: 0.2)) {
                        selected = item.key
                    }
                } label: {
                    VStack(spacing: 6) {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(item.color)
                            .frame(height: 40)
                            .overlay {
                                if item.key == "default" {
                                    // Split circle to show it's adaptive
                                    HStack(spacing: 0) {
                                        Color(hex: 0x171717).frame(maxWidth: .infinity)
                                        Color(hex: 0xFAFAFA).frame(maxWidth: .infinity)
                                    }
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                                    .padding(4)
                                }
                            }
                            .overlay {
                                if isSelected {
                                    RoundedRectangle(cornerRadius: 10)
                                        .strokeBorder(.white, lineWidth: 2.5)
                                        .shadow(color: item.color.opacity(0.5), radius: 6)
                                }
                            }

                        Text(item.label)
                            .font(.system(size: 10, weight: isSelected ? .bold : .medium))
                            .foregroundStyle(isSelected ? Color.appTextDark : Color.appTextLight)
                            .lineLimit(1)
                    }
                }
                .accessibilityLabel(item.label)
                .accessibilityAddTraits(isSelected ? .isSelected : [])
            }
        }
    }
}
