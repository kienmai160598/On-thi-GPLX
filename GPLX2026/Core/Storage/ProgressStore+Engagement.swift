import Foundation

extension ProgressStore {

    // MARK: - Keys

    private enum EngagementKeys {
        static let dailyChallengeHistory = "daily_challenge_history"
        static let dailyChallengeLastDate = "daily_challenge_last_date"
        static let dailyChallengeStreak = "daily_challenge_streak"
    }

    // MARK: - Daily Challenge History

    var dailyChallengeHistory: [ExamResult] {
        if let cached = _dailyChallengeHistoryCache { return cached }
        guard let results = SecureStorage.load([ExamResult].self, forKey: EngagementKeys.dailyChallengeHistory, defaults: defaults) else {
            _dailyChallengeHistoryCache = []
            return []
        }
        _dailyChallengeHistoryCache = results
        return results
    }

    func recordDailyChallengeResult(_ result: ExamResult) {
        var history = dailyChallengeHistory
        history.insert(result, at: 0)
        while history.count > AppConstants.Storage.historyLimit { history.removeLast() }
        _dailyChallengeHistoryCache = history
        safeWrite { SecureStorage.save(history, forKey: EngagementKeys.dailyChallengeHistory, defaults: $0) }
        updateDailyChallengeStreak()
    }

    // MARK: - Daily Challenge Streak

    var dailyChallengeStreak: Int {
        if let cached = _dailyChallengeStreakCache { return cached }
        let value = defaults.integer(forKey: EngagementKeys.dailyChallengeStreak)
        _dailyChallengeStreakCache = value
        return value
    }

    var dailyChallengeLastDate: String? {
        if _dailyChallengeLastDateLoaded { return _dailyChallengeLastDateCache }
        let value = defaults.string(forKey: EngagementKeys.dailyChallengeLastDate)
        _dailyChallengeLastDateCache = value
        _dailyChallengeLastDateLoaded = true
        return value
    }

    var hasCompletedTodayChallenge: Bool {
        guard let lastDate = dailyChallengeLastDate else { return false }
        let today = Self.streakDateFormatter.string(from: Date())
        return lastDate == today
    }

    private func updateDailyChallengeStreak() {
        let today = Self.streakDateFormatter.string(from: Date())
        let yesterday = Self.streakDateFormatter.string(from: Calendar.current.date(byAdding: .day, value: -1, to: Date())!)

        var newStreak: Int
        if dailyChallengeLastDate == yesterday {
            newStreak = dailyChallengeStreak + 1
        } else if dailyChallengeLastDate == today {
            newStreak = dailyChallengeStreak // Already counted today
        } else {
            newStreak = 1 // Reset streak
        }

        _dailyChallengeStreakCache = newStreak
        _dailyChallengeLastDateCache = today
        _dailyChallengeLastDateLoaded = true
        safeWrite { defaults in
            defaults.set(newStreak, forKey: EngagementKeys.dailyChallengeStreak)
            defaults.set(today, forKey: EngagementKeys.dailyChallengeLastDate)
        }
    }
}
