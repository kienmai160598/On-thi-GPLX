import SwiftUI
import UIKit

@Observable
@MainActor
final class LayoutMetrics {
    var horizontalSizeClass: UserInterfaceSizeClass? = .compact

    var isWide: Bool { horizontalSizeClass == .regular }

    var columns: Int {
        guard isWide else { return 1 }
        let width = UIScreen.main.bounds.width
        if width > 1100 { return 3 }
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
        content
            .onChange(of: sizeClass, initial: true) { _, newValue in
                metrics.horizontalSizeClass = newValue
            }
    }
}

extension View {
    func trackLayoutMetrics() -> some View {
        modifier(LayoutMetricsReader())
    }
}
