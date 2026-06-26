import SwiftUI

extension View {
    /// Pill / segmented-control *track* background: Liquid Glass on iOS 26+,
    /// falling back to a translucent ink fill on earlier systems. Used by the
    /// settings appearance controls and other capsule-shaped containers.
    @ViewBuilder
    func glassCapsuleTrack() -> some View {
        if #available(iOS 26.0, *) {
            self.glassEffect(.regular, in: Capsule())
        } else {
            self.background(Color(hex: 0x0F0F12, opacity: 0.06), in: Capsule())
        }
    }

    /// Prominent CTA fill — Liquid Glass tinted with `color` on iOS 26+, a solid
    /// `color` fill on earlier systems.
    @ViewBuilder
    func glassFill(_ color: Color, cornerRadius: CGFloat) -> some View {
        if #available(iOS 26.0, *) {
            self.glassEffect(.regular.interactive().tint(color), in: .rect(cornerRadius: cornerRadius))
        } else {
            self.background(color, in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
        }
    }
}
