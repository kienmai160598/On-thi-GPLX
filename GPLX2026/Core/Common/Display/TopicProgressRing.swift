import SwiftUI

// MARK: - Progress Ring (large, with percentage text)

struct TopicProgressRing: View {
    let fraction: Double
    let color: Color
    var size: CGFloat = 72

    private var strokeWidth: CGFloat { max(size * 0.1, 4) }

    private var safeFraction: Double {
        guard fraction.isFinite else { return 0 }
        return min(max(fraction, 0), 1)
    }

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.appDivider, lineWidth: strokeWidth)

            Circle()
                .trim(from: 0, to: safeFraction)
                .stroke(color, style: StrokeStyle(lineWidth: strokeWidth, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(.spring(duration: 0.8, bounce: 0.15), value: fraction)

            Text("\(Int(safeFraction * 100))%")
                .font(.appSans(size: size * 0.24, weight: .heavy))
                .foregroundStyle(Color.appTextDark)
                .contentTransition(.numericText())
        }
        .frame(width: size, height: size)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(Int(safeFraction * 100))% hoàn thành")
    }
}

// MARK: - Topic Icon Ring (small, wraps an SF Symbol)

struct TopicIconRing: View {
    let icon: String
    let fraction: Double
    let color: Color

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.appDivider, lineWidth: 3)

            Circle()
                .trim(from: 0, to: fraction)
                .stroke(color, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(.snappy, value: fraction)

            Image(systemName: icon)
                .font(.appSans(size: 16))
                .foregroundStyle(color)
        }
        .frame(width: 40, height: 40)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(Int(min(max(fraction, 0), 1) * 100))% hoàn thành")
    }
}
