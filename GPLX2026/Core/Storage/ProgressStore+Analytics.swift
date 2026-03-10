import Foundation

extension ProgressStore {

    // MARK: - Overall progress

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

    // MARK: - Topic accuracy

    func topicAccuracy(for key: String) -> Double {
        let progress = topicProgress(for: key)
        guard !progress.isEmpty else { return 0 }
        let correct = progress.values.filter { $0 }.count
        return Double(correct) / Double(progress.count)
    }

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

    // MARK: - Diem liet mastery

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

    // MARK: - Readiness

    struct ReadinessStatus {
        let score: Double
        let percentage: Int
        let diemLiet: (correct: Int, total: Int)
        let totalCorrect: Int
        let totalQuestions: Int
        let totalAttempted: Int
        let isReady: Bool
        let passRate: Double

        enum Level { case ready, needsWork, notReady }

        var level: Level {
            if isReady { return .ready }
            return percentage >= AppConstants.Readiness.intermediatePercentage ? .needsWork : .notReady
        }
    }

    func readinessStatus(topics: [Topic], allQuestions: [Question]) -> ReadinessStatus {
        if let cached = _readinessCache { return cached }

        let totalCorrect = totalCorrectCount(topics: topics)
        let totalAttempted = totalAttemptedCount(topics: topics)
        let overallAccuracy = totalAttempted > 0 ? Double(totalCorrect) / Double(totalAttempted) : 0

        let dl = diemLietMastery(questions: allQuestions)
        let dlAccuracy = dl.total > 0 ? Double(dl.correct) / Double(dl.total) : 0

        let history = examHistory
        let passRate: Double = history.isEmpty ? 0 : Double(history.filter(\.passed).count) / Double(history.count)

        let totalQuestions = topics.reduce(0) { $0 + $1.questionCount }
        let coverage = totalQuestions > 0 ? Double(totalAttempted) / Double(totalQuestions) : 0

        let score = overallAccuracy * 0.4 + dlAccuracy * 0.3 + passRate * 0.2 + coverage * 0.1
        let pct = Int(score * 100)
        let isReady = pct >= AppConstants.Readiness.readyPercentage
            && dl.correct == dl.total
            && totalAttempted >= AppConstants.Readiness.attemptedGoal

        let result = ReadinessStatus(
            score: score,
            percentage: pct,
            diemLiet: dl,
            totalCorrect: totalCorrect,
            totalQuestions: totalQuestions,
            totalAttempted: totalAttempted,
            isReady: isReady,
            passRate: passRate
        )
        _readinessCache = result
        return result
    }

    // MARK: - Aggregate counts

    func correctCount(forTopic key: String) -> Int {
        topicProgress(for: key).values.filter { $0 }.count
    }

    func totalCorrectCount(topics: [Topic]) -> Int {
        topics.reduce(0) { $0 + correctCount(forTopic: $1.key) }
    }

    func totalAttemptedCount(topics: [Topic]) -> Int {
        topics.reduce(0) { $0 + topicProgress(for: $1.key).count }
    }

}
