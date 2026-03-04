import Foundation
import Observation

// MARK: - ProgressStore

@Observable
final class ProgressStore {

    // MARK: - Storage key constants

    private enum Keys {
        static let progressPrefix     = "progress_"
        static let examHistory        = "exam_history"
        static let bookmarks          = "bookmarks"
        static let wrongAnswers       = "wrong_answers"
        static let completedExamSets  = "completed_exam_sets"
        static let simulationHistory  = "simulation_history"
        static let streakCount        = "streak_count"
        static let lastStudyDate      = "last_study_date"
        static let lastTopicKey       = "last_topic_key"
        static let lastQuestionIndex  = "last_question_index"
    }

    // MARK: - Private backing store

    private let defaults: UserDefaults

    /// Stored property so @Observable can track data changes.
    private(set) var dataVersion = 0

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    // MARK: - Topic progress  [questionNo : correct]

    func topicProgress(for key: String) -> [Int: Bool] {
        _ = dataVersion
        guard let data = defaults.data(forKey: Keys.progressPrefix + key),
              let dict = try? JSONDecoder().decode([String: Bool].self, from: data) else {
            return [:]
        }
        return dict.reduce(into: [:]) { result, pair in
            if let intKey = Int(pair.key) {
                result[intKey] = pair.value
            }
        }
    }

    func saveQuestionResult(topicKey: String, questionNo: Int, correct: Bool) {
        var current = topicProgress(for: topicKey)
        current[questionNo] = correct
        let encoded = current.reduce(into: [String: Bool]()) { $0[String($1.key)] = $1.value }
        if let data = try? JSONEncoder().encode(encoded) {
            defaults.set(data, forKey: Keys.progressPrefix + topicKey)
        }
        dataVersion += 1
    }

    // MARK: - Exam history

    var examHistory: [ExamResult] {
        _ = dataVersion
        guard let data = defaults.data(forKey: Keys.examHistory),
              let results = try? JSONDecoder().decode([ExamResult].self, from: data) else {
            return []
        }
        return results
    }

    func recordExamResult(_ result: ExamResult) {
        var history = examHistory
        history.insert(result, at: 0)
        if history.count > 50 { history.removeLast() }
        if let data = try? JSONEncoder().encode(history) {
            defaults.set(data, forKey: Keys.examHistory)
        }
        dataVersion += 1
    }

    // MARK: - Simulation history

    var simulationHistory: [SimulationResult] {
        _ = dataVersion
        guard let data = defaults.data(forKey: Keys.simulationHistory),
              let results = try? JSONDecoder().decode([SimulationResult].self, from: data) else {
            return []
        }
        return results
    }

    func recordSimulationResult(_ result: SimulationResult) {
        var history = simulationHistory
        history.insert(result, at: 0)
        if history.count > 50 { history.removeLast() }
        if let data = try? JSONEncoder().encode(history) {
            defaults.set(data, forKey: Keys.simulationHistory)
        }
        dataVersion += 1
    }

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

    // MARK: - Bookmarks

    var bookmarks: Set<Int> {
        _ = dataVersion
        guard let data = defaults.data(forKey: Keys.bookmarks),
              let list = try? JSONDecoder().decode([Int].self, from: data) else {
            return []
        }
        return Set(list)
    }

    func toggleBookmark(questionNo: Int) {
        var current = bookmarks
        if current.contains(questionNo) {
            current.remove(questionNo)
        } else {
            current.insert(questionNo)
        }
        saveIntSet(current, forKey: Keys.bookmarks)
        dataVersion += 1
    }

    func isBookmarked(questionNo: Int) -> Bool {
        return bookmarks.contains(questionNo)
    }

    // MARK: - Wrong answers

    var wrongAnswers: Set<Int> {
        _ = dataVersion
        guard let data = defaults.data(forKey: Keys.wrongAnswers),
              let list = try? JSONDecoder().decode([Int].self, from: data) else {
            return []
        }
        return Set(list)
    }

    func addWrongAnswer(_ questionNo: Int) {
        var current = wrongAnswers
        current.insert(questionNo)
        saveIntSet(current, forKey: Keys.wrongAnswers)
        dataVersion += 1
    }

    func removeWrongAnswer(_ questionNo: Int) {
        var current = wrongAnswers
        current.remove(questionNo)
        saveIntSet(current, forKey: Keys.wrongAnswers)
        dataVersion += 1
    }

    // MARK: - Completed exam sets

    var completedExamSets: Set<Int> {
        _ = dataVersion
        guard let data = defaults.data(forKey: Keys.completedExamSets),
              let list = try? JSONDecoder().decode([Int].self, from: data) else {
            return []
        }
        return Set(list)
    }

    func addCompletedExamSet(_ id: Int) {
        var current = completedExamSets
        current.insert(id)
        saveIntSet(current, forKey: Keys.completedExamSets)
        dataVersion += 1
    }

    // MARK: - Streak

    var streakCount: Int {
        _ = dataVersion
        return defaults.integer(forKey: Keys.streakCount)
    }

    var lastStudyDate: String? {
        _ = dataVersion
        return defaults.string(forKey: Keys.lastStudyDate)
    }

    func updateStreak() {
        let today = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let todayStr = formatter.string(from: today)

        let last = lastStudyDate
        if last == todayStr { return } // already counted today

        var newStreak = 1
        if let last, let lastDate = formatter.date(from: last) {
            let diff = Calendar.current.dateComponents([.day], from: lastDate, to: today).day ?? 0
            if diff == 1 {
                newStreak = streakCount + 1
            }
        }

        defaults.set(newStreak, forKey: Keys.streakCount)
        defaults.set(todayStr, forKey: Keys.lastStudyDate)
        dataVersion += 1
    }

    // MARK: - Continue learning position

    var lastTopicKey: String? {
        _ = dataVersion
        return defaults.string(forKey: Keys.lastTopicKey)
    }

    var lastQuestionIndex: Int {
        _ = dataVersion
        return defaults.integer(forKey: Keys.lastQuestionIndex)
    }

    func saveLastPosition(topicKey: String, index: Int) {
        defaults.set(topicKey, forKey: Keys.lastTopicKey)
        defaults.set(index, forKey: Keys.lastQuestionIndex)
        dataVersion += 1
    }

    // MARK: - Overall progress

    /// Overall progress as a fraction (0.0 ... 1.0) across all topics.
    func overallProgress(topics: [Topic]) -> Double {
        var totalAnswered = 0
        var totalQuestions = 0
        for topic in topics {
            let progress = topicProgress(for: topic.key)
            totalAnswered += progress.count
            totalQuestions += topic.questionCount
        }
        guard totalQuestions > 0 else { return 0 }
        return Double(totalAnswered) / Double(totalQuestions)
    }

    /// Average exam score across all completed exams (0.0 ... 1.0).
    var averageExamScore: Double {
        let history = examHistory
        guard !history.isEmpty else { return 0 }
        let totalAccuracy = history.reduce(0.0) { $0 + $1.accuracy }
        return totalAccuracy / Double(history.count)
    }

    var bestExamScore: Double {
        examHistory.map(\.accuracy).max() ?? 0
    }

    var examCount: Int {
        examHistory.count
    }

    // MARK: - Exam readiness

    /// Per-topic accuracy (0.0 ... 1.0). Returns only topics with at least one attempt.
    func topicAccuracy(for key: String) -> Double {
        let progress = topicProgress(for: key)
        guard !progress.isEmpty else { return 0 }
        let correct = progress.values.filter { $0 }.count
        return Double(correct) / Double(progress.count)
    }

    /// Topics sorted by accuracy (weakest first). Only includes topics with attempts.
    func weakTopics(topics: [Topic]) -> [(topic: Topic, accuracy: Double, correct: Int, attempted: Int, total: Int)] {
        topics.compactMap { topic in
            let progress = topicProgress(for: topic.key)
            let correct = progress.values.filter { $0 }.count
            let attempted = progress.count
            let accuracy = attempted > 0 ? Double(correct) / Double(attempted) : 0
            return (topic: topic, accuracy: accuracy, correct: correct, attempted: attempted, total: topic.questionCount)
        }
        .sorted { $0.accuracy < $1.accuracy }
    }

    /// Điểm liệt mastery: fraction of critical questions answered correctly.
    func diemLietMastery(questions: [Question]) -> (correct: Int, total: Int) {
        let diemLietQuestions = questions.filter(\.isDiemLiet)
        let total = diemLietQuestions.count
        var correct = 0
        for q in diemLietQuestions {
            let topicKey = Topic.keyForTopicId(q.topic)
            if topicProgress(for: topicKey)[q.no] == true {
                correct += 1
            }
        }
        return (correct, total)
    }

    /// Overall readiness score (0.0 ... 1.0) combining topic mastery, điểm liệt, and exam history.
    func readinessScore(topics: [Topic], allQuestions: [Question]) -> Double {
        // 40% weight: overall accuracy
        let totalCorrect = totalCorrectCount(topics: topics)
        let totalAttempted = totalAttemptedCount(topics: topics)
        let overallAccuracy = totalAttempted > 0 ? Double(totalCorrect) / Double(totalAttempted) : 0

        // 30% weight: điểm liệt mastery
        let dl = diemLietMastery(questions: allQuestions)
        let dlAccuracy = dl.total > 0 ? Double(dl.correct) / Double(dl.total) : 0

        // 20% weight: exam pass rate
        let history = examHistory
        let passRate: Double = history.isEmpty ? 0 : Double(history.filter(\.passed).count) / Double(history.count)

        // 10% weight: coverage (how many questions attempted)
        let totalQuestions = topics.reduce(0) { $0 + $1.questionCount }
        let coverage = totalQuestions > 0 ? Double(totalAttempted) / Double(totalQuestions) : 0

        return overallAccuracy * 0.4 + dlAccuracy * 0.3 + passRate * 0.2 + coverage * 0.1
    }

    // MARK: - Convenience wrappers (used by views)

    /// Number of correctly answered questions for a topic.
    func correctCount(forTopic key: String) -> Int {
        topicProgress(for: key).values.filter { $0 }.count
    }

    /// Total correct answers across all topics.
    func totalCorrectCount(topics: [Topic]) -> Int {
        topics.reduce(0) { $0 + correctCount(forTopic: $1.key) }
    }

    /// Total attempted answers across all topics.
    func totalAttemptedCount(topics: [Topic]) -> Int {
        topics.reduce(0) { $0 + topicProgress(for: $1.key).count }
    }

    /// Whether a specific question was answered correctly.
    func isCorrect(topicKey: String, questionNo: Int) -> Bool {
        topicProgress(for: topicKey)[questionNo] == true
    }

    /// Answer status for a question in a topic.
    func answerStatus(topicKey: String, questionNo: Int) -> AnswerStatus {
        guard let result = topicProgress(for: topicKey)[questionNo] else {
            return .unanswered
        }
        return result ? .correct : .wrong
    }

    /// Record a question answer (saves progress + tracks wrong answers).
    func recordQuestionAnswer(topicKey: String, questionNo: Int, correct: Bool) {
        saveQuestionResult(topicKey: topicKey, questionNo: questionNo, correct: correct)
        if correct {
            removeWrongAnswer(questionNo)
        } else {
            addWrongAnswer(questionNo)
        }
        updateStreak()
    }


    // MARK: - Badge support

    /// Number of unlocked badges.
    var unlockedBadgesCount: Int {
        badgeStatuses.filter(\.isUnlocked).count
    }

    /// Compute badge statuses for all badges.
    var badgeStatuses: [BadgeStatus] {
        let history = examHistory
        let passedCount = history.filter(\.passed).count
        let avgAccuracy = averageExamScore
        let topicKeys = Topic.all.map(\.key)

        return AppBadge.all.map { badge in
            let (progress, target, unlocked): (Int, Int, Bool) = {
                switch badge.type {
                case .streak7, .streak30:
                    return (streakCount, badge.threshold, streakCount >= badge.threshold)
                case .questions100, .questions300, .questions600:
                    let total = topicKeys.reduce(0) { $0 + correctCount(forTopic: $1) }
                    return (total, badge.threshold, total >= badge.threshold)
                case .allTopics:
                    let completed = topicKeys.filter { correctCount(forTopic: $0) > 0 }.count
                    return (completed, topicKeys.count, completed >= topicKeys.count)
                case .exam10Pass:
                    return (passedCount, badge.threshold, passedCount >= badge.threshold)
                case .accuracy90:
                    let pct = Int(avgAccuracy * 100)
                    return (pct, badge.threshold, pct >= badge.threshold)
                case .diemLietMaster:
                    let dlCorrect = correctCount(forTopic: "diem_liet")
                    return (dlCorrect > 0 ? 1 : 0, 1, dlCorrect > 0)
                }
            }()
            return BadgeStatus(badge: badge, isUnlocked: unlocked, progress: progress, target: target)
        }
    }

    // MARK: - Reset

    func clearAllProgress() {
        let topicKeys = Topic.all.map(\.key) + ["diem_liet"]
        for key in topicKeys {
            defaults.removeObject(forKey: Keys.progressPrefix + key)
        }
        defaults.removeObject(forKey: Keys.examHistory)
        defaults.removeObject(forKey: Keys.bookmarks)
        defaults.removeObject(forKey: Keys.wrongAnswers)
        defaults.removeObject(forKey: Keys.lastTopicKey)
        defaults.removeObject(forKey: Keys.lastQuestionIndex)
        defaults.removeObject(forKey: Keys.streakCount)
        defaults.removeObject(forKey: Keys.lastStudyDate)
        defaults.removeObject(forKey: Keys.completedExamSets)
        defaults.removeObject(forKey: Keys.simulationHistory)
        dataVersion += 1
    }

    // MARK: - Private helpers

    private func saveIntSet(_ set: Set<Int>, forKey key: String) {
        if let data = try? JSONEncoder().encode(Array(set)) {
            defaults.set(data, forKey: key)
        }
    }
}

// MARK: - AnswerStatus

enum AnswerStatus {
    case correct
    case wrong
    case unanswered
}
