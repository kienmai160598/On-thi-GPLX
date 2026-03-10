import SwiftUI

struct HistoryRow: View {
    let passed: Bool
    let scoreText: String
    let date: Date

    private static let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "dd/MM HH:mm"
        return f
    }()

    var body: some View {
        ListItemCard(
            icon: passed ? "checkmark.circle.fill" : "xmark.circle.fill",
            title: scoreText,
            subtitle: Self.dateFormatter.string(from: date)
        ) {
            StatusBadge(
                text: passed ? "Đạt" : "Trượt",
                color: .appPrimary,
                fontSize: 10
            )
        }
    }
}
