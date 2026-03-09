# Reorganize App Around the 3-Part National Exam

## Problem
The "Thực hành" tab combines Mô phỏng (Part 2) and Tình huống (Part 3) of the national exam under one tab with a segmented picker. Meanwhile, "Ôn tập" has study content scattered separately. This doesn't mirror the real exam structure, and "Mô phỏng" appears duplicated with Topic 6 in study topics.

## Solution
Reorganize tabs so each maps directly to a national exam part. Each tab has both study and exam modes. Utility features move to Home.

## Vietnamese B2 National Exam Structure

| Part | Name | Format | Pass Criteria |
|------|------|--------|---------------|
| 1 | Lý thuyết | 35 MCQ, 25 min | ≥32 correct + no điểm liệt wrong |
| 2 | Mô phỏng | 20 scenario images, 60s each | ≥70% (14/20) |
| 3 | Tình huống | 10 hazard videos, tap-based | ≥35/50 points |

## New Tab Structure (5 tabs)

### Tab 1: Trang chủ (Home) — `house`
- Overview card (progress, readiness)
- Continue learning card
- Recent results card
- Utility sections (moved from old "Ôn tập"):
  - Flashcard
  - Câu điểm liệt (critical questions)
  - Câu trả lời sai (wrong answers)
  - Đã đánh dấu (bookmarks)
  - Tra cứu (traffic signs, speed rules reference)

### Tab 2: Lý thuyết — `book` — Part 1
- **Study**: Topics 1-5 grid (485 questions), all questions in order, study by topic
- **Exam**: 35-question mock exam — free random + 20 fixed sets (Đề 1-20), history + stats

### Tab 3: Mô phỏng — `map` — Part 2
- **Study**: Topic 6 questions (115 scenario images), browse/practice, question number grid
- **Exam**: 20-question simulation exam (60s each, ≥70%), CTA + history + stats

### Tab 4: Tình huống — `play.circle` — Part 3
- **Study**: 120 video situations by chapter, download management, chapter-based practice
- **Exam**: 10-video hazard perception exam (≥35/50), CTA + history + stats

### Tab 5: Tìm kiếm — `magnifyingglass`
- Unchanged

## Files Affected
- `HomeView.swift` — update tab definitions
- `SimulationTab.swift` → refactor into `TinhHuongTab.swift` (hazard only)
- `MockExamTab.swift` → refactor into `LyThuyetTab.swift` (study + exam)
- New: `MoPhongTab.swift` — Topic 6 study + simulation exam
- `HomeTab.swift` — add utility sections from old StudyMenuView
- `StudyMenuView.swift` — remove (content split across new tabs)
- `TopicsView.swift` — filter Topics 1-5 for Lý thuyết, Topic 6 for Mô phỏng

## Unchanged
- All models, stores, exam logic, question data
- BaseExamView, SimulationExamView, HazardTestView
- ProgressStore, QuestionStore
- All history data
