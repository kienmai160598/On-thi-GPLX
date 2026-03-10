import Foundation

extension ProgressStore {

    private static let activityKey = "study_activity"

    /// Returns study activity as [dateString: count] for the last N days.
    var studyActivity: [String: Int] {
        if let cached = _studyActivityCache { return cached }
        guard let data = defaults.data(forKey: Self.activityKey) else {
            _studyActivityCache = [:]
            return [:]
        }
        let value = (try? JSONDecoder().decode([String: Int].self, from: data)) ?? [:]
        _studyActivityCache = value
        return value
    }

    /// Record one question answered today.
    func recordStudyActivity() {
        let today = Self.activityDateString(from: Date())
        var activity = studyActivity
        activity[today, default: 0] += 1
        // Keep only last 120 days
        let cutoff = Calendar.current.date(byAdding: .day, value: -120, to: Date())!
        let cutoffStr = Self.activityDateString(from: cutoff)
        activity = activity.filter { $0.key >= cutoffStr }
        if let data = try? JSONEncoder().encode(activity) {
            defaults.set(data, forKey: Self.activityKey)
        }
        _studyActivityCache = activity
    }

    /// Activity count for a specific date.
    func activityCount(for date: Date) -> Int {
        studyActivity[Self.activityDateString(from: date)] ?? 0
    }

    /// Total questions answered in the last N days.
    func totalActivity(lastDays: Int) -> Int {
        let calendar = Calendar.current
        var total = 0
        for i in 0..<lastDays {
            if let date = calendar.date(byAdding: .day, value: -i, to: Date()) {
                total += activityCount(for: date)
            }
        }
        return total
    }

    private static let _activityFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f
    }()

    private static func activityDateString(from date: Date) -> String {
        _activityFormatter.string(from: date)
    }
}
