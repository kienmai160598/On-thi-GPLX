# App Update: New Exam Format + UX Enhancements

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Update the app to match the June 2025 exam format (30 questions / 22 min / 28 pass / 1 instant-fail), add a study activity heat map, spaced repetition, exam countdown, and refine the UI to follow Apple HIG with breathing study experience.

**Architecture:** Update `AppConstants` and exam logic for the new format. Add `StudyActivityStore` for daily tracking and heat map. Add spaced repetition metadata to `ProgressStore`. Add exam date + daily goal to settings. Refine `QuestionView` with calm transitions and proper Apple HIG spacing.

**Tech Stack:** SwiftUI, Swift 6 (strict concurrency), iOS 18+ / iOS 26 liquid glass, Swift Charts (heat map), `xcodeproj` Ruby gem for pbxproj.

---

### Task 1: Update exam format constants

**Files:**
- Modify: `GPLX2026/Core/Common/Utilities/AppConstants.swift`

**Step 1: Update exam constants**

Change `AppConstants.Exam`:
```swift
enum Exam {
    static let totalTimeSeconds = 22 * 60    // was 25 * 60
    static let questionsPerExam = 30         // was 35
    static let passThreshold = 28            // was 32
    static let diemLietPerExam = 1           // NEW: exactly 1 instant-fail question per exam
    static let urgencyThresholdSeconds = 300
}
```

**Step 2: Build to verify**

Run: `xcodebuild -project GPLX2026.xcodeproj -scheme GPLX2026 -destination 'id=00008120-0016116A1103C01E' build 2>&1 | tail -3`
Expected: BUILD SUCCEEDED

**Step 3: Commit**

```bash
git add GPLX2026/Core/Common/Utilities/AppConstants.swift
git commit -m "fix: update exam constants to June 2025 format (30q/22min/28pass)"
```

---

### Task 2: Update exam question selection to guarantee 1 điểm liệt

**Files:**
- Modify: `GPLX2026/Core/Storage/QuestionStore.swift`

**Step 1: Update randomExamQuestions()**

Find `randomExamQuestions()` (around line 135-138). Currently shuffles all and takes 35. Replace with logic that guarantees exactly 1 điểm liệt question:

```swift
func randomExamQuestions() -> [Question] {
    let diemLietQuestions = allQuestions.filter(\.isDiemLiet)
    let normalQuestions = allQuestions.filter { !$0.isDiemLiet }

    // Pick exactly 1 điểm liệt + (N-1) normal questions
    let dlCount = AppConstants.Exam.diemLietPerExam
    let normalCount = AppConstants.Exam.questionsPerExam - dlCount

    let selectedDL = Array(diemLietQuestions.shuffled().prefix(dlCount))
    let selectedNormal = Array(normalQuestions.shuffled().prefix(normalCount))

    return (selectedDL + selectedNormal).shuffled()
}
```

**Step 2: Update examSetQuestions()**

Find `examSetQuestions(setId:)` (around line 144). Update the slice size from 35 to use the constant:

```swift
func examSetQuestions(setId: Int) -> [Question] {
    let perSet = AppConstants.Exam.questionsPerExam
    let startIndex = (setId - 1) * perSet
    let endIndex = min(startIndex + perSet, allQuestions.count)
    guard startIndex < allQuestions.count else { return [] }
    return Array(allQuestions[startIndex..<endIndex])
}
```

**Step 3: Build and commit**

```bash
git add GPLX2026/Core/Storage/QuestionStore.swift
git commit -m "fix: exam selection uses 30 questions with 1 guaranteed điểm liệt"
```

---

### Task 3: Update all UI text referencing old exam format

**Files:**
- Modify: `GPLX2026/Features/Home/TheoryTab.swift`
- Modify: `GPLX2026/Features/Home/HomeTab.swift`

**Step 1: Update TheoryTab ExamCTACard rules**

In `TheoryTab.swift`, find the `ExamCTACard` (search for "35 câu"). Update:

```swift
ExamCTACard(
    buttonLabel: "Bắt đầu thi thử",
    rules: [
        (icon: "questionmark.circle", text: "30 câu"),      // was "35 câu"
        (icon: "timer", text: "22 phút"),                    // was "25 phút"
        (icon: "checkmark.circle", text: "≥ 28 đạt"),       // was "≥ 32 đạt"
    ],
    tip: "Sai câu điểm liệt = Trượt. Làm câu điểm liệt trước, không bỏ trống câu nào.",
    // ... rest unchanged
)
```

**Step 2: Update HomeTab smart nudge references if any**

Search HomeTab.swift for any hardcoded "35" or "25 phút" references and update.

**Step 3: Update design docs**

Update `docs/plans/2026-03-09-ux-focus-redesign.md` table to reflect new exam format.

**Step 4: Build and commit**

```bash
git add GPLX2026/Features/Home/TheoryTab.swift GPLX2026/Features/Home/HomeTab.swift docs/plans/
git commit -m "fix: update all UI text to new exam format (30q/22min/28pass)"
```

---

### Task 4: Add study activity tracking to ProgressStore

**Files:**
- Create: `GPLX2026/Core/Storage/ProgressStore+Activity.swift`

**Step 1: Create activity tracking extension**

This tracks daily study activity for the heat map. Stores a dictionary of `[dateString: questionsAnswered]`.

```swift
import Foundation

extension ProgressStore {

    // MARK: - Study Activity Tracking

    private static let activityKey = "study_activity"

    /// Returns study activity as [dateString: count] for the last N days.
    var studyActivity: [String: Int] {
        _ = dataVersion
        guard let data = UserDefaults.standard.data(forKey: Self.activityKey) else { return [:] }
        return (try? JSONDecoder().decode([String: Int].self, from: data)) ?? [:]
    }

    /// Record one question answered today.
    func recordStudyActivity() {
        let today = Self.dateString(from: Date())
        var activity = studyActivity
        activity[today, default: 0] += 1

        // Keep only last 120 days
        let cutoff = Calendar.current.date(byAdding: .day, value: -120, to: Date())!
        let cutoffStr = Self.dateString(from: cutoff)
        activity = activity.filter { $0.key >= cutoffStr }

        if let data = try? JSONEncoder().encode(activity) {
            UserDefaults.standard.set(data, forKey: Self.activityKey)
        }
        dataVersion += 1
    }

    /// Activity count for a specific date.
    func activityCount(for date: Date) -> Int {
        studyActivity[Self.dateString(from: date)] ?? 0
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

    private static func dateString(from date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f.string(from: date)
    }
}
```

**Step 2: Hook into existing question recording**

In `ProgressStore.swift`, find `recordQuestionAnswer(topicKey:questionNo:correct:)` (around line 383). Add `recordStudyActivity()` call at the end:

```swift
func recordQuestionAnswer(topicKey: String, questionNo: Int, correct: Bool) {
    saveQuestionResult(topicKey: topicKey, questionNo: questionNo, correct: correct)
    if correct {
        removeWrongAnswer(questionNo)
    } else {
        addWrongAnswer(questionNo)
    }
    updateStreak()
    recordStudyActivity()  // ADD THIS LINE
}
```

**Step 3: Add file to Xcode project**

```bash
cd /Users/maitrungkien/Desktop/project/GPLX2026
ruby -e "
require 'xcodeproj'
proj = Xcodeproj::Project.open('GPLX2026.xcodeproj')
target = proj.targets.first
group = proj['GPLX2026']['Core']['Storage']
ref = group.new_file('GPLX2026/Core/Storage/ProgressStore+Activity.swift')
target.source_build_phase.add_file_reference(ref)
proj.save
"
```

**Step 4: Build and commit**

```bash
git add GPLX2026/Core/Storage/ProgressStore+Activity.swift GPLX2026/Core/Storage/ProgressStore.swift GPLX2026.xcodeproj
git commit -m "feat: add study activity tracking for heat map"
```

---

### Task 5: Add study heat map component to Home

**Files:**
- Create: `GPLX2026/Core/Common/Display/StudyHeatMap.swift`
- Modify: `GPLX2026/Features/Home/HomeTab.swift`

**Step 1: Create StudyHeatMap view**

A GitHub-style contribution grid using Swift Charts. Shows 16 weeks (112 days) of study activity.

```swift
import SwiftUI
import Charts

struct StudyHeatMap: View {
    @Environment(ProgressStore.self) private var progressStore

    private let weeks = 16
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 3), count: 7)
    private let dayLabels = ["T2", "", "T4", "", "T6", "", "CN"]

    var body: some View {
        let days = generateDays()
        let maxCount = max(days.map(\.count).max() ?? 1, 1)

        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Hoạt động học tập")
                    .font(.system(size: 20, weight: .heavy))
                    .foregroundStyle(Color.appTextDark)

                Spacer()

                let total = progressStore.totalActivity(lastDays: weeks * 7)
                Text("\(total) câu · \(weeks) tuần")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(Color.appTextMedium)
            }

            HStack(alignment: .top, spacing: 3) {
                // Day labels
                VStack(spacing: 3) {
                    ForEach(0..<7, id: \.self) { i in
                        Text(dayLabels[i])
                            .font(.system(size: 9, weight: .medium))
                            .foregroundStyle(Color.appTextLight)
                            .frame(width: 16, height: 14)
                    }
                }

                // Grid
                LazyHGrid(rows: Array(repeating: GridItem(.fixed(14), spacing: 3), count: 7), spacing: 3) {
                    ForEach(days, id: \.date) { day in
                        RoundedRectangle(cornerRadius: 2.5)
                            .fill(cellColor(count: day.count, max: maxCount))
                            .frame(width: 14, height: 14)
                    }
                }
            }

            // Legend
            HStack(spacing: 4) {
                Text("Ít")
                    .font(.system(size: 10))
                    .foregroundStyle(Color.appTextLight)
                ForEach([0.0, 0.25, 0.5, 0.75, 1.0], id: \.self) { intensity in
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color.appSuccess.opacity(max(intensity, 0.08)))
                        .frame(width: 10, height: 10)
                }
                Text("Nhiều")
                    .font(.system(size: 10))
                    .foregroundStyle(Color.appTextLight)
            }
        }
        .padding(20)
        .glassCard()
    }

    private struct DayData {
        let date: Date
        let count: Int
    }

    private func generateDays() -> [DayData] {
        let calendar = Calendar.current
        let today = Date()
        let totalDays = weeks * 7

        // Find the most recent Monday
        let weekday = calendar.component(.weekday, from: today)
        let daysFromMonday = (weekday + 5) % 7
        guard let endMonday = calendar.date(byAdding: .day, value: -daysFromMonday, to: today) else { return [] }
        guard let startDate = calendar.date(byAdding: .day, value: -(totalDays - 1), to: endMonday) else { return [] }

        var days: [DayData] = []
        for i in 0..<totalDays {
            if let date = calendar.date(byAdding: .day, value: i, to: startDate) {
                let count = date <= today ? progressStore.activityCount(for: date) : 0
                days.append(DayData(date: date, count: count))
            }
        }

        // Pad to include remaining days of current week
        let remaining = 7 - (days.count % 7)
        if remaining < 7 {
            for i in 0..<remaining {
                if let date = calendar.date(byAdding: .day, value: totalDays + i, to: startDate) {
                    days.append(DayData(date: date, count: 0))
                }
            }
        }

        return days
    }

    private func cellColor(count: Int, max: Int) -> Color {
        guard count > 0 else { return Color.appDivider.opacity(0.4) }
        let intensity = Double(count) / Double(max)
        return Color.appSuccess.opacity(0.2 + intensity * 0.8)
    }
}
```

**Step 2: Add to HomeTab**

In `HomeTab.swift`, add `StudyHeatMap()` after `TopicProgressSection()` and before `RecentResultsCard()`:

```swift
VStack(spacing: 24) {
    ProgressHeroCard()
    SmartNudgeCard()
    UtilityGrid()
    TopicProgressSection()
    StudyHeatMap()          // ADD HERE
    RecentResultsCard()
    ReferenceSection()
}
```

**Step 3: Add file to Xcode project**

```bash
cd /Users/maitrungkien/Desktop/project/GPLX2026
ruby -e "
require 'xcodeproj'
proj = Xcodeproj::Project.open('GPLX2026.xcodeproj')
target = proj.targets.first
group = proj['GPLX2026']['Core']['Common']['Display']
ref = group.new_file('GPLX2026/Core/Common/Display/StudyHeatMap.swift')
target.source_build_phase.add_file_reference(ref)
proj.save
"
```

**Step 4: Build and commit**

```bash
git add GPLX2026/Core/Common/Display/StudyHeatMap.swift GPLX2026/Features/Home/HomeTab.swift GPLX2026.xcodeproj
git commit -m "feat: add GitHub-style study activity heat map to Home"
```

---

### Task 6: Add exam countdown and daily study goal

**Files:**
- Create: `GPLX2026/Core/Storage/ProgressStore+ExamDate.swift`
- Create: `GPLX2026/Core/Common/Display/ExamCountdownCard.swift`
- Modify: `GPLX2026/Features/Home/HomeTab.swift`
- Modify: `GPLX2026/Features/Settings/SettingsView.swift`

**Step 1: Create exam date storage**

```swift
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
        return goal > 0 ? goal : 30  // default 30 questions/day
    }

    func setDailyGoal(_ goal: Int) {
        UserDefaults.standard.set(goal, forKey: Self.dailyGoalKey)
        dataVersion += 1
    }

    /// Days until exam (nil if no exam date set).
    var daysUntilExam: Int? {
        guard let examDate else { return nil }
        return max(0, Calendar.current.dateComponents([.day], from: Date(), to: examDate).day ?? 0)
    }

    /// Today's progress toward daily goal.
    var todayProgress: (done: Int, goal: Int) {
        let done = activityCount(for: Date())
        return (done, dailyGoal)
    }
}
```

**Step 2: Create ExamCountdownCard**

```swift
import SwiftUI

struct ExamCountdownCard: View {
    @Environment(ProgressStore.self) private var progressStore

    var body: some View {
        if let daysLeft = progressStore.daysUntilExam {
            let today = progressStore.todayProgress

            VStack(spacing: 16) {
                HStack(spacing: 16) {
                    // Days countdown
                    VStack(spacing: 2) {
                        Text("\(daysLeft)")
                            .font(.system(size: 36, weight: .heavy).monospacedDigit())
                            .foregroundStyle(daysLeft <= 7 ? Color.appError : Color.appPrimary)
                            .contentTransition(.numericText())
                        Text("ngày còn lại")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(Color.appTextMedium)
                    }
                    .frame(width: 90)

                    Rectangle().fill(Color.appDivider).frame(width: 1, height: 48)

                    // Today's goal
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Hôm nay")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(Color.appTextLight)
                            .textCase(.uppercase)

                        HStack(spacing: 8) {
                            Text("\(today.done)/\(today.goal)")
                                .font(.system(size: 20, weight: .bold).monospacedDigit())
                                .foregroundStyle(today.done >= today.goal ? Color.appSuccess : Color.appTextDark)
                                .contentTransition(.numericText())

                            Text("câu")
                                .font(.system(size: 14))
                                .foregroundStyle(Color.appTextMedium)

                            if today.done >= today.goal {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(Color.appSuccess)
                                    .font(.system(size: 16))
                            }
                        }

                        ProgressView(value: min(Double(today.done) / Double(today.goal), 1.0))
                            .tint(today.done >= today.goal ? Color.appSuccess : Color.appPrimary)
                    }
                }
            }
            .padding(20)
            .glassCard()
        }
    }
}
```

**Step 3: Add to HomeTab**

In `HomeTab.swift`, add `ExamCountdownCard()` between `ProgressHeroCard()` and `SmartNudgeCard()`:

```swift
VStack(spacing: 24) {
    ProgressHeroCard()
    ExamCountdownCard()    // ADD HERE
    SmartNudgeCard()
    UtilityGrid()
    TopicProgressSection()
    StudyHeatMap()
    RecentResultsCard()
    ReferenceSection()
}
```

**Step 4: Add exam date picker to SettingsView**

In `SettingsView.swift`, find the settings list and add a section for exam date. Add these controls:

```swift
// Inside SettingsView, add a section:
Section("Ngày thi") {
    if let examDate = progressStore.examDate {
        HStack {
            Text("Ngày thi dự kiến")
            Spacer()
            Text(examDate, style: .date)
                .foregroundStyle(Color.appTextMedium)
        }
    }

    DatePicker(
        progressStore.examDate == nil ? "Chọn ngày thi" : "Đổi ngày",
        selection: Binding(
            get: { progressStore.examDate ?? Date() },
            set: { progressStore.setExamDate($0) }
        ),
        in: Date()...,
        displayedComponents: .date
    )

    if progressStore.examDate != nil {
        Button("Xoá ngày thi", role: .destructive) {
            progressStore.setExamDate(nil)
        }
    }

    Stepper(
        "Mục tiêu: \(progressStore.dailyGoal) câu/ngày",
        value: Binding(
            get: { progressStore.dailyGoal },
            set: { progressStore.setDailyGoal($0) }
        ),
        in: 10...100,
        step: 10
    )
}
```

**Step 5: Add files to Xcode project and build**

```bash
cd /Users/maitrungkien/Desktop/project/GPLX2026
ruby -e "
require 'xcodeproj'
proj = Xcodeproj::Project.open('GPLX2026.xcodeproj')
target = proj.targets.first
storage_group = proj['GPLX2026']['Core']['Storage']
display_group = proj['GPLX2026']['Core']['Common']['Display']
ref1 = storage_group.new_file('GPLX2026/Core/Storage/ProgressStore+ExamDate.swift')
ref2 = display_group.new_file('GPLX2026/Core/Common/Display/ExamCountdownCard.swift')
target.source_build_phase.add_file_reference(ref1)
target.source_build_phase.add_file_reference(ref2)
proj.save
"
```

**Step 6: Build and commit**

```bash
git add GPLX2026/Core/Storage/ProgressStore+ExamDate.swift GPLX2026/Core/Common/Display/ExamCountdownCard.swift GPLX2026/Features/Home/HomeTab.swift GPLX2026/Features/Settings/SettingsView.swift GPLX2026.xcodeproj
git commit -m "feat: add exam countdown card with daily study goal"
```

---

### Task 7: Breathing UI for QuestionView (calm study experience)

**Files:**
- Modify: `GPLX2026/Features/Learn/QuestionView.swift`

**Step 1: Improve answer transition**

In `QuestionView.swift`, find the question display section. Add smooth cross-dissolve animation when navigating between questions instead of the default slide:

Find the place where `currentIndex` changes (the next/previous buttons). Wrap the question content in:

```swift
.animation(.easeInOut(duration: 0.3), value: currentIndex)
.transition(.opacity)
```

**Step 2: Add post-answer breathing moment**

After the user confirms an answer (in the confirmation handler), add a brief delay before allowing next:

Find the confirmation logic (around line 262-278). After recording the answer, keep `isConfirmed = true` for at least 1 second before enabling the next button, allowing the user to see the explanation. The explanation box is already shown — just ensure the "Next" button has a slight delay via:

```swift
@State private var canAdvance = true

// In confirmation handler, after recording:
canAdvance = false
DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
    canAdvance = true
}
```

Then disable the Next button with `.disabled(!canAdvance)` and add subtle opacity: `.opacity(canAdvance ? 1.0 : 0.5)`.

**Step 3: Improve typography and spacing**

Ensure question text uses 17pt body font with 1.4 line spacing for readability:

```swift
Text(question.text)
    .font(.system(size: 17, weight: .regular))
    .lineSpacing(4)
    .foregroundStyle(Color.appTextDark)
```

Ensure answer cards have at least 16pt padding and clear touch targets (min 44pt height per Apple HIG).

**Step 4: Add progress indicator**

At the top of the question view, show a thin progress bar:

```swift
ProgressView(value: Double(currentIndex + 1) / Double(questions.count))
    .tint(Color.appPrimary)
    .scaleEffect(y: 0.5)
```

**Step 5: Build and commit**

```bash
git add GPLX2026/Features/Learn/QuestionView.swift
git commit -m "feat: breathing UI for QuestionView — calm transitions, spacing, progress"
```

---

### Task 8: Apple HIG compliance pass

**Files:**
- Modify: `GPLX2026/Core/Theme/AppTheme.swift`
- Modify: `GPLX2026/Core/Common/Cards/AnswerOptionCard.swift`

**Step 1: Verify glass effect usage**

In `AppTheme.swift`, verify the `GlassCard` modifier follows Apple's liquid glass guidelines:
- `.glassEffect(.regular)` for content cards (non-interactive) — correct
- `.glassEffect(.regular.interactive())` for tappable cards — correct
- Ensure `GlassEffectContainer` is used on parent ScrollViews for proper glass grouping (iOS 26)

If `GlassEffectContainer` is not used, wrap the main ScrollView in `HomeTab`, `TheoryTab`, `SimulationTab`, `HazardTab` with:

```swift
if #available(iOS 26.0, *) {
    ScrollView {
        // content
    }
    .glassEffectContainer()
} else {
    ScrollView {
        // content
    }
}
```

Or use a conditional modifier approach to avoid code duplication.

**Step 2: Verify touch targets**

In `AnswerOptionCard.swift`, ensure all answer buttons have minimum 44pt height (Apple HIG requirement). If any answer card has less than 44pt height, increase padding.

**Step 3: Verify SF Symbol usage**

Ensure all icons use SF Symbols with proper rendering modes:
- `.symbolRenderingMode(.hierarchical)` for decorative icons
- `.symbolRenderingMode(.monochrome)` for action icons

**Step 4: Build and commit**

```bash
git add GPLX2026/Core/Theme/AppTheme.swift GPLX2026/Core/Common/Cards/AnswerOptionCard.swift
git commit -m "refactor: Apple HIG compliance — glass containers, touch targets, SF symbols"
```

---

### Task 9: Final build, install, and verify

**Step 1: Clean build**

```bash
xcodebuild -project GPLX2026.xcodeproj -scheme GPLX2026 -destination 'id=00008120-0016116A1103C01E' clean build 2>&1 | tail -10
```

**Step 2: Install on device**

```bash
xcrun devicectl device install app --device 00008120-0016116A1103C01E <app_path>
```

**Step 3: Verify checklist**

- [ ] Mock exam shows 30 questions / 22 min / ≥28 pass
- [ ] Mock exam includes exactly 1 điểm liệt question
- [ ] Fixed exam sets (Đề 1-20) work with 30 questions each
- [ ] Exam results correctly show pass/fail with new thresholds
- [ ] Study heat map appears on Home, shows activity grid
- [ ] Answering questions increments heat map for today
- [ ] Exam countdown card shows when exam date is set in Settings
- [ ] Daily goal progress bar updates as questions are answered
- [ ] Settings: exam date picker works, daily goal stepper works
- [ ] QuestionView: smooth transitions between questions
- [ ] QuestionView: brief pause after answering before next
- [ ] QuestionView: progress bar at top
- [ ] All cards use proper glass effects on iOS 26
- [ ] All touch targets are ≥44pt
- [ ] App feels calm and focused during study

**Step 4: Commit any fixes**

```bash
git add -A
git commit -m "feat: complete app update — new exam format, heat map, countdown, breathing UI"
```
