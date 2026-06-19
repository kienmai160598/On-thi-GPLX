import SwiftUI

struct AdaptiveGrid<Content: View>: View {
    @Environment(LayoutMetrics.self) private var metrics

    var spacing: CGFloat?
    @ViewBuilder var content: () -> Content

    var body: some View {
        if metrics.isIPadLayout {
            LazyVGrid(
                columns: Array(
                    repeating: GridItem(.flexible(), spacing: metrics.gridSpacing),
                    count: metrics.columns
                ),
                spacing: spacing ?? metrics.rowSpacing
            ) {
                content()
            }
        } else {
            LazyVStack(spacing: spacing ?? metrics.rowSpacing) {
                content()
            }
        }
    }
}
