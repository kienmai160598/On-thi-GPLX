import SwiftUI

struct ResultHero: View {
    let isPassed: Bool
    let score: Int
    let total: Int
    let subtitle: String

    @State private var animateRing = false

    private var statusColor: Color { isPassed ? .appSuccess : .appError }
    private var fraction: Double { total > 0 ? Double(score) / Double(total) : 0 }

    var body: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .stroke(Color.appDivider, lineWidth: 10)

                Circle()
                    .trim(from: 0, to: animateRing ? fraction : 0)
                    .stroke(statusColor, style: StrokeStyle(lineWidth: 10, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .animation(.spring(duration: 1.0, bounce: 0.15), value: animateRing)

                VStack(spacing: 2) {
                    Text("\(score)")
                        .font(.appSerif(size: 44, weight: .bold))
                        .foregroundStyle(Color.appTextDark)
                        .contentTransition(.numericText())
                    Text("/\(total) c\u{00E2}u")
                        .font(.appSans(size: 14))
                        .foregroundStyle(Color.appTextMedium)
                }
            }
            .frame(width: 140, height: 140)

            StatusBadge(
                text: isPassed ? "\u{0110}\u{1EA0}T" : "TR\u{01AF}\u{1EE2}T",
                color: statusColor,
                fontSize: 16
            )

            Text(subtitle)
                .font(.appSans(size: 15))
                .foregroundStyle(Color.appTextMedium)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 28)
        .glassCard()
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                animateRing = true
            }
        }
    }
}
