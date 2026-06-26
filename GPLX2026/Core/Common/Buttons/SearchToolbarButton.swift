import SwiftUI

/// Trailing toolbar button that opens the full-screen question search.
///
/// Lives in the content tabs (Luyện tập, Thi thử, Mô phỏng) so the user can
/// search the question bank from wherever they practise — not on the Home tab.
/// Rendered as a plain native toolbar button so the system supplies the tap
/// target and (on iOS 26) the Liquid Glass background, matching the other
/// native toolbar actions.
struct SearchToolbarButton: View {
    @Environment(\.openExam) private var openExam

    var body: some View {
        Button { openExam(.search) } label: {
            Image(systemName: "magnifyingglass")
        }
        .accessibilityLabel("Tìm kiếm")
    }
}
