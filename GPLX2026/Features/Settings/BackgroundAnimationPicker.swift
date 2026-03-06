import SwiftUI

struct BackgroundAnimationPicker: View {
    @Binding var selected: String
    @Binding var speedKey: String
    var primaryColorKey: String

    private static let styles: [(key: String, label: String, icon: String)] = [
        ("none", "Tắt", "xmark"),
        ("bubbles", "Bong bóng", "bubbles.and.sparkles"),
        ("waves", "Sóng", "water.waves"),
        ("mesh", "Lưới", "circle.grid.3x3"),
        ("aurora", "Cực quang", "aurora"),
    ]

    private static let speeds: [(key: String, label: String)] = [
        ("slow", "Chậm"),
        ("normal", "Vừa"),
        ("fast", "Nhanh"),
    ]

    private var accentColor: Color { Color.primaryColor(for: primaryColorKey) }

    var body: some View {
        VStack(spacing: 14) {
            // Style picker
            let rows = [Self.styles.prefix(3), Self.styles.suffix(2)]

            // Row 1: none, bubbles, waves
            HStack(spacing: 10) {
                ForEach(Array(rows[0]), id: \.key) { option in
                    styleButton(option)
                }
            }

            // Row 2: mesh, aurora
            HStack(spacing: 10) {
                ForEach(Array(rows[1]), id: \.key) { option in
                    styleButton(option)
                }
                // Spacer to keep same width as row 1
                Color.clear.frame(maxWidth: .infinity, maxHeight: 0)
            }

            // Speed picker (only when animation is active)
            if selected != "none" {
                VStack(spacing: 8) {
                    HStack(spacing: 6) {
                        Image(systemName: "gauge.with.dots.needle.33percent")
                            .font(.system(size: 13))
                            .foregroundStyle(Color.appTextLight)
                        Text("Tốc độ")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(Color.appTextMedium)
                        Spacer()
                    }

                    HStack(spacing: 8) {
                        ForEach(Self.speeds, id: \.key) { speed in
                            let isActive = speedKey == speed.key

                            Button {
                                Haptics.selection()
                                withAnimation(.easeOut(duration: 0.2)) {
                                    speedKey = speed.key
                                }
                            } label: {
                                Text(speed.label)
                                    .font(.system(size: 13, weight: isActive ? .bold : .medium))
                                    .foregroundStyle(isActive ? accentColor : Color.appTextMedium)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 36)
                            }
                            .glassCard()
                            .overlay {
                                if isActive {
                                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                                        .stroke(accentColor, lineWidth: 2)
                                }
                            }
                        }
                    }
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
    }

    @ViewBuilder
    private func styleButton(_ option: (key: String, label: String, icon: String)) -> some View {
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
