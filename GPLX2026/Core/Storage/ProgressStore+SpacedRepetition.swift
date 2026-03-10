import Foundation

extension ProgressStore {

    private static let reviewDatesKey = "wrong_answer_review_dates"

    /// Returns the last review date for each wrong answer question number.
    var reviewDates: [Int: Date] {
        if let cached = _reviewDatesCache { return cached }
        guard let data = defaults.data(forKey: Self.reviewDatesKey) else {
            _reviewDatesCache = [:]
            return [:]
        }
        guard let raw = try? JSONDecoder().decode([String: TimeInterval].self, from: data) else {
            _reviewDatesCache = [:]
            return [:]
        }
        let value = raw.reduce(into: [Int: Date]()) { result, entry in
            if let no = Int(entry.key) {
                result[no] = Date(timeIntervalSince1970: entry.value)
            }
        }
        _reviewDatesCache = value
        return value
    }

    /// Record that a wrong answer was reviewed now.
    func recordReview(questionNo: Int) {
        var dates = reviewDates
        dates[questionNo] = Date()
        saveReviewDates(dates)
    }

    /// Remove review data for a question (when it's answered correctly and removed from wrong answers).
    func clearReview(questionNo: Int) {
        var dates = reviewDates
        dates.removeValue(forKey: questionNo)
        saveReviewDates(dates)
    }

    /// Sort wrong answer question numbers by review priority.
    /// Questions never reviewed come first, then oldest reviewed.
    func prioritizedWrongAnswers() -> [Int] {
        let wrong = Array(wrongAnswers)
        let dates = reviewDates

        return wrong.sorted { a, b in
            let dateA = dates[a]
            let dateB = dates[b]

            // Never reviewed → highest priority
            if dateA == nil && dateB != nil { return true }
            if dateA != nil && dateB == nil { return false }
            if dateA == nil && dateB == nil { return a < b }

            // Both reviewed → oldest first
            return dateA! < dateB!
        }
    }

    /// Questions due for review based on simple intervals.
    func wrongAnswersDueForReview() -> Set<Int> {
        let dates = reviewDates
        let now = Date()

        return wrongAnswers.filter { questionNo in
            guard let lastReview = dates[questionNo] else { return true }
            let daysSince = Calendar.current.dateComponents([.day], from: lastReview, to: now).day ?? 0
            return daysSince >= 1
        }
    }

    private func saveReviewDates(_ dates: [Int: Date]) {
        let raw = dates.reduce(into: [String: TimeInterval]()) { result, entry in
            result[String(entry.key)] = entry.value.timeIntervalSince1970
        }
        if let data = try? JSONEncoder().encode(raw) {
            defaults.set(data, forKey: Self.reviewDatesKey)
        }
        _reviewDatesCache = dates
    }
}
