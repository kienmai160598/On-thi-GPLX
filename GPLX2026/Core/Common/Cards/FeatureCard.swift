import SwiftUI

/// The design's dark "signature" feature card: a featured / recommended action
/// on a near-black card accented by the configured theme color — used for hero
/// CTAs (sample exam, focus situation, recommended topic). This is the one card
/// allowed a soft shadow; ordinary cards stay flat (see `GlassCard`).
struct FeatureCard: View {
    @Environment(ThemeStore.self) private var themeStore
    let eyebrow: String
    let title: String
    var tags: [String] = []
    /// Render the last tag as a solid accent pill (the design's highlighted pill).
    var highlightLastTag: Bool = true
    var icon: String = "play.fill"
    var accessibilityLabel: String? = nil
    let action: () -> Void

    private let cardInk = Color(hex: 0x0F0F12)

    var body: some View {
        HStack(alignment: .center, spacing: 14) {
            VStack(alignment: .leading, spacing: 12) {
                Text(eyebrow.uppercased())
                    .font(.appSans(size: 10, weight: .heavy))
                    .tracking(1.2)
                    .foregroundStyle(themeStore.primaryColor)

                Text(title)
                    .font(.appSerif(size: 20, weight: .bold))
                    .foregroundStyle(.white)
                    .fixedSize(horizontal: false, vertical: true)

                if !tags.isEmpty {
                    HStack(spacing: 6) {
                        ForEach(Array(tags.enumerated()), id: \.offset) { index, tag in
                            let highlighted = highlightLastTag && index == tags.count - 1
                            Text(tag)
                                .font(.appSans(size: 11, weight: .semibold))
                                .foregroundStyle(highlighted ? themeStore.onPrimaryColor : .white)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(
                                    highlighted ? themeStore.primaryColor : Color.white.opacity(0.12),
                                    in: Capsule()
                                )
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Button(action: action) {
                Image(systemName: icon)
                    .font(.appSans(size: 20, weight: .bold))
                    .foregroundStyle(themeStore.primaryColor)
                    .frame(width: 52, height: 52)
                    .background(Color.white.opacity(0.14), in: Circle())
                    .contentShape(Circle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel(accessibilityLabel ?? title)
        }
        .padding(12)
        .background(cardInk, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
        .shadow(color: cardInk.opacity(0.22), radius: 16, x: 0, y: 8)
    }
}
