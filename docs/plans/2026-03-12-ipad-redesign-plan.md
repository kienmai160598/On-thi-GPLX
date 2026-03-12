# iPad Redesign Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Make every screen in the GPLX2026 app responsive on iPad with multi-column grids, side-by-side exam layouts, and senior-friendly sizing — while keeping iPhone layouts completely unchanged.

**Architecture:** Three shared primitives (`LayoutMetrics`, `AdaptiveGrid`, `SplitContent`) injected via SwiftUI environment. Each screen swaps its `LazyVStack`/`VStack` for `AdaptiveGrid` or `SplitContent` based on `LayoutMetrics.isWide`. Breakpoints are computed from `horizontalSizeClass` + screen width.

**Tech Stack:** SwiftUI, `@Observable`, `@Environment(\.horizontalSizeClass)`, `LazyVGrid`, `GeometryReader`

---

### Task 1: Create LayoutMetrics

**Files:**
- Create: `GPLX2026/Core/Common/Layout/LayoutMetrics.swift`
- Modify: `GPLX2026/GPLX2026App.swift` (inject into environment)

**Step 1: Create LayoutMetrics.swift**

```swift
import SwiftUI

@Observable
@MainActor
final class LayoutMetrics {
    // Inputs
    var horizontalSizeClass: UserInterfaceSizeClass? = .compact

    // Computed
    var isWide: Bool { horizontalSizeClass == .regular }

    var columns: Int {
        guard isWide else { return 1 }
        let width = UIScreen.main.bounds.width
        if width > 1100 { return 3 }
        return 2
    }

    var gridSpacing: CGFloat { isWide ? 16 : 12 }
    var contentPadding: CGFloat { isWide ? 28 : 20 }
    var cardPadding: CGFloat { isWide ? 18 : 12 }
    var rowSpacing: CGFloat { isWide ? 14 : 8 }
    var fontScale: CGFloat { isWide ? 1.15 : 1.0 }

    var buttonHeight: CGFloat { isWide ? 56 : 48 }
    var answerHeight: CGFloat { isWide ? 60 : 48 }
    var gridCellSize: CGFloat { isWide ? 48 : 44 }
    var gridColumns: Int { isWide ? 8 : 6 }

    var cardMinWidth: CGFloat { 300 }
}
```

**Step 2: Add LayoutMetrics to the app environment**

In `GPLX2026App.swift`, find the `@State` property declarations (around line 8-12). Add:

```swift
@State private var layoutMetrics = LayoutMetrics()
```

Then in the body where environments are injected, add `.environment(layoutMetrics)` to the view chain.

**Step 3: Add a sizeClass reader**

Create a ViewModifier that reads `horizontalSizeClass` and writes it to `LayoutMetrics`. Add to `LayoutMetrics.swift`:

```swift
struct LayoutMetricsReader: ViewModifier {
    @Environment(LayoutMetrics.self) private var metrics
    @Environment(\.horizontalSizeClass) private var sizeClass

    func body(content: Content) -> some View {
        content
            .onChange(of: sizeClass, initial: true) { _, newValue in
                metrics.horizontalSizeClass = newValue
            }
    }
}

extension View {
    func trackLayoutMetrics() -> some View {
        modifier(LayoutMetricsReader())
    }
}
```

Apply `.trackLayoutMetrics()` in `GPLX2026App.swift` on the root view (right after the TabView or the outermost container).

**Step 4: Build and verify**

Run: `xcodebuild -project GPLX2026.xcodeproj -scheme GPLX2026 -destination 'generic/platform=iOS' build`
Expected: BUILD SUCCEEDED

**Step 5: Commit**

```bash
git add GPLX2026/Core/Common/Layout/LayoutMetrics.swift GPLX2026/GPLX2026App.swift
git commit -m "feat: add LayoutMetrics environment object for iPad adaptive layouts"
```

---

### Task 2: Create AdaptiveGrid

**Files:**
- Create: `GPLX2026/Core/Common/Layout/AdaptiveGrid.swift`

**Step 1: Create AdaptiveGrid.swift**

```swift
import SwiftUI

/// Drop-in replacement for LazyVStack that becomes a LazyVGrid on iPad.
/// Usage: AdaptiveGrid { ForEach(...) { ... } }
struct AdaptiveGrid<Content: View>: View {
    @Environment(LayoutMetrics.self) private var metrics

    var spacing: CGFloat?
    @ViewBuilder var content: () -> Content

    var body: some View {
        if metrics.isWide {
            LazyVGrid(
                columns: Array(
                    repeating: GridItem(.flexible(), spacing: metrics.gridSpacing),
                    count: metrics.columns
                ),
                spacing: spacing ?? metrics.rowSpacing
            ) {
                content()
            }
        } else {
            LazyVStack(spacing: spacing ?? metrics.rowSpacing) {
                content()
            }
        }
    }
}
```

**Step 2: Build and verify**

Run: `xcodebuild -project GPLX2026.xcodeproj -scheme GPLX2026 -destination 'generic/platform=iOS' build`
Expected: BUILD SUCCEEDED

**Step 3: Commit**

```bash
git add GPLX2026/Core/Common/Layout/AdaptiveGrid.swift
git commit -m "feat: add AdaptiveGrid component (LazyVStack on iPhone, LazyVGrid on iPad)"
```

---

### Task 3: Create SplitContent

**Files:**
- Create: `GPLX2026/Core/Common/Layout/SplitContent.swift`

**Step 1: Create SplitContent.swift**

```swift
import SwiftUI

/// Side-by-side layout on iPad, vertical stack on iPhone.
/// Usage: SplitContent(leading: { QuestionCard() }, trailing: { AnswerList() })
struct SplitContent<Leading: View, Trailing: View>: View {
    @Environment(LayoutMetrics.self) private var metrics

    var leadingRatio: CGFloat = 0.55
    @ViewBuilder var leading: () -> Leading
    @ViewBuilder var trailing: () -> Trailing

    var body: some View {
        if metrics.isWide {
            GeometryReader { geo in
                HStack(alignment: .top, spacing: metrics.gridSpacing) {
                    ScrollView {
                        leading()
                            .frame(maxWidth: .infinity)
                    }
                    .frame(width: geo.size.width * leadingRatio)

                    ScrollView {
                        trailing()
                            .frame(maxWidth: .infinity)
                    }
                }
                .padding(.horizontal, metrics.contentPadding)
            }
        } else {
            // iPhone: just a regular VStack inside a ScrollView (caller provides ScrollView)
            VStack(alignment: .leading, spacing: 0) {
                leading()
                trailing()
            }
        }
    }
}
```

**Step 2: Build and verify**

Run: `xcodebuild -project GPLX2026.xcodeproj -scheme GPLX2026 -destination 'generic/platform=iOS' build`
Expected: BUILD SUCCEEDED

**Step 3: Commit**

```bash
git add GPLX2026/Core/Common/Layout/SplitContent.swift
git commit -m "feat: add SplitContent component (VStack on iPhone, HStack on iPad)"
```

---

### Task 4: Add new files to Xcode project

**Files:**
- Modify: `GPLX2026.xcodeproj/project.pbxproj`

**Step 1: Use xcodeproj Ruby gem to add the 3 new files**

```bash
ruby -e '
require "xcodeproj"
project = Xcodeproj::Project.open("GPLX2026.xcodeproj")
target = project.targets.first
group = project["GPLX2026"]["Core"]["Common"]["Layout"]
%w[LayoutMetrics.swift AdaptiveGrid.swift SplitContent.swift].each do |name|
  path = "GPLX2026/Core/Common/Layout/#{name}"
  next if group.files.any? { |f| f.path == name }
  ref = group.new_reference(name)
  ref.set_last_known_file_type("sourcecode.swift")
  target.source_build_phase.add_file_reference(ref)
end
project.save
'
```

**Step 2: Build and verify**

Run: `xcodebuild -project GPLX2026.xcodeproj -scheme GPLX2026 -destination 'generic/platform=iOS' build`
Expected: BUILD SUCCEEDED

**Step 3: Commit**

```bash
git add GPLX2026.xcodeproj/project.pbxproj
git commit -m "chore: add LayoutMetrics, AdaptiveGrid, SplitContent to Xcode project"
```

---

### Task 5: Update HomeTab for iPad grid layout

**Files:**
- Modify: `GPLX2026/Features/Home/HomeTab.swift`

**Step 1: Add LayoutMetrics environment**

At line 7 (after the existing `@Environment` declarations), add:

```swift
@Environment(LayoutMetrics.self) private var metrics
```

**Step 2: Replace the body layout**

Replace the current body content (lines 21-33) with a layout that uses `AdaptiveGrid` for topic cards and side-by-side for ContinueLearning + RecentResults on iPad:

```swift
ScrollView {
    VStack(spacing: metrics.isWide ? 24 : 20) {
        // Full-width hero — always 1 column
        ProgressOverview()

        PrimaryActionCard()

        // Quick actions — already a 2-col grid, bump to 3 on landscape iPad
        QuickActionsGrid()

        ShortcutsRow()

        RecentResultsCard()

        AchievementsCard()
    }
    .padding(.horizontal, metrics.contentPadding)
    .frame(maxWidth: metrics.isWide ? .infinity : 700)
    .frame(maxWidth: .infinity)
    .padding(.bottom, 32)
}
```

**Step 3: Update QuickActionsGrid columns**

In `QuickActionsGrid` (line 282), replace the fixed 2-column definition:

```swift
// Old:
private let columns = [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)]
```

With dynamic columns:

```swift
@Environment(LayoutMetrics.self) private var metrics

private var columns: [GridItem] {
    Array(repeating: GridItem(.flexible(), spacing: metrics.gridSpacing),
          count: metrics.columns == 3 ? 4 : 2)
}
```

And update the `LazyVGrid` spacing to use `metrics.gridSpacing`.

**Step 4: Build and verify**

Run: `xcodebuild -project GPLX2026.xcodeproj -scheme GPLX2026 -destination 'generic/platform=iOS' build`
Expected: BUILD SUCCEEDED

**Step 5: Commit**

```bash
git add GPLX2026/Features/Home/HomeTab.swift
git commit -m "feat: make HomeTab responsive with multi-column grid on iPad"
```

---

### Task 6: Update PracticeTab for iPad grid layout

**Files:**
- Modify: `GPLX2026/Features/Home/PracticeTab.swift`

**Step 1: Add LayoutMetrics environment**

Add after line 6:

```swift
@Environment(LayoutMetrics.self) private var metrics
```

**Step 2: Update body padding**

Replace `.padding(.horizontal, 20)` (line 14) with:

```swift
.padding(.horizontal, metrics.contentPadding)
```

Remove `.iPadReadable()` (line 15) — the content will fill the iPad screen with multi-column topic rows.

**Step 3: Convert topic list to AdaptiveGrid (optional approach)**

The topic list in `questionSection` uses a `VStack(spacing: 0)` with dividers inside a single `.glassCard()`. On iPad, we could keep this as a list (it works well) but make the cards wider. Alternatively, if the list has many topics, split into 2-column cards.

Recommended: Keep the topic list as a single-column card (it's a settings-like list with dividers), but use `metrics.contentPadding` and remove `iPadReadable` so it's wider on iPad. The hazard section is the same pattern.

**Step 4: Build and verify**

Run: `xcodebuild -project GPLX2026.xcodeproj -scheme GPLX2026 -destination 'generic/platform=iOS' build`
Expected: BUILD SUCCEEDED

**Step 5: Commit**

```bash
git add GPLX2026/Features/Home/PracticeTab.swift
git commit -m "feat: make PracticeTab use LayoutMetrics padding for iPad"
```

---

### Task 7: Update ExamTab for iPad grid layout

**Files:**
- Modify: `GPLX2026/Features/Home/ExamTab.swift`

**Step 1: Add LayoutMetrics environment**

Add to `ExamTab`:

```swift
@Environment(LayoutMetrics.self) private var metrics
```

**Step 2: Update padding and remove iPadReadable**

Replace `.padding(.horizontal, 20)` with `.padding(.horizontal, metrics.contentPadding)` and remove `.iPadReadable()`.

**Step 3: Make exam cards and history lists use AdaptiveGrid on iPad**

When `filter == .all` and on iPad, the three exam type sections could lay out side by side. But since each section has conditional history below it, it's better to keep them vertical but wider.

The history lists (HistoryList) should use `AdaptiveGrid` so cards flow into 2 columns:

In each history section, wrap the `HistoryList` in something that uses the grid. If `HistoryList` is a reusable component, modify it to accept a column count, or wrap its content.

**Step 4: Build and verify**

Run: `xcodebuild -project GPLX2026.xcodeproj -scheme GPLX2026 -destination 'generic/platform=iOS' build`
Expected: BUILD SUCCEEDED

**Step 5: Commit**

```bash
git add GPLX2026/Features/Home/ExamTab.swift
git commit -m "feat: make ExamTab use LayoutMetrics padding for iPad"
```

---

### Task 8: Update QuestionView with SplitContent for iPad

**Files:**
- Modify: `GPLX2026/Features/Learn/QuestionView.swift`
- Modify: `GPLX2026/Core/Common/Cards/AnswerOptionCard.swift`
- Modify: `GPLX2026/Core/Common/Exam/ExamBottomBar.swift`

**Step 1: Add LayoutMetrics to QuestionView**

Add to the `@Environment` declarations:

```swift
@Environment(LayoutMetrics.self) private var metrics
```

**Step 2: Replace questionContent layout with SplitContent**

Currently the layout is (lines 108-134):
```swift
VStack(spacing: 0) {
    ScrollView {
        VStack(alignment: .leading, spacing: 0) {
            QuestionCard(...)
            AnswerTileList(...)
            ExplanationBox(...)
        }
        .padding(.horizontal, 20)
        .iPadReadable()
    }
    ExamBottomBar(...)
}
```

Replace with:

```swift
VStack(spacing: 0) {
    if metrics.isWide {
        // iPad: side-by-side
        HStack(alignment: .top, spacing: metrics.gridSpacing) {
            // Left: question + image
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    QuestionCard(label: "Câu \(question.no):", question: question)
                    if isConfirmed && !question.tip.isEmpty {
                        ExplanationBox(content: question.tip)
                            .padding(.top, 12)
                            .transition(.opacity.combined(with: .move(edge: .top)))
                    }
                }
                .padding(metrics.contentPadding)
            }

            // Right: answers
            ScrollView {
                AnswerTileList(
                    answers: shuffledAnswers,
                    selectedAnswerId: selectedAnswerId,
                    isConfirmed: isConfirmed,
                    showCorrectness: true,
                    onSelect: { selectAnswer($0) }
                )
                .padding(metrics.contentPadding)
            }
        }
        .id(currentIndex)
    } else {
        // iPhone: current vertical layout
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                QuestionCard(label: "Câu \(question.no):", question: question)
                    .padding(.bottom, 20)
                AnswerTileList(
                    answers: shuffledAnswers,
                    selectedAnswerId: selectedAnswerId,
                    isConfirmed: isConfirmed,
                    showCorrectness: true,
                    onSelect: { selectAnswer($0) }
                )
                if isConfirmed && !question.tip.isEmpty {
                    ExplanationBox(content: question.tip)
                        .padding(.top, 4)
                        .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
            .padding(.horizontal, 20)
            .iPadReadable()
            .padding(.top, 16)
        }
        .id(currentIndex)
        .transition(.opacity)
        .animation(.easeInOut(duration: 0.3), value: currentIndex)
    }
    ExamBottomBar(...)
}
```

**Step 3: Update AnswerOptionCard for senior-friendly iPad sizing**

In `AnswerOptionCard.swift`, add `@Environment(LayoutMetrics.self) private var metrics` and:

- Change letter indicator size: `frame(width: metrics.isWide ? 44 : 36, height: metrics.isWide ? 44 : 36)`
- Change letter font: `font(.appSans(size: metrics.isWide ? 18 : 16, weight: .bold))`
- Change text font scale: multiply by `metrics.fontScale`
- Change padding: `.padding(.horizontal, metrics.isWide ? 16 : 12).padding(.vertical, metrics.isWide ? 16 : 12)`
- Make left border thicker on iPad: `frame(width: metrics.isWide ? 5 : 4)`

**Step 4: Update ExamBottomBar for iPad**

In `ExamBottomBar.swift`, add `@Environment(LayoutMetrics.self) private var metrics` and:

- Change button height references: use `metrics.buttonHeight` (56 on iPad)
- Change padding: `.padding(.horizontal, metrics.contentPadding)`
- Remove `.iPadReadable()` (line 55)

**Step 5: Build and verify**

Run: `xcodebuild -project GPLX2026.xcodeproj -scheme GPLX2026 -destination 'generic/platform=iOS' build`
Expected: BUILD SUCCEEDED

**Step 6: Commit**

```bash
git add GPLX2026/Features/Learn/QuestionView.swift GPLX2026/Core/Common/Cards/AnswerOptionCard.swift GPLX2026/Core/Common/Exam/ExamBottomBar.swift
git commit -m "feat: side-by-side question/answer layout on iPad with larger touch targets"
```

---

### Task 9: Update ExamQuestionGridSheet for iPad

**Files:**
- Modify: `GPLX2026/Core/Common/Exam/ExamQuestionGridSheet.swift`

**Step 1: Add LayoutMetrics and make columns dynamic**

Replace the fixed columns definition (line 12):

```swift
// Old:
private let columns = Array(repeating: GridItem(.flexible(), spacing: 10), count: 6)
```

With:

```swift
@Environment(LayoutMetrics.self) private var metrics

private var columns: [GridItem] {
    Array(repeating: GridItem(.flexible(), spacing: 10), count: metrics.gridColumns)
}
```

**Step 2: Update grid cell size for iPad**

In `gridCell` (line 62), change:

```swift
// Old:
.frame(maxWidth: .infinity, minHeight: 44)
```

To:

```swift
.frame(maxWidth: .infinity, minHeight: metrics.gridCellSize)
```

**Step 3: Build and verify**

Run: `xcodebuild -project GPLX2026.xcodeproj -scheme GPLX2026 -destination 'generic/platform=iOS' build`
Expected: BUILD SUCCEEDED

**Step 4: Commit**

```bash
git add GPLX2026/Core/Common/Exam/ExamQuestionGridSheet.swift
git commit -m "feat: question grid sheet uses 8 columns with larger cells on iPad"
```

---

### Task 10: Update ExamResultView for iPad dashboard layout

**Files:**
- Modify: `GPLX2026/Features/Exam/ExamResultView.swift`

**Step 1: Add LayoutMetrics**

```swift
@Environment(LayoutMetrics.self) private var metrics
```

**Step 2: Update the layout**

Replace `.padding(.horizontal, 20)` with `.padding(.horizontal, metrics.contentPadding)`.

Remove `.iPadReadable()` (line 79).

Wrap the `LazyVStack` question review section (lines 65-76) with `AdaptiveGrid`:

```swift
// Old:
LazyVStack(spacing: 8) {
    ForEach(...) { ... }
}

// New:
AdaptiveGrid {
    ForEach(...) { ... }
}
```

**Step 3: Update bottom bar padding**

In the `safeAreaInset` (lines 82-108), update padding:

```swift
.padding(.horizontal, metrics.contentPadding)
```

And button heights to use `metrics.buttonHeight`.

**Step 4: Build and verify**

Run: `xcodebuild -project GPLX2026.xcodeproj -scheme GPLX2026 -destination 'generic/platform=iOS' build`
Expected: BUILD SUCCEEDED

**Step 5: Commit**

```bash
git add GPLX2026/Features/Exam/ExamResultView.swift
git commit -m "feat: ExamResultView uses AdaptiveGrid for question review on iPad"
```

---

### Task 11: Update SimulationResultView for iPad

**Files:**
- Modify: `GPLX2026/Features/Simulation/SimulationResultView.swift`

Same pattern as Task 10:
- Add `@Environment(LayoutMetrics.self) private var metrics`
- Replace `.padding(.horizontal, 20)` with `.padding(.horizontal, metrics.contentPadding)`
- Remove `.iPadReadable()`
- Wrap question review `LazyVStack` with `AdaptiveGrid`
- Update bottom bar button heights to `metrics.buttonHeight`

**Build, verify, commit:**

```bash
git add GPLX2026/Features/Simulation/SimulationResultView.swift
git commit -m "feat: SimulationResultView uses AdaptiveGrid for iPad"
```

---

### Task 12: Update HazardResultView for iPad

**Files:**
- Modify: `GPLX2026/Features/Hazard/HazardResultView.swift`

**Step 1: Add LayoutMetrics**

```swift
@Environment(LayoutMetrics.self) private var metrics
```

**Step 2: Update layout**

- Replace `.padding(.horizontal, 20)` uses with `.padding(.horizontal, metrics.contentPadding)`
- Wrap the `LazyVStack` of `HazardReviewRow` (lines 64-77) with `AdaptiveGrid`
- Add `.iPadReadable()` removal from line 83

**Step 3: Add "Xem chi tiết" label to expandable rows**

In `HazardReviewRow` (line 314), after the chevron, add visible text on iPad:

```swift
// After the chevron.right Image:
if metrics.isWide {
    Text(isExpanded ? "Thu gọn" : "Xem chi tiết")
        .font(.appSans(size: 13, weight: .medium))
        .foregroundStyle(Color.appTextLight)
}
```

Also increase score dots size on iPad (line 305):

```swift
.frame(width: metrics.isWide ? 10 : 8, height: metrics.isWide ? 10 : 8)
```

**Build, verify, commit:**

```bash
git add GPLX2026/Features/Hazard/HazardResultView.swift
git commit -m "feat: HazardResultView uses AdaptiveGrid and senior-friendly sizing on iPad"
```

---

### Task 13: Update secondary list screens for iPad

**Files:**
- Modify: `GPLX2026/Features/Bookmarks/BookmarksView.swift`
- Modify: `GPLX2026/Features/Bookmarks/WrongAnswersView.swift`
- Modify: `GPLX2026/Features/Search/QuestionSearchView.swift`
- Modify: `GPLX2026/Features/Home/TopicDetailView.swift`

For each file:

**Step 1: Add LayoutMetrics**

```swift
@Environment(LayoutMetrics.self) private var metrics
```

**Step 2: Replace padding and remove iPadReadable**

- Replace `.padding(.horizontal, 20)` with `.padding(.horizontal, metrics.contentPadding)`
- Remove `.iPadReadable()` where present

**Step 3: Wrap card lists with AdaptiveGrid**

BookmarksView — wrap the `ForEach(bookmarked, ...)` (line 18) in `AdaptiveGrid`:
```swift
AdaptiveGrid {
    ForEach(bookmarked, id: \.no) { question in
        BookmarkQuestionCard(question: question, topicKey: AppConstants.TopicKey.bookmarks)
    }
}
```

WrongAnswersView — wrap the `ForEach(wrongByTopic, ...)` (line 17) in `AdaptiveGrid`:
```swift
AdaptiveGrid {
    ForEach(wrongByTopic, id: \.topic.key) { group in
        WrongTopicCard(topic: group.topic, questions: group.questions)
    }
}
```

QuestionSearchView — wrap the `LazyVStack` (line 72) with `AdaptiveGrid`:
```swift
AdaptiveGrid {
    ForEach(filteredQuestions, id: \.no) { question in
        ...
    }
}
```

TopicDetailView — use `metrics.contentPadding` and remove `iPadReadable`.

**Step 4: Build and verify**

Run: `xcodebuild -project GPLX2026.xcodeproj -scheme GPLX2026 -destination 'generic/platform=iOS' build`
Expected: BUILD SUCCEEDED

**Step 5: Commit**

```bash
git add GPLX2026/Features/Bookmarks/BookmarksView.swift GPLX2026/Features/Bookmarks/WrongAnswersView.swift GPLX2026/Features/Search/QuestionSearchView.swift GPLX2026/Features/Home/TopicDetailView.swift
git commit -m "feat: secondary list screens use AdaptiveGrid for iPad multi-column layout"
```

---

### Task 14: Update SimulationTab for iPad

**Files:**
- Modify: `GPLX2026/Features/Home/SimulationTab.swift`

**Step 1: Add LayoutMetrics and update padding**

Same pattern: add `@Environment(LayoutMetrics.self) private var metrics`, replace hardcoded padding with `metrics.contentPadding`, remove `iPadReadable` if present.

**Build, verify, commit:**

```bash
git add GPLX2026/Features/Home/SimulationTab.swift
git commit -m "feat: SimulationTab uses LayoutMetrics for iPad spacing"
```

---

### Task 15: Update SettingsView and reference views for iPad

**Files:**
- Modify: `GPLX2026/Features/Settings/SettingsView.swift`
- Modify: `GPLX2026/Features/Reference/SpeedDistanceReferenceView.swift`
- Modify: `GPLX2026/Features/Reference/TrafficSignsReferenceView.swift`

These screens stay single-column but should be wider on iPad:

**Step 1: Replace `.iPadReadable()` with `.iPadReadable(maxWidth: 900)` for wider cards on iPad**

Settings and reference views don't need multi-column. They just need to be wider (900pt max instead of 700pt).

**Build, verify, commit:**

```bash
git add GPLX2026/Features/Settings/SettingsView.swift GPLX2026/Features/Reference/SpeedDistanceReferenceView.swift GPLX2026/Features/Reference/TrafficSignsReferenceView.swift
git commit -m "feat: widen SettingsView and reference views on iPad (900pt max)"
```

---

### Task 16: Align HazardTestView with LayoutMetrics

**Files:**
- Modify: `GPLX2026/Features/Hazard/HazardTestView.swift`

**Step 1: Add LayoutMetrics**

HazardTestView already has iPad-aware layout using `horizontalSizeClass`. Integrate `LayoutMetrics` for consistency:

- Add `@Environment(LayoutMetrics.self) private var metrics`
- Replace hardcoded button heights with `metrics.buttonHeight`
- Use `metrics.contentPadding` for spacing

This is a light alignment pass, not a restructure.

**Build, verify, commit:**

```bash
git add GPLX2026/Features/Hazard/HazardTestView.swift
git commit -m "refactor: align HazardTestView with LayoutMetrics for consistent iPad sizing"
```

---

### Task 17: Final build and iPad device test

**Step 1: Full build**

```bash
xcodebuild -project GPLX2026.xcodeproj -scheme GPLX2026 -destination 'generic/platform=iOS' build
```

Expected: BUILD SUCCEEDED

**Step 2: Install on iPad**

```bash
xcrun devicectl device install app --device 0F57637E-4EFA-516B-850D-063A6D0D6FFB <path_to_app>
```

**Step 3: Manual verification checklist**

- [ ] HomeTab: cards in 2 columns portrait, 3 landscape
- [ ] PracticeTab: wider content, proper padding
- [ ] ExamTab: wider exam cards, proper padding
- [ ] QuestionView: side-by-side layout (question left, answers right)
- [ ] ExamResultView: review cards in 2 columns
- [ ] HazardResultView: review rows in 2 columns, "Xem chi tiết" labels visible
- [ ] BookmarksView: bookmark cards in 2 columns
- [ ] WrongAnswersView: topic cards in 2 columns
- [ ] QuestionSearchView: search results in 2 columns
- [ ] SettingsView: wider cards (900pt max)
- [ ] Question grid sheet: 8 columns, 48pt cells
- [ ] All buttons: 56pt height on iPad
- [ ] Answer cards: larger text, larger letter indicators
- [ ] Rotate to landscape: column count increases to 3
- [ ] iPhone: completely unchanged

**Step 4: Commit final adjustments if needed**
