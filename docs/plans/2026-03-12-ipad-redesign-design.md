# iPad Redesign Design

**Date:** 2026-03-12
**Approach:** Adaptive Layout System (shared primitives)

## Goals

- Multi-column grid layouts on iPad (2 cols portrait, 3 cols landscape)
- Side-by-side question/answer layout for exam screens
- Dashboard-style grid for result screens
- Landscape-aware responsive breakpoints
- Senior-friendly: large touch targets, bigger text, more spacing

## Core Primitives (3 new files)

### LayoutMetrics

Observable environment object computed from `horizontalSizeClass` + screen width.

| Property | iPhone | iPad Portrait | iPad Landscape |
|----------|--------|---------------|----------------|
| `columns` | 1 | 2 | 3 |
| `isWide` | false | true | true |
| `gridSpacing` | 12 | 16 | 16 |
| `contentPadding` | 20 | 28 | 28 |
| `cardMinWidth` | — | 300 | 300 |
| `fontScale` | 1.0 | 1.15 | 1.15 |

Breakpoints by screen width:
- < 700pt → 1 column (iPhone)
- 700–1100pt → 2 columns (iPad portrait)
- > 1100pt → 3 columns (iPad landscape)

### AdaptiveGrid

Drop-in replacement for `LazyVStack` in card-heavy screens:
- iPhone: `LazyVStack(spacing:)`
- iPad: `LazyVGrid(columns: adaptive(minimum: cardMinWidth), spacing:)`
- Accepts optional `pinnedViews` for section headers

### SplitContent

Side-by-side layout for exam/question screens:
- iPhone: `VStack` (question top, answers below)
- iPad: `HStack` with leading (55%) and trailing (45%) panes
- Adjusts proportions for landscape

## Senior-Friendly Adjustments

### Touch Targets
- Minimum tap target: 56pt on iPad (vs 44pt standard)
- Answer option cards: 60pt height on iPad
- Bottom bar buttons: 56pt on iPad (vs 48pt iPhone)
- QuestionGrid cells: 48x48pt on iPad

### Typography (iPad)
- Body text: 16pt (vs 14pt iPhone)
- Question text: 18pt (vs 16pt iPhone)
- Button labels: 17pt (vs 15pt iPhone)
- All sizes via `fontScale` multiplier in LayoutMetrics

### Spacing (iPad)
- Card internal padding: 18pt (vs 12-14pt iPhone)
- List row spacing: 14pt (vs 8pt iPhone)
- Answer option spacing: 14pt between choices

### Visual Clarity
- Selected answer: 3pt border + stronger background tint
- Score dots: 10pt on iPad (vs 8pt)
- Icons/chevrons: +2pt larger on iPad
- Expandable rows get visible "Xem chi tiết" text label alongside chevron

### Simplified Interactions
- No long-press or swipe gesture reliance
- Visible text labels on all interactive elements

## Screen-by-Screen Plan

### Phase 1: Core Screens

| Screen | Change |
|--------|--------|
| **HomeTab** | `AdaptiveGrid` for topic cards. OverviewCard full-width. ContinueLearning + RecentResults side-by-side via `SplitContent`. |
| **PracticeTab** | `AdaptiveGrid` for topic rows (2-3 cols) |
| **ExamTab** | `AdaptiveGrid` for exam type cards. Fixed exams use more columns. |
| **SettingsView** | Wider cards with `iPadReadable(900)`, no grid needed |

### Phase 2: Exam & Results

| Screen | Change |
|--------|--------|
| **QuestionView** | `SplitContent`: question+image left, answers right. Bottom bar full width, 56pt buttons. |
| **ExamResultView** | Score hero full-width. Stats in 2-col grid. Question review in `AdaptiveGrid`. |
| **SimulationResultView** | Same treatment as ExamResultView |
| **HazardResultView** | Score hero + stats full-width. Situation reviews in `AdaptiveGrid` (2 cols). |

### Phase 3: Secondary Screens

| Screen | Change |
|--------|--------|
| **TopicDetailView** | `AdaptiveGrid` for question cards |
| **BookmarksView** | `AdaptiveGrid` for bookmark cards |
| **WrongAnswersView** | `AdaptiveGrid` for wrong-topic cards |
| **QuestionSearchView** | `AdaptiveGrid` for result cards |
| **SimulationTab** | `AdaptiveGrid` for simulation sets |
| **Reference views** | Wider tables, `iPadReadable(900)` |

### Unchanged

- iPhone layouts: completely unchanged
- Navigation: TabView + per-tab NavigationStack stays
- `.tabViewStyle(.sidebarAdaptable)` already handles iPad sidebar
- HazardTestView: existing split layout aligned with shared metrics
- Onboarding: single column is fine for a flow

## Migration Notes

- Replace `.iPadReadable()` with `LayoutMetrics`-driven padding on grid screens
- Keep `.iPadReadable()` on single-column screens (Settings, References)
- `ExamBottomBar`: wider buttons, larger touch targets on iPad
- `QuestionGridButton` sheet: 6 columns per row on iPad (vs 5)
