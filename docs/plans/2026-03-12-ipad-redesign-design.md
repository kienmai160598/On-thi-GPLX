# iPad UI Renovation Design

**Date:** 2026-03-12 (v2 — comprehensive overhaul)
**Approach:** iPad-Native Redesign (Approach B)

## Goals

- iPad should feel native, not like a stretched iPhone
- Persistent sidebar navigation on iPad
- Multi-column dashboard layouts (2-col portrait, 3-col landscape)
- 3-panel exam layout with always-visible question grid
- Remove wasted space — no more 700pt max-width cap
- Three-tier responsive breakpoint system
- Refined typography and spacing for iPad screens

---

## 1. Navigation Architecture

### iPad (all orientations)
```
NavigationSplitView {
  Sidebar (Home, Practice, Exam, Settings)
} detail: {
  NavigationStack { selectedTab.content }
}
```

- Persistent sidebar with icons + labels
- Settings moves to sidebar on iPad (frees toolbar space)
- Sidebar is collapsible in portrait via swipe
- Search stays in toolbar on both platforms

### iPhone (unchanged)
```
TabView {
  Tab("Trang chu") { NavigationStack { HomeTab() } }
  Tab("Luyen tap") { NavigationStack { PracticeTab() } }
  Tab("Thi thu")   { NavigationStack { ExamTab() } }
}
```

### Exam screens
- `fullScreenCover` continues to work for both platforms
- Exam screens manage their own internal NavigationStack

---

## 2. LayoutMetrics Overhaul

### Three-tier breakpoint system

| Tier | Width | Use case | Columns |
|------|-------|----------|---------|
| `isCompact` | < 744pt | iPhone (all), iPad split-screen narrow | 1 |
| `isMedium` | 744 - 1023pt | iPad portrait | 2 |
| `isWide` | >= 1024pt | iPad landscape | 3 |

### Metrics per tier

| Property | compact | medium | wide |
|----------|---------|--------|------|
| `columns` | 1 | 2 | 3 |
| `contentPadding` | 20 | 24 | 32 |
| `cardPadding` | 12 | 16 | 20 |
| `gridSpacing` | 12 | 14 | 18 |
| `rowSpacing` | 8 | 12 | 14 |
| `buttonHeight` | 48 | 52 | 56 |
| `answerHeight` | 48 | 54 | 60 |
| `fontScale` | 1.0 | 1.08 | 1.15 |
| `gridColumns` | 6 | 7 | 9 |
| `gridCellSize` | 44 | 46 | 48 |

### Key changes
- **Remove `.iPadReadable()` entirely** — content fills natural width via adaptive grids
- `isWide` retains existing semantics (backward compat) for views not yet migrated
- New `isMedium` enables 2-column layouts for iPad portrait

---

## 3. Dashboard Layouts

### HomeTab

**iPad landscape (3-col):**
```
┌──────────────┐ ┌──────────────┐ ┌──────────────┐
│ Progress     │ │ Primary      │ │ Quick        │
│ Overview     │ │ Action       │ │ Actions      │
└──────────────┘ └──────────────┘ └──────────────┘
┌──────────────┐ ┌──────────────┐ ┌──────────────┐
│ Shortcuts    │ │ Recent       │ │ Achievements │
│              │ │ Results      │ │              │
└──────────────┘ └──────────────┘ └──────────────┘
```

**iPad portrait (2-col):**
```
┌───────────┐ ┌───────────────┐
│ Progress  │ │ Primary       │
│ Overview  │ │ Action        │
└───────────┘ └───────────────┘
┌───────────┐ ┌───────────────┐
│ Quick     │ │ Shortcuts     │
│ Actions   │ │               │
└───────────┘ └───────────────┘
┌─────────────────────────────┐
│ Recent Results (full width) │
└─────────────────────────────┘
┌─────────────────────────────┐
│ Achievements                │
└─────────────────────────────┘
```

### PracticeTab
- Topic list → 2-col (portrait) / 3-col (landscape) grid of topic cards
- Each card: icon ring + name + progress + correct/total
- "On tap tat ca" button spans full width above grid
- Hazard section: own column group below

### ExamTab
- Exam type cards: row on landscape, 2-col on portrait
- Fixed exam sets: 2-col portrait, 3-col landscape grid
- History: `AdaptiveGrid` multi-column result cards

---

## 4. 3-Panel Exam Layout (BaseExamView)

### iPad Landscape — 3 panels (40/35/25 split)
```
┌───────────────────┬──────────────────┬───────────────────┐
│                   │                  │  Question Grid    │
│  Question Card    │  Answer Tiles    │  [1][2][3][4][5]  │
│  Cau 15/30        │  A. Answer       │  [6][7][8][9][10] │
│                   │  B. Answer       │                   │
│  [Question text]  │  C. Answer       │  Progress:        │
│  [Image if any]   │  D. Answer       │  Da tra loi: 14   │
│                   │                  │  Chua: 16         │
│  -- Explain --    │                  │  [Nop bai]        │
├───────────────────┴──────────────────┴───────────────────┤
│  [Prev]                 dots                  [Next]     │
└──────────────────────────────────────────────────────────┘
```

- 3rd panel replaces `ExamQuestionGridSheet` popup on landscape
- Question grid is always visible — no sheet needed
- Grid shows answered/unanswered/current state with color coding
- Progress summary + submit button in the sidebar

### iPad Portrait — 2 panels (55/45 split)
```
┌────────────────────┬───────────────────┐
│  Question Card     │  Answer Tiles     │
│  + Image           │  A. B. C. D.      │
│  + Explanation     │                   │
├────────────────────┴───────────────────┤
│  [Prev]       dots        [Next]       │
└────────────────────────────────────────┘
```

Grid accessed via sheet (same as current).

### iPhone — unchanged vertical layout

---

## 5. Result Views

### iPad Landscape
```
┌──────────────────┐  ┌──────────────────────┐
│   Result Hero    │  │  Score Grid (2-col)  │
│   (large ring)   │  │  Dung 28  |  Sai 2  │
│   28/30 Dat      │  │  T.gian   |  Dat>=28 │
│                  │  │  [Review]  [Retry]   │
└──────────────────┘  └──────────────────────┘
┌────────────────────────────────────────────┐
│ Answer Review List (2-col adaptive grid)   │
└────────────────────────────────────────────┘
```

- No 700pt cap — content fills width
- Review list uses `AdaptiveGrid` (2-col)
- Hero and score grid side-by-side (existing `SplitContent`)

### QuestionView (Practice mode)
- Same 3-panel logic as BaseExamView on landscape
- 3rd panel shows topic progress sidebar instead of question grid

### Reference Views
- Remove `.iPadReadable()`, use `AdaptiveGrid` for sign cards
- 3-col landscape, 2-col portrait

### Settings
- NavigationSplitView on iPad (list left, detail right)
- iPhone: unchanged push navigation

---

## 6. Files to Modify

### Core changes (new/modified)
- `HomeView.swift` — conditional NavigationSplitView vs TabView
- `LayoutMetrics.swift` — 3-tier breakpoints, new properties
- `SplitContent.swift` — support 3-panel variant
- `AdaptiveGrid.swift` — minor tweaks for new metrics

### Remove `.iPadReadable()` from
- `HomeTab.swift`
- `PracticeTab.swift`
- `ExamTab.swift`
- `ExamResultView.swift`
- `SimulationResultView.swift`
- `HazardResultView.swift`
- `SpeedDistanceReferenceView.swift`
- `TrafficSignsReferenceView.swift`

### Exam 3-panel
- `BaseExamView.swift` — 3-panel layout for isWide
- `ExamQuestionGridSheet.swift` — conditionally inline vs sheet

### Dashboard multi-column
- `HomeTab.swift` — wrap cards in adaptive grid
- `PracticeTab.swift` — topic cards grid
- `ExamTab.swift` — exam type cards grid

### Navigation
- `HomeView.swift` — NavigationSplitView for iPad
- `SettingsView.swift` — move to sidebar on iPad

---

## 7. What Does NOT Change

- iPhone layouts: completely unchanged
- Exam flow via `fullScreenCover`
- HazardTestView video playback
- Onboarding flow (single column is fine)
- Theme colors and font families
- OrientationManager behavior
- All business logic and data models
