import SwiftUI

struct MiniMetricCard: View {
    let fraction: Double
    let stats: [(value: String, label: String)]
    var color: Color = .appPrimary

    var body: some View {
        HStack(spacing: 14) {
            TopicProgressRing(fraction: fraction, color: color, size: 64)

            VStack(alignment: .leading, spacing: 8) {
                ForEach(Array(stats.enumerated()), id: \.offset) { _, stat in
                    HStack {
                        Text(stat.label)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(Color.appTextMedium)
                        Spacer()
                        Text(stat.value)
                            .font(.system(size: 16, weight: .bold).monospacedDigit())
                            .foregroundStyle(Color.appTextDark)
                            .contentTransition(.numericText())
                    }
                }
            }
            .frame(maxWidth: .infinity)
        }
        .padding(12)
        .glassCard()
    }
}
