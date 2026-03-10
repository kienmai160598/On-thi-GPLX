# Performance Optimization Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Fix 4 performance issues (PERF2-5) from the comprehensive audit to eliminate global view invalidation, reduce main-thread blocking, and optimize network resources.

**Architecture:** Remove the `dataVersion` global invalidation pattern from `ProgressStore`, replacing it with native `@Observable` property tracking. Cache expensive computations. Share a single `URLSession` for video downloads. Move file I/O off the main thread.

**Tech Stack:** Swift 6, SwiftUI, `@Observable`, `URLSession`, `FileManager`

---

## Task 1: Remove `dataVersion` from `ProgressStore.swift`

**Files:**
- Modify: `GPLX2026/Core/Storage/ProgressStore.swift`

**Step 1: Add new cache properties for UserDefaults-backed values**

In `ProgressStore.swift`, after the existing cache properties (line ~43), add:

```swift
private var _streakCountCache: Int?
private var _lastStudyDateCache: String??   // outer nil = not loaded
private var _lastTopicKeyCache: String??    // outer nil = not loaded
private var _lastQuestionIndexCache: Int?
```

**Step 2: Remove `dataVersion` and update comment**

Remove:
```swift
/// Stored property so @Observable can track data changes.
internal(set) var dataVersion = 0
```

Update the caches comment:
```swift
// MARK: - In-memory caches (lazy-loaded from UserDefaults)
```

**Step 3: Remove all `_ = dataVersion` reads from computed properties**

In every computed property / read method, remove the `_ = dataVersion` line. The affected properties:
- `topicProgress(for:)` — line 69
- `examHistory` — line 110
- `simulationHistory` — line 144
- `hazardHistory` — line 178
- `bookmarks` — line 212
- `wrongAnswers` — line 249
- `completedExamSets` — line 286

**Step 4: Remove all `dataVersion += 1` from mutation methods**

Remove the `dataVersion += 1` line from every mutating method:
- `saveQuestionResult` — line 104
- `recordExamResult` — line 138
- `recordSimulationResult` — line 172
- `recordHazardResult` — line 206
- `toggleBookmark` — line 239
- `addWrongAnswer` — line 272
- `removeWrongAnswer` — line 280
- `addCompletedExamSet` — line 309
- `updateStreak` — line 346
- `saveLastPosition` — line 364
- `clearAllProgress` — line 407
- `clearTopicProgress` — line 418
- `clearExamHistory` — line 425
- `clearSimulationHistory` — line 431
- `clearHazardHistory` — line 437
- `clearBookmarks` — line 443
- `clearWrongAnswers` — line 449
- `clearStreak` — line 455

**Step 5: Convert `streakCount`, `lastStudyDate`, `lastTopicKey`, `lastQuestionIndex` to use caches**

Replace the current implementations:

```swift
// MARK: - Streak

var streakCount: Int {
    if let cached = _streakCountCache { return cached }
    let value = defaults.integer(forKey: Keys.streakCount)
    _streakCountCache = value
    return value
}

var lastStudyDate: String? {
    if let cached = _lastStudyDateCache { return cached }
    let value = defaults.string(forKey: Keys.lastStudyDate)
    _lastStudyDateCache = .some(value)
    return value
}

func updateStreak() {
    let today = Date()
    let todayStr = Self.streakDateFormatter.string(from: today)

    let last = lastStudyDate
    if last == todayStr { return }

    var newStreak = 1
    if let last, let lastDate = Self.streakDateFormatter.date(from: last) {
        let diff = Calendar.current.dateComponents([.day], from: lastDate, to: today).day ?? 0
        if diff == 1 {
            newStreak = streakCount + 1
        }
    }

    defaults.set(newStreak, forKey: Keys.streakCount)
    defaults.set(todayStr, forKey: Keys.lastStudyDate)
    _streakCountCache = newStreak
    _lastStudyDateCache = .some(todayStr)
}

// MARK: - Continue learning position

var lastTopicKey: String? {
    if let cached = _lastTopicKeyCache { return cached }
    let value = defaults.string(forKey: Keys.lastTopicKey)
    _lastTopicKeyCache = .some(value)
    return value
}

var lastQuestionIndex: Int {
    if let cached = _lastQuestionIndexCache { return cached }
    let value = defaults.integer(forKey: Keys.lastQuestionIndex)
    _lastQuestionIndexCache = value
    return value
}

func saveLastPosition(topicKey: String, index: Int) {
    defaults.set(topicKey, forKey: Keys.lastTopicKey)
    defaults.set(index, forKey: Keys.lastQuestionIndex)
    _lastTopicKeyCache = .some(topicKey)
    _lastQuestionIndexCache = index
}
```

**Step 6: Update `invalidateCaches()` to include new caches**

```swift
private func invalidateCaches() {
    _topicProgressCache.removeAll()
    _examHistoryCache = nil
    _simulationHistoryCache = nil
    _hazardHistoryCache = nil
    _bookmarksCache = nil
    _wrongAnswersCache = nil
    _completedExamSetsCache = nil
    _streakCountCache = nil
    _lastStudyDateCache = nil
    _lastTopicKeyCache = nil
    _lastQuestionIndexCache = nil
    _studyActivityCache = nil
    _examDateCache = nil
    _dailyGoalCache = nil
    _reviewDatesCache = nil
    _readinessCache = nil
}
```

Note: `_studyActivityCache`, `_examDateCache`, `_dailyGoalCache`, `_reviewDatesCache`, and `_readinessCache` are added in Tasks 2–3. Add them to `invalidateCaches()` at the same time as declaring them.

**Step 7: Update `clearStreak()` and `clearTopicProgress()`**

```swift
func clearStreak() {
    defaults.removeObject(forKey: Keys.streakCount)
    defaults.removeObject(forKey: Keys.lastStudyDate)
    _streakCountCache = nil
    _lastStudyDateCache = nil
}

func clearTopicProgress() {
    let topicKeys = Topic.all.map(\.key) + [AppConstants.TopicKey.diemLiet]
    for key in topicKeys {
        defaults.removeObject(forKey: Keys.progressPrefix + key)
    }
    defaults.removeObject(forKey: Keys.lastTopicKey)
    defaults.removeObject(forKey: Keys.lastQuestionIndex)
    _topicProgressCache.removeAll()
    _lastTopicKeyCache = nil
    _lastQuestionIndexCache = nil
    _readinessCache = nil
}
```

**Step 8: Build**

Run: `xcodebuild -project GPLX2026.xcodeproj -scheme GPLX2026 -destination 'platform=iOS Simulator,name=iPhone 16' build 2>&1 | tail -5`

Expected: BUILD SUCCEEDED (may have warnings from extension files not yet updated)

**Step 9: Commit**

```bash
git add GPLX2026/Core/Storage/ProgressStore.swift
git commit -m "perf: remove dataVersion from ProgressStore, use native @Observable tracking"
```

---

## Task 2: Remove `dataVersion` from ProgressStore extension files

**Files:**
- Modify: `GPLX2026/Core/Storage/ProgressStore.swift` (add cache properties)
- Modify: `GPLX2026/Core/Storage/ProgressStore+Activity.swift`
- Modify: `GPLX2026/Core/Storage/ProgressStore+ExamDate.swift`
- Modify: `GPLX2026/Core/Storage/ProgressStore+SpacedRepetition.swift`

**Step 1: Add cache properties to `ProgressStore.swift`**

Extensions can't add stored properties, so add these to the main class alongside the other caches:

```swift
private var _studyActivityCache: [String: Int]?
private var _examDateCache: Date??         // outer nil = not loaded
private var _dailyGoalCache: Int?
private var _reviewDatesCache: [Int: Date]?
```

**Step 2: Update `ProgressStore+Activity.swift`**

Replace the entire file:

```swift
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
```

**Step 3: Update `ProgressStore+ExamDate.swift`**

Replace the entire file:

```swift
import Foundation

extension ProgressStore {

    private static let examDateKey = "exam_date"
    private static let dailyGoalKey = "daily_goal"

    var examDate: Date? {
        if let cached = _examDateCache { return cached }
        guard let interval = defaults.object(forKey: Self.examDateKey) as? TimeInterval else {
            _examDateCache = .some(nil)
            return nil
        }
        let value = Date(timeIntervalSince1970: interval)
        _examDateCache = .some(value)
        return value
    }

    func setExamDate(_ date: Date?) {
        if let date {
            defaults.set(date.timeIntervalSince1970, forKey: Self.examDateKey)
        } else {
            defaults.removeObject(forKey: Self.examDateKey)
        }
        _examDateCache = .some(date)
    }

    var dailyGoal: Int {
        if let cached = _dailyGoalCache { return cached }
        let goal = defaults.integer(forKey: Self.dailyGoalKey)
        let value = goal > 0 ? goal : 30
        _dailyGoalCache = value
        return value
    }

    func setDailyGoal(_ goal: Int) {
        defaults.set(goal, forKey: Self.dailyGoalKey)
        _dailyGoalCache = goal
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
```

**Step 4: Update `ProgressStore+SpacedRepetition.swift`**

Replace the entire file:

```swift
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
```

**Step 5: Build**

Run: `xcodebuild -project GPLX2026.xcodeproj -scheme GPLX2026 -destination 'platform=iOS Simulator,name=iPhone 16' build 2>&1 | tail -5`

Expected: BUILD SUCCEEDED

**Step 6: Commit**

```bash
git add GPLX2026/Core/Storage/ProgressStore.swift GPLX2026/Core/Storage/ProgressStore+Activity.swift GPLX2026/Core/Storage/ProgressStore+ExamDate.swift GPLX2026/Core/Storage/ProgressStore+SpacedRepetition.swift
git commit -m "perf: remove dataVersion from all ProgressStore extensions"
```

---

## Task 3: Cache `readinessStatus()` result (PERF3)

**Files:**
- Modify: `GPLX2026/Core/Storage/ProgressStore.swift` (add cache property)
- Modify: `GPLX2026/Core/Storage/ProgressStore+Analytics.swift`

**Step 1: Add cache property to `ProgressStore.swift`**

Add alongside other caches:

```swift
internal var _readinessCache: ReadinessStatus?
```

(Needs `internal` because it's written from the `+Analytics` extension.)

**Step 2: Update `readinessStatus()` in `ProgressStore+Analytics.swift`**

```swift
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
```

**Step 3: Invalidate `_readinessCache` in mutation methods**

In `ProgressStore.swift`, add `_readinessCache = nil` to these methods:
- `saveQuestionResult` (topic progress changed)
- `recordExamResult` (pass rate changed)
- `clearAllProgress` (already handled via `invalidateCaches()`)
- `clearTopicProgress` (already handled in Task 1 step 7)
- `clearExamHistory` (add `_readinessCache = nil`)

**Step 4: Build**

Run: `xcodebuild -project GPLX2026.xcodeproj -scheme GPLX2026 -destination 'platform=iOS Simulator,name=iPhone 16' build 2>&1 | tail -5`

Expected: BUILD SUCCEEDED

**Step 5: Commit**

```bash
git add GPLX2026/Core/Storage/ProgressStore.swift GPLX2026/Core/Storage/ProgressStore+Analytics.swift
git commit -m "perf: cache readinessStatus() result, invalidate on data change"
```

---

## Task 4: Shared URLSession + lazy cache stats in HazardVideoCache (PERF4 + PERF5)

**Files:**
- Modify: `GPLX2026/Core/Storage/HazardVideoCache.swift`

**Step 1: Replace per-download URLSession with shared session + shared delegate**

Replace the entire `HazardVideoCache.swift` with:

```swift
import Foundation
import os

// MARK: - HazardVideoCache

@MainActor
@Observable
final class HazardVideoCache {

    private static let logger = Logger(subsystem: "com.gplx2026", category: "HazardVideoCache")

    private(set) var downloadProgress: [Int: Double] = [:]
    private(set) var isDownloadingAll = false
    private(set) var downloadSpeedMBps: Double = 0
    private(set) var downloadingChapters: Set<Int> = []
    private(set) var cachedCount: Int = 0
    private(set) var cacheSizeMB: Double = 0
    private var cachedIds: Set<Int> = []
    private var activeTasks: [Int: URLSessionTask] = [:]

    private var speedWindowBytes: Int64 = 0
    private var speedWindowStart: Date?

    // PERF5: Lazy stats — don't scan files in init()
    private var _statsLoaded = false

    // PERF4: Shared session + delegate
    private let downloadDelegate = SharedDownloadDelegate()
    private lazy var downloadSession: URLSession = {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForResource = 300
        return URLSession(configuration: config, delegate: downloadDelegate, delegateQueue: nil)
    }()

    init() {
        // No file I/O here — stats loaded lazily
    }

    // MARK: - Cache directory

    nonisolated static var cacheDir: URL {
        let dir = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("hazard_videos", isDirectory: true)
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir
    }

    // MARK: - Public API

    func localURL(for situation: HazardSituation) -> URL? {
        let file = Self.cacheDir.appendingPathComponent("\(situation.videoFileName).mp4")
        return FileManager.default.fileExists(atPath: file.path) ? file : nil
    }

    func playableURL(for situation: HazardSituation) -> URL {
        localURL(for: situation) ?? situation.videoURL
    }

    var totalCount: Int { HazardSituation.all.count }

    var isCached: Bool { cachedCount == totalCount }

    var isDownloading: Bool {
        isDownloadingAll || !downloadingChapters.isEmpty
    }

    func cachedCount(forChapter chapterId: Int) -> Int {
        ensureStatsLoaded()
        return HazardSituation.all
            .filter { $0.chapter == chapterId && cachedIds.contains($0.id) }
            .count
    }

    func totalCount(forChapter chapterId: Int) -> Int {
        HazardSituation.all.filter { $0.chapter == chapterId }.count
    }

    /// Trigger lazy stats load. Call from views that display cache info.
    func ensureStatsLoaded() {
        guard !_statsLoaded else { return }
        _statsLoaded = true
        let cacheDir = Self.cacheDir
        let allSituations = HazardSituation.all
        Task.detached {
            var ids = Set<Int>()
            for situation in allSituations {
                let file = cacheDir.appendingPathComponent("\(situation.videoFileName).mp4")
                if FileManager.default.fileExists(atPath: file.path) {
                    ids.insert(situation.id)
                }
            }
            let sizeMB = Self.computeCacheSizeMB(cacheDir: cacheDir)
            await MainActor.run { [weak self] in
                guard let self else { return }
                self.cachedIds = ids
                self.cachedCount = ids.count
                self.cacheSizeMB = sizeMB
            }
        }
    }

    private nonisolated static func computeCacheSizeMB(cacheDir: URL) -> Double {
        let files = (try? FileManager.default.contentsOfDirectory(
            at: cacheDir,
            includingPropertiesForKeys: [.fileSizeKey]
        )) ?? []
        let totalBytes = files.reduce(0) { sum, url in
            let size = (try? url.resourceValues(forKeys: [.fileSizeKey]).fileSize) ?? 0
            return sum + size
        }
        return Double(totalBytes) / (1024 * 1024)
    }

    private func fileSizeMB(_ url: URL) -> Double {
        let size = (try? url.resourceValues(forKeys: [.fileSizeKey]).fileSize) ?? 0
        return Double(size) / (1024 * 1024)
    }

    // MARK: - Downloads

    func downloadChapter(_ chapterId: Int) async {
        ensureStatsLoaded()
        downloadingChapters.insert(chapterId)
        let uncached = HazardSituation.all
            .filter { $0.chapter == chapterId && localURL(for: $0) == nil }

        for situation in uncached {
            guard downloadingChapters.contains(chapterId) else { break }
            await downloadVideo(for: situation)
        }

        downloadingChapters.remove(chapterId)
        resetSpeedIfIdle()
        Haptics.notification(.success)
    }

    func cancelChapter(_ chapterId: Int) {
        downloadingChapters.remove(chapterId)
        let chapterSituations = HazardSituation.all.filter { $0.chapter == chapterId }
        for s in chapterSituations {
            if let task = activeTasks.removeValue(forKey: s.id) {
                task.cancel()
            }
        }
    }

    func downloadVideo(for situation: HazardSituation) async {
        guard localURL(for: situation) == nil else { return }
        downloadProgress[situation.id] = 0

        do {
            let tempURL: URL = try await withCheckedThrowingContinuation { continuation in
                let task = downloadSession.downloadTask(with: situation.videoURL)
                downloadDelegate.register(
                    taskId: task.taskIdentifier,
                    onProgress: { [weak self] bytesWritten, totalWritten, expected in
                        Task { @MainActor [weak self] in
                            guard let self else { return }
                            if expected > 0 {
                                self.downloadProgress[situation.id] = Double(totalWritten) / Double(expected)
                            }
                            self.trackSpeed(bytesJustWritten: bytesWritten)
                        }
                    },
                    continuation: continuation
                )
                self.activeTasks[situation.id] = task
                task.resume()
            }

            activeTasks.removeValue(forKey: situation.id)
            let dest = Self.cacheDir.appendingPathComponent("\(situation.videoFileName).mp4")
            try? FileManager.default.removeItem(at: dest)
            try FileManager.default.moveItem(at: tempURL, to: dest)
            downloadProgress[situation.id] = 1.0
            // PERF5: Incremental update instead of full rescan
            cachedIds.insert(situation.id)
            cachedCount = cachedIds.count
            cacheSizeMB += fileSizeMB(dest)
            Self.logger.info("Cached video \(situation.id)")
        } catch {
            activeTasks.removeValue(forKey: situation.id)
            downloadProgress.removeValue(forKey: situation.id)
            if (error as NSError).code != NSURLErrorCancelled {
                Self.logger.error("Failed to download video \(situation.id): \(error.localizedDescription)")
            }
        }
    }

    func downloadAll() async {
        ensureStatsLoaded()
        isDownloadingAll = true
        let uncached = HazardSituation.all.filter { localURL(for: $0) == nil }

        for situation in uncached {
            guard isDownloadingAll else { break }
            await downloadVideo(for: situation)
        }

        isDownloadingAll = false
        resetSpeedIfIdle()
        Haptics.notification(.success)
    }

    func cancelAll() {
        activeTasks.values.forEach { $0.cancel() }
        activeTasks.removeAll()
        downloadProgress.removeAll()
        downloadingChapters.removeAll()
        isDownloadingAll = false
        resetSpeedIfIdle()
    }

    func clearCache() {
        try? FileManager.default.removeItem(at: Self.cacheDir)
        try? FileManager.default.createDirectory(at: Self.cacheDir, withIntermediateDirectories: true)
        downloadProgress.removeAll()
        cachedIds.removeAll()
        cachedCount = 0
        cacheSizeMB = 0
    }

    // MARK: - Speed tracking

    private func trackSpeed(bytesJustWritten: Int64) {
        let now = Date()
        guard let start = speedWindowStart else {
            speedWindowStart = now
            speedWindowBytes = bytesJustWritten
            return
        }
        speedWindowBytes += bytesJustWritten
        let elapsed = now.timeIntervalSince(start)
        if elapsed >= 0.5 {
            downloadSpeedMBps = Double(speedWindowBytes) / elapsed / (1024 * 1024)
            speedWindowStart = now
            speedWindowBytes = 0
        }
    }

    private func resetSpeedIfIdle() {
        if !isDownloading {
            downloadSpeedMBps = 0
            speedWindowBytes = 0
            speedWindowStart = nil
        }
    }
}

// MARK: - Shared Download Delegate

private final class SharedDownloadDelegate: NSObject, URLSessionDownloadDelegate, @unchecked Sendable {
    private let lock = NSLock()
    private var progressHandlers: [Int: @Sendable (Int64, Int64, Int64) -> Void] = [:]
    private var continuations: [Int: CheckedContinuation<URL, Error>] = [:]

    func register(
        taskId: Int,
        onProgress: @escaping @Sendable (Int64, Int64, Int64) -> Void,
        continuation: CheckedContinuation<URL, Error>
    ) {
        lock.withLock {
            progressHandlers[taskId] = onProgress
            continuations[taskId] = continuation
        }
    }

    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        let id = downloadTask.taskIdentifier
        let tempFile = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString + ".mp4")
        do {
            try FileManager.default.copyItem(at: location, to: tempFile)
            lock.withLock { continuations.removeValue(forKey: id) }?.resume(returning: tempFile)
        } catch {
            lock.withLock { continuations.removeValue(forKey: id) }?.resume(throwing: error)
        }
        lock.withLock { _ = progressHandlers.removeValue(forKey: id) }
    }

    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        let handler = lock.withLock { progressHandlers[downloadTask.taskIdentifier] }
        handler?(bytesWritten, totalBytesWritten, totalBytesExpectedToWrite)
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        let id = task.taskIdentifier
        if let error {
            lock.withLock { continuations.removeValue(forKey: id) }?.resume(throwing: error)
        }
        lock.withLock { _ = progressHandlers.removeValue(forKey: id) }
    }
}
```

**Step 2: Add `ensureStatsLoaded()` call to views that display cache info**

Search for uses of `cachedCount`, `cacheSizeMB`, `isCached` in views and add `videoCache.ensureStatsLoaded()` in their `.onAppear` or `.task` modifiers. Likely in `SettingsView.swift` and any hazard download management UI.

**Step 3: Build**

Run: `xcodebuild -project GPLX2026.xcodeproj -scheme GPLX2026 -destination 'platform=iOS Simulator,name=iPhone 16' build 2>&1 | tail -5`

Expected: BUILD SUCCEEDED

**Step 4: Commit**

```bash
git add GPLX2026/Core/Storage/HazardVideoCache.swift
git commit -m "perf: shared URLSession for downloads, lazy background cache stats"
```

---

## Task 5: Build verification and install

**Step 1: Clean build**

Run: `xcodebuild -project GPLX2026.xcodeproj -scheme GPLX2026 -destination 'platform=iOS Simulator,name=iPhone 16' clean build 2>&1 | tail -10`

Expected: BUILD SUCCEEDED with 0 errors

**Step 2: Verify no remaining `dataVersion` references in source**

Run: `grep -r "dataVersion" GPLX2026/ --include="*.swift"`

Expected: No matches (only plan docs should reference it)

**Step 3: Commit all remaining changes**

If any files were missed, stage and commit them.
