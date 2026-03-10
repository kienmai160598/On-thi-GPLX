import Foundation

extension ProgressStore {

    private static let examDateKey = "exam_date"
    private static let dailyGoalKey = "daily_goal"

    var examDate: Date? {
        _ = dataVersion
        guard let interval = UserDefaults.standard.object(forKey: Self.examDateKey) as? TimeInterval else { return nil }
        return Date(timeIntervalSince1970: interval)
    }

    func setExamDate(_ date: Date?) {
        if let date {
            UserDefaults.standard.set(date.timeIntervalSince1970, forKey: Self.examDateKey)
        } else {
            UserDefaults.standard.removeObject(forKey: Self.examDateKey)
        }
        dataVersion += 1
    }

    var dailyGoal: Int {
        _ = dataVersion
        let goal = UserDefaults.standard.integer(forKey: Self.dailyGoalKey)
        return goal > 0 ? goal : 30
    }

    func setDailyGoal(_ goal: Int) {
        UserDefaults.standard.set(goal, forKey: Self.dailyGoalKey)
        dataVersion += 1
    }

    var daysUntilExam: Int? {
        guard let examDate else { return nil }
        return max(0, Calendar.current.dateComponents([.day], from: Date(), to: examDate).day ?? 0)
    }

    var todayProgress: (done: Int, goal: Int) {
        let done = activityCount(for: Date())
        return (done, dailyGoal)
    }
}
