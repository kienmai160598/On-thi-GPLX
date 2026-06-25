import SwiftUI

/// A circular icon button. It owns its `action` (the Apple-HIG pattern: the
/// button, not a wrapper, performs the tap) — do **not** nest it inside another
/// `Button`/`NavigationLink`. For push navigation, pass a closure that flips a
/// `@State` flag and drive a `.navigationDestination` at the call site.
///
/// The hit area is the full circle (`.contentShape(Circle())`) so tapping
/// anywhere on the visible circle triggers the action, not just the glyph.
struct AppIconButton: View {
    @Environment(ThemeStore.self) private var themeStore
    let icon: String
    var size: CGFloat = 44
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.appSans(size: 16, weight: .semibold))
                .foregroundStyle(themeStore.primaryColor)
                .frame(width: size, height: size)
                .contentShape(Circle())
        }
        .buttonStyle(.plain)
        .modifier(AppIconButtonChrome())
    }
}

/// The circular background/border chrome, split out so the iOS-26 Liquid Glass
/// path and the fallback path share the same call site.
private struct AppIconButtonChrome: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 26.0, *) {
            content.glassEffect(.regular.interactive(), in: .circle)
        } else {
            content
                .background(Color.cardBg, in: Circle())
                .overlay(Circle().strokeBorder(Color.appDivider, lineWidth: 0.5))
        }
    }
}
