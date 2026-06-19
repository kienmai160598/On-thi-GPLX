# iPad UI Renovation Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Make the iPad experience feel native — persistent sidebar, multi-column dashboards, 3-panel exam, no wasted space.

**Architecture:** Three-tier responsive breakpoint system (compact/medium/wide) in LayoutMetrics drives all layout decisions. NavigationSplitView replaces TabView on iPad. `.iPadReadable()` removed everywhere — content fills naturally via adaptive grids.

**Tech Stack:** SwiftUI, iOS 18+, @Observable, NavigationSplitView, LazyVGrid

**Design doc:** `docs/plans/2026-03-12-ipad-redesign-design.md`

---

### Task 1: LayoutMetrics 3-Tier Breakpoints

**Files:**
- Modify: `GPLX2026/Core/Common/Layout/LayoutMetrics.swift`

This is the foundation — all other tasks depend on it.

**Step 1: Update LayoutMetrics with 3-tier system**

Replace the entire file content:

```swift
import SwiftUI

@Observable
@MainActor
final class LayoutMetrics {
    var horizontalSizeClass: UserInterfaceSizeClass? = .compact
    var windowWidth: CGFloat = 0

    // MARK: - Breakpoints

    /// iPhone, narrow iPad split-screen
    var isCompact: Bool { windowWidth < 744 }

    /// iPad portrait (2 columns)
    var isMedium: Bool { windowWidth >= 744 && windowWidth < 1024 }

    /// iPad landscape (3 columns)
    var isWide: Bool { horizontalSizeClass == .regular && windowWidth >= 1024 }

    /// True for any iPad-class layout (medium or wide)
    var isIPadLayout: Bool { isMedium || isWide }

    // MARK: - Columns

    var columns: Int {
        if isWide { return 3 }
        if isMedium { return 2 }
        return 1
    }

    // MARK: - Spacing

    var gridSpacing: CGFloat {
        if isWide { return 18 }
        if isMedium { return 14 }
        return 12
    }

    var contentPadding: CGFloat {
        if isWide { return 32 }
        if isMedium { return 24 }
        return 20
    }

    var cardPadding: CGFloat {
        if isWide { return 20 }
        if isMedium { return 16 }
        return 12
    }

    var rowSpacing: CGFloat {
        if isWide { return 14 }
        if isMedium { return 12 }
        return 8
    }

    // MARK: - Component Sizes

    var fontScale: CGFloat {
        if isWide { return 1.15 }
        if isMedium { return 1.08 }
        return 1.0
    }

    var buttonHeight: CGFloat {
        if isWide { return 56 }
        if isMedium { return 52 }
        return 48
    }

    var answerHeight: CGFloat {
        if isWide { return 60 }
        if isMedium { return 54 }
        return 48
    }

    var gridCellSize: CGFloat {
        if isWide { return 48 }
        if isMedium { return 46 }
        return 44
    }

    var gridColumns: Int {
        if isWide { return 9 }
        if isMedium { return 7 }
        return 6
    }

    var cardMinWidth: CGFloat { 300 }
}

struct LayoutMetricsReader: ViewModifier {
    @Environment(LayoutMetrics.self) private var metrics
    @Environment(\.horizontalSizeClass) private var sizeClass

    func body(content: Content) -> some View {
        GeometryReader { geo in
            content
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .onChange(of: sizeClass, initial: true) { _, newValue in
                    metrics.horizontalSizeClass = newValue
                }
                .onChange(of: geo.size.width, initial: true) { _, newWidth in
                    metrics.windowWidth = newWidth
                }
        }
    }
}

extension View {
    func trackLayoutMetrics() -> some View {
        modifier(LayoutMetricsReader())
    }
}
```

**Step 2: Build to verify compilation**

```bash
xcodebuild -project GPLX2026.xcodeproj -scheme GPLX2026 -destination 'id=00008120-0016116A1103C01E' build 2>&1 | tail -5
```

Expected: BUILD SUCCEEDED. Existing `isWide` references still work. `isMedium` and `isCompact` are additive.

**Step 3: Commit**

```bash
git add GPLX2026/Core/Common/Layout/LayoutMetrics.swift
git commit -m "feat: 3-tier LayoutMetrics (compact/medium/wide breakpoints)"
```

---

### Task 2: NavigationSplitView for iPad

**Files:**
- Modify: `GPLX2026/Features/Home/HomeView.swift`

**Step 1: Add iPad sidebar navigation**

Replace HomeView with device-adaptive navigation:

```swift
import SwiftUI

enum SidebarTab: String, CaseIterable, Identifiable {
    case home = "Trang chủ"
    case practice = "Luyện tập"
    case exam = "Thi thử"
    case settings = "Cài đặt"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .home: "house"
        case .practice: "book"
        case .exam: "list.clipboard.fill"
        case .settings: "gearshape"
        }
    }
}

struct HomeView: View {
    @Environment(ThemeStore.self) private var themeStore
    @Environment(LayoutMetrics.self) private var metrics
    @State private var activeExam: ExamScreen?
    @State private var pendingExam: ExamScreen?
    @State private var selectedTab: SidebarTab = .home

    private var accentColor: Color {
        themeStore.primaryColor
    }

    var body: some View {
        Group {
            if metrics.isIPadLayout {
                iPadNavigation
            } else {
                iPhoneNavigation
            }
        }
        .tint(accentColor)
        .environment(\.openExam) { screen in activeExam = screen }
        .fullScreenCover(item: $activeExam, onDismiss: {
            if let next = pendingExam {
                pendingExam = nil
                DispatchQueue.main.async {
                    activeExam = next
                }
            }
        }) { exam in
            NavigationStack {
                exam.destination
            }
            .environment(\.popToRoot) { activeExam = nil }
            .environment(\.openExam) { newScreen in
                pendingExam = newScreen
                activeExam = nil
            }
            .tint(accentColor)
        }
    }

    // MARK: - iPad: NavigationSplitView

    private var iPadNavigation: some View {
        NavigationSplitView {
            List(SidebarTab.allCases, selection: $selectedTab) { tab in
                Label(tab.rawValue, systemImage: tab.icon)
                    .tag(tab)
            }
            .navigationTitle("GPLX 2026")
        } detail: {
            NavigationStack {
                selectedTabContent
            }
            .tint(accentColor)
        }
    }

    // MARK: - iPhone: TabView (unchanged)

    private var iPhoneNavigation: some View {
        TabView {
            Tab("Trang chủ", systemImage: "house") {
                NavigationStack {
                    HomeTab()
                }
                .tint(accentColor)
            }

            Tab("Luyện tập", systemImage: "book") {
                NavigationStack {
                    PracticeTab()
                }
                .tint(accentColor)
            }

            Tab("Thi thử", systemImage: "list.clipboard.fill") {
                NavigationStack {
                    ExamTab()
                }
                .tint(accentColor)
            }
        }
        .tabViewStyle(.sidebarAdaptable)
    }

    // MARK: - Tab Content

    @ViewBuilder
    private var selectedTabContent: some View {
        switch selectedTab {
        case .home: HomeTab()
        case .practice: PracticeTab()
        case .exam: ExamTab()
        case .settings: SettingsView()
        }
    }
}
```

**Step 2: Build and verify**

```bash
xcodebuild -project GPLX2026.xcodeproj -scheme GPLX2026 -destination 'id=00008120-0016116A1103C01E' build 2>&1 | tail -5
```

Expected: BUILD SUCCEEDED.

**Step 3: Visual test**

Run on iPad simulator to verify:
- Landscape: sidebar visible with 4 items, detail area shows selected tab
- Portrait: sidebar collapsible, tab content fills screen
- iPhone: TabView with 3 tabs (no settings tab, unchanged)

**Step 4: Commit**

```bash
git add GPLX2026/Features/Home/HomeView.swift
git commit -m "feat: NavigationSplitView sidebar for iPad, TabView for iPhone"
```

---

### Task 3: HomeTab Multi-Column Dashboard

**Files:**
- Modify: `GPLX2026/Features/Home/HomeTab.swift`

**Step 1: Replace iPadReadable with adaptive grid layout**

In `HomeTab.body`, replace the VStack + `.iPadReadable()` with an adaptive grid:

Find (around line 22-33):
```swift
ScrollView {
    VStack(spacing: 20) {
        ProgressOverview()
        PrimaryActionCard()
        QuickActionsGrid()
        ShortcutsRow()
        RecentResultsCard()
        AchievementsCard()
    }
    .padding(.horizontal, metrics.contentPadding)
    .iPadReadable()
    .padding(.bottom, 32)
}
```

Replace with:
```swift
ScrollView {
    if metrics.isCompact {
        // iPhone: single column VStack (unchanged)
        VStack(spacing: 20) {
            ProgressOverview()
            PrimaryActionCard()
            QuickActionsGrid()
            ShortcutsRow()
            RecentResultsCard()
            AchievementsCard()
        }
        .padding(.horizontal, metrics.contentPadding)
        .padding(.bottom, 32)
    } else {
        // iPad: multi-column adaptive grid
        LazyVGrid(
            columns: Array(
                repeating: GridItem(.flexible(), spacing: metrics.gridSpacing),
                count: metrics.columns
            ),
            spacing: metrics.gridSpacing
        ) {
            ProgressOverview()
            PrimaryActionCard()
            QuickActionsGrid()
            ShortcutsRow()
            RecentResultsCard()
            AchievementsCard()
        }
        .padding(.horizontal, metrics.contentPadding)
        .padding(.bottom, 32)
    }
}
```

**Note:** Some cards may need equal-height alignment. If cards look uneven in the grid, wrap each in a container with `.frame(maxHeight: .infinity, alignment: .top)`.

**Step 2: Remove settings toolbar on iPad**

In the `.toolbar` section, conditionally hide the settings gear on iPad since it's now in the sidebar:

```swift
.toolbar {
    ToolbarItem(placement: .navigationBarTrailing) {
        HStack(spacing: 16) {
            NavigationLink(destination: QuestionSearchView()) {
                Image(systemName: "magnifyingglass")
                    .font(.appSans(size: 15, weight: .medium))
                    .foregroundStyle(Color.appTextDark)
            }
            if metrics.isCompact {
                NavigationLink(destination: SettingsView()) {
                    Image(systemName: "gearshape")
                        .font(.appSans(size: 15, weight: .medium))
                        .foregroundStyle(Color.appTextDark)
                }
            }
        }
    }
}
```

**Step 3: Build and verify**

```bash
xcodebuild -project GPLX2026.xcodeproj -scheme GPLX2026 -destination 'id=00008120-0016116A1103C01E' build 2>&1 | tail -5
```

**Step 4: Visual test on iPad**

- Landscape: 3-column grid of dashboard cards
- Portrait: 2-column grid
- iPhone: unchanged single-column VStack
- Settings gear hidden on iPad (available in sidebar)

**Step 5: Commit**

```bash
git add GPLX2026/Features/Home/HomeTab.swift
git commit -m "feat: HomeTab multi-column dashboard grid for iPad"
```

---

### Task 4: PracticeTab Multi-Column Topic Grid

**Files:**
- Modify: `GPLX2026/Features/Home/PracticeTab.swift`

**Step 1: Remove iPadReadable and add adaptive grid for topics**

In `PracticeTab.body`, remove `.iPadReadable()` from the outer VStack.

Then in `questionSection`, wrap the topic list in `AdaptiveGrid`:

Find the ForEach loop inside the inner `VStack(spacing: 0)` that iterates over `topicStats` and convert it to use `AdaptiveGrid`. Each topic row needs to become a self-contained card (with its own `.glassCard()` background) so it works in a grid cell.

```swift
// Replace VStack(spacing: 0) { ForEach... } with:
AdaptiveGrid {
    ForEach(Array(topicStats.enumerated()), id: \.element.topic.id) { index, item in
        // ... existing topic row content, wrapped in .glassCard()
    }
}
```

**Step 2: Same treatment for hazardSection**

Wrap hazard chapter rows in `AdaptiveGrid` as well.

**Step 3: Build and verify**

```bash
xcodebuild -project GPLX2026.xcodeproj -scheme GPLX2026 -destination 'id=00008120-0016116A1103C01E' build 2>&1 | tail -5
```

**Step 4: Visual test**

- iPad landscape: 3-col topic cards + 3-col hazard chapters
- iPad portrait: 2-col topics + 2-col hazard chapters
- iPhone: unchanged single-column list

**Step 5: Commit**

```bash
git add GPLX2026/Features/Home/PracticeTab.swift
git commit -m "feat: PracticeTab multi-column topic grid for iPad"
```

---

### Task 5: ExamTab Multi-Column Layout

**Files:**
- Modify: `GPLX2026/Features/Home/ExamTab.swift`

**Step 1: Remove iPadReadable**

In `ExamTab.body`, remove `.iPadReadable()` (line ~47).

**Step 2: Wrap exam type cards in adaptive layout**

The three sections (`questionExamContent`, `simulationExamContent`, `hazardExamContent`) each contain an `ExamTypeCard` + history sections. When `filter == .all` and iPad, arrange ExamTypeCards in a row:

```swift
if filter == .all && metrics.isIPadLayout {
    LazyVGrid(
        columns: Array(repeating: GridItem(.flexible(), spacing: metrics.gridSpacing), count: min(3, metrics.columns)),
        spacing: metrics.gridSpacing
    ) {
        questionExamCard
        simulationExamCard
        hazardExamCard
    }
    // History sections below in full width
    questionHistorySection
    simulationHistorySection
    hazardHistorySection
} else {
    if filter == .all || filter == .questions { questionExamContent }
    if filter == .all || filter == .simulation { simulationExamContent }
    if filter == .all || filter == .hazard { hazardExamContent }
}
```

This may require splitting each content section into a card part and a history part.

**Step 3: Fixed exam sets in grid**

Wrap fixed exam set lists in `AdaptiveGrid` so they flow into 2-3 columns on iPad.

**Step 4: Build and verify**

```bash
xcodebuild -project GPLX2026.xcodeproj -scheme GPLX2026 -destination 'id=00008120-0016116A1103C01E' build 2>&1 | tail -5
```

**Step 5: Visual test**

- iPad landscape: exam type cards in a row, fixed sets in 3-col grid
- iPad portrait: 2-col layout
- iPhone: unchanged

**Step 6: Commit**

```bash
git add GPLX2026/Features/Home/ExamTab.swift
git commit -m "feat: ExamTab multi-column cards and fixed exam grid for iPad"
```

---

### Task 6: BaseExamView 3-Panel Layout

**Files:**
- Modify: `GPLX2026/Features/Exam/BaseExamView.swift`
- Reference: `GPLX2026/Core/Common/Exam/ExamQuestionGridSheet.swift`

This is the most complex task. The current `examContent` has two branches: `metrics.isWide` (2-panel HStack) and else (VStack). We add a 3rd panel for the question grid on landscape.

**Step 1: Create inline question grid sidebar view**

Add a private computed property `examGridSidebar` within BaseExamView:

```swift
// MARK: - Exam Grid Sidebar (iPad Landscape)

private var examGridSidebar: some View {
    VStack(spacing: 16) {
        // Legend
        HStack(spacing: 12) {
            legendDot(color: themeStore.primaryColor, label: "Hiện tại")
            legendDot(color: .appSuccess, label: "Đã trả lời")
            legendDot(color: Color.appTextLight.opacity(0.3), label: "Chưa")
        }
        .font(.appSans(size: 11))

        // Grid
        let cols = Array(repeating: GridItem(.flexible(), spacing: 6), count: 5)
        LazyVGrid(columns: cols, spacing: 6) {
            ForEach(0..<questions.count, id: \.self) { index in
                Button {
                    if !isMockExam { saveCurrentTimerState() }
                    currentIndex = index
                    if !isMockExam { restoreStateForCurrentIndex() }
                } label: {
                    Text("\(index + 1)")
                        .font(.appMono(size: 12, weight: .medium))
                        .frame(width: metrics.gridCellSize, height: metrics.gridCellSize)
                        .background(gridCellColor(for: index))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .foregroundStyle(index == currentIndex ? .white : Color.appTextDark)
                }
            }
        }

        Spacer()

        // Progress summary
        VStack(alignment: .leading, spacing: 8) {
            Text("Đã trả lời: \(answers.count)/\(questions.count)")
                .font(.appSans(size: 13))
                .foregroundStyle(Color.appTextMedium)

            if isMockExam {
                Button {
                    showSubmitDialog = true
                } label: {
                    AppButton(icon: "arrow.up.doc", label: "Nộp bài", height: 44)
                }
            }
        }
    }
    .padding(metrics.cardPadding)
}

private func gridCellColor(for index: Int) -> Color {
    if index == currentIndex { return themeStore.primaryColor }
    if answers[index] != nil { return .appSuccess.opacity(0.2) }
    return Color.appTextLight.opacity(0.1)
}

private func legendDot(color: Color, label: String) -> some View {
    HStack(spacing: 4) {
        Circle().fill(color).frame(width: 8, height: 8)
        Text(label).foregroundStyle(Color.appTextMedium)
    }
}
```

Note: Add `@Environment(ThemeStore.self) private var themeStore` to BaseExamView if not already present.

**Step 2: Update examContent for 3-panel on isWide**

Replace the current `if metrics.isWide { ... }` block (lines ~100-150) with a 3-tier version:

```swift
if metrics.isWide {
    // iPad Landscape: 3-panel (40% question / 35% answers / 25% grid)
    GeometryReader { geo in
        let pad = metrics.contentPadding
        let gap = metrics.gridSpacing
        let available = geo.size.width - pad * 2 - gap * 2
        let leftWidth = available * 0.40
        let centerWidth = available * 0.35
        let rightWidth = available * 0.25

        HStack(alignment: .top, spacing: gap) {
            // Left: question + explanation
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    QuestionCard(label: "Câu \(currentIndex + 1)", question: question, showDiemLietBadge: true)
                    if !isMockExam && isRevealed && !question.tip.isEmpty {
                        ExplanationBox(content: question.tip)
                            .padding(.top, 12)
                            .transition(.opacity.combined(with: .move(edge: .top)))
                    }
                }
                .padding(.vertical, pad)
            }
            .frame(width: leftWidth)

            // Center: answers
            ScrollView {
                if isMockExam {
                    AnswerTileList(
                        answers: shuffledAnswers,
                        selectedAnswerId: answers[currentIndex],
                        onSelect: { answer in
                            Haptics.selection()
                            answers[currentIndex] = answer.id
                        }
                    )
                } else {
                    AnswerTileList(
                        answers: shuffledAnswers,
                        selectedAnswerId: selectedAnswerId,
                        isConfirmed: isRevealed,
                        showCorrectness: true,
                        onSelect: { handleSimulationAnswerSelection(answer: $0) }
                    )
                }
            }
            .padding(.vertical, pad)
            .frame(width: centerWidth)

            // Right: question grid sidebar
            examGridSidebar
                .frame(width: rightWidth)
                .padding(.vertical, pad)
        }
        .padding(.horizontal, pad)
    }
    .id(currentIndex)
} else if metrics.isMedium {
    // iPad Portrait: 2-panel (55/45)
    GeometryReader { geo in
        let pad = metrics.contentPadding
        let gap = metrics.gridSpacing
        let available = geo.size.width - pad * 2 - gap
        let leftWidth = available * 0.55
        let rightWidth = available * 0.45

        HStack(alignment: .top, spacing: gap) {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    QuestionCard(label: "Câu \(currentIndex + 1)", question: question, showDiemLietBadge: true)
                    if !isMockExam && isRevealed && !question.tip.isEmpty {
                        ExplanationBox(content: question.tip)
                            .padding(.top, 12)
                            .transition(.opacity.combined(with: .move(edge: .top)))
                    }
                }
                .padding(.vertical, pad)
            }
            .frame(width: leftWidth)

            ScrollView {
                if isMockExam {
                    AnswerTileList(
                        answers: shuffledAnswers,
                        selectedAnswerId: answers[currentIndex],
                        onSelect: { answer in
                            Haptics.selection()
                            answers[currentIndex] = answer.id
                        }
                    )
                } else {
                    AnswerTileList(
                        answers: shuffledAnswers,
                        selectedAnswerId: selectedAnswerId,
                        isConfirmed: isRevealed,
                        showCorrectness: true,
                        onSelect: { handleSimulationAnswerSelection(answer: $0) }
                    )
                }
            }
            .padding(.vertical, pad)
            .frame(width: rightWidth)
        }
        .padding(.horizontal, pad)
    }
    .id(currentIndex)
} else {
    // iPhone: vertical layout (unchanged — keep existing code)
    ...
}
```

**Step 3: Build and verify**

```bash
xcodebuild -project GPLX2026.xcodeproj -scheme GPLX2026 -destination 'id=00008120-0016116A1103C01E' build 2>&1 | tail -5
```

**Step 4: Visual test on iPad**

- Landscape: 3 panels — question left, answers center, grid sidebar right
- Portrait: 2 panels — question left, answers right (grid via sheet)
- iPhone: vertical layout unchanged
- Grid sidebar: cells colored by state, tappable, progress count at bottom

**Step 5: Commit**

```bash
git add GPLX2026/Features/Exam/BaseExamView.swift
git commit -m "feat: 3-panel exam layout with always-visible grid sidebar on iPad landscape"
```

---

### Task 7: QuestionView (Practice) iPad Layout

**Files:**
- Modify: `GPLX2026/Features/Learn/QuestionView.swift`

Apply the same 3-tier layout pattern as BaseExamView:
- `isWide`: 3-panel with topic progress sidebar (instead of question grid)
- `isMedium`: 2-panel question/answers
- compact: unchanged vertical

**Step 1: Add topic progress sidebar**

Create a private view showing:
- Current topic name and icon
- Progress ring (correct/total for this topic)
- Question navigation grid (current position in topic)

**Step 2: Apply 3-tier layout to question content**

Mirror the BaseExamView pattern — 40/35/25 split on wide, 55/45 on medium, vertical on compact.

**Step 3: Build and verify**

```bash
xcodebuild -project GPLX2026.xcodeproj -scheme GPLX2026 -destination 'id=00008120-0016116A1103C01E' build 2>&1 | tail -5
```

**Step 4: Commit**

```bash
git add GPLX2026/Features/Learn/QuestionView.swift
git commit -m "feat: QuestionView 3-panel layout with topic sidebar for iPad"
```

---

### Task 8: Result Views — Remove iPadReadable, Widen Layout

**Files:**
- Modify: `GPLX2026/Features/Exam/ExamResultView.swift` (iPadReadable at line ~99)
- Modify: `GPLX2026/Features/Simulation/SimulationResultView.swift` (iPadReadable at line ~100)
- Modify: `GPLX2026/Features/Hazard/HazardResultView.swift` (iPadReadable at line ~87)

All three follow the same pattern. For each:

**Step 1: Remove `.iPadReadable()`**

Delete the `.iPadReadable()` modifier call from each file.

**Step 2: Update conditional layout to use 3-tier**

Replace `metrics.isWide` checks with `metrics.isIPadLayout` where the side-by-side hero+scores layout should apply (both portrait and landscape):

```swift
// Was: if metrics.isWide {
if metrics.isIPadLayout {
    HStack(alignment: .top, spacing: metrics.gridSpacing) {
        // Hero left, scores right
    }
} else {
    VStack { ... }
}
```

The review list `AdaptiveGrid` already works with the new `metrics.columns` value — no changes needed there.

**Step 3: Build and verify**

```bash
xcodebuild -project GPLX2026.xcodeproj -scheme GPLX2026 -destination 'id=00008120-0016116A1103C01E' build 2>&1 | tail -5
```

**Step 4: Visual test**

- iPad landscape: hero+scores side-by-side, review list 3-col grid
- iPad portrait: hero+scores side-by-side, review list 2-col grid
- iPhone: unchanged vertical

**Step 5: Commit**

```bash
git add GPLX2026/Features/Exam/ExamResultView.swift GPLX2026/Features/Simulation/SimulationResultView.swift GPLX2026/Features/Hazard/HazardResultView.swift
git commit -m "feat: result views use full iPad width, side-by-side in portrait too"
```

---

### Task 9: Reference Views — Adaptive Grids

**Files:**
- Modify: `GPLX2026/Features/Reference/TrafficSignsReferenceView.swift` (iPadReadable at line ~37)
- Modify: `GPLX2026/Features/Reference/SpeedDistanceReferenceView.swift`

**Step 1: TrafficSignsReferenceView**

Remove `.iPadReadable()`. Wrap the sign cards within each category in `AdaptiveGrid`:

```swift
AdaptiveGrid {
    ForEach(filteredSigns) { sign in
        // ... sign card
    }
}
```

**Step 2: SpeedDistanceReferenceView**

Remove `.iPadReadable()` if present. Speed limit tables can use the full width naturally — wider tables are easier to read.

**Step 3: Build and verify**

```bash
xcodebuild -project GPLX2026.xcodeproj -scheme GPLX2026 -destination 'id=00008120-0016116A1103C01E' build 2>&1 | tail -5
```

**Step 4: Commit**

```bash
git add GPLX2026/Features/Reference/TrafficSignsReferenceView.swift GPLX2026/Features/Reference/SpeedDistanceReferenceView.swift
git commit -m "feat: reference views use adaptive grids, remove iPadReadable cap"
```

---

### Task 10: Remove .iPadReadable() Helper

**Files:**
- Modify: `GPLX2026/Core/Theme/AppTheme.swift`

**Step 1: Verify no remaining callers**

```bash
grep -r "iPadReadable" GPLX2026/ --include="*.swift"
```

If any remain, remove them first.

**Step 2: Remove the extension**

In `AppTheme.swift`, delete the `iPadReadable` extension (lines ~161-164):

```swift
// DELETE these lines:
/// Constrain content to readable width on iPad (centered)
func iPadReadable(maxWidth: CGFloat = 700) -> some View {
    frame(maxWidth: maxWidth)
        .frame(maxWidth: .infinity)
}
```

**Step 3: Build and verify**

```bash
xcodebuild -project GPLX2026.xcodeproj -scheme GPLX2026 -destination 'id=00008120-0016116A1103C01E' build 2>&1 | tail -5
```

Expected: BUILD SUCCEEDED with zero references to `iPadReadable`.

**Step 4: Commit**

```bash
git add GPLX2026/Core/Theme/AppTheme.swift
git commit -m "chore: remove unused .iPadReadable() helper"
```

---

## Task Dependency Order

```
Task 1 (LayoutMetrics) ──→ Task 2 (Navigation)
                        ──→ Task 3 (HomeTab)
                        ──→ Task 4 (PracticeTab)
                        ──→ Task 5 (ExamTab)
                        ──→ Task 6 (BaseExamView) ──→ Task 7 (QuestionView)
                        ──→ Task 8 (Result Views)
                        ──→ Task 9 (Reference Views)
                                                   ──→ Task 10 (Cleanup)
```

Tasks 2-9 can be done in any order after Task 1, but Task 10 must be last.
Tasks 3, 4, 5 are independent and can be parallelized.
Tasks 8, 9 are independent and can be parallelized.
Task 7 depends on Task 6 (same pattern, easier to do second).
