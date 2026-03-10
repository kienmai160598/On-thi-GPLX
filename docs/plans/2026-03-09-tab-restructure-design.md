# 3-Tab Restructure Design

## Goal

Consolidate 4 tabs (Trang chủ, Lý thuyết, Sa hình, Tình huống) into 3 tabs (Trang chủ, Luyện tập, Thi thử) so that "Luyện tập" covers all study content and "Thi thử" covers all exam types.

## Tab Bar

| Tab | Icon | Content |
|-----|------|---------|
| Trang chủ | `house` | Dashboard (unchanged) |
| Luyện tập | `book` | Sub-tabs: Câu hỏi · Sa hình · Tình huống |
| Thi thử | `pencil.and.list.clipboard` | Sub-tabs: Câu hỏi · Sa hình · Tình huống |

## Luyện tập (Practice)

Segmented picker at top with 3 segments. Content per segment:

- **Câu hỏi**: Topics 1-5 study cards with progress, "Tất cả câu hỏi" button
- **Sa hình**: Topic 6 card with progress, "Luyện tất cả sa hình" button
- **Tình huống**: "Luyện tập tất cả (120 TH)" button, chapter list, video download management card

Source: study sections extracted from TheoryTab, SimulationTab, HazardTab.

## Thi thử (Mock Exam)

Same segmented picker, exam-focused content per segment:

- **Câu hỏi**: Mock exam CTA (30 câu, 22 phút), exam stats, 20 fixed exam sets grid, exam history
- **Sa hình**: Simulation exam CTA (20 câu, 60s/câu), stats, history
- **Tình huống**: Hazard exam CTA (10 video), stats, history

Source: exam sections extracted from TheoryTab, SimulationTab, HazardTab.

## Trang chủ (Home)

No changes. SmartNudge, ContinueLearning, ProgressHero, ExamCountdown, UtilityGrid, TopicProgress, RecentResults, StudyHeatMap, ReferenceSection all remain. They route via `openExam()` which is unaffected.

## File Changes

- **`HomeView.swift`** — 4 tabs → 3 tabs
- **New `PracticeTab.swift`** — Segmented control + 3 sub-views for study content
- **New `ExamTab.swift`** — Segmented control + 3 sub-views for exam content
- **`TheoryTab.swift`** — Remove (content split into PracticeTab/ExamTab sub-views)
- **`SimulationTab.swift`** — Remove (content moved)
- **`HazardTab.swift`** — Remove (content moved)

## Routing

No changes to `ExamScreen` enum or `openExam`/`popToRoot` environment. All existing navigation paths remain valid.
