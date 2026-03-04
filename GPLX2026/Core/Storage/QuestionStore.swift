import Foundation
import Observation

// MARK: - QuestionStore

@Observable
final class QuestionStore {

    // MARK: Published state

    private(set) var allQuestions: [Question] = []
    private(set) var isLoading = false

    /// Optional reference to ProgressStore for filtering bookmarks/wrong answers.
    var progressStore: ProgressStore?

    /// Topics with computed question counts.
    var topics: [Topic] {
        Topic.all.map { topic in
            let count = allQuestions.filter { topic.topicIds.contains($0.topic) }.count
            return topic.withQuestionCount(count)
        }
    }

    // MARK: - Memory tips cache

    private var memoryTipsCache: [String: [MemoryTip]]?

    // MARK: - Loading questions

    func loadQuestions() {
        guard allQuestions.isEmpty else { return }
        isLoading = true

        guard let url = Bundle.main.url(forResource: "questions", withExtension: "json"),
              let data = try? Data(contentsOf: url) else {
            isLoading = false
            return
        }

        do {
            allQuestions = try JSONDecoder().decode([Question].self, from: data)
        } catch {
            print("[QuestionStore] Failed to decode questions.json: \(error)")
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
        allQuestions.filter(\.isDiemLiet)
    }

    // MARK: - Memory tips

    /// Load and cache the memory_tips.json file.
    private func loadMemoryTipsIfNeeded() {
        guard memoryTipsCache == nil else { return }

        guard let url = Bundle.main.url(forResource: "memory_tips", withExtension: "json"),
              let data = try? Data(contentsOf: url) else {
            memoryTipsCache = [:]
            return
        }

        do {
            memoryTipsCache = try JSONDecoder().decode([String: [MemoryTip]].self, from: data)
        } catch {
            print("[QuestionStore] Failed to decode memory_tips.json: \(error)")
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
    /// Supports special keys: "diem_liet", "bookmarks", "wrong_answers".
    func questions(forTopicKey key: String) -> [Question] {
        switch key {
        case "all_questions":
            return allQuestions
        case "diem_liet":
            return diemLietQuestions
        case "bookmarks":
            if let ps = progressStore {
                let ids = ps.bookmarks
                return allQuestions.filter { ids.contains($0.no) }
            }
            return []
        case "wrong_answers":
            if let ps = progressStore {
                let ids = ps.wrongAnswers
                return allQuestions.filter { ids.contains($0.no) }
            }
            return []
        default:
            return questionsForTopic(key: key)
        }
    }

    // MARK: - Exam questions

    /// Generate 35 random questions for a mock exam.
    func randomExamQuestions() -> [Question] {
        guard allQuestions.count >= 35 else { return Array(allQuestions.shuffled()) }
        return Array(allQuestions.shuffled().prefix(35))
    }

    /// Fixed exam set questions. Each set takes a slice of 35 questions.
    func examSetQuestions(setId: Int) -> [Question] {
        let setSize = 35
        let startIndex = (setId - 1) * setSize
        guard startIndex < allQuestions.count else { return randomExamQuestions() }
        let endIndex = min(startIndex + setSize, allQuestions.count)
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
        allQuestions.filter { $0.topic == 6 && $0.hasImage }
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
