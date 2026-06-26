import SwiftUI

/// Trailing toolbar button that pushes a history screen.
///
/// Lives in the content tabs (Luyện tập, Thi thử, Mô phỏng) so history opens
/// from the nav bar instead of as an inline item beside the question list.
/// Rendered as a plain native toolbar `NavigationLink` so the system supplies
/// the tap target and (on iOS 26) the Liquid Glass background, matching the
/// search action next to it.
struct HistoryToolbarButton<Destination: View>: View {
    @ViewBuilder var destination: () -> Destination

    var body: some View {
        NavigationLink {
            destination()
        } label: {
            Image(systemName: "clock.arrow.circlepath")
        }
        .accessibilityLabel("Lịch sử")
    }
}
