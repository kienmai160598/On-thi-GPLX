import Foundation

// MARK: - ExamResult

struct ExamResult: Codable, Identifiable {

    /// Use the date as a unique identity.
    var id: Date { date }

    let date: Date
    let score: Int
    let totalQuestions: Int
    let passed: Bool
    let timeUsedSeconds: Int
    let wrongDiemLiet: Int
    let questionDetails: [QuestionDetail]

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

    private nonisolated(unsafe) static let isoFormatter = ISO8601DateFormatter()

    enum CodingKeys: String, CodingKey {
        case date, score, totalQuestions, passed, timeUsedSeconds, wrongDiemLiet, questionDetails
    }

    init(
        date: Date,
        score: Int,
        totalQuestions: Int,
        passed: Bool,
        timeUsedSeconds: Int,
        wrongDiemLiet: Int,
        questionDetails: [QuestionDetail] = []
    ) {
        self.date = date
        self.score = score
        self.totalQuestions = totalQuestions
        self.passed = passed
        self.timeUsedSeconds = timeUsedSeconds
        self.wrongDiemLiet = wrongDiemLiet
        self.questionDetails = questionDetails
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        let dateString = try c.decode(String.self, forKey: .date)
        date = Self.isoFormatter.date(from: dateString) ?? Date()
        score = try c.decode(Int.self, forKey: .score)
        totalQuestions = try c.decode(Int.self, forKey: .totalQuestions)
        passed = try c.decode(Bool.self, forKey: .passed)
        timeUsedSeconds = try c.decode(Int.self, forKey: .timeUsedSeconds)
        wrongDiemLiet = try c.decode(Int.self, forKey: .wrongDiemLiet)
        questionDetails = (try? c.decode([QuestionDetail].self, forKey: .questionDetails)) ?? []
    }

    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(Self.isoFormatter.string(from: date), forKey: .date)
        try c.encode(score, forKey: .score)
        try c.encode(totalQuestions, forKey: .totalQuestions)
        try c.encode(passed, forKey: .passed)
        try c.encode(timeUsedSeconds, forKey: .timeUsedSeconds)
        try c.encode(wrongDiemLiet, forKey: .wrongDiemLiet)
        try c.encode(questionDetails, forKey: .questionDetails)
    }

    // MARK: - Factory

    /// Calculate an ExamResult from the user's answers.
    static func calculate(
        questions: [Question],
        answers: [Int: Int],
        timeUsedSeconds: Int
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
        let passed = correctCount >= AppConstants.Exam.passThreshold && wrongDiemLietCount == 0
        return ExamResult(
            date: Date(),
            score: correctCount,
            totalQuestions: questions.count,
            passed: passed,
            timeUsedSeconds: timeUsedSeconds,
            wrongDiemLiet: wrongDiemLietCount,
            questionDetails: details
        )
    }
}
