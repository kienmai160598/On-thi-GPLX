import Foundation

extension ProgressStore {

    // MARK: - Exam stats

    var averageExamScore: Double {
        let history = examHistory
        guard !history.isEmpty else { return 0 }
        return history.reduce(0.0) { $0 + $1.accuracy } / Double(history.count)
    }

    var bestExamScore: Double {
        examHistory.map(\.accuracy).max() ?? 0
    }

    var examCount: Int {
        examHistory.count
    }

    // MARK: - Simulation stats

    var averageSimulationScore: Double {
        let history = simulationHistory
        guard !history.isEmpty else { return 0 }
        return history.reduce(0.0) { $0 + $1.accuracy } / Double(history.count)
    }

    var bestSimulationScore: Double {
        simulationHistory.map(\.accuracy).max() ?? 0
    }

    var simulationExamCount: Int {
        simulationHistory.count
    }
}
