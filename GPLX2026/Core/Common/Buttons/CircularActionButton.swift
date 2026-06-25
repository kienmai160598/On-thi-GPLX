import SwiftUI

/// Circular action button used on item cards (matches the design mockup's play
/// button): a neutral gray wrapper with the glyph tinted by the configured
/// accent color, so the icon — not the wrapper — carries the theme.
struct CircularActionButton: View {
    @Environment(ThemeStore.self) private var themeStore

    var icon: String = "play.fill"
    var size: CGFloat = 44

    var body: some View {
        Image(systemName: icon)
            .font(.appSans(size: size * 0.34, weight: .bold))
            .foregroundStyle(themeStore.primaryColor)
            .frame(width: size, height: size)
            .background(Color.neutralWash, in: Circle())
            // Make the whole circle tappable, not just the glyph pixels.
            .contentShape(Circle())
    }
}
