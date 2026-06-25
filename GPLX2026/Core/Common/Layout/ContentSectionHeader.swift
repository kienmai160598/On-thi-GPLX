import SwiftUI

/// In-content section heading — a 22pt bold sans title with an optional trailing
/// count badge. Used for the bold list-section headers on the Home tabs ("Câu
/// hỏi", "Theo chương", "Đề thi cố định"). Distinct from `SectionTitle`
/// (small uppercase serif divider) and `SectionHeader` (icon + title).
struct ContentSectionHeader: View {
    let title: String
    var badge: String? = nil

    init(_ title: String, badge: String? = nil) {
        self.title = title
        self.badge = badge
    }

    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            Text(title)
                .font(.appSans(size: 22, weight: .bold))
                .foregroundStyle(Color.appTextDark)
                .tracking(-0.2)

            if let badge {
                Spacer()
                Text(badge)
                    .font(.appSans(size: 12, weight: .semibold))
                    .foregroundStyle(Color.appTextMedium)
            }
        }
    }
}
