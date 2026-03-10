import Foundation

// MARK: - ExamResult

struct ExamResult: Codable, Identifiable {

    let id: UUID
    let date: Date
    let score: Int
    let totalQuestions: Int
    let passed: Bool
    let timeUsedSeconds: Int
    let wrongDiemLiet: Int
    let questionDetails: [QuestionDetail]
    let examSetId: Int?

    /// Accuracy as a fraction (0.0 ... 1.0).
    var accuracy: Double {
        guard totalQuestions > 0 else { return 0 }
        return Double(score) / Double(totalQuestions)
    }

    // MARK: - QuestionDetail

    struct QuestionDetail: Codable {
        let questionNo: Int
        let selectedAnswerId: Int?
        let correct: Bool
    }

    // MARK: Coding

    enum CodingKeys: String, CodingKey {
        case id, date, score, totalQuestions, passed, timeUsedSeconds, wrongDiemLiet, questionDetails, examSetId
    }

    init(
        date: Date,
        score: Int,
        totalQuestions: Int,
        passed: Bool,
        timeUsedSeconds: Int,
        wrongDiemLiet: Int,
        questionDetails: [QuestionDetail] = [],
        examSetId: Int? = nil
    ) {
        self.id = UUID()
        self.date = date
        self.score = score
        self.totalQuestions = totalQuestions
        self.passed = passed
        self.timeUsedSeconds = timeUsedSeconds
        self.wrongDiemLiet = wrongDiemLiet
        self.questionDetails = questionDetails
        self.examSetId = examSetId
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = (try? c.decode(UUID.self, forKey: .id)) ?? UUID()
        let dateString = try c.decode(String.self, forKey: .date)
        date = DateFormatters.iso8601.date(from: dateString) ?? Date()
        score = try c.decode(Int.self, forKey: .score)
        totalQuestions = try c.decode(Int.self, forKey: .totalQuestions)
        passed = try c.decode(Bool.self, forKey: .passed)
        timeUsedSeconds = try c.decode(Int.self, forKey: .timeUsedSeconds)
        wrongDiemLiet = try c.decode(Int.self, forKey: .wrongDiemLiet)
        questionDetails = (try? c.decode([QuestionDetail].self, forKey: .questionDetails)) ?? []
        examSetId = try? c.decode(Int.self, forKey: .examSetId)
    }

    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(id, forKey: .id)
        try c.encode(DateFormatters.iso8601.string(from: date), forKey: .date)
        try c.encode(score, forKey: .score)
        try c.encode(totalQuestions, forKey: .totalQuestions)
        try c.encode(passed, forKey: .passed)
        try c.encode(timeUsedSeconds, forKey: .timeUsedSeconds)
        try c.encode(wrongDiemLiet, forKey: .wrongDiemLiet)
        try c.encode(questionDetails, forKey: .questionDetails)
        try c.encodeIfPresent(examSetId, forKey: .examSetId)
    }

    // MARK: - Factory

    /// Calculate an ExamResult from the user's answers.
    static func calculate(
        questions: [Question],
        answers: [Int: Int],
        timeUsedSeconds: Int,
        examSetId: Int? = nil
    ) -> ExamResult {
        var correctCount = 0
        var wrongDiemLietCount = 0
        var details: [QuestionDetail] = []

        for (i, q) in questions.enumerated() {
            let selectedId = answers[i]
            let isCorrect = selectedId != nil && q.answers.contains(where: { $0.id == selectedId && $0.correct })
            if isCorrect {
                correctCount += 1
            } else if q.isDiemLiet {
                wrongDiemLietCount += 1
            }
            details.append(QuestionDetail(
                questionNo: q.no,
                selectedAnswerId: selectedId,
                correct: isCorrect
            ))
        }
        let passed = correctCount >= LicenseType.current.passThreshold && wrongDiemLietCount == 0
        return ExamResult(
            date: Date(),
            score: correctCount,
            totalQuestions: questions.count,
            passed: passed,
            timeUsedSeconds: timeUsedSeconds,
            wrongDiemLiet: wrongDiemLietCount,
            questionDetails: details,
            examSetId: examSetId
        )
    }
}
