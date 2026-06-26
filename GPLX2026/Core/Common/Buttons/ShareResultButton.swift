import SwiftUI

/// Trailing nav-bar button that shares a plain-text summary of a result
/// (exam, simulation, hazard, daily challenge) via the system share sheet.
///
/// The design (node VVIdQ) puts a share action in the result screen's nav bar;
/// every result screen passes its own Vietnamese summary string.
struct ShareResultButton: View {
    let text: String

    var body: some View {
        ShareLink(item: text) {
            Image(systemName: "square.and.arrow.up")
                .font(.appSans(size: 15, weight: .semibold))
        }
        .accessibilityLabel("Chia sẻ kết quả")
    }
}
