import Foundation

// MARK: - AppConstants

enum AppConstants {

    // MARK: - Mock Exam

    enum Exam {
        static let totalTimeSeconds = 22 * 60
        static let questionsPerExam = 30
        static let passThreshold = 28
        static let diemLietPerExam = 1
        static let urgencyThresholdSeconds = 300
    }

    // MARK: - Simulation Exam

    enum Simulation {
        static let scenarioTimeSeconds = 60
        static let passRate = 0.7
        static let urgencyThresholdSeconds = 10
    }

    // MARK: - Readiness

    enum Readiness {
        static let attemptedGoal = 400
        static let totalQuestionsGoal = 600
        static let readyPercentage = 80
        static let intermediatePercentage = 50
    }

    // MARK: - Hazard Perception

    enum Hazard {
        static let situationsPerExam = 10
        static let maxScorePerSituation = 5
        static let passScore = 35
        static let maxTotalScore = situationsPerExam * maxScorePerSituation
    }

    // MARK: - Storage

    enum Storage {
        static let historyLimit = 50
    }

    // MARK: - Special Topic Keys

    enum TopicKey {
        static let diemLiet = "diem_liet"
        static let bookmarks = "bookmarks"
        static let wrongAnswers = "wrong_answers"
        static let allQuestions = "all_questions"
    }
}
