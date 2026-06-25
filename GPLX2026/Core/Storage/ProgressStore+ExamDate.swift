import Foundation

extension ProgressStore {

    private static let examDateKey = "exam_date"
    private static let dailyGoalKey = "daily_goal"

    var examDate: Date? {
        if _examDateCacheLoaded { return _examDateCache }
        guard let interval = defaults.object(forKey: Self.examDateKey) as? TimeInterval else {
            _examDateCache = nil
            _examDateCacheLoaded = true
            return nil
        }
        let value = Date(timeIntervalSince1970: interval)
        _examDateCache = value
        _examDateCacheLoaded = true
        return value
    }

    func setExamDate(_ date: Date?) {
        if let date {
            safeWrite { $0.set(date.timeIntervalSince1970, forKey: Self.examDateKey) }
        } else {
            safeWrite { $0.removeObject(forKey: Self.examDateKey) }
        }
        _examDateCache = date
        _examDateCacheLoaded = true
    }

    var dailyGoal: Int {
        if let cached = _dailyGoalCache { return cached }
        let goal = defaults.integer(forKey: Self.dailyGoalKey)
        let value = goal > 0 ? goal : 30
        _dailyGoalCache = value
        return value
    }

    func setDailyGoal(_ goal: Int) {
        safeWrite { $0.set(goal, forKey: Self.dailyGoalKey) }
        _dailyGoalCache = goal
    }

    var daysUntilExam: Int? {
        guard let examDate else { return nil }
        let cal = Calendar.current
        let from = cal.startOfDay(for: Date())
        let to   = cal.startOfDay(for: examDate)
        guard let days = cal.dateComponents([.day], from: from, to: to).day else { return nil }
        // Once the exam day has passed, treat it as unset so the countdown UI
        // hides instead of pinning to "Hôm nay thi!" indefinitely.
        return days >= 0 ? days : nil
    }

    var todayProgress: (done: Int, goal: Int) {
        let done = activityCount(for: Date())
        return (done, dailyGoal)
    }
}
