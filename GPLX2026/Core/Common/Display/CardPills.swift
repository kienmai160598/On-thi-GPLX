import SwiftUI

/// Neutral count chip used on topic/chapter cards (e.g. "25 câu", "10 video").
struct CountPill: View {
    let text: String

    init(_ text: String) { self.text = text }

    var body: some View {
        Text(text)
            .font(.appSans(size: 11.5, weight: .semibold))
            .foregroundStyle(Color(hex: 0x7A7166))
            .padding(.horizontal, 9)
            .padding(.vertical, 4)
            .background(Color(hex: 0x0F0F12, opacity: 0.07), in: Capsule())
    }
}

/// Accuracy chip: accent "X% đúng" when attempted, neutral "Chưa làm" otherwise.
/// Shared by Luyện tập's topic rows and Mô phỏng's chapter cards.
struct AccuracyPill: View {
    @Environment(ThemeStore.self) private var themeStore
    /// nil = not yet attempted.
    let accuracy: Double?

    var body: some View {
        if let acc = accuracy {
            Text("\(Int(acc * 100))% đúng")
                .font(.appSans(size: 11.5, weight: .bold))
                .foregroundStyle(themeStore.primaryColor)
                .padding(.horizontal, 9)
                .padding(.vertical, 4)
                .background(themeStore.primaryColor.opacity(0.14), in: Capsule())
        } else {
            Text("Chưa làm")
                .font(.appSans(size: 12, weight: .medium))
                .foregroundStyle(Color(hex: 0x737373))
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(Color(hex: 0x737373).opacity(0.10), in: Capsule())
        }
    }
}
