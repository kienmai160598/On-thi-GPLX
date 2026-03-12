import SwiftUI

struct SplitContent<Leading: View, Trailing: View>: View {
    @Environment(LayoutMetrics.self) private var metrics

    var leadingRatio: CGFloat = 0.55
    @ViewBuilder var leading: () -> Leading
    @ViewBuilder var trailing: () -> Trailing

    var body: some View {
        if metrics.isWide {
            GeometryReader { geo in
                HStack(alignment: .top, spacing: metrics.gridSpacing) {
                    ScrollView {
                        leading()
                            .frame(maxWidth: .infinity)
                    }
                    .frame(width: geo.size.width * leadingRatio)

                    ScrollView {
                        trailing()
                            .frame(maxWidth: .infinity)
                    }
                }
                .padding(.horizontal, metrics.contentPadding)
            }
        } else {
            VStack(alignment: .leading, spacing: 0) {
                leading()
                trailing()
            }
        }
    }
}
