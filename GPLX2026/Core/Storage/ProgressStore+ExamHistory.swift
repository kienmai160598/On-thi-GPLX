import Foundation

extension ProgressStore {

    // MARK: - Helper

    private func average<T>(_ items: [T], _ value: (T) -> Double) -> Double {
        guard !items.isEmpty else { return 0 }
        return items.reduce(0.0) { $0 + value($1) } / Double(items.count)
    }

    // MARK: - Exam stats

    var averageExamScore: Double { average(examHistory, \.accuracy) }
    var bestExamScore: Double { examHistory.map(\.accuracy).max() ?? 0 }
    var examCount: Int { examHistory.count }

    // MARK: - Simulation stats

    var averageSimulationScore: Double { average(simulationHistory, \.accuracy) }
    var bestSimulationScore: Double { simulationHistory.map(\.accuracy).max() ?? 0 }
    var simulationExamCount: Int { simulationHistory.count }

    // MARK: - Hazard stats

    var averageHazardScore: Double { average(hazardHistory, \.scorePercentage) }
    var bestHazardScore: Int { hazardHistory.map(\.totalScore).max() ?? 0 }
    var hazardExamCount: Int { hazardHistory.count }
}
