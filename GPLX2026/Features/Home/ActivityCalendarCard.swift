import SwiftUI

// MARK: - Activity Calendar Card (GitHub-style heatmap)

struct ActivityCalendarCard: View {
    @Environment(ProgressStore.self) private var progressStore
    @Environment(ThemeStore.self) private var themeStore

    private let weeks = 13
    private let cellSize: CGFloat = 14
    private let cellSpacing: CGFloat = 3
    private let dayLabels = ["T2", "", "T4", "", "T6", "", "CN"]

    var body: some View {
        let activity = progressStore.studyActivity
        let totalLast30 = progressStore.totalActivity(lastDays: 30)

        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("Hoạt động học")
                    .font(.appSans(size: 20, weight: .bold))
                    .foregroundStyle(Color.appTextDark)

                Spacer()

                Text("\(totalLast30) câu / 30 ngày")
                    .font(.appSans(size: 13, weight: .medium))
                    .foregroundStyle(Color.appTextMedium)
            }

            HStack(alignment: .top, spacing: cellSpacing) {
                // Day labels
                VStack(spacing: cellSpacing) {
                    ForEach(0..<7, id: \.self) { day in
                        Text(dayLabels[day])
                            .font(.appSans(size: 9))
                            .foregroundStyle(Color.appTextLight)
                            .frame(width: 16, height: cellSize)
                    }
                }

                // Calendar grid
                calendarGrid(activity: activity)
            }

            // Legend
            HStack(spacing: 4) {
                Text("Ít")
                    .font(.appSans(size: 10))
                    .foregroundStyle(Color.appTextLight)
                ForEach(0..<5, id: \.self) { level in
                    RoundedRectangle(cornerRadius: 2)
                        .fill(colorForLevel(level))
                        .frame(width: 10, height: 10)
                }
                Text("Nhiều")
                    .font(.appSans(size: 10))
                    .foregroundStyle(Color.appTextLight)
            }
        }
        .padding(16)
        .glassCard()
    }

    @ViewBuilder
    private func calendarGrid(activity: [String: Int]) -> some View {
        let calendar = Calendar.current
        let today = Date()
        let todayWeekday = calendar.component(.weekday, from: today)
        // Convert to Monday-based (0=Mon, 6=Sun)
        let todayOffset = (todayWeekday + 5) % 7

        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: cellSpacing) {
                ForEach((0..<weeks).reversed(), id: \.self) { weekIndex in
                    VStack(spacing: cellSpacing) {
                        ForEach(0..<7, id: \.self) { dayIndex in
                            let daysAgo = weekIndex * 7 + (todayOffset - dayIndex)
                            if daysAgo >= 0, let date = calendar.date(byAdding: .day, value: -daysAgo, to: today) {
                                let dateStr = Self.dateString(from: date)
                                let count = activity[dateStr] ?? 0
                                RoundedRectangle(cornerRadius: 2)
                                    .fill(colorForCount(count))
                                    .frame(width: cellSize, height: cellSize)
                            } else {
                                Color.clear.frame(width: cellSize, height: cellSize)
                            }
                        }
                    }
                }
            }
        }
    }

    private func colorForCount(_ count: Int) -> Color {
        switch count {
        case 0: return Color.appDivider.opacity(0.3)
        case 1...5: return themeStore.primaryColor.opacity(0.25)
        case 6...15: return themeStore.primaryColor.opacity(0.5)
        case 16...30: return themeStore.primaryColor.opacity(0.75)
        default: return themeStore.primaryColor
        }
    }

    private func colorForLevel(_ level: Int) -> Color {
        switch level {
        case 0: return Color.appDivider.opacity(0.3)
        case 1: return themeStore.primaryColor.opacity(0.25)
        case 2: return themeStore.primaryColor.opacity(0.5)
        case 3: return themeStore.primaryColor.opacity(0.75)
        default: return themeStore.primaryColor
        }
    }

    private static let _dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f
    }()

    private static func dateString(from date: Date) -> String {
        _dateFormatter.string(from: date)
    }
}
