import SwiftUI

@Observable
@MainActor
final class LayoutMetrics {
    var horizontalSizeClass: UserInterfaceSizeClass? = .compact
    var windowWidth: CGFloat = 0

    /// Only wide when iPad landscape (portrait uses iPhone layout)
    var isWide: Bool { horizontalSizeClass == .regular && windowWidth >= 1024 }

    var columns: Int {
        guard isWide else { return 1 }
        if windowWidth > 1100 { return 3 }
        return 2
    }

    var gridSpacing: CGFloat { isWide ? 16 : 12 }
    var contentPadding: CGFloat { isWide ? 28 : 20 }
    var cardPadding: CGFloat { isWide ? 18 : 12 }
    var rowSpacing: CGFloat { isWide ? 14 : 8 }
    var fontScale: CGFloat { isWide ? 1.15 : 1.0 }

    var buttonHeight: CGFloat { isWide ? 56 : 48 }
    var answerHeight: CGFloat { isWide ? 60 : 48 }
    var gridCellSize: CGFloat { isWide ? 48 : 44 }
    var gridColumns: Int { isWide ? 8 : 6 }

    var cardMinWidth: CGFloat { 300 }
}

struct LayoutMetricsReader: ViewModifier {
    @Environment(LayoutMetrics.self) private var metrics
    @Environment(\.horizontalSizeClass) private var sizeClass

    func body(content: Content) -> some View {
        GeometryReader { geo in
            content
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .onChange(of: sizeClass, initial: true) { _, newValue in
                    metrics.horizontalSizeClass = newValue
                }
                .onChange(of: geo.size.width, initial: true) { _, newWidth in
                    metrics.windowWidth = newWidth
                }
        }
    }
}

extension View {
    func trackLayoutMetrics() -> some View {
        modifier(LayoutMetricsReader())
    }
}
