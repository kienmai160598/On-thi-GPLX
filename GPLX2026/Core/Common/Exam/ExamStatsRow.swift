import SwiftUI

struct ExamStatsRow: View {
    let items: [(value: String, label: String)]

    var body: some View {
        HStack(spacing: 0) {
            ForEach(Array(items.enumerated()), id: \.offset) { index, item in
                if index > 0 {
                    Rectangle()
                        .fill(Color.appDivider)
                        .frame(width: 1, height: 32)
                }
                StatItem(value: item.value, label: item.label)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 12)
        .glassCard()
    }
}
