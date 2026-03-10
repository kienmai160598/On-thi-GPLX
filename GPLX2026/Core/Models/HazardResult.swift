import Foundation

// MARK: - HazardResult

struct HazardResult: Codable, Identifiable {

    let id: UUID
    let date: Date
    let totalScore: Int
    let maxScore: Int
    let situationCount: Int
    let details: [SituationDetail]

    var passed: Bool {
        totalScore >= AppConstants.Hazard.passScore
    }

    var scorePercentage: Double {
        guard maxScore > 0 else { return 0 }
        return Double(totalScore) / Double(maxScore)
    }

    // MARK: - SituationDetail

    struct SituationDetail: Codable {
        let situationId: Int
        let tapTime: Double?
        let score: Int
    }

    // MARK: Coding

    enum CodingKeys: String, CodingKey {
        case id, date, totalScore, maxScore, situationCount, details
    }

    init(
        date: Date,
        totalScore: Int,
        maxScore: Int,
        situationCount: Int,
        details: [SituationDetail]
    ) {
        self.id = UUID()
        self.date = date
        self.totalScore = totalScore
        self.maxScore = maxScore
        self.situationCount = situationCount
        self.details = details
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = (try? c.decode(UUID.self, forKey: .id)) ?? UUID()
        let dateString = try c.decode(String.self, forKey: .date)
        date = DateFormatters.iso8601.date(from: dateString) ?? Date()
        totalScore = try c.decode(Int.self, forKey: .totalScore)
        maxScore = try c.decode(Int.self, forKey: .maxScore)
        situationCount = try c.decode(Int.self, forKey: .situationCount)
        details = try c.decode([SituationDetail].self, forKey: .details)
    }

    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(id, forKey: .id)
        try c.encode(DateFormatters.iso8601.string(from: date), forKey: .date)
        try c.encode(totalScore, forKey: .totalScore)
        try c.encode(maxScore, forKey: .maxScore)
        try c.encode(situationCount, forKey: .situationCount)
        try c.encode(details, forKey: .details)
    }

    // MARK: - Factory

    static func calculate(
        situations: [HazardSituation],
        tapTimes: [Int: Double?]
    ) -> HazardResult {
        var details: [SituationDetail] = []
        var total = 0

        for (i, situation) in situations.enumerated() {
            let tapTime = tapTimes[i] ?? nil
            let score = situation.score(tapTime: tapTime)
            total += score
            details.append(SituationDetail(
                situationId: situation.id,
                tapTime: tapTime,
                score: score
            ))
        }

        return HazardResult(
            date: Date(),
            totalScore: total,
            maxScore: situations.count * AppConstants.Hazard.maxScorePerSituation,
            situationCount: situations.count,
            details: details
        )
    }
}
