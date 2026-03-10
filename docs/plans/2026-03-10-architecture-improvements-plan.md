# Architecture Improvements Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Split ProgressStore god object, extract ViewModels, merge duplicate result views, add ThemeStore, and create test target.

**Architecture:** Create 3 independent @Observable stores (StudyProgressStore, ExamHistoryStore, ActivityStore) + AnalyticsService to replace the monolithic ProgressStore. Extract ExamViewModel, QuestionViewModel, HazardViewModel from views. Merge ExamResultView/SimulationResultView. Cache theme colors in ThemeStore.

**Tech Stack:** SwiftUI, @Observable (Observation framework), XCTest, xcodegen (project.yml)

---

## Phase 1: Foundation

### Task 1: Create ThemeStore (A5)

**Files:**
- Create: `GPLX2026/Core/Theme/ThemeStore.swift`

**Step 1: Create ThemeStore**

```swift
// GPLX2026/Core/Theme/ThemeStore.swift
import SwiftUI
import Observation

@Observable
final class ThemeStore {

    var primaryColorKey: String {
        didSet { defaults.set(primaryColorKey, forKey: AppConstants.StorageKey.primaryColor) }
    }

    var primaryColor: Color { Color.primaryColor(for: primaryColorKey) }

    var onPrimaryColor: Color {
        if primaryColorKey == "default" {
            return Color.adaptive(light: 0xFAFAFA, dark: 0x1A1A1A)
        }
        return .white
    }

    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        self.primaryColorKey = defaults.string(forKey: AppConstants.StorageKey.primaryColor) ?? "default"
    }
}
```

**Step 2: Inject ThemeStore in GPLX2026App.swift**

Add `@State private var themeStore = ThemeStore()` and `.environment(themeStore)` alongside existing stores.

**Step 3: Update AppButton.swift to use ThemeStore**

Replace `@AppStorage(AppConstants.StorageKey.primaryColor) private var primaryColorKey = "default"` with `@Environment(ThemeStore.self) private var themeStore` and use `themeStore.primaryColor` / `themeStore.onPrimaryColor`.

**Step 4: Update AnimatedBackground.swift to use ThemeStore**

Replace `@AppStorage(AppConstants.StorageKey.primaryColor) private var primaryColorKey = "default"` with `@Environment(ThemeStore.self) private var themeStore`. Use `themeStore.primaryColor` in Canvas.

Note: AnimatedBackground uses color inside a Canvas closure which runs on render thread. Read `themeStore.primaryColor` outside the Canvas, store in a local let, and pass it into the draw functions.

**Step 5: Update all views using `Color.appPrimary` or `Color.appOnPrimary`**

There are ~23 files using `Color.appPrimary`. For each:
- If the file already has access to ThemeStore via environment, use `themeStore.primaryColor`
- If the file is a small component (ProgressRing, FilterChip, etc.), add `@Environment(ThemeStore.self) private var themeStore`
- Replace `Color.appPrimary` → `themeStore.primaryColor`
- Replace `Color.appOnPrimary` → `themeStore.onPrimaryColor`

Key files to update (from grep results):
- `HomeTab.swift`, `ExamTab.swift`, `HazardTestView.swift`, `HazardResultView.swift`
- `QuestionView.swift`, `SettingsView.swift`, `WeakTopicsView.swift`
- `OnboardingView.swift`, `OnboardingPageView.swift`
- `RulePill.swift`, `ExamQuestionGridSheet.swift`, `ExamCountdownCard.swift`
- `QuestionCard.swift`, `FilterChip.swift`, `InlinePill.swift`
- `QuestionSearchView.swift`, `ExamLoadingView.swift`, `QuestionReviewRow.swift`
- `ProgressRing.swift`, `ContentView.swift`
- `AchievementsCard.swift`, `ScoreTrendCard.swift`, `ActivityCalendarCard.swift`

**Step 6: Remove `Color.appPrimary` and `Color.appOnPrimary` from AppTheme.swift**

Delete lines 47-55 (the two static computed properties). Keep `Color.primaryColor(for:)` static method since ThemeStore uses it internally.

Also remove `static let accentTerra = appPrimary` on line 105 — replace with direct reference or remove if unused.

**Step 7: Update SettingsView color picker**

SettingsView has `@AppStorage(AppConstants.StorageKey.primaryColor)` for the color picker. Change to write through `themeStore.primaryColorKey` instead.

**Step 8: Build and verify**

Run: `xcodebuild -project GPLX2026.xcodeproj -scheme GPLX2026 -destination 'platform=iOS Simulator,name=iPhone 16' build 2>&1 | tail -5`
Expected: BUILD SUCCEEDED

**Step 9: Commit**

```bash
git add GPLX2026/Core/Theme/ThemeStore.swift
git add -u
git commit -m "feat(A5): add ThemeStore to cache primary color, remove UserDefaults reads per access"
```

---

### Task 2: Add test target scaffold (A4)

**Files:**
- Modify: `project.yml`
- Create: `GPLX2026Tests/GPLX2026Tests.swift`

**Step 1: Create test directory and placeholder test**

```swift
// GPLX2026Tests/GPLX2026Tests.swift
import Testing
@testable import GPLX2026

@Test func sanityCheck() {
    #expect(true)
}
```

**Step 2: Add test target to project.yml**

Append after the GPLX2026 target:

```yaml
  GPLX2026Tests:
    type: bundle.unit-test
    platform: iOS
    sources:
      - GPLX2026Tests
    dependencies:
      - target: GPLX2026
    settings:
      base:
        GENERATE_INFOPLIST_FILE: YES
```

**Step 3: Regenerate Xcode project**

Run: `xcodegen generate`

**Step 4: Build tests**

Run: `xcodebuild -project GPLX2026.xcodeproj -scheme GPLX2026Tests -destination 'platform=iOS Simulator,name=iPhone 16' test 2>&1 | tail -10`
Expected: Test suite passed

**Step 5: Commit**

```bash
git add project.yml GPLX2026Tests/
git commit -m "feat(A4): add test target with Swift Testing scaffold"
```

---

## Phase 2: New Stores (A1)

Strategy: Create new stores alongside old ProgressStore. Both exist simultaneously until migration complete. New stores use fresh UserDefaults keys (fresh start OK per decision).

### Task 3: Create StudyProgressStore

**Files:**
- Create: `GPLX2026/Core/Storage/StudyProgressStore.swift`

This store owns: topic progress, bookmarks, wrong answers, completed exam sets, last study position, spaced repetition review dates.

**Step 1: Create StudyProgressStore**

```swift
// GPLX2026/Core/Storage/StudyProgressStore.swift
import Foundation
import Observation
import os

private let logger = Logger(subsystem: "com.gplx2026", category: "StudyProgressStore")

@Observable
final class StudyProgressStore {

    // MARK: - Storage keys

    private enum Keys {
        static let progressPrefix    = "progress_"
        static let bookmarks         = "bookmarks"
        static let wrongAnswers      = "wrong_answers"
        static let completedExamSets = "completed_exam_sets"
        static let lastTopicKey      = "last_topic_key"
        static let lastQuestionIndex = "last_question_index"
        static let reviewDates       = "wrong_answer_review_dates"
    }

    // MARK: - Stored properties (tracked by @Observable)

    private var _topicProgressCache: [String: [Int: Bool]] = [:]
    private(set) var bookmarks: Set<Int> = []
    private(set) var wrongAnswers: Set<Int> = []
    private(set) var completedExamSets: Set<Int> = []
    private(set) var lastTopicKey: String?
    private(set) var lastQuestionIndex: Int = 0
    private(set) var reviewDates: [Int: Date] = [:]

    let defaults: UserDefaults

    // MARK: - Init

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        loadCaches()
    }

    private func loadCaches() {
        bookmarks = loadIntSet(forKey: Keys.bookmarks)
        wrongAnswers = loadIntSet(forKey: Keys.wrongAnswers)
        completedExamSets = loadIntSet(forKey: Keys.completedExamSets)
        lastTopicKey = defaults.string(forKey: Keys.lastTopicKey)
        lastQuestionIndex = defaults.integer(forKey: Keys.lastQuestionIndex)
        reviewDates = loadReviewDates()
    }

    // MARK: - Topic progress

    func topicProgress(for key: String) -> [Int: Bool] {
        if let cached = _topicProgressCache[key] { return cached }
        guard let data = defaults.data(forKey: Keys.progressPrefix + key) else {
            _topicProgressCache[key] = [:]
            return [:]
        }
        do {
            let dict = try JSONDecoder().decode([String: Bool].self, from: data)
            let result = dict.reduce(into: [Int: Bool]()) { r, pair in
                if let intKey = Int(pair.key) { r[intKey] = pair.value }
            }
            _topicProgressCache[key] = result
            return result
        } catch {
            logger.warning("Failed to decode topic progress for '\(key)': \(error.localizedDescription)")
            _topicProgressCache[key] = [:]
            return [:]
        }
    }

    func saveQuestionResult(topicKey: String, questionNo: Int, correct: Bool) {
        var current = topicProgress(for: topicKey)
        current[questionNo] = correct
        _topicProgressCache[topicKey] = current
        let encoded = current.reduce(into: [String: Bool]()) { $0[String($1.key)] = $1.value }
        if let data = try? JSONEncoder().encode(encoded) {
            defaults.set(data, forKey: Keys.progressPrefix + topicKey)
        }
    }

    // MARK: - Bookmarks

    func isBookmarked(questionNo: Int) -> Bool {
        bookmarks.contains(questionNo)
    }

    func toggleBookmark(questionNo: Int) {
        if bookmarks.contains(questionNo) {
            bookmarks.remove(questionNo)
        } else {
            bookmarks.insert(questionNo)
        }
        saveIntSet(bookmarks, forKey: Keys.bookmarks)
    }

    // MARK: - Wrong answers

    func addWrongAnswer(_ questionNo: Int) {
        wrongAnswers.insert(questionNo)
        saveIntSet(wrongAnswers, forKey: Keys.wrongAnswers)
    }

    func removeWrongAnswer(_ questionNo: Int) {
        wrongAnswers.remove(questionNo)
        saveIntSet(wrongAnswers, forKey: Keys.wrongAnswers)
    }

    // MARK: - Completed exam sets

    func addCompletedExamSet(_ id: Int) {
        completedExamSets.insert(id)
        saveIntSet(completedExamSets, forKey: Keys.completedExamSets)
    }

    // MARK: - Last position

    func saveLastPosition(topicKey: String, index: Int) {
        self.lastTopicKey = topicKey
        self.lastQuestionIndex = index
        defaults.set(topicKey, forKey: Keys.lastTopicKey)
        defaults.set(index, forKey: Keys.lastQuestionIndex)
    }

    // MARK: - Spaced repetition

    func recordReview(questionNo: Int) {
        reviewDates[questionNo] = Date()
        saveReviewDates()
    }

    func clearReview(questionNo: Int) {
        reviewDates.removeValue(forKey: questionNo)
        saveReviewDates()
    }

    func prioritizedWrongAnswers() -> [Int] {
        let wrong = Array(wrongAnswers)
        let dates = reviewDates
        return wrong.sorted { a, b in
            let dateA = dates[a]
            let dateB = dates[b]
            if dateA == nil && dateB != nil { return true }
            if dateA != nil && dateB == nil { return false }
            if dateA == nil && dateB == nil { return a < b }
            return dateA! < dateB!
        }
    }

    func wrongAnswersDueForReview() -> Set<Int> {
        let dates = reviewDates
        let now = Date()
        return wrongAnswers.filter { questionNo in
            guard let lastReview = dates[questionNo] else { return true }
            let daysSince = Calendar.current.dateComponents([.day], from: lastReview, to: now).day ?? 0
            return daysSince >= 1
        }
    }

    // MARK: - Compound action

    /// Records answer + updates wrong answers + spaced repetition.
    /// Caller is responsible for streak/activity updates (on ActivityStore).
    func recordQuestionAnswer(topicKey: String, questionNo: Int, correct: Bool) {
        saveQuestionResult(topicKey: topicKey, questionNo: questionNo, correct: correct)
        if correct {
            removeWrongAnswer(questionNo)
            clearReview(questionNo: questionNo)
        } else {
            addWrongAnswer(questionNo)
            recordReview(questionNo: questionNo)
        }
    }

    // MARK: - Convenience

    func isCorrect(topicKey: String, questionNo: Int) -> Bool {
        topicProgress(for: topicKey)[questionNo] == true
    }

    func answerStatus(topicKey: String, questionNo: Int) -> AnswerStatus {
        guard let result = topicProgress(for: topicKey)[questionNo] else { return .unanswered }
        return result ? .correct : .wrong
    }

    // MARK: - Analytics helpers

    func correctCount(forTopic key: String) -> Int {
        topicProgress(for: key).values.filter { $0 }.count
    }

    func totalCorrectCount(topics: [Topic]) -> Int {
        topics.reduce(0) { $0 + correctCount(forTopic: $1.key) }
    }

    func totalAttemptedCount(topics: [Topic]) -> Int {
        topics.reduce(0) { $0 + topicProgress(for: $1.key).count }
    }

    func topicAccuracy(for key: String) -> Double {
        let progress = topicProgress(for: key)
        guard !progress.isEmpty else { return 0 }
        let correct = progress.values.filter { $0 }.count
        return Double(correct) / Double(progress.count)
    }

    func overallProgress(topics: [Topic]) -> Double {
        var totalAnswered = 0
        var totalQuestions = 0
        for topic in topics {
            totalAnswered += topicProgress(for: topic.key).count
            totalQuestions += topic.questionCount
        }
        guard totalQuestions > 0 else { return 0 }
        return Double(totalAnswered) / Double(totalQuestions)
    }

    func weakTopics(topics: [Topic]) -> [(topic: Topic, accuracy: Double, correct: Int, attempted: Int, total: Int)] {
        topics.compactMap { topic in
            let progress = topicProgress(for: topic.key)
            let correct = progress.values.filter { $0 }.count
            let attempted = progress.count
            let accuracy = attempted > 0 ? Double(correct) / Double(attempted) : 0
            return (topic, accuracy, correct, attempted, topic.questionCount)
        }
        .sorted { $0.accuracy < $1.accuracy }
    }

    func diemLietMastery(questions: [Question]) -> (correct: Int, total: Int) {
        let diemLietQuestions = questions.filter(\.isDiemLiet)
        var correct = 0
        for q in diemLietQuestions {
            let topicKey = Topic.keyForTopicId(q.topic)
            if topicProgress(for: topicKey)[q.no] == true { correct += 1 }
        }
        return (correct, diemLietQuestions.count)
    }

    // MARK: - Clear

    func clearTopicProgress() {
        let topicKeys = Topic.all.map(\.key) + [AppConstants.TopicKey.diemLiet]
        for key in topicKeys {
            defaults.removeObject(forKey: Keys.progressPrefix + key)
        }
        defaults.removeObject(forKey: Keys.lastTopicKey)
        defaults.removeObject(forKey: Keys.lastQuestionIndex)
        _topicProgressCache.removeAll()
        lastTopicKey = nil
        lastQuestionIndex = 0
    }

    func clearBookmarks() {
        defaults.removeObject(forKey: Keys.bookmarks)
        bookmarks = []
    }

    func clearWrongAnswers() {
        defaults.removeObject(forKey: Keys.wrongAnswers)
        defaults.removeObject(forKey: Keys.reviewDates)
        wrongAnswers = []
        reviewDates = [:]
    }

    func clearAll() {
        clearTopicProgress()
        clearBookmarks()
        clearWrongAnswers()
        defaults.removeObject(forKey: Keys.completedExamSets)
        completedExamSets = []
    }

    // MARK: - Private helpers

    private func saveIntSet(_ set: Set<Int>, forKey key: String) {
        if let data = try? JSONEncoder().encode(Array(set)) {
            defaults.set(data, forKey: key)
        }
    }

    private func loadIntSet(forKey key: String) -> Set<Int> {
        guard let data = defaults.data(forKey: key),
              let list = try? JSONDecoder().decode([Int].self, from: data) else { return [] }
        return Set(list)
    }

    private func loadReviewDates() -> [Int: Date] {
        guard let data = defaults.data(forKey: Keys.reviewDates),
              let raw = try? JSONDecoder().decode([String: TimeInterval].self, from: data) else { return [:] }
        return raw.reduce(into: [:]) { result, entry in
            if let no = Int(entry.key) { result[no] = Date(timeIntervalSince1970: entry.value) }
        }
    }

    private func saveReviewDates() {
        let raw = reviewDates.reduce(into: [String: TimeInterval]()) {
            $0[String($1.key)] = $1.value.timeIntervalSince1970
        }
        if let data = try? JSONEncoder().encode(raw) {
            defaults.set(data, forKey: Keys.reviewDates)
        }
    }
}
```

**Step 2: Build**

Run: `xcodebuild -project GPLX2026.xcodeproj -scheme GPLX2026 -destination 'platform=iOS Simulator,name=iPhone 16' build 2>&1 | tail -5`

**Step 3: Commit**

```bash
git add GPLX2026/Core/Storage/StudyProgressStore.swift
git commit -m "feat(A1): add StudyProgressStore — topic progress, bookmarks, wrong answers"
```

---

### Task 4: Create ExamHistoryStore

**Files:**
- Create: `GPLX2026/Core/Storage/ExamHistoryStore.swift`

**Step 1: Create ExamHistoryStore**

```swift
// GPLX2026/Core/Storage/ExamHistoryStore.swift
import Foundation
import Observation
import os

private let logger = Logger(subsystem: "com.gplx2026", category: "ExamHistoryStore")

@Observable
final class ExamHistoryStore {

    private enum Keys {
        static let examHistory       = "exam_history"
        static let simulationHistory = "simulation_history"
        static let hazardHistory     = "hazard_history"
    }

    private(set) var examHistory: [ExamResult] = []
    private(set) var simulationHistory: [SimulationResult] = []
    private(set) var hazardHistory: [HazardResult] = []

    let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        examHistory = loadHistory(forKey: Keys.examHistory)
        simulationHistory = loadHistory(forKey: Keys.simulationHistory)
        hazardHistory = loadHistory(forKey: Keys.hazardHistory)
    }

    // MARK: - Record

    func recordExamResult(_ result: ExamResult) {
        examHistory.insert(result, at: 0)
        if examHistory.count > AppConstants.Storage.historyLimit { examHistory.removeLast() }
        saveHistory(examHistory, forKey: Keys.examHistory)
    }

    func recordSimulationResult(_ result: SimulationResult) {
        simulationHistory.insert(result, at: 0)
        if simulationHistory.count > AppConstants.Storage.historyLimit { simulationHistory.removeLast() }
        saveHistory(simulationHistory, forKey: Keys.simulationHistory)
    }

    func recordHazardResult(_ result: HazardResult) {
        hazardHistory.insert(result, at: 0)
        if hazardHistory.count > AppConstants.Storage.historyLimit { hazardHistory.removeLast() }
        saveHistory(hazardHistory, forKey: Keys.hazardHistory)
    }

    // MARK: - Query

    func latestResult(forExamSet setId: Int) -> ExamResult? {
        examHistory.first { $0.examSetId == setId }
    }

    // MARK: - Exam stats

    var averageExamScore: Double { average(examHistory, \.accuracy) }
    var bestExamScore: Double { examHistory.map(\.accuracy).max() ?? 0 }
    var examCount: Int { examHistory.count }

    // MARK: - Simulation stats

    var averageSimulationScore: Double { average(simulationHistory, \.accuracy) }
    var bestSimulationScore: Double { simulationHistory.map(\.accuracy).max() ?? 0 }
    var simulationExamCount: Int { simulationHistory.count }

    // MARK: - Hazard stats

    var averageHazardScore: Double { average(hazardHistory, \.scorePercentage) }
    var bestHazardScore: Int { hazardHistory.map(\.totalScore).max() ?? 0 }
    var hazardExamCount: Int { hazardHistory.count }

    var hazardPracticedCount: Int {
        var seen = Set<Int>()
        for result in hazardHistory {
            for detail in result.details { seen.insert(detail.situationId) }
        }
        return seen.count
    }

    func chapterAverageScore(chapterId: Int) -> Double {
        guard let chapter = HazardSituation.chapters.first(where: { $0.id == chapterId }) else { return 0 }
        let chapterIds = Set(chapter.range)
        var totalScore = 0, totalMax = 0
        for result in hazardHistory {
            for detail in result.details where chapterIds.contains(detail.situationId) {
                totalScore += detail.score
                totalMax += AppConstants.Hazard.maxScorePerSituation
            }
        }
        guard totalMax > 0 else { return 0 }
        return Double(totalScore) / Double(totalMax)
    }

    func chapterHasPractice(chapterId: Int) -> Bool {
        guard let chapter = HazardSituation.chapters.first(where: { $0.id == chapterId }) else { return false }
        let chapterIds = Set(chapter.range)
        return hazardHistory.contains { result in
            result.details.contains { chapterIds.contains($0.situationId) }
        }
    }

    // MARK: - Clear

    func clearExamHistory() {
        defaults.removeObject(forKey: Keys.examHistory)
        examHistory = []
    }

    func clearSimulationHistory() {
        defaults.removeObject(forKey: Keys.simulationHistory)
        simulationHistory = []
    }

    func clearHazardHistory() {
        defaults.removeObject(forKey: Keys.hazardHistory)
        hazardHistory = []
    }

    func clearAll() {
        clearExamHistory()
        clearSimulationHistory()
        clearHazardHistory()
    }

    // MARK: - Private

    private func average<T>(_ items: [T], _ value: (T) -> Double) -> Double {
        guard !items.isEmpty else { return 0 }
        return items.reduce(0.0) { $0 + value($1) } / Double(items.count)
    }

    private func loadHistory<T: Decodable>(forKey key: String) -> [T] {
        guard let data = defaults.data(forKey: key) else { return [] }
        do {
            return try JSONDecoder().decode([T].self, from: data)
        } catch {
            logger.warning("Failed to decode \(key): \(error.localizedDescription)")
            return []
        }
    }

    private func saveHistory<T: Encodable>(_ history: [T], forKey key: String) {
        do {
            let data = try JSONEncoder().encode(history)
            defaults.set(data, forKey: key)
        } catch {
            logger.error("Failed to encode \(key): \(error.localizedDescription)")
        }
    }
}
```

**Step 2: Build and commit**

```bash
git add GPLX2026/Core/Storage/ExamHistoryStore.swift
git commit -m "feat(A1): add ExamHistoryStore — exam/simulation/hazard history + stats"
```

---

### Task 5: Create ActivityStore

**Files:**
- Create: `GPLX2026/Core/Storage/ActivityStore.swift`

**Step 1: Create ActivityStore**

```swift
// GPLX2026/Core/Storage/ActivityStore.swift
import Foundation
import Observation

@Observable
final class ActivityStore {

    private enum Keys {
        static let streakCount   = "streak_count"
        static let lastStudyDate = "last_study_date"
        static let studyActivity = "study_activity"
        static let examDate      = "exam_date"
        static let dailyGoal     = "daily_goal"
    }

    private(set) var streakCount: Int = 0
    private(set) var lastStudyDate: String?
    private(set) var studyActivity: [String: Int] = [:]
    var examDate: Date? {
        didSet {
            if let examDate {
                defaults.set(examDate.timeIntervalSince1970, forKey: Keys.examDate)
            } else {
                defaults.removeObject(forKey: Keys.examDate)
            }
        }
    }
    var dailyGoal: Int {
        didSet { defaults.set(dailyGoal, forKey: Keys.dailyGoal) }
    }

    let defaults: UserDefaults

    private static let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f
    }()

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        streakCount = defaults.integer(forKey: Keys.streakCount)
        lastStudyDate = defaults.string(forKey: Keys.lastStudyDate)
        let goal = defaults.integer(forKey: Keys.dailyGoal)
        dailyGoal = goal > 0 ? goal : 30
        if let interval = defaults.object(forKey: Keys.examDate) as? TimeInterval {
            examDate = Date(timeIntervalSince1970: interval)
        }
        studyActivity = Self.loadActivity(defaults: defaults)
    }

    // MARK: - Streak

    func updateStreak() {
        let today = Date()
        let todayStr = Self.dateFormatter.string(from: today)
        if lastStudyDate == todayStr { return }

        var newStreak = 1
        if let last = lastStudyDate, let lastDate = Self.dateFormatter.date(from: last) {
            let diff = Calendar.current.dateComponents([.day], from: lastDate, to: today).day ?? 0
            if diff == 1 { newStreak = streakCount + 1 }
        }

        streakCount = newStreak
        lastStudyDate = todayStr
        defaults.set(newStreak, forKey: Keys.streakCount)
        defaults.set(todayStr, forKey: Keys.lastStudyDate)
    }

    // MARK: - Activity

    func recordStudyActivity() {
        let today = Self.dateString(from: Date())
        studyActivity[today, default: 0] += 1
        let cutoff = Calendar.current.date(byAdding: .day, value: -120, to: Date())!
        let cutoffStr = Self.dateString(from: cutoff)
        studyActivity = studyActivity.filter { $0.key >= cutoffStr }
        if let data = try? JSONEncoder().encode(studyActivity) {
            defaults.set(data, forKey: Keys.studyActivity)
        }
    }

    func activityCount(for date: Date) -> Int {
        studyActivity[Self.dateString(from: date)] ?? 0
    }

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

    // MARK: - Computed

    var daysUntilExam: Int? {
        guard let examDate else { return nil }
        return max(0, Calendar.current.dateComponents([.day], from: Date(), to: examDate).day ?? 0)
    }

    var todayProgress: (done: Int, goal: Int) {
        (activityCount(for: Date()), dailyGoal)
    }

    // MARK: - Clear

    func clearStreak() {
        defaults.removeObject(forKey: Keys.streakCount)
        defaults.removeObject(forKey: Keys.lastStudyDate)
        streakCount = 0
        lastStudyDate = nil
    }

    func clearAll() {
        clearStreak()
        defaults.removeObject(forKey: Keys.studyActivity)
        defaults.removeObject(forKey: Keys.examDate)
        defaults.removeObject(forKey: Keys.dailyGoal)
        studyActivity = [:]
        examDate = nil
        dailyGoal = 30
    }

    // MARK: - Private

    private static func dateString(from date: Date) -> String {
        dateFormatter.string(from: date)
    }

    private static func loadActivity(defaults: UserDefaults) -> [String: Int] {
        guard let data = defaults.data(forKey: Keys.studyActivity) else { return [:] }
        return (try? JSONDecoder().decode([String: Int].self, from: data)) ?? [:]
    }
}
```

**Step 2: Build and commit**

```bash
git add GPLX2026/Core/Storage/ActivityStore.swift
git commit -m "feat(A1): add ActivityStore — streaks, daily activity, exam date"
```

---

### Task 6: Create AnalyticsService

**Files:**
- Create: `GPLX2026/Core/Storage/AnalyticsService.swift`

This is stateless — pure functions that read from the stores.

**Step 1: Create AnalyticsService**

```swift
// GPLX2026/Core/Storage/AnalyticsService.swift
import Foundation

enum AnalyticsService {

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

    static func readinessStatus(
        study: StudyProgressStore,
        history: ExamHistoryStore,
        topics: [Topic],
        allQuestions: [Question]
    ) -> ReadinessStatus {
        let totalCorrect = study.totalCorrectCount(topics: topics)
        let totalAttempted = study.totalAttemptedCount(topics: topics)
        let overallAccuracy = totalAttempted > 0 ? Double(totalCorrect) / Double(totalAttempted) : 0

        let dl = study.diemLietMastery(questions: allQuestions)
        let dlAccuracy = dl.total > 0 ? Double(dl.correct) / Double(dl.total) : 0

        let exams = history.examHistory
        let passRate: Double = exams.isEmpty ? 0 : Double(exams.filter(\.passed).count) / Double(exams.count)

        let totalQuestions = topics.reduce(0) { $0 + $1.questionCount }
        let coverage = totalQuestions > 0 ? Double(totalAttempted) / Double(totalQuestions) : 0

        let score = overallAccuracy * 0.4 + dlAccuracy * 0.3 + passRate * 0.2 + coverage * 0.1
        let pct = Int(score * 100)
        let isReady = pct >= AppConstants.Readiness.readyPercentage
            && dl.correct == dl.total
            && totalAttempted >= AppConstants.Readiness.attemptedGoal

        return ReadinessStatus(
            score: score, percentage: pct, diemLiet: dl,
            totalCorrect: totalCorrect, totalQuestions: totalQuestions,
            totalAttempted: totalAttempted, isReady: isReady, passRate: passRate
        )
    }

    // MARK: - Smart Nudge

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
            case .masterDiemLiet(let remaining): return "Ôn điểm liệt — \(remaining) câu chưa thuộc"
            case .weakTopic(let name, _, let acc): return "Ôn chủ đề: \(name) (\(acc)%)"
            case .takeExam: return "Thi thử lý thuyết"
            case .improveTopic(let name, _, let acc): return "Cải thiện: \(name) (\(acc)%)"
            case .startSimulation: return "Bắt đầu ôn Mô phỏng"
            case .startHazard: return "Bắt đầu ôn Tình huống"
            case .testWeakestPart(let name): return "Thi thử \(name)"
            case .examReady: return "Sẵn sàng thi! Hãy thi thử lần nữa"
            }
        }

        var icon: String {
            switch self {
            case .masterDiemLiet: return "exclamationmark.triangle.fill"
            case .weakTopic: return "book.fill"
            case .takeExam: return "doc.text.fill"
            case .improveTopic: return "arrow.up.circle.fill"
            case .startSimulation: return "map.fill"
            case .startHazard: return "play.circle.fill"
            case .testWeakestPart: return "checkmark.circle.fill"
            case .examReady: return "star.fill"
            }
        }

        var subtitle: String? {
            switch self {
            case .masterDiemLiet: return "Sai 1 câu điểm liệt = Trượt ngay"
            case .weakTopic: return "Chủ đề cần ôn nhiều hơn"
            case .takeExam: return "Kiểm tra kiến thức tổng hợp"
            case .improveTopic: return "Nâng cao độ chính xác"
            case .startSimulation: return "Lý thuyết đã ổn, chuyển sang sa hình"
            case .startHazard: return "Sa hình đã ổn, chuyển sang video"
            case .testWeakestPart: return "Tìm điểm yếu còn lại"
            case .examReady: return "Tất cả phần đều ≥90%"
            }
        }
    }

    static func smartNudge(
        study: StudyProgressStore,
        history: ExamHistoryStore,
        topics: [Topic],
        allQuestions: [Question]
    ) -> SmartNudge {
        let theoryTopics = topics.filter { !$0.topicIds.contains(6) }
        let simulationTopic = topics.first { $0.topicIds.contains(6) }

        // 1. Điểm liệt not mastered
        let dl = study.diemLietMastery(questions: allQuestions)
        if dl.correct < dl.total {
            return .masterDiemLiet(remaining: dl.total - dl.correct)
        }

        // 2. Any theory topic < 50%
        let theoryStats = study.weakTopics(topics: theoryTopics)
        if let weakest = theoryStats.first, weakest.accuracy < 0.5 {
            return .weakTopic(topicName: weakest.topic.shortName, topicKey: weakest.topic.key, accuracy: Int(weakest.accuracy * 100))
        }

        // 3. No mock exam in 3+ days
        let totalAttempted = study.totalAttemptedCount(topics: topics)
        let lastExamDate = history.examHistory.first?.date
        let daysSinceExam: Int? = lastExamDate.map {
            Calendar.current.dateComponents([.day], from: $0, to: Date()).day ?? 0
        }
        if let days = daysSinceExam, days >= 3 { return .takeExam }
        if daysSinceExam == nil && totalAttempted >= 30 { return .takeExam }

        // 4. Any theory topic 50-70%
        if let weakest = theoryStats.first, weakest.accuracy >= 0.5, weakest.accuracy < 0.7 {
            return .improveTopic(topicName: weakest.topic.shortName, topicKey: weakest.topic.key, accuracy: Int(weakest.accuracy * 100))
        }

        // 5. Theory ≥70%, simulation < 50%
        let theoryAvg: Double = {
            guard !theoryStats.isEmpty else { return 0 }
            return theoryStats.reduce(0.0) { $0 + $1.accuracy } / Double(theoryStats.count)
        }()
        let simAccuracy: Double = {
            guard let sim = simulationTopic else { return 0 }
            return study.topicAccuracy(for: sim.key)
        }()
        if theoryAvg >= 0.7 && simAccuracy < 0.5 { return .startSimulation }

        // 6. Simulation ≥70%, hazard < 50%
        let hazardAvg = history.averageHazardScore
        if simAccuracy >= 0.7 && hazardAvg < 0.5 { return .startHazard }

        // 7. All ≥70% but not all ≥90%
        let partScores: [(name: String, score: Double)] = [
            ("Lý thuyết", theoryAvg), ("Mô phỏng", simAccuracy), ("Tình huống", hazardAvg),
        ]
        let allAbove70 = partScores.allSatisfy { $0.score >= 0.7 }
        let allAbove90 = partScores.allSatisfy { $0.score >= 0.9 }
        if allAbove70 && !allAbove90 {
            let weakest = partScores.min { $0.score < $1.score }!
            return .testWeakestPart(partName: weakest.name)
        }

        return .examReady
    }

    // MARK: - Achievements

    enum Achievement: String, CaseIterable {
        case firstExamPassed, diemLietMastered, streak7, streak30
        case questions100, questions500, firstSimPassed, firstHazardPassed, perfectExam

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

    static func unlockedAchievements(
        study: StudyProgressStore,
        history: ExamHistoryStore,
        activity: ActivityStore,
        topics: [Topic],
        allQuestions: [Question]
    ) -> Set<Achievement> {
        var unlocked = Set<Achievement>()

        if history.examHistory.contains(where: \.passed) { unlocked.insert(.firstExamPassed) }
        if history.examHistory.contains(where: { $0.score == $0.totalQuestions }) { unlocked.insert(.perfectExam) }

        let dl = study.diemLietMastery(questions: allQuestions)
        if dl.total > 0 && dl.correct == dl.total { unlocked.insert(.diemLietMastered) }

        if activity.streakCount >= 7 { unlocked.insert(.streak7) }
        if activity.streakCount >= 30 { unlocked.insert(.streak30) }

        let totalAnswered = study.totalAttemptedCount(topics: topics)
        if totalAnswered >= 100 { unlocked.insert(.questions100) }
        if totalAnswered >= 500 { unlocked.insert(.questions500) }

        if history.simulationHistory.contains(where: \.passed) { unlocked.insert(.firstSimPassed) }
        if history.hazardHistory.contains(where: \.passed) { unlocked.insert(.firstHazardPassed) }

        return unlocked
    }
}
```

**Step 2: Build and commit**

```bash
git add GPLX2026/Core/Storage/AnalyticsService.swift
git commit -m "feat(A1): add AnalyticsService — readiness, smart nudge, achievements"
```

---

## Phase 3: Wire Up & Migrate Views

### Task 7: Wire up new stores and migrate GPLX2026App + delete old ProgressStore

**Files:**
- Modify: `GPLX2026/GPLX2026App.swift`
- Delete: `GPLX2026/Core/Storage/ProgressStore.swift`
- Delete: `GPLX2026/Core/Storage/ProgressStore+Activity.swift`
- Delete: `GPLX2026/Core/Storage/ProgressStore+Analytics.swift`
- Delete: `GPLX2026/Core/Storage/ProgressStore+ExamDate.swift`
- Delete: `GPLX2026/Core/Storage/ProgressStore+ExamHistory.swift`
- Delete: `GPLX2026/Core/Storage/ProgressStore+SmartNudge.swift`
- Delete: `GPLX2026/Core/Storage/ProgressStore+SpacedRepetition.swift`
- Delete: `GPLX2026/Core/Storage/ProgressStore+Achievements.swift`

**Step 1: Update GPLX2026App.swift**

Replace `@State private var progressStore = ProgressStore()` with:

```swift
@State private var studyStore = StudyProgressStore()
@State private var historyStore = ExamHistoryStore()
@State private var activityStore = ActivityStore()
```

Replace `.environment(progressStore)` with:

```swift
.environment(studyStore)
.environment(historyStore)
.environment(activityStore)
```

**Step 2: Delete old ProgressStore files**

```bash
rm GPLX2026/Core/Storage/ProgressStore.swift
rm GPLX2026/Core/Storage/ProgressStore+Activity.swift
rm GPLX2026/Core/Storage/ProgressStore+Analytics.swift
rm GPLX2026/Core/Storage/ProgressStore+ExamDate.swift
rm GPLX2026/Core/Storage/ProgressStore+ExamHistory.swift
rm GPLX2026/Core/Storage/ProgressStore+SmartNudge.swift
rm GPLX2026/Core/Storage/ProgressStore+SpacedRepetition.swift
rm GPLX2026/Core/Storage/ProgressStore+Achievements.swift
```

**Step 3: Move `AnswerStatus` enum to its own location or into StudyProgressStore**

The `AnswerStatus` enum was at the bottom of `ProgressStore.swift`. Move it into `StudyProgressStore.swift` (already included above) or create a small file. Since it's already used by `StudyProgressStore.answerStatus()`, keep it alongside.

Create `GPLX2026/Core/Models/AnswerStatus.swift`:
```swift
enum AnswerStatus {
    case correct
    case wrong
    case unanswered
}
```

**Step 4: Do NOT build yet** — views still reference `ProgressStore`. Proceed to Task 8.

---

### Task 8: Migrate all views from ProgressStore to new stores

This is the largest task. Every file referencing `ProgressStore` needs updating. The pattern is mechanical:

**Replacement rules:**

| Old | New |
|-----|-----|
| `@Environment(ProgressStore.self) private var progressStore` | Replace with the specific stores the view needs |
| `progressStore.topicProgress(for:)` | `studyStore.topicProgress(for:)` |
| `progressStore.bookmarks` | `studyStore.bookmarks` |
| `progressStore.wrongAnswers` | `studyStore.wrongAnswers` |
| `progressStore.isBookmarked(questionNo:)` | `studyStore.isBookmarked(questionNo:)` |
| `progressStore.toggleBookmark(questionNo:)` | `studyStore.toggleBookmark(questionNo:)` |
| `progressStore.recordQuestionAnswer(...)` | `studyStore.recordQuestionAnswer(...); activityStore.updateStreak(); activityStore.recordStudyActivity()` |
| `progressStore.saveLastPosition(...)` | `studyStore.saveLastPosition(...)` |
| `progressStore.lastTopicKey` | `studyStore.lastTopicKey` |
| `progressStore.lastQuestionIndex` | `studyStore.lastQuestionIndex` |
| `progressStore.completedExamSets` | `studyStore.completedExamSets` |
| `progressStore.addCompletedExamSet(...)` | `studyStore.addCompletedExamSet(...)` |
| `progressStore.examHistory` | `historyStore.examHistory` |
| `progressStore.simulationHistory` | `historyStore.simulationHistory` |
| `progressStore.hazardHistory` | `historyStore.hazardHistory` |
| `progressStore.recordExamResult(...)` | `historyStore.recordExamResult(...)` |
| `progressStore.recordSimulationResult(...)` | `historyStore.recordSimulationResult(...)` |
| `progressStore.recordHazardResult(...)` | `historyStore.recordHazardResult(...)` |
| `progressStore.latestResult(forExamSet:)` | `historyStore.latestResult(forExamSet:)` |
| `progressStore.streakCount` | `activityStore.streakCount` |
| `progressStore.todayProgress` | `activityStore.todayProgress` |
| `progressStore.examDate` | `activityStore.examDate` |
| `progressStore.setExamDate(...)` | `activityStore.examDate = ...` |
| `progressStore.dailyGoal` | `activityStore.dailyGoal` |
| `progressStore.setDailyGoal(...)` | `activityStore.dailyGoal = ...` |
| `progressStore.daysUntilExam` | `activityStore.daysUntilExam` |
| `progressStore.studyActivity` | `activityStore.studyActivity` |
| `progressStore.activityCount(for:)` | `activityStore.activityCount(for:)` |
| `progressStore.updateStreak()` | `activityStore.updateStreak()` |
| `progressStore.recordStudyActivity()` | `activityStore.recordStudyActivity()` |
| `progressStore.readinessStatus(topics:allQuestions:)` | `AnalyticsService.readinessStatus(study: studyStore, history: historyStore, topics:, allQuestions:)` |
| `progressStore.smartNudge(topics:allQuestions:)` | `AnalyticsService.smartNudge(study: studyStore, history: historyStore, topics:, allQuestions:)` |
| `progressStore.unlockedAchievements(...)` | `AnalyticsService.unlockedAchievements(study: studyStore, history: historyStore, activity: activityStore, ...)` |
| `progressStore.averageExamScore` | `historyStore.averageExamScore` |
| `progressStore.bestExamScore` | `historyStore.bestExamScore` |
| `progressStore.examCount` | `historyStore.examCount` |
| `progressStore.averageSimulationScore` | `historyStore.averageSimulationScore` |
| `progressStore.averageHazardScore` | `historyStore.averageHazardScore` |
| `progressStore.hazardPracticedCount` | `historyStore.hazardPracticedCount` |
| `progressStore.chapterAverageScore(...)` | `historyStore.chapterAverageScore(...)` |
| `progressStore.chapterHasPractice(...)` | `historyStore.chapterHasPractice(...)` |
| `progressStore.overallProgress(topics:)` | `studyStore.overallProgress(topics:)` |
| `progressStore.topicAccuracy(for:)` | `studyStore.topicAccuracy(for:)` |
| `progressStore.weakTopics(topics:)` | `studyStore.weakTopics(topics:)` |
| `progressStore.diemLietMastery(questions:)` | `studyStore.diemLietMastery(questions:)` |
| `progressStore.correctCount(forTopic:)` | `studyStore.correctCount(forTopic:)` |
| `progressStore.isCorrect(topicKey:questionNo:)` | `studyStore.isCorrect(topicKey:questionNo:)` |
| `progressStore.answerStatus(topicKey:questionNo:)` | `studyStore.answerStatus(topicKey:questionNo:)` |
| `progressStore.prioritizedWrongAnswers()` | `studyStore.prioritizedWrongAnswers()` |
| `progressStore.wrongAnswersDueForReview()` | `studyStore.wrongAnswersDueForReview()` |
| `progressStore.clearAllProgress()` | Call `studyStore.clearAll(); historyStore.clearAll(); activityStore.clearAll()` |
| `progressStore.clearTopicProgress()` | `studyStore.clearTopicProgress()` |
| `progressStore.clearExamHistory()` | `historyStore.clearExamHistory()` |
| `progressStore.clearSimulationHistory()` | `historyStore.clearSimulationHistory()` |
| `progressStore.clearHazardHistory()` | `historyStore.clearHazardHistory()` |
| `progressStore.clearBookmarks()` | `studyStore.clearBookmarks()` |
| `progressStore.clearWrongAnswers()` | `studyStore.clearWrongAnswers()` |
| `progressStore.clearStreak()` | `activityStore.clearStreak()` |

**CRITICAL: `recordQuestionAnswer` no longer calls streak/activity.**

In the old code, `ProgressStore.recordQuestionAnswer()` called `updateStreak()` and `recordStudyActivity()` internally. In the new architecture, `StudyProgressStore.recordQuestionAnswer()` only handles study data. Views that call `recordQuestionAnswer` must also call:
```swift
activityStore.updateStreak()
activityStore.recordStudyActivity()
```

This applies to:
- `BaseExamView.swift` — `confirmSimulationAnswer()`, `handleSimulationTimeout()`, `submitMockExam()`
- `QuestionView.swift` — `confirmAnswer()`
- `HazardTestView.swift` — wherever it records answers

**Files to migrate (from grep):**

1. `HomeTab.swift` — needs studyStore, historyStore, activityStore
2. `PracticeTab.swift` — needs studyStore, historyStore
3. `ExamTab.swift` — needs studyStore, historyStore
4. `SettingsView.swift` — needs studyStore, historyStore, activityStore
5. `BaseExamView.swift` — needs studyStore, historyStore, activityStore
6. `QuestionView.swift` — needs studyStore, activityStore
7. `HazardTestView.swift` — needs studyStore, historyStore, activityStore
8. `TopicsView.swift` — needs studyStore
9. `WeakTopicsView.swift` — needs studyStore
10. `TopicDetailView.swift` — needs studyStore
11. `BookmarksView.swift` — needs studyStore
12. `WrongAnswersView.swift` — needs studyStore
13. `QuestionSearchView.swift` — needs studyStore
14. `StudyHeatMap.swift` — needs activityStore
15. `ExamCountdownCard.swift` — needs activityStore
16. `AchievementsCard.swift` — needs studyStore, historyStore, activityStore
17. `ScoreTrendCard.swift` — needs historyStore
18. `ActivityCalendarCard.swift` — needs activityStore

**Step: Migrate each file mechanically using the table above.**

**After all files migrated, build:**

Run: `xcodebuild -project GPLX2026.xcodeproj -scheme GPLX2026 -destination 'platform=iOS Simulator,name=iPhone 16' build 2>&1 | tail -20`

Fix any remaining compile errors — likely missed references.

**Commit:**

```bash
git add -u
git add GPLX2026/Core/Models/AnswerStatus.swift
git commit -m "refactor(A1): replace ProgressStore with StudyProgressStore, ExamHistoryStore, ActivityStore

Delete ProgressStore god object and all 8 extension files.
Migrate all 18 view files to use independent stores.
AnalyticsService provides readiness, smart nudge, achievements as static functions."
```

---

## Phase 4: Merge Result Views (A3)

### Task 9: Create unified ExamResultView

**Files:**
- Modify: `GPLX2026/Features/Exam/ExamResultView.swift`
- Delete: `GPLX2026/Features/Simulation/SimulationResultView.swift`
- Modify: `GPLX2026/Features/Exam/BaseExamView.swift` (update result destination)
- Modify: `GPLX2026/Features/Simulation/SimulationHistoryDetailView.swift`

**Step 1: Define ResultConfig**

Add to `ExamResultView.swift`:

```swift
struct ResultConfig {
    let screenTitle: String           // "Kết quả thi" / "Kết quả mô phỏng"
    let historyTitle: String          // "Chi tiết bài thi" / "Chi tiết mô phỏng"
    let score: Int
    let total: Int
    let passed: Bool
    let timeUsedSeconds: Int
    let passRequirementText: String
    let extraRows: [(label: String, value: String, color: Color)]
    let questions: [Question]
    let answers: [Int: Int]
    let timedOutBadgeForUnanswered: String?   // nil for exam, "Hết giờ" for simulation
    let retryExamScreen: ExamScreen?          // nil when isFromHistory
}
```

**Step 2: Add factory methods**

```swift
extension ResultConfig {
    static func forExam(
        questions: [Question], answers: [Int: Int],
        timeUsedSeconds: Int, result: ExamResult, isFromHistory: Bool
    ) -> ResultConfig {
        ResultConfig(
            screenTitle: "Kết quả thi",
            historyTitle: "Chi tiết bài thi",
            score: result.score,
            total: questions.count,
            passed: result.passed,
            timeUsedSeconds: timeUsedSeconds,
            passRequirementText: "≥ \(AppConstants.Exam.passThreshold) & 0 ĐL sai",
            extraRows: [
                ("Điểm liệt sai", "\(result.wrongDiemLiet)",
                 result.wrongDiemLiet > 0 ? Color.appError : Color.appSuccess)
            ],
            questions: questions,
            answers: answers,
            timedOutBadgeForUnanswered: nil,
            retryExamScreen: isFromHistory ? nil : .mockExam(examSetId: result.examSetId)
        )
    }

    static func forSimulation(
        questions: [Question], answers: [Int: Int],
        result: SimulationResult, isFromHistory: Bool
    ) -> ResultConfig {
        ResultConfig(
            screenTitle: "Kết quả mô phỏng",
            historyTitle: "Chi tiết mô phỏng",
            score: result.score,
            total: questions.count,
            passed: result.passed,
            timeUsedSeconds: result.totalTimeUsedSeconds,
            passRequirementText: "≥ 70% (\(Int(Double(questions.count) * 0.7))/\(questions.count))",
            extraRows: [
                ("Hết thời gian", "\(result.timedOutCount)",
                 result.timedOutCount > 0 ? Color.appWarning : Color.appSuccess)
            ],
            questions: questions,
            answers: answers,
            timedOutBadgeForUnanswered: "Hết giờ",
            retryExamScreen: isFromHistory ? nil : .simulationExam(mode: .random)
        )
    }
}
```

**Step 3: Rewrite ExamResultView to use ResultConfig**

```swift
struct ExamResultView: View {
    @Environment(\.popToRoot) private var popToRoot
    @Environment(\.openExam) private var openExam

    let config: ResultConfig

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                Spacer().frame(height: 8)

                ResultHero(
                    isPassed: config.passed,
                    score: config.score,
                    total: config.total,
                    subtitle: config.passed
                        ? "Chúc mừng bạn đã vượt qua!"
                        : "Hãy ôn tập thêm và thử lại nhé"
                )

                VStack(spacing: 0) {
                    ScoreRow(label: "Câu đúng", value: "\(config.score)/\(config.total)", color: Color.appSuccess)
                    Divider().padding(.horizontal, 16)
                    ScoreRow(label: "Câu sai", value: "\(config.total - config.score)/\(config.total)", color: Color.appError)

                    for row in config.extraRows {
                        Divider().padding(.horizontal, 16)
                        ScoreRow(label: row.label, value: row.value, color: row.color)
                    }

                    Divider().padding(.horizontal, 16)
                    let minutes = config.timeUsedSeconds / 60
                    let seconds = config.timeUsedSeconds % 60
                    ScoreRow(label: "Thời gian", value: String(format: "%02d:%02d", minutes, seconds), color: Color.appTextMedium)
                    Divider().padding(.horizontal, 16)
                    ScoreRow(label: "Yêu cầu đạt", value: config.passRequirementText, color: Color.appTextMedium)
                }
                .padding(.vertical, 4)
                .glassCard()

                SectionTitle(title: "Xem lại đáp án")

                LazyVStack(spacing: 8) {
                    ForEach(Array(config.questions.enumerated()), id: \.element.no) { index, question in
                        let selectedId = config.answers[index]
                        let isCorrect = selectedId != nil && question.answers.contains(where: { $0.id == selectedId && $0.correct })
                        QuestionReviewRow(
                            question: question,
                            status: selectedId == nil ? .unanswered : isCorrect ? .correct : .wrong,
                            selectedAnswerId: selectedId,
                            timeUsedBadge: selectedId == nil ? config.timedOutBadgeForUnanswered : nil
                        )
                        .glassCard()
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 32)
        }
        .safeAreaInset(edge: .bottom) {
            if config.retryExamScreen != nil {
                VStack(spacing: 8) {
                    let wrongCount = config.total - config.score
                    if wrongCount > 0 {
                        Button {
                            openExam(.questionView(topicKey: AppConstants.TopicKey.wrongAnswers, startIndex: 0))
                        } label: {
                            AppButton(icon: "arrow.trianglehead.2.clockwise", label: "Luyện \(wrongCount) câu sai", style: .secondary, height: 48)
                        }
                    }

                    HStack(spacing: 10) {
                        Button {
                            if let screen = config.retryExamScreen { openExam(screen) }
                        } label: {
                            AppButton(icon: "arrow.counterclockwise", label: "Thi lại", style: .secondary, height: 48)
                        }

                        Button { popToRoot() } label: {
                            AppButton(icon: "checkmark", label: "Hoàn thành", height: 48)
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(.ultraThinMaterial)
            }
        }
        .navigationBarBackButtonHidden(config.retryExamScreen != nil)
        .screenHeader(config.retryExamScreen != nil ? config.screenTitle : config.historyTitle)
        .toolbar {
            if config.retryExamScreen != nil {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button { popToRoot() } label: {
                        Image(systemName: "checkmark")
                            .font(.system(size: 15, weight: .semibold))
                    }
                }
            }
        }
    }
}
```

**Step 4: Update BaseExamView.swift resultDestination**

```swift
@ViewBuilder
private var resultDestination: some View {
    if let result = examResult {
        ExamResultView(config: .forExam(
            questions: questions, answers: answers,
            timeUsedSeconds: result.timeUsedSeconds, result: result, isFromHistory: false
        ))
    } else if let result = simulationResult {
        ExamResultView(config: .forSimulation(
            questions: questions, answers: answers,
            result: result, isFromHistory: false
        ))
    }
}
```

**Step 5: Update SimulationHistoryDetailView.swift**

```swift
var body: some View {
    ExamResultView(config: .forSimulation(
        questions: questions, answers: answers,
        result: result, isFromHistory: true
    ))
}
```

**Step 6: Update ExamHistoryDetailView.swift** (if it exists — uses old ExamResultView)

Check and update to use `ResultConfig.forExam(... isFromHistory: true)`.

**Step 7: Delete SimulationResultView.swift**

```bash
rm GPLX2026/Features/Simulation/SimulationResultView.swift
```

**Step 8: Build and commit**

```bash
git add -u
git commit -m "refactor(A3): merge ExamResultView + SimulationResultView into unified view with ResultConfig"
```

---

## Phase 5: Extract ViewModels (A2)

### Task 10: Extract ExamViewModel

**Files:**
- Create: `GPLX2026/Features/Exam/ExamViewModel.swift`
- Modify: `GPLX2026/Features/Exam/BaseExamView.swift`

**Step 1: Create ExamViewModel**

Extract all state and logic from `BaseExamView` into an `@Observable` class. The VM receives stores via init (not environment — VMs should not depend on SwiftUI environment).

```swift
// GPLX2026/Features/Exam/ExamViewModel.swift
import Foundation
import Observation

@Observable
final class ExamViewModel {

    // MARK: - Dependencies
    private let questionStore: QuestionStore
    private let studyStore: StudyProgressStore
    private let historyStore: ExamHistoryStore
    private let activityStore: ActivityStore

    let mode: BaseExamView.Mode

    // MARK: - State
    private(set) var questions: [Question] = []
    var currentIndex = 0
    var answers: [Int: Int] = [:]
    var timePerScenario: [Int: Int] = [:]
    private(set) var remainingSeconds = 0
    var showSubmitDialog = false
    var showExitDialog = false
    var navigateToResult = false
    var selectedAnswerId: Int?
    var isRevealed = false
    private(set) var examResult: ExamResult?
    private(set) var simulationResult: SimulationResult?

    private var deadline: Date?
    private var timer: Timer?
    private var savedRemainingTime: [Int: Int] = [:]

    // MARK: - Computed

    var isMockExam: Bool {
        if case .mockExam = mode { return true }
        return false
    }

    var timerText: String {
        if isMockExam {
            let m = remainingSeconds / 60
            let s = remainingSeconds % 60
            return String(format: "%02d:%02d", m, s)
        }
        return "\(remainingSeconds)s"
    }

    var isUrgent: Bool {
        isMockExam
            ? remainingSeconds <= AppConstants.Exam.urgencyThresholdSeconds
            : remainingSeconds <= AppConstants.Simulation.urgencyThresholdSeconds
    }

    var isLast: Bool { currentIndex + 1 >= questions.count }

    var isBookmarked: Bool {
        guard !questions.isEmpty else { return false }
        return studyStore.isBookmarked(questionNo: questions[currentIndex].no)
    }

    // MARK: - Init

    init(mode: BaseExamView.Mode, questionStore: QuestionStore, studyStore: StudyProgressStore, historyStore: ExamHistoryStore, activityStore: ActivityStore) {
        self.mode = mode
        self.questionStore = questionStore
        self.studyStore = studyStore
        self.historyStore = historyStore
        self.activityStore = activityStore
    }

    // MARK: - Start

    func startExam() {
        switch mode {
        case .mockExam(let setId):
            questions = setId != nil ? questionStore.examSetQuestions(setId: setId!) : questionStore.randomExamQuestions()
            remainingSeconds = AppConstants.Exam.totalTimeSeconds
            startGlobalTimer()
        case .simulation(let simMode):
            switch simMode {
            case .random: questions = questionStore.randomSimulationQuestions(count: 20)
            case .fullPractice: questions = questionStore.allSimulationQuestions()
            }
            remainingSeconds = AppConstants.Simulation.scenarioTimeSeconds
            startScenarioTimer()
        }
    }

    func cleanup() {
        timer?.invalidate()
        deadline = nil
    }

    // MARK: - Actions

    func toggleBookmark() {
        guard !questions.isEmpty else { return }
        studyStore.toggleBookmark(questionNo: questions[currentIndex].no)
    }

    func handlePrev() {
        if isMockExam {
            currentIndex -= 1
        } else if currentIndex > 0 {
            saveCurrentTimerState()
            currentIndex -= 1
            restoreStateForCurrentIndex()
        }
    }

    func handleNext() {
        if isMockExam {
            if isLast {
                showSubmitDialog = true
            } else {
                currentIndex += 1
            }
        } else {
            if isRevealed {
                advanceOrFinishSimulation()
            } else if let answerId = selectedAnswerId {
                confirmSimulationAnswer(answerId: answerId, question: questions[currentIndex])
            }
        }
    }

    func selectIndex(_ index: Int) {
        if !isMockExam { saveCurrentTimerState() }
        currentIndex = index
        if !isMockExam { restoreStateForCurrentIndex() }
    }

    func selectSimulationAnswer(_ answerId: Int) {
        guard !isRevealed else { return }
        selectedAnswerId = answerId
    }

    func selectMockExamAnswer(_ answerId: Int) {
        answers[currentIndex] = answerId
    }

    // MARK: - Mock Exam

    private func startGlobalTimer() {
        timer?.invalidate()
        deadline = Date().addingTimeInterval(TimeInterval(remainingSeconds))
        let t = Timer(timeInterval: 1, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                guard let self, let deadline = self.deadline else { return }
                let remaining = max(0, Int(deadline.timeIntervalSinceNow))
                self.remainingSeconds = remaining
                if remaining <= 0 {
                    self.timer?.invalidate()
                    self.submitMockExam()
                }
            }
        }
        RunLoop.main.add(t, forMode: .common)
        timer = t
    }

    func submitMockExam() {
        timer?.invalidate()
        guard case .mockExam(let examSetId) = mode else { return }

        let result = ExamResult.calculate(
            questions: questions, answers: answers,
            timeUsedSeconds: AppConstants.Exam.totalTimeSeconds - remainingSeconds,
            examSetId: examSetId
        )
        examResult = result
        historyStore.recordExamResult(result)

        if let setId = examSetId { studyStore.addCompletedExamSet(setId) }

        for (i, q) in questions.enumerated() {
            let selectedId = answers[i]
            let correct = selectedId != nil && q.answers.contains(where: { $0.id == selectedId && $0.correct })
            let topicKey = Topic.keyForTopicId(q.topic)
            studyStore.recordQuestionAnswer(topicKey: topicKey, questionNo: q.no, correct: correct)
        }
        activityStore.updateStreak()
        activityStore.recordStudyActivity()

        navigateToResult = true
    }

    // MARK: - Simulation

    private func startScenarioTimer(remainingTime: Int? = nil) {
        remainingSeconds = remainingTime ?? AppConstants.Simulation.scenarioTimeSeconds
        deadline = Date().addingTimeInterval(TimeInterval(remainingSeconds))
        timer?.invalidate()
        let t = Timer(timeInterval: 1, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                guard let self, let deadline = self.deadline else { return }
                let remaining = max(0, Int(deadline.timeIntervalSinceNow))
                self.remainingSeconds = remaining
                if remaining <= 0 { self.handleSimulationTimeout() }
            }
        }
        RunLoop.main.add(t, forMode: .common)
        timer = t
    }

    private func confirmSimulationAnswer(answerId: Int, question: Question) {
        guard !isRevealed else { return }
        answers[currentIndex] = answerId
        timePerScenario[currentIndex] = AppConstants.Simulation.scenarioTimeSeconds - remainingSeconds
        isRevealed = true
        timer?.invalidate()

        let isCorrect = question.answers.contains(where: { $0.id == answerId && $0.correct })
        let topicKey = Topic.keyForTopicId(question.topic)
        studyStore.recordQuestionAnswer(topicKey: topicKey, questionNo: question.no, correct: isCorrect)
        activityStore.updateStreak()
        activityStore.recordStudyActivity()
    }

    private func handleSimulationTimeout() {
        timer?.invalidate()
        answers[currentIndex] = -1
        timePerScenario[currentIndex] = AppConstants.Simulation.scenarioTimeSeconds
        isRevealed = true

        let question = questions[currentIndex]
        let topicKey = Topic.keyForTopicId(question.topic)
        studyStore.recordQuestionAnswer(topicKey: topicKey, questionNo: question.no, correct: false)
        activityStore.updateStreak()
        activityStore.recordStudyActivity()
    }

    func saveCurrentTimerState() {
        if !isMockExam && !isRevealed && answers[currentIndex] == nil {
            savedRemainingTime[currentIndex] = remainingSeconds
        }
    }

    private func restoreStateForCurrentIndex() {
        if let savedAnswer = answers[currentIndex] {
            selectedAnswerId = savedAnswer == -1 ? nil : savedAnswer
            isRevealed = true
            timer?.invalidate()
        } else {
            selectedAnswerId = nil
            isRevealed = false
            startScenarioTimer(remainingTime: savedRemainingTime[currentIndex])
        }
    }

    private func advanceOrFinishSimulation() {
        if isLast {
            finishSimulation()
        } else {
            currentIndex += 1
            selectedAnswerId = nil
            isRevealed = false
            startScenarioTimer()
        }
    }

    private func finishSimulation() {
        timer?.invalidate()
        let result = SimulationResult.calculate(questions: questions, answers: answers, timePerScenario: timePerScenario)
        simulationResult = result
        historyStore.recordSimulationResult(result)
        navigateToResult = true
    }

    /// Returns whether the answer was correct (for haptics).
    func confirmSimulationAnswerIsCorrect(answerId: Int, question: Question) -> Bool {
        question.answers.contains(where: { $0.id == answerId && $0.correct })
    }
}
```

**Step 2: Rewrite BaseExamView as thin UI shell**

Replace all `@State` properties with a single `@State private var vm: ExamViewModel`. Init the VM in `.task` or via init. The view body reads from `vm` and calls `vm.handleNext()`, `vm.handlePrev()`, etc. Keep animations (`withAnimation`) in the view since they're UI concerns.

**Step 3: Build and commit**

```bash
git add GPLX2026/Features/Exam/ExamViewModel.swift
git add -u
git commit -m "refactor(A2): extract ExamViewModel from BaseExamView"
```

---

### Task 11: Extract QuestionViewModel

**Files:**
- Create: `GPLX2026/Features/Learn/QuestionViewModel.swift`
- Modify: `GPLX2026/Features/Learn/QuestionView.swift`

**Step 1: Create QuestionViewModel**

```swift
// GPLX2026/Features/Learn/QuestionViewModel.swift
import Foundation
import Observation

@Observable
final class QuestionViewModel {

    private let studyStore: StudyProgressStore
    private let activityStore: ActivityStore
    private let questionStore: QuestionStore
    let topicKey: String

    // MARK: - State
    private(set) var sessionQuestions: [Question] = []
    var currentIndex: Int
    var selectedAnswerId: Int?
    var isConfirmed = false
    var canAdvance = true
    private(set) var correctCount = 0
    private(set) var answeredInSession: Set<Int> = []

    init(topicKey: String, startIndex: Int, studyStore: StudyProgressStore, activityStore: ActivityStore, questionStore: QuestionStore) {
        self.topicKey = topicKey
        self.currentIndex = startIndex
        self.studyStore = studyStore
        self.activityStore = activityStore
        self.questionStore = questionStore
    }

    // MARK: - Loading

    var filterIds: Set<Int>? {
        switch topicKey {
        case AppConstants.TopicKey.bookmarks: return studyStore.bookmarks
        case AppConstants.TopicKey.wrongAnswers: return studyStore.wrongAnswers
        case let key where key.hasPrefix(AppConstants.TopicKey.wrongAnswers + ":"): return studyStore.wrongAnswers
        default: return nil
        }
    }

    var liveQuestions: [Question] {
        questionStore.questions(forTopicKey: topicKey, filterIds: filterIds)
    }

    func loadQuestions() {
        if sessionQuestions.isEmpty {
            sessionQuestions = liveQuestions
        }
    }

    // MARK: - Computed

    var topicName: String {
        switch topicKey {
        case AppConstants.TopicKey.allQuestions: return "Tất cả câu hỏi"
        case AppConstants.TopicKey.diemLiet: return "Câu điểm liệt"
        case AppConstants.TopicKey.bookmarks: return "Đánh dấu"
        case AppConstants.TopicKey.wrongAnswers: return "Câu sai"
        case let key where key.hasPrefix(AppConstants.TopicKey.wrongAnswers + ":"):
            let scopedKey = String(key.dropFirst(AppConstants.TopicKey.wrongAnswers.count + 1))
            return "Câu sai — \(questionStore.topic(forKey: scopedKey)?.name ?? scopedKey)"
        default: return questionStore.topic(forKey: topicKey)?.name ?? topicKey
        }
    }

    var isLast: Bool { currentIndex + 1 >= sessionQuestions.count }

    func isBookmarked(questionNo: Int) -> Bool {
        studyStore.isBookmarked(questionNo: questionNo)
    }

    func toggleBookmark(questionNo: Int) {
        studyStore.toggleBookmark(questionNo: questionNo)
    }

    // MARK: - Actions

    func selectAnswer(_ answerId: Int) {
        guard !isConfirmed else { return }
        selectedAnswerId = selectedAnswerId == answerId ? nil : answerId
    }

    /// Returns whether answer is correct (for haptics).
    func confirmAnswer(question: Question) -> Bool {
        guard !isConfirmed, let answerId = selectedAnswerId else { return false }
        let answer = question.answers.first(where: { $0.id == answerId })
        let isCorrect = answer?.correct ?? false

        isConfirmed = true
        canAdvance = false

        if !answeredInSession.contains(question.no) {
            answeredInSession.insert(question.no)
            if isCorrect { correctCount += 1 }
        }

        let tKey = Topic.keyForTopicId(question.topic)
        studyStore.recordQuestionAnswer(topicKey: tKey, questionNo: question.no, correct: isCorrect)
        activityStore.updateStreak()
        activityStore.recordStudyActivity()

        return isCorrect
    }

    func nextQuestion() {
        currentIndex += 1
        selectedAnswerId = nil
        isConfirmed = false
        canAdvance = true
        studyStore.saveLastPosition(topicKey: topicKey, index: currentIndex)
    }

    func prevQuestion() {
        guard currentIndex > 0 else { return }
        currentIndex -= 1
        selectedAnswerId = nil
        isConfirmed = false
        canAdvance = true
    }

    func resetQuiz() {
        sessionQuestions = liveQuestions
        currentIndex = 0
        selectedAnswerId = nil
        isConfirmed = false
        correctCount = 0
        canAdvance = true
        answeredInSession.removeAll()
    }

    func savePosition() {
        studyStore.saveLastPosition(topicKey: topicKey, index: currentIndex)
    }

    func answeredIndices() -> Set<Int> {
        var progressCache: [String: [Int: Bool]] = [:]
        var result = Set<Int>()
        for (i, q) in sessionQuestions.enumerated() {
            let tk = Topic.keyForTopicId(q.topic)
            if progressCache[tk] == nil {
                progressCache[tk] = studyStore.topicProgress(for: tk)
            }
            if progressCache[tk]?[q.no] != nil { result.insert(i) }
        }
        return result
    }
}
```

**Step 2: Rewrite QuestionView as thin UI shell using QuestionViewModel**

**Step 3: Build and commit**

```bash
git add GPLX2026/Features/Learn/QuestionViewModel.swift
git add -u
git commit -m "refactor(A2): extract QuestionViewModel from QuestionView"
```

---

### Task 12: Extract HazardViewModel

**Files:**
- Create: `GPLX2026/Features/Hazard/HazardViewModel.swift`
- Modify: `GPLX2026/Features/Hazard/HazardTestView.swift`

**Step 1: Create HazardViewModel**

Extract from HazardTestView: `situations`, `currentIndex`, `tapTimes`, `scoreRevealed`, scoring logic, result building, navigation. Keep video player and orientation management in the view.

The VM should handle:
- Situation list and navigation (next/prev)
- Tap time recording
- Score computation (delegates to `HazardSituation.score()`)
- Result building → `HazardResult`
- Recording results to `ExamHistoryStore`

**Step 2: Rewrite HazardTestView as thinner UI shell**

The view still handles:
- AVPlayer lifecycle (UI concern)
- Orientation management (UIKit side effect)
- Layout (landscape/portrait)
- Animations

**Step 3: Build and commit**

```bash
git add GPLX2026/Features/Hazard/HazardViewModel.swift
git add -u
git commit -m "refactor(A2): extract HazardViewModel from HazardTestView"
```

---

## Phase 6: Tests (A4)

### Task 13: Write core logic tests

**Files:**
- Create: `GPLX2026Tests/ExamResultTests.swift`
- Create: `GPLX2026Tests/SimulationResultTests.swift`
- Create: `GPLX2026Tests/StudyProgressStoreTests.swift`
- Create: `GPLX2026Tests/ExamHistoryStoreTests.swift`
- Create: `GPLX2026Tests/ActivityStoreTests.swift`
- Create: `GPLX2026Tests/AnalyticsServiceTests.swift`

**Step 1: ExamResult tests**

```swift
// GPLX2026Tests/ExamResultTests.swift
import Testing
@testable import GPLX2026

@Test func examResultPassesWithSufficientScore() {
    // Create mock questions and answers that meet pass threshold
    // Verify .passed == true, .score == expected, .wrongDiemLiet == 0
}

@Test func examResultFailsWithWrongDiemLiet() {
    // Even with enough correct answers, if wrongDiemLiet > 0 → failed
}

@Test func examResultFailsBelowThreshold() {
    // Score < passThreshold → failed
}
```

**Step 2: SimulationResult tests**

```swift
@Test func simulationResultTimedOutDetection() {
    // answers[i] == nil or -1 → counted as timed out
}

@Test func simulationResultPassAt70Percent() {
    // ≥70% → passed
}
```

**Step 3: Store tests** (using ephemeral UserDefaults)

```swift
@Test func studyStoreRecordsQuestionResult() {
    let defaults = UserDefaults(suiteName: UUID().uuidString)!
    let store = StudyProgressStore(defaults: defaults)
    store.saveQuestionResult(topicKey: "topic1", questionNo: 1, correct: true)
    #expect(store.topicProgress(for: "topic1")[1] == true)
}

@Test func studyStoreToggleBookmark() {
    let defaults = UserDefaults(suiteName: UUID().uuidString)!
    let store = StudyProgressStore(defaults: defaults)
    store.toggleBookmark(questionNo: 42)
    #expect(store.isBookmarked(questionNo: 42))
    store.toggleBookmark(questionNo: 42)
    #expect(!store.isBookmarked(questionNo: 42))
}
```

**Step 4: AnalyticsService tests**

Test `smartNudge` and `readinessStatus` with mocked stores.

**Step 5: Run tests**

Run: `xcodebuild -project GPLX2026.xcodeproj -scheme GPLX2026Tests -destination 'platform=iOS Simulator,name=iPhone 16' test 2>&1 | tail -10`

**Step 6: Commit**

```bash
git add GPLX2026Tests/
git commit -m "test(A4): add core logic tests for scoring, stores, and analytics"
```

---

## Phase 7: Verify

### Task 14: Final build verification

**Step 1: Full clean build**

```bash
xcodebuild -project GPLX2026.xcodeproj -scheme GPLX2026 -destination 'platform=iOS Simulator,name=iPhone 16' clean build 2>&1 | tail -10
```

**Step 2: Run tests**

```bash
xcodebuild -project GPLX2026.xcodeproj -scheme GPLX2026Tests -destination 'platform=iOS Simulator,name=iPhone 16' test 2>&1 | tail -10
```

**Step 3: Verify no remaining ProgressStore references**

```bash
grep -r "ProgressStore" GPLX2026/ --include="*.swift" | grep -v ".build"
```
Expected: 0 results

**Step 4: Verify no remaining Color.appPrimary static references**

```bash
grep -r "Color\.appPrimary" GPLX2026/ --include="*.swift"
```
Expected: 0 results (or only in AppTheme.swift if kept as backward compat alias)

---

## Summary

| Task | What | Files Changed |
|------|------|---------------|
| 1 | ThemeStore (A5) | +1 new, ~25 modified |
| 2 | Test target scaffold (A4) | +1 new, project.yml |
| 3 | StudyProgressStore (A1) | +1 new |
| 4 | ExamHistoryStore (A1) | +1 new |
| 5 | ActivityStore (A1) | +1 new |
| 6 | AnalyticsService (A1) | +1 new |
| 7-8 | Wire up + migrate views | ~20 modified, 8 deleted |
| 9 | Unified ExamResultView (A3) | 3 modified, 1 deleted |
| 10 | ExamViewModel (A2) | +1 new, 1 modified |
| 11 | QuestionViewModel (A2) | +1 new, 1 modified |
| 12 | HazardViewModel (A2) | +1 new, 1 modified |
| 13 | Core logic tests (A4) | +6 new test files |
| 14 | Final verification | 0 |

**Total: ~9 new files, 8 deleted files, ~25 modified files**
