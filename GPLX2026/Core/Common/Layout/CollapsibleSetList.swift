import SwiftUI

/// A collapsible "fixed exam sets" list — a glass card whose header toggles a
/// divider-separated list of `Đề 1…N` rows, each opening a fixed set. Used by
/// Luyện tập for the Sa hình and Tình huống practice sets.
struct CollapsibleSetList: View {
    let title: String
    @Binding var isExpanded: Bool
    let totalSets: Int
    let completedSets: Set<Int>
    /// Optional per-row trailing tag pill (e.g. "TH 1-10").
    var tag: ((Int) -> String)? = nil
    /// When true, renders on a flat card background so it can nest inside
    /// another card instead of carrying its own glass card.
    var nested: Bool = false
    let onSelect: (Int) -> Void

    @Environment(ThemeStore.self) private var themeStore

    var body: some View {
        if totalSets > 0 {
            if nested {
                cardStack
                    .background(Color.adaptive(light: 0xFFF7E8, dark: 0x33302A), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .strokeBorder(Color.adaptive(light: 0xFFE9B0, dark: 0x46402F), lineWidth: 1)
                    )
            } else {
                cardStack
                    .glassCard()
            }
        }
    }

    private var cardStack: some View {
        VStack(spacing: 0) {
            header
            if isExpanded {
                Divider().padding(.horizontal, 12)
                ForEach(1...totalSets, id: \.self) { setId in
                    row(setId)
                    if setId < totalSets {
                        Divider().padding(.horizontal, 12)
                    }
                }
            }
        }
    }

    private var header: some View {
        Button {
            withAnimation(.easeOut(duration: 0.25)) { isExpanded.toggle() }
        } label: {
            HStack(spacing: 8) {
                Text(title)
                    .font(.appSans(size: 14, weight: .semibold))
                    .foregroundStyle(Color.appTextDark)

                if !completedSets.isEmpty {
                    Text("\(completedSets.count)/\(totalSets)")
                        .font(.appSans(size: 12, weight: .medium))
                        .foregroundStyle(themeStore.primaryColor)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(themeStore.primaryColor.opacity(0.1))
                        .clipShape(Capsule())
                }

                Spacer()

                Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                    .font(.appSans(size: 12, weight: .medium))
                    .foregroundStyle(Color.appTextLight)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 12)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    private func row(_ setId: Int) -> some View {
        let isCompleted = completedSets.contains(setId)
        return Button { onSelect(setId) } label: {
            HStack(spacing: 10) {
                Text("Đề \(setId)")
                    .font(.appSans(size: 15, weight: .semibold))
                    .foregroundStyle(Color.appTextDark)

                if let tag {
                    TagPill(text: tag(setId))
                }

                Spacer()

                CircularActionButton(
                    icon: isCompleted ? "checkmark" : "play.fill",
                    size: 34
                )
            }
            .padding(.horizontal, 12)
            .frame(height: 56)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}
