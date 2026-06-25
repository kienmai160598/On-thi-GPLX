import SwiftUI

/// Filled circular action button used on item cards (matches the design
/// mockup's play button). The accent-filled circle is the card's only color;
/// cards themselves stay neutral/flat.
struct CircularActionButton: View {
    @Environment(ThemeStore.self) private var themeStore

    var icon: String = "play.fill"
    var size: CGFloat = 44
    /// When true, renders an accent-tinted circle with the accent icon (used
    /// for a "done"/secondary state); otherwise a solid accent fill.
    var subtle: Bool = false

    var body: some View {
        Image(systemName: icon)
            .font(.appSans(size: size * 0.34, weight: .bold))
            .foregroundStyle(subtle ? themeStore.primaryColor : themeStore.onPrimaryColor)
            .frame(width: size, height: size)
            .background(
                subtle ? themeStore.primaryColor.opacity(0.14) : themeStore.primaryColor,
                in: Circle()
            )
            // Make the whole circle tappable, not just the glyph pixels.
            .contentShape(Circle())
    }
}
