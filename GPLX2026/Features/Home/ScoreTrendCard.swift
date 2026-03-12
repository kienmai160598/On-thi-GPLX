import SwiftUI
import Charts

// MARK: - Score Trend Card

struct ScoreTrendCard: View {
    @Environment(ProgressStore.self) private var progressStore
    @Environment(ThemeStore.self) private var themeStore

    var body: some View {
        let examData = progressStore.examHistory.suffix(10).reversed().map { result in
            ScorePoint(date: result.date, score: result.accuracy, label: "Lý thuyết")
        }
        let simData = progressStore.simulationHistory.suffix(10).reversed().map { result in
            ScorePoint(date: result.date, score: result.accuracy, label: "Mô phỏng")
        }
        let hazardData = progressStore.hazardHistory.suffix(10).reversed().map { result in
            ScorePoint(date: result.date, score: result.scorePercentage, label: "Tình huống")
        }

        let allData = examData + simData + hazardData

        if !allData.isEmpty {
            VStack(alignment: .leading, spacing: 14) {
                Text("Xu hướng điểm")
                    .font(.appSans(size: 20, weight: .bold))
                    .foregroundStyle(Color.appTextDark)

                Chart(allData) { point in
                    LineMark(
                        x: .value("Ngày", point.date),
                        y: .value("Điểm", point.score * 100)
                    )
                    .foregroundStyle(by: .value("Loại", point.label))
                    .interpolationMethod(.catmullRom)
                    .lineStyle(StrokeStyle(lineWidth: 2))

                    PointMark(
                        x: .value("Ngày", point.date),
                        y: .value("Điểm", point.score * 100)
                    )
                    .foregroundStyle(by: .value("Loại", point.label))
                    .symbolSize(20)
                }
                .chartYScale(domain: 0...100)
                .chartYAxis {
                    AxisMarks(values: [0, 25, 50, 75, 100]) { value in
                        AxisGridLine()
                            .foregroundStyle(Color.appDivider.opacity(0.3))
                        AxisValueLabel {
                            Text("\(value.as(Int.self) ?? 0)%")
                                .font(.appSans(size: 10))
                                .foregroundStyle(Color.appTextLight)
                        }
                    }
                }
                .chartXAxis {
                    AxisMarks(values: .automatic(desiredCount: 4)) { _ in
                        AxisGridLine()
                            .foregroundStyle(Color.appDivider.opacity(0.2))
                        AxisValueLabel(format: .dateTime.day().month(.abbreviated))
                            .font(.appSans(size: 10))
                            .foregroundStyle(Color.appTextLight)
                    }
                }
                .chartForegroundStyleScale([
                    "Lý thuyết": themeStore.primaryColor,
                    "Mô phỏng": Color.appWarning,
                    "Tình huống": Color.appSuccess,
                ])
                .chartLegend(position: .bottom, spacing: 8)
                .frame(height: 200)
            }
            .padding(16)
            .glassCard()
        }
    }
}

private struct ScorePoint: Identifiable {
    let id = UUID()
    let date: Date
    let score: Double
    let label: String
}
