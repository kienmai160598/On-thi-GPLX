import SwiftUI

struct StudyHeatMap: View {
    @Environment(ProgressStore.self) private var progressStore

    private let weeks = 16
    private let dayLabels = ["T2", "", "T4", "", "T6", "", "CN"]

    var body: some View {
        let days = generateDays()
        let maxCount = max(days.map(\.count).max() ?? 1, 1)

        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Hoạt động học tập")
                    .font(.system(size: 20, weight: .heavy))
                    .foregroundStyle(Color.appTextDark)
                Spacer()
                let total = progressStore.totalActivity(lastDays: weeks * 7)
                Text("\(total) câu · \(weeks) tuần")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(Color.appTextMedium)
            }

            HStack(alignment: .top, spacing: 3) {
                VStack(spacing: 3) {
                    ForEach(0..<7, id: \.self) { i in
                        Text(dayLabels[i])
                            .font(.system(size: 10, weight: .medium))
                            .foregroundStyle(Color.appTextLight)
                            .frame(width: 16, height: 14)
                    }
                }

                LazyHGrid(rows: Array(repeating: GridItem(.fixed(14), spacing: 3), count: 7), spacing: 3) {
                    ForEach(Array(days.enumerated()), id: \.offset) { _, day in
                        RoundedRectangle(cornerRadius: 2.5)
                            .fill(cellColor(count: day.count, max: maxCount))
                            .frame(width: 14, height: 14)
                    }
                }
            }

            HStack(spacing: 4) {
                Text("Ít")
                    .font(.system(size: 11))
                    .foregroundStyle(Color.appTextLight)
                ForEach([0.0, 0.25, 0.5, 0.75, 1.0], id: \.self) { intensity in
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color.appSuccess.opacity(max(intensity, 0.08)))
                        .frame(width: 10, height: 10)
                }
                Text("Nhiều")
                    .font(.system(size: 11))
                    .foregroundStyle(Color.appTextLight)
            }
        }
        .padding(20)
        .glassCard()
    }

    private struct DayData {
        let date: Date
        let count: Int
    }

    private static let heatMapDateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f
    }()

    private func generateDays() -> [DayData] {
        let calendar = Calendar.current
        let today = Date()
        let totalDays = weeks * 7

        let weekday = calendar.component(.weekday, from: today)
        let daysFromMonday = (weekday + 5) % 7
        guard let currentMonday = calendar.date(byAdding: .day, value: -daysFromMonday, to: today) else { return [] }
        guard let startDate = calendar.date(byAdding: .day, value: -(totalDays - 7), to: currentMonday) else { return [] }

        let allActivity = progressStore.studyActivity

        var days: [DayData] = []
        let endDay = daysFromMonday // days into current week (0 = Monday)
        let totalCells = totalDays + endDay + 1 // fill current week up to today

        for i in 0..<totalCells {
            if let date = calendar.date(byAdding: .day, value: i, to: startDate) {
                let dateStr = Self.heatMapDateFormatter.string(from: date)
                let count = date <= today ? (allActivity[dateStr] ?? 0) : 0
                days.append(DayData(date: date, count: count))
            }
        }

        // Pad to fill last column
        let remainder = days.count % 7
        if remainder > 0 {
            for i in 0..<(7 - remainder) {
                if let date = calendar.date(byAdding: .day, value: days.count + i, to: startDate) {
                    days.append(DayData(date: date, count: 0))
                }
            }
        }

        return days
    }

    private func cellColor(count: Int, max: Int) -> Color {
        guard count > 0 else { return Color.appDivider.opacity(0.4) }
        let intensity = Double(count) / Double(max)
        return Color.appSuccess.opacity(0.2 + intensity * 0.8)
    }
}
