# UX Focus Redesign: Mirror 3-Part National Exam

## Problem
Users report 3 pain points:
1. **No guided path** — "I don't know what to study next"
2. **Features hard to find** — too many taps, unexpected locations
3. **Duplication** — Mô phỏng appears in both Ôn tập (Topic 6) and Thực hành tab

## Solution
Restructure from 5 tabs to 4 tabs that mirror the national exam. Add a smart nudge card on Home. Each exam tab combines study + exam for its part.

## Vietnamese B2 National Exam Structure

| Part | Name | Format | Pass Criteria |
|------|------|--------|---------------|
| 1 | Lý thuyết | 35 MCQ, 25 min | ≥32 correct + no điểm liệt wrong |
| 2 | Mô phỏng | 20 scenario images, 60s each | ≥70% (14/20) |
| 3 | Tình huống | 10 hazard videos, tap-based | ≥35/50 points |

## New Tab Structure (4 tabs)

Old: `Home` | `Ôn tập` | `Thi thử` | `Thực hành` | `Tìm kiếm`
New: `Home` | `Lý thuyết` | `Mô phỏng` | `Tình huống`

### Tab 1: Trang chủ (HomeTab.swift) — `house`

1. **ProgressHeroCard** — unchanged (readiness %, streak, key stats)
2. **"Tiếp theo" Smart Nudge Card** — NEW, single recommended next action
3. **QuickActionsGrid** — 4 items: Flashcard, Câu điểm liệt, Câu sai, Đã đánh dấu
4. **TopicProgressSection** — unchanged (5 topic progress rings)
5. **RecentResultsCard** — unchanged (latest results from all 3 parts)
6. **Tra cứu section** — Biển báo giao thông, Tốc độ & Quy tắc

Toolbar: Settings (left), Search button (right) → pushes QuestionSearchView

### Tab 2: Lý thuyết (TheoryTab.swift) — `book` — Part 1

**Study section:**
- Section header: "Ôn tập"
- Topic grid: 5 topic cards (Topics 1-5) with progress rings → TopicDetailView
- "Tất cả câu hỏi" row — sequential practice through all 485 questions

**Exam section:**
- Section header: "Thi thử"
- ExamCTACard — "Thi ngẫu nhiên (35 câu / 25 phút)"
- ExamStatsRow — exam count, average %, best score
- Fixed exam sets — Đề 1-20 in 2-column grid
- History list — recent exam attempts

### Tab 3: Mô phỏng (SimulationTab.swift) — `map` — Part 2

**Study section:**
- Section header: "Ôn tập"
- Topic 6 question grid — 115 scenario images, numbered grid (green/red/gray)
- "Tất cả sa hình" row — sequential practice

**Exam section:**
- Section header: "Thi thử"
- SimulationCTACard — "Thi mô phỏng (20 câu / 60s mỗi câu)", ≥70% pass
- SimulationStatsRow — exam count, average %, best score
- History list — recent simulation attempts

### Tab 4: Tình huống (HazardTab.swift) — `play.circle` — Part 3

**Study section:**
- Section header: "Ôn tập"
- Chapter buttons — 6 chapters with name, count, icon → chapter practice
- Download management — progress bar, per-chapter download, clear cache

**Exam section:**
- Section header: "Thi thử"
- HazardCTACard — "Thi tình huống (10 video / ≥35 điểm)"
- HazardStatsRow — exam count, average points, best score
- History list — recent hazard attempts

## Smart Nudge Priority Chain

Pure function on `ProgressStore`, returns label + destination:

```
1. Điểm liệt not mastered       → CriticalQuestionsView
2. Any topic < 50%               → TopicDetailView (weakest)
3. No mock exam in 3+ days       → random mock exam
4. Any topic 50-70%              → TopicDetailView (weakest)
5. Lý thuyết ≥70%, Mô phỏng <50%  → Mô phỏng tab
6. Mô phỏng ≥70%, Tình huống <50%  → Tình huống tab
7. All parts ≥70%                → "Thi thử" for weakest part
8. All parts ≥90%                → "Sẵn sàng thi! Hãy thi thử lần nữa"
```

## File Changes

**Deleted:**
- `StudyMenuView.swift` — content split across Home + 3 exam tabs

**Renamed:**
- `MockExamTab.swift` → `TheoryTab.swift`

**Repurposed:**
- `SimulationTab.swift` — was combined Mô phỏng + Tình huống, becomes Part 2 only

**New:**
- `HazardTab.swift` — Part 3 (hazard content extracted from old SimulationTab)

**Modified:**
- `HomeView.swift` — 4 tabs instead of 5, update tab definitions
- `HomeTab.swift` — add smart nudge card, utility grid, search toolbar, tra cứu section
- `TopicsView.swift` — filter Topics 1-5 for Lý thuyết, Topic 6 for Mô phỏng

**Unchanged:**
- All models, stores, exam engines, question data
- BaseExamView, QuestionView, FlashcardView, HazardTestView
- All result/history detail views
- ProgressStore (just adding one computed function for smart nudge)
