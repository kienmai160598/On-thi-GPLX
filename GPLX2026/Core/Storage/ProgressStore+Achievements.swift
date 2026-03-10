import Foundation

extension ProgressStore {

    enum Achievement: String, CaseIterable {
        case firstExamPassed
        case diemLietMastered
        case streak7
        case streak30
        case questions100
        case questions500
        case firstSimPassed
        case firstHazardPassed
        case perfectExam

        var title: String {
            switch self {
            case .firstExamPassed: return "Lần đầu đỗ"
            case .diemLietMastered: return "Điểm liệt"
            case .streak7: return "7 ngày"
            case .streak30: return "30 ngày"
            case .questions100: return "100 câu"
            case .questions500: return "500 câu"
            case .firstSimPassed: return "Sa hình"
            case .firstHazardPassed: return "Tình huống"
            case .perfectExam: return "Tuyệt đối"
            }
        }

        var subtitle: String {
            switch self {
            case .firstExamPassed: return "Đỗ bài thi thử đầu tiên"
            case .diemLietMastered: return "Thuộc hết câu điểm liệt"
            case .streak7: return "Học 7 ngày liên tục"
            case .streak30: return "Học 30 ngày liên tục"
            case .questions100: return "Trả lời 100 câu hỏi"
            case .questions500: return "Trả lời 500 câu hỏi"
            case .firstSimPassed: return "Đỗ mô phỏng đầu tiên"
            case .firstHazardPassed: return "Đỗ tình huống đầu tiên"
            case .perfectExam: return "Đạt điểm tuyệt đối"
            }
        }

        var icon: String {
            switch self {
            case .firstExamPassed: return "checkmark.seal.fill"
            case .diemLietMastered: return "exclamationmark.triangle.fill"
            case .streak7: return "flame.fill"
            case .streak30: return "flame.circle.fill"
            case .questions100: return "text.page.fill"
            case .questions500: return "books.vertical.fill"
            case .firstSimPassed: return "map.fill"
            case .firstHazardPassed: return "play.circle.fill"
            case .perfectExam: return "star.fill"
            }
        }
    }

    // MARK: - Check achievements

    func unlockedAchievements(topics: [Topic], allQuestions: [Question]) -> Set<Achievement> {
        var unlocked = Set<Achievement>()

        // First exam passed
        if examHistory.contains(where: \.passed) {
            unlocked.insert(.firstExamPassed)
        }

        // Perfect exam (all correct)
        if examHistory.contains(where: { $0.score == $0.totalQuestions }) {
            unlocked.insert(.perfectExam)
        }

        // Diem liet mastered
        let dl = diemLietMastery(questions: allQuestions)
        if dl.total > 0 && dl.correct == dl.total {
            unlocked.insert(.diemLietMastered)
        }

        // Streaks
        if streakCount >= 7 { unlocked.insert(.streak7) }
        if streakCount >= 30 { unlocked.insert(.streak30) }

        // Questions answered
        let totalAnswered = totalAttemptedCount(topics: topics)
        if totalAnswered >= 100 { unlocked.insert(.questions100) }
        if totalAnswered >= 500 { unlocked.insert(.questions500) }

        // First simulation passed
        if simulationHistory.contains(where: \.passed) {
            unlocked.insert(.firstSimPassed)
        }

        // First hazard passed
        if hazardHistory.contains(where: \.passed) {
            unlocked.insert(.firstHazardPassed)
        }

        return unlocked
    }
}
