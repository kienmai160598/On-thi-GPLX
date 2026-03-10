import Foundation
import Observation
import os

private let logger = Logger(subsystem: "com.gplx2026", category: "QuestionStore")

// MARK: - QuestionStore

@Observable
final class QuestionStore {

    // MARK: Published state

    private(set) var allQuestions: [Question] = []
    private(set) var isLoading = false

    // MARK: - Cached derived data

    private(set) var topics: [Topic] = []
    private var _diemLietCache: [Question]?
    private var _simulationCache: [Question]?

    // MARK: - Memory tips cache

    private var memoryTipsCache: [String: [MemoryTip]]?

    // MARK: - Loading questions

    func loadQuestions() {
        guard allQuestions.isEmpty else { return }
        isLoading = true

        guard let url = Bundle.main.url(forResource: "questions", withExtension: "json") else {
            logger.error("questions.json not found in bundle")
            isLoading = false
            return
        }

        do {
            let data = try Data(contentsOf: url)
            allQuestions = try JSONDecoder().decode([Question].self, from: data)
            rebuildCaches()
        } catch {
            logger.error("Failed to load questions.json: \(error.localizedDescription)")
        }

        isLoading = false
    }

    // MARK: - Queries

    /// All questions that belong to a topic identified by its composite key (e.g. "1_2").
    func questionsForTopic(key: String) -> [Question] {
        let ids = key.split(separator: "_").compactMap { Int($0) }
        return questionsByTopic(topicIds: ids)
    }

    /// All questions whose `topic` value is in the given set of IDs.
    func questionsByTopic(topicIds: [Int]) -> [Question] {
        allQuestions.filter { topicIds.contains($0.topic) }
    }

    /// All "diem liet" (critical / disqualifying) questions.
    var diemLietQuestions: [Question] {
        if let cached = _diemLietCache { return cached }
        let result = allQuestions.filter(\.isDiemLiet)
        _diemLietCache = result
        return result
    }

    // MARK: - Memory tips

    /// Load and cache the memory_tips.json file.
    private func loadMemoryTipsIfNeeded() {
        guard memoryTipsCache == nil else { return }

        guard let url = Bundle.main.url(forResource: "memory_tips", withExtension: "json") else {
            memoryTipsCache = [:]
            return
        }

        do {
            let data = try Data(contentsOf: url)
            memoryTipsCache = try JSONDecoder().decode([String: [MemoryTip]].self, from: data)
        } catch {
            logger.error("Failed to load memory_tips.json: \(error.localizedDescription)")
            memoryTipsCache = [:]
        }
    }

    /// Memory tips for a given topic key (e.g. "1_2", "3", etc.).
    func memoryTips(for topicKey: String) -> [MemoryTip] {
        loadMemoryTipsIfNeeded()
        return memoryTipsCache?[topicKey] ?? []
    }

    /// Alias used by views: `memoryTips(forTopicKey:)`.
    func memoryTips(forTopicKey topicKey: String) -> [MemoryTip] {
        memoryTips(for: topicKey)
    }

    // MARK: - Topic lookup

    /// Find a `Topic` by its composite key (e.g. "1_2", "3").
    func topic(forKey key: String) -> Topic? {
        topics.first(where: { $0.key == key })
    }

    // MARK: - Questions for topic key (handles special keys)

    /// Returns questions for a given topic key.
    /// Supports special keys via `AppConstants.TopicKey`.
    /// Pass `filterIds` for bookmarks/wrong answers filtering.
    func questions(forTopicKey key: String, filterIds: Set<Int>? = nil) -> [Question] {
        switch key {
        case AppConstants.TopicKey.allQuestions:
            return allQuestions
        case AppConstants.TopicKey.diemLiet:
            return diemLietQuestions
        case AppConstants.TopicKey.bookmarks, AppConstants.TopicKey.wrongAnswers:
            guard let ids = filterIds else { return [] }
            return allQuestions.filter { ids.contains($0.no) }
        case let key where key.hasPrefix(AppConstants.TopicKey.wrongAnswers + ":"):
            guard let ids = filterIds else { return [] }
            let scopedTopicKey = String(key.dropFirst(AppConstants.TopicKey.wrongAnswers.count + 1))
            return questionsForTopic(key: scopedTopicKey).filter { ids.contains($0.no) }
        default:
            return questionsForTopic(key: key)
        }
    }

    // MARK: - Exam questions

    /// Generate random questions for a mock exam.
    func randomExamQuestions() -> [Question] {
        let diemLietQuestions = allQuestions.filter(\.isDiemLiet)
        let normalQuestions = allQuestions.filter { !$0.isDiemLiet }
        let dlCount = AppConstants.Exam.diemLietPerExam
        let normalCount = AppConstants.Exam.questionsPerExam - dlCount
        let selectedDL = Array(diemLietQuestions.shuffled().prefix(dlCount))
        let selectedNormal = Array(normalQuestions.shuffled().prefix(normalCount))
        return (selectedDL + selectedNormal).shuffled()
    }

    /// Fixed exam set questions. Each set takes a slice of questions.
    func examSetQuestions(setId: Int) -> [Question] {
        let perSet = AppConstants.Exam.questionsPerExam
        let startIndex = (setId - 1) * perSet
        let endIndex = min(startIndex + perSet, allQuestions.count)
        guard startIndex < allQuestions.count else { return [] }
        return Array(allQuestions[startIndex..<endIndex])
    }

    // MARK: - Diem Liet by topic

    /// Group diem liet questions by their topic.
    var diemLietByTopic: [(topic: Topic, questions: [Question])] {
        groupByTopic(diemLietQuestions)
    }

    // MARK: - Wrong answers by topic

    /// Group wrong answer questions by their topic.
    func wrongAnswersByTopic(wrongIds: Set<Int>) -> [(topic: Topic, questions: [Question])] {
        groupByTopic(allQuestions.filter { wrongIds.contains($0.no) })
    }

    // MARK: - Simulation questions

    /// All questions from Topic 6 (Sa hinh & Tinh huong) that have images.
    var simulationQuestions: [Question] {
        if let cached = _simulationCache { return cached }
        let result = allQuestions.filter { $0.topic == 6 && $0.hasImage }
        _simulationCache = result
        return result
    }

    /// Generate a random set of simulation scenario questions.
    func randomSimulationQuestions(count: Int = 20) -> [Question] {
        let pool = simulationQuestions
        guard pool.count >= count else { return pool.shuffled() }
        return Array(pool.shuffled().prefix(count))
    }

    /// All simulation questions in order (for full practice mode).
    func allSimulationQuestions() -> [Question] {
        simulationQuestions
    }

    /// Look up questions by their `no` values, preserving order.
    func questions(byNos nos: [Int]) -> [Question] {
        let lookup = Dictionary(uniqueKeysWithValues: allQuestions.map { ($0.no, $0) })
        return nos.compactMap { lookup[$0] }
    }

    // MARK: - Cache management

    private func rebuildCaches() {
        topics = Topic.all.map { topic in
            let count = allQuestions.filter { topic.topicIds.contains($0.topic) }.count
            return topic.withQuestionCount(count)
        }
        _diemLietCache = allQuestions.filter(\.isDiemLiet)
        _simulationCache = allQuestions.filter { $0.topic == 6 && $0.hasImage }
    }

    // MARK: - Private helpers

    private func groupByTopic(_ questions: [Question]) -> [(topic: Topic, questions: [Question])] {
        var grouped: [String: [Question]] = [:]
        for q in questions {
            let key = Topic.keyForTopicId(q.topic)
            grouped[key, default: []].append(q)
        }
        return topics.compactMap { topic in
            guard let qs = grouped[topic.key], !qs.isEmpty else { return nil }
            return (topic: topic, questions: qs)
        }
    }
}
