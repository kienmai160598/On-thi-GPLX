import SwiftUI

@Observable
@MainActor
final class LayoutMetrics {
    var horizontalSizeClass: UserInterfaceSizeClass? = .compact
    var windowWidth: CGFloat = 0

    // MARK: - 3-Tier Breakpoints

    /// iPhone and narrow iPad split-screen (width < 744)
    var isCompact: Bool { windowWidth < 744 }

    /// iPad portrait or medium split-screen (744 ≤ width < 1024)
    var isMedium: Bool { windowWidth >= 744 && windowWidth < 1024 }

    /// iPad landscape full-screen (sizeClass == .regular && width ≥ 1024)
    var isWide: Bool { horizontalSizeClass == .regular && windowWidth >= 1024 }

    /// Convenience: true for any iPad-class layout (medium or wide)
    var isIPadLayout: Bool { isMedium || isWide }

    // MARK: - Adaptive Metrics

    var columns: Int {
        if isWide { return 3 }
        if isMedium { return 2 }
        return 1
    }

    var contentPadding: CGFloat {
        if isWide { return 32 }
        if isMedium { return 24 }
        return 20
    }

    var cardPadding: CGFloat {
        if isWide { return 20 }
        if isMedium { return 16 }
        return 12
    }

    var gridSpacing: CGFloat {
        if isWide { return 18 }
        if isMedium { return 14 }
        return 12
    }

    var rowSpacing: CGFloat {
        if isWide { return 14 }
        if isMedium { return 12 }
        return 8
    }

    var buttonHeight: CGFloat {
        if isWide { return 56 }
        if isMedium { return 52 }
        return 48
    }

    var answerHeight: CGFloat {
        if isWide { return 60 }
        if isMedium { return 54 }
        return 48
    }

    var fontScale: CGFloat {
        if isWide { return 1.15 }
        if isMedium { return 1.08 }
        return 1.0
    }

    var gridColumns: Int {
        if isWide { return 9 }
        if isMedium { return 7 }
        return 6
    }

    var gridCellSize: CGFloat {
        if isWide { return 48 }
        if isMedium { return 46 }
        return 44
    }

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
