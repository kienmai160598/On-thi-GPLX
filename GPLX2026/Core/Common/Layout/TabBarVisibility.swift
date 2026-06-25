import SwiftUI

/// Shared scroll-driven state for the collapsing iPhone tab bar. The active
/// tab's scroll view reports its offset via `.tracksTabBarCollapse()`, which
/// flips `collapsed` when the user scrolls down and back when they scroll up or
/// reach the top. The custom tab bar and the in-nav "play" buttons read it.
@Observable
@MainActor
final class TabBarVisibility {
    var collapsed = false
}

private struct TabBarCollapseTracker: ViewModifier {
    @Environment(TabBarVisibility.self) private var visibility

    func body(content: Content) -> some View {
        content.onScrollGeometryChange(for: CGFloat.self) { geo in
            geo.contentOffset.y
        } action: { _, newValue in
            // Stable offset threshold with a wide dead-zone so the in-nav play
            // button settles instead of flickering on tiny scrolls or direction
            // reversals. Collapses once the large title has scrolled away (~90pt),
            // restores near the top (<40pt); no change in between.
            let target: Bool
            if newValue > 90 {
                target = true
            } else if newValue < 40 {
                target = false
            } else {
                return
            }
            guard visibility.collapsed != target else { return }
            withAnimation(.easeInOut(duration: 0.25)) {
                visibility.collapsed = target
            }
        }
    }
}

extension View {
    /// Reports scroll offset to drive the collapsing tab bar + in-nav play button.
    func tracksTabBarCollapse() -> some View {
        modifier(TabBarCollapseTracker())
    }
}

/// A toolbar "play" button that fades in only when the tab bar is collapsed
/// (i.e. the user has scrolled the primary CTA off-screen), giving a persistent
/// quick-start affordance. Used on the Luyện tập / Thi thử / Mô phỏng tabs.
struct NavPlayButton: View {
    @Environment(TabBarVisibility.self) private var visibility
    var label: String = "Bắt đầu"
    let action: () -> Void

    var body: some View {
        // Render nothing until scrolled — so the toolbar's glass wrapper doesn't
        // show as an empty pill. When collapsed, the wrapper + icon appear together.
        if visibility.collapsed {
            Button {
                Haptics.impact(.medium)
                action()
            } label: {
                Image(systemName: "play.fill")
                    .navIconStyle()
            }
            .accessibilityLabel(label)
        }
    }
}

/// Tinted glyph styling for nav-bar toolbar icon buttons (search, settings,
/// play): the user's accent color and a 44pt HIG-minimum tap target.
private struct NavIconStyle: ViewModifier {
    @Environment(ThemeStore.self) private var themeStore
    func body(content: Content) -> some View {
        content
            .font(.appSans(size: 15, weight: .semibold))
            .foregroundStyle(themeStore.primaryColor)
            .frame(width: 44, height: 44)
            .contentShape(Rectangle())
    }
}

extension View {
    func navIconStyle() -> some View { modifier(NavIconStyle()) }
}
