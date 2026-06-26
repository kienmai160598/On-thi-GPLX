import SwiftUI

/// Horizontal pill filter bar — a row of selectable pills with a near-black
/// (`#0F0F12`) selected fill and a light `cardBg` unselected fill. Replaces the
/// per-screen inline filter bars that were copy-pasted across the Home tabs
/// (`PracticeTypeFilterBar`, `MasteryFilterBar`, `ChapterFilterBar`, the exam
/// `filterBar`).
///
/// Generic over any `Hashable` item; pass a `label` projection (e.g. `\.label`
/// or `\.rawValue`). `onSelect` runs after the selection changes for any extra
/// side effects (resetting paging, etc.).
struct PillFilterBar<Item: Hashable>: View {
    enum Style: Equatable {
        /// Capsule pill, 12.5pt, dark unselected text — top-level filters.
        case primary
        /// Rounded-rect (14) pill, 12pt, muted unselected text — sub-filters.
        case compact
    }

    let items: [Item]
    let label: (Item) -> String
    @Binding var selection: Item
    var style: Style = .primary
    /// When false, lays out in a fixed `HStack` with a trailing `Spacer`
    /// instead of a horizontal `ScrollView`.
    var scrollable: Bool = true
    var onSelect: ((Item) -> Void)? = nil

    var body: some View {
        if scrollable {
            ScrollView(.horizontal, showsIndicators: false) { row }
        } else {
            row
        }
    }

    private var row: some View {
        HStack(spacing: 8) {
            ForEach(items, id: \.self) { pill($0) }
            if !scrollable { Spacer(minLength: 0) }
        }
    }

    private func pill(_ item: Item) -> some View {
        let isSelected = item == selection
        return Button {
            Haptics.impact(.light)
            withAnimation(.easeOut(duration: 0.2)) { selection = item }
            onSelect?(item)
        } label: {
            pillLabel(item, isSelected: isSelected)
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private func pillLabel(_ item: Item, isSelected: Bool) -> some View {
        let labelText = Text(label(item))
            .font(.appSans(size: fontSize, weight: isSelected ? .bold : unselectedWeight))
            .foregroundStyle(isSelected ? Color.white : unselectedText)
            .padding(.horizontal, hPad)
            .padding(.vertical, vPad)
        // Liquid Glass pills on iOS 26+; the selected pill tints the glass near-
        // black. Earlier systems keep the original solid fills.
        if #available(iOS 26.0, *) {
            if isSelected {
                labelText.glassEffect(.regular.interactive().tint(Color(hex: 0x0F0F12)), in: shape)
            } else {
                labelText.glassEffect(.regular.interactive(), in: shape)
            }
        } else {
            labelText
                .background(isSelected ? Color(hex: 0x0F0F12) : Color.cardBg, in: shape)
                .overlay(
                    shape.stroke(
                        isSelected ? Color.clear : Color(hex: 0x0F0F12).opacity(0.08),
                        lineWidth: 1
                    )
                )
        }
    }

    // MARK: - Style tokens

    private var shape: AnyShape {
        switch style {
        case .primary: AnyShape(Capsule())
        case .compact: AnyShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        }
    }
    private var fontSize: CGFloat { style == .primary ? 12.5 : 12 }
    private var unselectedWeight: Font.Weight { style == .primary ? .bold : .semibold }
    private var unselectedText: Color { style == .primary ? Color.appTextDark : Color(hex: 0x7A7166) }
    private var hPad: CGFloat { style == .primary ? 14 : 12 }
    private var vPad: CGFloat { style == .primary ? 7 : 6 }
}
