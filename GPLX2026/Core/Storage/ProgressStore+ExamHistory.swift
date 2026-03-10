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

    /// Number of unique situations practiced across all hazard history.
    var hazardPracticedCount: Int {
        var seen = Set<Int>()
        for result in hazardHistory {
            for detail in result.details {
                seen.insert(detail.situationId)
            }
        }
        return seen.count
    }

    /// Average score percentage for situations in a specific chapter.
    func chapterAverageScore(chapterId: Int) -> Double {
        guard let chapter = HazardSituation.chapters.first(where: { $0.id == chapterId }) else { return 0 }
        let chapterIds = Set(chapter.range)
        var totalScore = 0
        var totalMax = 0
        for result in hazardHistory {
            for detail in result.details where chapterIds.contains(detail.situationId) {
                totalScore += detail.score
                totalMax += AppConstants.Hazard.maxScorePerSituation
            }
        }
        guard totalMax > 0 else { return 0 }
        return Double(totalScore) / Double(totalMax)
    }

    /// Whether any situations in this chapter have been practiced.
    func chapterHasPractice(chapterId: Int) -> Bool {
        guard let chapter = HazardSituation.chapters.first(where: { $0.id == chapterId }) else { return false }
        let chapterIds = Set(chapter.range)
        return hazardHistory.contains { result in
            result.details.contains { chapterIds.contains($0.situationId) }
        }
    }
}
