# Architecture Improvements Design

**Date:** 2026-03-10
**Scope:** A1-A5 from comprehensive audit Priority 4

---

## Decisions

- **A1:** Fully independent stores (replace ProgressStore entirely)
- **A2:** One ViewModel per screen (ExamViewModel, QuestionViewModel, HazardViewModel)
- **A3:** Merge ExamResultView + SimulationResultView into shared view
- **A4:** Test target with core logic tests (~15-20 tests)
- **A5:** Cache Color.appPrimary in @Observable ThemeStore
- **Migration:** Fresh start OK — no backward compatibility with old UserDefaults keys

---

## A1: Split ProgressStore into Independent Stores

### Current Problem

`ProgressStore` is a 475-line god object covering 12 domains with 25 `dataVersion += 1` calls. A single `recordQuestionAnswer()` triggers 5 increments, invalidating every observing view.

### New Stores

#### StudyProgressStore
- **Owns:** Topic progress, bookmarks, wrong answers, last study position, completed exam sets
- **Properties:** `topicProgress(for:)`, `bookmarks`, `wrongAnswers`, `lastTopicKey`, `lastQuestionIndex`, `completedExamSets`
- **Mutations:** `saveQuestionResult()`, `toggleBookmark()`, `addWrongAnswer()`, `removeWrongAnswer()`, `addCompletedExamSet()`, `saveLastPosition()`, `clearTopicProgress()`, `clearBookmarks()`, `clearWrongAnswers()`
- **Compound:** `recordQuestionAnswer()` calls save + wrong answer update (no more streak/activity side effects here)

#### ExamHistoryStore
- **Owns:** Exam, simulation, and hazard result histories
- **Properties:** `examHistory`, `simulationHistory`, `hazardHistory`
- **Mutations:** `recordExamResult()`, `recordSimulationResult()`, `recordHazardResult()`, `clearExamHistory()`, `clearSimulationHistory()`, `clearHazardHistory()`
- **Analytics computed:** `averageExamScore`, `bestExamScore`, `examCount`, etc. — same computed properties, now scoped to this store

#### ActivityStore
- **Owns:** Streaks, daily study activity, exam date, daily goal
- **Properties:** `streakCount`, `lastStudyDate`, `studyActivity`, `examDate`, `dailyGoal`, `daysUntilExam`, `todayProgress`
- **Mutations:** `updateStreak()`, `recordStudyActivity()`, `setExamDate()`, `setDailyGoal()`, `clearStreak()`

#### AnalyticsService (stateless)
- `readinessStatus(study:history:)` — takes StudyProgressStore + ExamHistoryStore
- `smartNudge(study:history:activity:)` — takes all three stores
- Free functions or static methods — no stored state, just computation over store data

### Injection

All three stores created in `GPLX2026App.swift` and injected via `.environment()`:

```swift
@State private var studyStore = StudyProgressStore()
@State private var historyStore = ExamHistoryStore()
@State private var activityStore = ActivityStore()

var body: some Scene {
    WindowGroup {
        ContentView()
            .environment(studyStore)
            .environment(historyStore)
            .environment(activityStore)
    }
}
```

Views pull only the stores they need:
```swift
@Environment(StudyProgressStore.self) private var studyStore
```

### No dataVersion

All three stores use `@Observable` with normal stored properties. SwiftUI's observation system tracks per-property access automatically — no manual invalidation needed.

---

## A2: Extract ViewModels

### ExamViewModel

Extracted from `BaseExamView.swift` (384 lines). Owns:

- **State:** `currentIndex`, `answers: [Int: Int]`, `selectedAnswerId`, `isRevealed`, `remainingSeconds`, `deadline`
- **Timer:** `startGlobalTimer()`, `startScenarioTimer()`, `saveCurrentTimerState()`, `restoreStateForCurrentIndex()` — timer added to `.common` RunLoop mode (fixes B6)
- **Scoring:** `submitExam()` → returns `ExamResult`, `submitSimulation()` → returns `SimulationResult`
- **Navigation:** `handlePrev()`, `handleNext()`, `confirmSimulationAnswer()`

`BaseExamView` becomes a thin UI shell that reads from the VM and calls its methods.

### QuestionViewModel

Extracted from `QuestionView.swift` (372 lines). Owns:

- **State:** `sessionQuestions: [Question]` (snapshot at init — fixes B5), `currentIndex`, `answeredInSession: Set<Int>`, `correctCount`
- **Filtering:** `loadQuestions(topicKey:filterIds:)` — determines question set at init, immutable after
- **Progress:** `recordAnswer(questionNo:correct:)` — delegates to StudyProgressStore

`QuestionView` becomes a thin UI shell.

### HazardViewModel

Extracted from `HazardTestView.swift` (900+ lines). Owns:

- **State:** `situations`, `currentIndex`, `tapTimes: [Int: Double?]`, `scoreRevealed`
- **Playback:** `startSituation()`, `recordTap(time:)`, `revealScore()`
- **Scoring:** `currentScore` computed, `buildResult()` → returns `HazardResult`
- **Navigation:** `goToNext()`, `goToPrevious()`, `isLastSituation`

Orientation management stays in the view (it's a UIKit side effect). Video player setup stays in the view (AVPlayer is a UI concern). The VM manages the *data* flow.

---

## A3: Unified ExamResultView

### Current Duplication

ExamResultView and SimulationResultView are ~70% identical (120+ duplicated lines). They differ in:
- Exam shows "Điểm liệt sai" count; Simulation shows "Hết thời gian" count
- Different pass requirement text
- Different retry action

### Design

A single `ExamResultView` parameterized by a `ResultConfig`:

```swift
struct ResultConfig {
    let title: String                    // "Kết quả thi" / "Kết quả sa hình"
    let score: Int
    let total: Int
    let passed: Bool
    let timeUsedSeconds: Int
    let passRequirementText: String      // "≥ 28 & 0 ĐL sai" / "≥ 70%"
    let extraRows: [ScoreRowData]        // điểm liệt or timed-out rows
    let wrongQuestionNos: [Int]          // for "Luyện câu sai" button
    let retryAction: (() -> Void)?       // nil when isFromHistory
}
```

Factory methods on ExamResult and SimulationResult produce `ResultConfig`:
```swift
extension ExamResult {
    func resultConfig(questions:answers:timeUsed:) -> ResultConfig
}
```

The unified view renders the config. No protocol needed — just a struct.

---

## A4: Test Target

### Setup

Add `GPLX2026Tests` target in `project.yml`:

```yaml
GPLX2026Tests:
  type: bundle.unit-test
  platform: iOS
  sources:
    - path: GPLX2026Tests
  dependencies:
    - target: GPLX2026
  settings:
    GENERATE_INFOPLIST_FILE: YES
```

### Test Coverage (~15-20 tests)

#### Scoring Tests
- `ExamResult.calculate()` — pass, fail, fail by điểm liệt, edge cases
- `SimulationResult.calculate()` — pass, fail, timed out scenarios
- `HazardSituation.score()` — perfect timing, late timing, no tap, edge of window

#### Store Tests
- `StudyProgressStore` — save/read question result, toggle bookmark, wrong answer tracking
- `ExamHistoryStore` — record/read results, history limit (50), clear
- `ActivityStore` — streak update, daily goal, exam date

#### SmartNudge Tests
- Stage progression logic (điểm liệt → weak topics → exams → simulation → hazard → mastery)
- Edge cases: no data, all perfect, mixed progress

#### ReadinessStatus Tests
- Weight formula: 40% accuracy + 30% điểm liệt + 20% pass rate + 10% coverage

---

## A5: ThemeStore

### Current Problem

`Color.appPrimary` calls `UserDefaults.standard.string(forKey:)` on every access. Multiple views read this independently.

### Design

```swift
@Observable
final class ThemeStore {
    var primaryColorKey: String {
        didSet { defaults.set(primaryColorKey, forKey: AppConstants.StorageKey.primaryColor) }
    }

    var primaryColor: Color { Self.color(for: primaryColorKey) }
    var onPrimaryColor: Color { Self.onColor(for: primaryColorKey) }

    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        self.primaryColorKey = defaults.string(forKey: AppConstants.StorageKey.primaryColor) ?? "default"
    }

    private static func color(for key: String) -> Color { ... }
    private static func onColor(for key: String) -> Color { ... }
}
```

Injected via `.environment()` alongside the other stores. `Color.appPrimary` static property removed — views use `themeStore.primaryColor` instead. `SettingsView` writes to `themeStore.primaryColorKey`.

---

## File Changes Summary

### New Files
- `Core/Storage/StudyProgressStore.swift`
- `Core/Storage/ExamHistoryStore.swift`
- `Core/Storage/ActivityStore.swift`
- `Core/Storage/AnalyticsService.swift`
- `Core/Theme/ThemeStore.swift`
- `Features/Exam/ExamViewModel.swift`
- `Features/Learn/QuestionViewModel.swift`
- `Features/Hazard/HazardViewModel.swift`
- `GPLX2026Tests/` (directory with test files)

### Modified Files
- `GPLX2026App.swift` — create & inject new stores + ThemeStore
- `BaseExamView.swift` — thin shell using ExamViewModel
- `QuestionView.swift` — thin shell using QuestionViewModel
- `HazardTestView.swift` — thin shell using HazardViewModel
- `ExamResultView.swift` — unified with ResultConfig
- `SimulationResultView.swift` — deleted (replaced by unified view)
- `HomeTab.swift` — use new stores
- `ExamTab.swift` — use new stores
- `PracticeTab.swift` — use new stores
- `SettingsView.swift` — use new stores + ThemeStore
- `AppTheme.swift` — remove Color.appPrimary static, remove dead code
- `AppButton.swift` — use ThemeStore
- `AnimatedBackground.swift` — use ThemeStore
- All views referencing `ProgressStore` — update to specific stores
- `project.yml` — add test target

### Deleted Files
- `Core/Storage/ProgressStore.swift`
- `Core/Storage/ProgressStore+Activity.swift`
- `Core/Storage/ProgressStore+Analytics.swift`
- `Core/Storage/ProgressStore+ExamDate.swift`
- `Core/Storage/ProgressStore+ExamHistory.swift`
- `Core/Storage/ProgressStore+SmartNudge.swift`
- `Features/Simulation/SimulationResultView.swift`
