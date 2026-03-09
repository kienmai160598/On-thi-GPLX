import Foundation

extension ProgressStore {

    // MARK: - SmartNudge

    enum SmartNudge {
        case masterDiemLiet(remaining: Int)
        case weakTopic(topicName: String, topicKey: String, accuracy: Int)
        case takeExam
        case improveTopic(topicName: String, topicKey: String, accuracy: Int)
        case startSimulation
        case startHazard
        case testWeakestPart(partName: String)
        case examReady

        var label: String {
            switch self {
            case .masterDiemLiet(let remaining):
                return "Ôn điểm liệt — \(remaining) câu chưa thuộc"
            case .weakTopic(let topicName, _, let accuracy):
                return "Ôn chủ đề: \(topicName) (\(accuracy)%)"
            case .takeExam:
                return "Thi thử lý thuyết"
            case .improveTopic(let topicName, _, let accuracy):
                return "Cải thiện: \(topicName) (\(accuracy)%)"
            case .startSimulation:
                return "Bắt đầu ôn Mô phỏng"
            case .startHazard:
                return "Bắt đầu ôn Tình huống"
            case .testWeakestPart(let partName):
                return "Thi thử \(partName)"
            case .examReady:
                return "Sẵn sàng thi! Hãy thi thử lần nữa"
            }
        }

        var icon: String {
            switch self {
            case .masterDiemLiet:
                return "exclamationmark.triangle.fill"
            case .weakTopic:
                return "book.fill"
            case .takeExam:
                return "doc.text.fill"
            case .improveTopic:
                return "arrow.up.circle.fill"
            case .startSimulation:
                return "map.fill"
            case .startHazard:
                return "play.circle.fill"
            case .testWeakestPart:
                return "checkmark.circle.fill"
            case .examReady:
                return "star.fill"
            }
        }
    }

    // MARK: - Smart nudge logic

    func smartNudge(topics: [Topic], allQuestions: [Question]) -> SmartNudge {

        // Helpers
        let theoryTopics = topics.filter { !$0.topicIds.contains(6) }
        let simulationTopic = topics.first { $0.topicIds.contains(6) }

        // 1. Điểm liệt not mastered
        let dl = diemLietMastery(questions: allQuestions)
        if dl.correct < dl.total {
            return .masterDiemLiet(remaining: dl.total - dl.correct)
        }

        // 2. Any theory topic (not Topic 6) < 50% accuracy → weakest
        let theoryStats = weakTopics(topics: theoryTopics)
        if let weakest = theoryStats.first, weakest.accuracy < 0.5 {
            return .weakTopic(
                topicName: weakest.topic.shortName,
                topicKey: weakest.topic.key,
                accuracy: Int(weakest.accuracy * 100)
            )
        }

        // 3. No mock exam in 3+ days (or never taken but attempted 30+ questions)
        let totalAttempted = totalAttemptedCount(topics: topics)
        let lastExamDate = examHistory.first?.date
        let daysSinceExam: Int? = lastExamDate.map { date in
            Calendar.current.dateComponents([.day], from: date, to: Date()).day ?? 0
        }

        if let days = daysSinceExam {
            if days >= 3 {
                return .takeExam
            }
        } else if totalAttempted >= 30 {
            // Never taken an exam but attempted 30+ questions
            return .takeExam
        }

        // 4. Any theory topic 50-70% → weakest
        if let weakest = theoryStats.first, weakest.accuracy >= 0.5, weakest.accuracy < 0.7 {
            return .improveTopic(
                topicName: weakest.topic.shortName,
                topicKey: weakest.topic.key,
                accuracy: Int(weakest.accuracy * 100)
            )
        }

        // 5. Theory avg ≥70%, simulation (Topic 6) < 50%
        let theoryAvg: Double = {
            let stats = theoryStats
            guard !stats.isEmpty else { return 0 }
            return stats.reduce(0.0) { $0 + $1.accuracy } / Double(stats.count)
        }()

        let simulationAccuracy: Double = {
            guard let sim = simulationTopic else { return 0 }
            return topicAccuracy(for: sim.key)
        }()

        if theoryAvg >= 0.7 && simulationAccuracy < 0.5 {
            return .startSimulation
        }

        // 6. Simulation ≥70%, hazard avg < 50%
        let hazardAvg = averageHazardScore / 100.0 // averageHazardScore is 0-100 percentage
        if simulationAccuracy >= 0.7 && hazardAvg < 0.5 {
            return .startHazard
        }

        // 7. All parts ≥70% but not all ≥90% → testWeakestPart
        let partScores: [(name: String, score: Double)] = [
            ("Lý thuyết", theoryAvg),
            ("Mô phỏng", simulationAccuracy),
            ("Tình huống", hazardAvg),
        ]

        let allAbove70 = partScores.allSatisfy { $0.score >= 0.7 }
        let allAbove90 = partScores.allSatisfy { $0.score >= 0.9 }

        if allAbove70 && !allAbove90 {
            let weakest = partScores.min { $0.score < $1.score }!
            return .testWeakestPart(partName: weakest.name)
        }

        // 8. All ≥90%
        return .examReady
    }
}
