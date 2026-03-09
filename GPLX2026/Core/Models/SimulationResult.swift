import Foundation

// MARK: - SimulationResult

struct SimulationResult: Codable, Identifiable {

    var id: Date { date }

    let date: Date
    let score: Int
    let totalScenarios: Int
    let totalTimeUsedSeconds: Int
    let timedOutCount: Int
    let scenarioDetails: [ScenarioDetail]

    var accuracy: Double {
        guard totalScenarios > 0 else { return 0 }
        return Double(score) / Double(totalScenarios)
    }

    /// Pass if score >= 70%.
    var passed: Bool {
        accuracy >= AppConstants.Simulation.passRate
    }

    // MARK: - ScenarioDetail

    struct ScenarioDetail: Codable {
        let questionNo: Int
        let selectedAnswerId: Int?
        let correct: Bool
        let timeUsedSeconds: Int
    }

    // MARK: Coding

    enum CodingKeys: String, CodingKey {
        case date, score, totalScenarios, totalTimeUsedSeconds, timedOutCount, scenarioDetails
    }

    init(
        date: Date,
        score: Int,
        totalScenarios: Int,
        totalTimeUsedSeconds: Int,
        timedOutCount: Int,
        scenarioDetails: [ScenarioDetail]
    ) {
        self.date = date
        self.score = score
        self.totalScenarios = totalScenarios
        self.totalTimeUsedSeconds = totalTimeUsedSeconds
        self.timedOutCount = timedOutCount
        self.scenarioDetails = scenarioDetails
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        let dateString = try c.decode(String.self, forKey: .date)
        date = DateFormatters.iso8601.date(from: dateString) ?? Date()
        score = try c.decode(Int.self, forKey: .score)
        totalScenarios = try c.decode(Int.self, forKey: .totalScenarios)
        totalTimeUsedSeconds = try c.decode(Int.self, forKey: .totalTimeUsedSeconds)
        timedOutCount = try c.decode(Int.self, forKey: .timedOutCount)
        scenarioDetails = try c.decode([ScenarioDetail].self, forKey: .scenarioDetails)
    }

    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(DateFormatters.iso8601.string(from: date), forKey: .date)
        try c.encode(score, forKey: .score)
        try c.encode(totalScenarios, forKey: .totalScenarios)
        try c.encode(totalTimeUsedSeconds, forKey: .totalTimeUsedSeconds)
        try c.encode(timedOutCount, forKey: .timedOutCount)
        try c.encode(scenarioDetails, forKey: .scenarioDetails)
    }

    // MARK: - Factory

    static func calculate(
        questions: [Question],
        answers: [Int: Int],
        timePerScenario: [Int: Int]
    ) -> SimulationResult {
        var correctCount = 0
        var timedOut = 0
        var details: [ScenarioDetail] = []

        for (i, q) in questions.enumerated() {
            let selectedId = answers[i]
            let isCorrect = selectedId != nil && q.answers.contains(where: { $0.id == selectedId && $0.correct })
            let timeUsed = timePerScenario[i] ?? 0

            if isCorrect { correctCount += 1 }
            if selectedId == nil { timedOut += 1 }

            details.append(ScenarioDetail(
                questionNo: q.no,
                selectedAnswerId: selectedId,
                correct: isCorrect,
                timeUsedSeconds: timeUsed
            ))
        }

        return SimulationResult(
            date: Date(),
            score: correctCount,
            totalScenarios: questions.count,
            totalTimeUsedSeconds: timePerScenario.values.reduce(0, +),
            timedOutCount: timedOut,
            scenarioDetails: details
        )
    }
}
