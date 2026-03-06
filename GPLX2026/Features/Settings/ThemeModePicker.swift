import SwiftUI

// MARK: - Theme Mode Picker

struct ThemeModePicker: View {
    @Binding var selected: String
    var primaryColorKey: String

    private static let modes: [(key: String, label: String, icon: String)] = [
        ("system", "Hệ thống", "circle.lefthalf.filled"),
        ("light", "Sáng", "sun.max.fill"),
        ("dark", "Tối", "moon.fill"),
    ]

    private var accentColor: Color { Color.primaryColor(for: primaryColorKey) }

    var body: some View {
        HStack(spacing: 10) {
            ForEach(Self.modes, id: \.key) { mode in
                let isSelected = selected == mode.key

                Button {
                    Haptics.selection()
                    selected = mode.key
                } label: {
                    VStack(spacing: 8) {
                        Image(systemName: mode.icon)
                            .font(.system(size: 24))
                            .foregroundStyle(isSelected ? accentColor : Color.appTextMedium)
                        Text(mode.label)
                            .font(.system(size: 13, weight: isSelected ? .bold : .medium))
                            .foregroundStyle(isSelected ? accentColor : Color.appTextMedium)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
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
