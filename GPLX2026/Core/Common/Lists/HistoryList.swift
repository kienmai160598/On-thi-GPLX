import SwiftUI

struct HistoryList<Result: Identifiable, Destination: View>: View {
    let results: [Result]
    let scoreText: (Result) -> String
    let passed: (Result) -> Bool
    let date: (Result) -> Date
    let destination: (Result) -> Destination

    var body: some View {
        VStack(spacing: 0) {
            ForEach(Array(results.prefix(10).enumerated()), id: \.element.id) { index, result in
                NavigationLink(destination: destination(result)) {
                    HistoryRow(
                        passed: passed(result),
                        scoreText: scoreText(result),
                        date: date(result)
                    )
                }
                .buttonStyle(.plain)

                if index < min(results.count, 10) - 1 {
                    Divider().padding(.leading, 60)
                }
            }
        }
        .glassCard()
    }
}
