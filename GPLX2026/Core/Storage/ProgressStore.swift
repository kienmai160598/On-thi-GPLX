import Foundation
import Observation
import os

// MARK: - ProgressStore

private let logger = Logger(subsystem: "com.gplx2026", category: "ProgressStore")

@Observable
final class ProgressStore {

    // MARK: - Storage key constants

    private enum Keys {
        static let progressPrefix     = "progress_"
        static let examHistory        = "exam_history"
        static let bookmarks          = "bookmarks"
        static let wrongAnswers       = "wrong_answers"
        static let completedExamSets  = "completed_exam_sets"
        static let completedSimSets   = "completed_sim_sets"
        static let completedHazardSets = "completed_hazard_sets"
        static let simulationHistory  = "simulation_history"
        static let hazardHistory      = "hazard_history"
        static let streakCount        = "streak_count"
        static let lastStudyDate      = "last_study_date"
        static let lastTopicKey       = "last_topic_key"
        static let lastQuestionIndex  = "last_question_index"
    }

    // MARK: - Private backing store

    let defaults: UserDefaults

    // MARK: - In-memory caches (lazy-loaded from UserDefaults)

    private var _topicProgressCache: [String: [Int: Bool]] = [:]
    private var _examHistoryCache: [ExamResult]?
    private var _simulationHistoryCache: [SimulationResult]?
    private var _hazardHistoryCache: [HazardResult]?
    private var _bookmarksCache: Set<Int>?
    private var _wrongAnswersCache: Set<Int>?
    private var _completedExamSetsCache: Set<Int>?
    private var _completedSimSetsCache: Set<Int>?
    private var _completedHazardSetsCache: Set<Int>?
    private var _streakCountCache: Int?
    private var _lastStudyDateCache: String??   // outer nil = not loaded
    private var _lastTopicKeyCache: String??    // outer nil = not loaded
    private var _lastQuestionIndexCache: Int?
    var _studyActivityCache: [String: Int]?
    var _examDateCache: Date??         // outer nil = not loaded
    var _dailyGoalCache: Int?
    var _reviewDatesCache: [Int: Date]?
    var _readinessCache: ReadinessStatus?

    private static let streakDateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f
    }()

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    /// Invalidate all caches when data changes.
    private func invalidateCaches() {
        _topicProgressCache.removeAll()
        _examHistoryCache = nil
        _simulationHistoryCache = nil
        _hazardHistoryCache = nil
        _bookmarksCache = nil
        _wrongAnswersCache = nil
        _completedExamSetsCache = nil
        _streakCountCache = nil
        _lastStudyDateCache = nil
        _lastTopicKeyCache = nil
        _lastQuestionIndexCache = nil
        _studyActivityCache = nil
        _examDateCache = nil
        _dailyGoalCache = nil
        _reviewDatesCache = nil
        _readinessCache = nil
    }

    // MARK: - Topic progress  [questionNo : correct]

    func topicProgress(for key: String) -> [Int: Bool] {
        if let cached = _topicProgressCache[key] {
            return cached
        }
        guard let data = defaults.data(forKey: Keys.progressPrefix + key) else {
            _topicProgressCache[key] = [:]
            return [:]
        }
        do {
            let dict = try JSONDecoder().decode([String: Bool].self, from: data)
            let result = dict.reduce(into: [Int: Bool]()) { result, pair in
                if let intKey = Int(pair.key) {
                    result[intKey] = pair.value
                }
            }
            _topicProgressCache[key] = result
            return result
        } catch {
            logger.warning("Failed to decode topic progress for key '\(key)': \(error.localizedDescription)")
            _topicProgressCache[key] = [:]
            return [:]
        }
    }

    func saveQuestionResult(topicKey: String, questionNo: Int, correct: Bool) {
        var current = topicProgress(for: topicKey)
        current[questionNo] = correct
        _topicProgressCache[topicKey] = current
        let encoded = current.reduce(into: [String: Bool]()) { $0[String($1.key)] = $1.value }
        do {
            let data = try JSONEncoder().encode(encoded)
            defaults.set(data, forKey: Keys.progressPrefix + topicKey)
        } catch {
            logger.error("Failed to encode topic progress for '\(topicKey)': \(error.localizedDescription)")
        }
        _readinessCache = nil
    }

    // MARK: - Exam history

    var examHistory: [ExamResult] {
        if let cached = _examHistoryCache { return cached }
        guard let data = defaults.data(forKey: Keys.examHistory) else {
            _examHistoryCache = []
            return []
        }
        do {
            let results = try JSONDecoder().decode([ExamResult].self, from: data)
            _examHistoryCache = results
            return results
        } catch {
            logger.warning("Failed to decode exam history: \(error.localizedDescription)")
            _examHistoryCache = []
            return []
        }
    }

    func recordExamResult(_ result: ExamResult) {
        var history = examHistory
        history.insert(result, at: 0)
        if history.count > AppConstants.Storage.historyLimit { history.removeLast() }
        _examHistoryCache = history
        do {
            let data = try JSONEncoder().encode(history)
            defaults.set(data, forKey: Keys.examHistory)
        } catch {
            logger.error("Failed to encode exam history: \(error.localizedDescription)")
        }
        _readinessCache = nil
    }

    // MARK: - Simulation history

    var simulationHistory: [SimulationResult] {
        if let cached = _simulationHistoryCache { return cached }
        guard let data = defaults.data(forKey: Keys.simulationHistory) else {
            _simulationHistoryCache = []
            return []
        }
        do {
            let results = try JSONDecoder().decode([SimulationResult].self, from: data)
            _simulationHistoryCache = results
            return results
        } catch {
            logger.warning("Failed to decode simulation history: \(error.localizedDescription)")
            _simulationHistoryCache = []
            return []
        }
    }

    func recordSimulationResult(_ result: SimulationResult) {
        var history = simulationHistory
        history.insert(result, at: 0)
        if history.count > AppConstants.Storage.historyLimit { history.removeLast() }
        _simulationHistoryCache = history
        do {
            let data = try JSONEncoder().encode(history)
            defaults.set(data, forKey: Keys.simulationHistory)
        } catch {
            logger.error("Failed to encode simulation history: \(error.localizedDescription)")
        }
    }

    // MARK: - Hazard history

    var hazardHistory: [HazardResult] {
        if let cached = _hazardHistoryCache { return cached }
        guard let data = defaults.data(forKey: Keys.hazardHistory) else {
            _hazardHistoryCache = []
            return []
        }
        do {
            let results = try JSONDecoder().decode([HazardResult].self, from: data)
            _hazardHistoryCache = results
            return results
        } catch {
            logger.warning("Failed to decode hazard history: \(error.localizedDescription)")
            _hazardHistoryCache = []
            return []
        }
    }

    func recordHazardResult(_ result: HazardResult) {
        var history = hazardHistory
        history.insert(result, at: 0)
        if history.count > AppConstants.Storage.historyLimit { history.removeLast() }
        _hazardHistoryCache = history
        do {
            let data = try JSONEncoder().encode(history)
            defaults.set(data, forKey: Keys.hazardHistory)
        } catch {
            logger.error("Failed to encode hazard history: \(error.localizedDescription)")
        }
    }

    // MARK: - Bookmarks

    var bookmarks: Set<Int> {
        if let cached = _bookmarksCache { return cached }
        guard let data = defaults.data(forKey: Keys.bookmarks) else {
            _bookmarksCache = []
            return []
        }
        do {
            let list = try JSONDecoder().decode([Int].self, from: data)
            let result = Set(list)
            _bookmarksCache = result
            return result
        } catch {
            logger.warning("Failed to decode bookmarks: \(error.localizedDescription)")
            _bookmarksCache = []
            return []
        }
    }

    func toggleBookmark(questionNo: Int) {
        var current = bookmarks
        if current.contains(questionNo) {
            current.remove(questionNo)
        } else {
            current.insert(questionNo)
        }
        _bookmarksCache = current
        saveIntSet(current, forKey: Keys.bookmarks)
    }

    func isBookmarked(questionNo: Int) -> Bool {
        return bookmarks.contains(questionNo)
    }

    // MARK: - Wrong answers

    var wrongAnswers: Set<Int> {
        if let cached = _wrongAnswersCache { return cached }
        guard let data = defaults.data(forKey: Keys.wrongAnswers) else {
            _wrongAnswersCache = []
            return []
        }
        do {
            let list = try JSONDecoder().decode([Int].self, from: data)
            let result = Set(list)
            _wrongAnswersCache = result
            return result
        } catch {
            logger.warning("Failed to decode wrong answers: \(error.localizedDescription)")
            _wrongAnswersCache = []
            return []
        }
    }

    func addWrongAnswer(_ questionNo: Int) {
        var current = wrongAnswers
        current.insert(questionNo)
        _wrongAnswersCache = current
        saveIntSet(current, forKey: Keys.wrongAnswers)
    }

    func removeWrongAnswer(_ questionNo: Int) {
        var current = wrongAnswers
        current.remove(questionNo)
        _wrongAnswersCache = current
        saveIntSet(current, forKey: Keys.wrongAnswers)
    }

    // MARK: - Completed exam sets

    var completedExamSets: Set<Int> {
        if let cached = _completedExamSetsCache { return cached }
        guard let data = defaults.data(forKey: Keys.completedExamSets) else {
            _completedExamSetsCache = []
            return []
        }
        do {
            let list = try JSONDecoder().decode([Int].self, from: data)
            let result = Set(list)
            _completedExamSetsCache = result
            return result
        } catch {
            logger.warning("Failed to decode completed exam sets: \(error.localizedDescription)")
            _completedExamSetsCache = []
            return []
        }
    }

    func addCompletedExamSet(_ id: Int) {
        var current = completedExamSets
        current.insert(id)
        _completedExamSetsCache = current
        saveIntSet(current, forKey: Keys.completedExamSets)
    }

    /// Returns the most recent exam result for a given fixed exam set, if any.
    func latestResult(forExamSet setId: Int) -> ExamResult? {
        examHistory.first { $0.examSetId == setId }
    }

    // MARK: - Completed simulation sets

    var completedSimulationSets: Set<Int> {
        if let cached = _completedSimSetsCache { return cached }
        guard let data = defaults.data(forKey: Keys.completedSimSets) else {
            _completedSimSetsCache = []
            return []
        }
        do {
            let list = try JSONDecoder().decode([Int].self, from: data)
            let result = Set(list)
            _completedSimSetsCache = result
            return result
        } catch {
            _completedSimSetsCache = []
            return []
        }
    }

    func addCompletedSimulationSet(_ id: Int) {
        var current = completedSimulationSets
        current.insert(id)
        _completedSimSetsCache = current
        saveIntSet(current, forKey: Keys.completedSimSets)
    }

    // MARK: - Completed hazard sets

    var completedHazardSets: Set<Int> {
        if let cached = _completedHazardSetsCache { return cached }
        guard let data = defaults.data(forKey: Keys.completedHazardSets) else {
            _completedHazardSetsCache = []
            return []
        }
        do {
            let list = try JSONDecoder().decode([Int].self, from: data)
            let result = Set(list)
            _completedHazardSetsCache = result
            return result
        } catch {
            _completedHazardSetsCache = []
            return []
        }
    }

    func addCompletedHazardSet(_ id: Int) {
        var current = completedHazardSets
        current.insert(id)
        _completedHazardSetsCache = current
        saveIntSet(current, forKey: Keys.completedHazardSets)
    }

    // MARK: - Streak

    var streakCount: Int {
        if let cached = _streakCountCache { return cached }
        let value = defaults.integer(forKey: Keys.streakCount)
        _streakCountCache = value
        return value
    }

    var lastStudyDate: String? {
        if let cached = _lastStudyDateCache { return cached }
        let value = defaults.string(forKey: Keys.lastStudyDate)
        _lastStudyDateCache = .some(value)
        return value
    }

    func updateStreak() {
        let today = Date()
        let todayStr = Self.streakDateFormatter.string(from: today)

        let last = lastStudyDate
        if last == todayStr { return }

        var newStreak = 1
        if let last, let lastDate = Self.streakDateFormatter.date(from: last) {
            let diff = Calendar.current.dateComponents([.day], from: lastDate, to: today).day ?? 0
            if diff == 1 {
                newStreak = streakCount + 1
            }
        }

        defaults.set(newStreak, forKey: Keys.streakCount)
        defaults.set(todayStr, forKey: Keys.lastStudyDate)
        _streakCountCache = newStreak
        _lastStudyDateCache = .some(todayStr)
    }

    // MARK: - Continue learning position

    var lastTopicKey: String? {
        if let cached = _lastTopicKeyCache { return cached }
        let value = defaults.string(forKey: Keys.lastTopicKey)
        _lastTopicKeyCache = .some(value)
        return value
    }

    var lastQuestionIndex: Int {
        if let cached = _lastQuestionIndexCache { return cached }
        let value = defaults.integer(forKey: Keys.lastQuestionIndex)
        _lastQuestionIndexCache = value
        return value
    }

    func saveLastPosition(topicKey: String, index: Int) {
        defaults.set(topicKey, forKey: Keys.lastTopicKey)
        defaults.set(index, forKey: Keys.lastQuestionIndex)
        _lastTopicKeyCache = .some(topicKey)
        _lastQuestionIndexCache = index
    }

    // MARK: - Convenience wrappers (used by views)

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
            clearReview(questionNo: questionNo)
        } else {
            addWrongAnswer(questionNo)
            recordReview(questionNo: questionNo)
        }
        updateStreak()
        recordStudyActivity()
    }

    // MARK: - Reset

    func clearAllProgress() {
        clearTopicProgress()
        clearExamHistory()
        clearSimulationHistory()
        clearHazardHistory()
        clearBookmarks()
        clearWrongAnswers()
        clearStreak()
        invalidateCaches()
    }

    func clearTopicProgress() {
        let topicKeys = Topic.all.map(\.key) + [AppConstants.TopicKey.diemLiet]
        for key in topicKeys {
            defaults.removeObject(forKey: Keys.progressPrefix + key)
        }
        defaults.removeObject(forKey: Keys.lastTopicKey)
        defaults.removeObject(forKey: Keys.lastQuestionIndex)
        _topicProgressCache.removeAll()
        _lastTopicKeyCache = nil
        _lastQuestionIndexCache = nil
    }

    func clearExamHistory() {
        defaults.removeObject(forKey: Keys.examHistory)
        defaults.removeObject(forKey: Keys.completedExamSets)
        invalidateCaches()
    }

    func clearSimulationHistory() {
        defaults.removeObject(forKey: Keys.simulationHistory)
        defaults.removeObject(forKey: Keys.completedSimSets)
        invalidateCaches()
    }

    func clearHazardHistory() {
        defaults.removeObject(forKey: Keys.hazardHistory)
        defaults.removeObject(forKey: Keys.completedHazardSets)
        invalidateCaches()
    }

    func clearBookmarks() {
        defaults.removeObject(forKey: Keys.bookmarks)
        invalidateCaches()
    }

    func clearWrongAnswers() {
        defaults.removeObject(forKey: Keys.wrongAnswers)
        invalidateCaches()
    }

    func clearStreak() {
        defaults.removeObject(forKey: Keys.streakCount)
        defaults.removeObject(forKey: Keys.lastStudyDate)
        _streakCountCache = nil
        _lastStudyDateCache = nil
    }

    // MARK: - Private helpers

    private func saveIntSet(_ set: Set<Int>, forKey key: String) {
        do {
            let data = try JSONEncoder().encode(Array(set))
            defaults.set(data, forKey: key)
        } catch {
            logger.error("Failed to encode int set for key '\(key)': \(error.localizedDescription)")
        }
    }
}

// MARK: - AnswerStatus

enum AnswerStatus {
    case correct
    case wrong
    case unanswered
}
