import SwiftUI

struct BackgroundAnimationPicker: View {
    @Binding var selected: String
    @Binding var speedKey: String
    private static let styles: [(key: String, label: String, icon: String)] = [
        ("none", "Tắt", "xmark"),
        ("bubbles", "Bong bóng", "bubbles.and.sparkles"),
        ("waves", "Sóng", "water.waves"),
    ]

    private static let speeds: [(key: String, label: String)] = [
        ("slow", "Chậm"),
        ("normal", "Vừa"),
        ("fast", "Nhanh"),
    ]

    private var accentColor: Color { .appPrimary }
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 12), count: 3)

    var body: some View {
        VStack(spacing: 12) {
            // Style picker — uniform 5-column grid
            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(Self.styles, id: \.key) { option in
                    let isSelected = selected == option.key

                    Button {
                        Haptics.selection()
                        withAnimation(.easeOut(duration: 0.2)) {
                            selected = option.key
                        }
                    } label: {
                        VStack(spacing: 6) {
                            Image(systemName: option.icon)
                                .font(.appSans(size: 20))
                                .foregroundStyle(isSelected ? accentColor : Color.appTextMedium)
                            Text(option.label)
                                .font(.appSans(size: 10, weight: isSelected ? .bold : .medium))
                                .foregroundStyle(isSelected ? accentColor : Color.appTextMedium)
                                .lineLimit(1)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                    }
                    .glassCard()
                    .overlay {
                        if isSelected {
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .stroke(accentColor, lineWidth: 2)
                        }
                    }
                    .accessibilityLabel(option.label)
                    .accessibilityAddTraits(isSelected ? .isSelected : [])
                }
            }

            // Speed picker (only when animation is active)
            if selected != "none" {
                HStack(spacing: 8) {
                    Image(systemName: "gauge.with.dots.needle.33percent")
                        .font(.appSans(size: 13))
                        .foregroundStyle(Color.appTextLight)

                    ForEach(Self.speeds, id: \.key) { speed in
                        let isActive = speedKey == speed.key

                        Button {
                            Haptics.selection()
                            withAnimation(.easeOut(duration: 0.2)) {
                                speedKey = speed.key
                            }
                        } label: {
                            Text(speed.label)
                                .font(.appSans(size: 12, weight: isActive ? .bold : .medium))
                                .foregroundStyle(isActive ? accentColor : Color.appTextMedium)
                                .frame(maxWidth: .infinity)
                                .frame(height: 32)
                        }
                        .glassCard()
                        .overlay {
                            if isActive {
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .stroke(accentColor, lineWidth: 2)
                            }
                        }
                        .accessibilityLabel("Tốc độ: \(speed.label)")
                        .accessibilityAddTraits(isActive ? .isSelected : [])
                    }
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
    }
}
