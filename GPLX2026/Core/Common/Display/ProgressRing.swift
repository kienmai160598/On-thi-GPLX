import SwiftUI

struct ProgressRing: View {
    @Environment(ThemeStore.self) private var themeStore
    let current: Int
    let total: Int
    var size: CGFloat = 52

    private var fraction: CGFloat {
        total > 0 ? CGFloat(current) / CGFloat(total) : 0
    }

    var body: some View {
        ringContent
            .background(Color.cardBg)
            .clipShape(Circle())
    }

    private var ringContent: some View {
        ZStack {
            Circle()
                .stroke(Color.appDivider, lineWidth: 3)

            Circle()
                .trim(from: 0, to: fraction)
                .stroke(themeStore.primaryColor, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(.snappy, value: fraction)

            Text("\(current)")
                .font(.appSans(size: 14, weight: .semibold))
                .foregroundStyle(Color.appTextDark)
                .contentTransition(.numericText())
                .animation(.snappy, value: current)
        }
        .padding(6)
        .frame(width: size, height: size)
    }
}
