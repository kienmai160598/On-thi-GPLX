# Priority 3: Business-Critical Features Design

**Date:** 2026-03-10
**Status:** Approved
**Scope:** F1 (License type selection), F2 (Correct exam rules), F4 (App Store review prompt)
**F3 (Donation):** Kept as-is — no changes.

---

## F1. License Type Selection (B1/B2)

### Storage
- `@AppStorage("licenseType")` — values: `"b1"`, `"b2"` — default `"b2"`
- Added to `AppConstants.StorageKey`

### Question Data
- JSON `b1` field = position index (1-300) within B1 exam bank; `b1=0` means not in B1 pool
- B2 pool: all 600 questions
- B1 pool: 300 questions where `b1 > 0`, sorted by `b1` value
- 60 diem liet total (B2), 46 in B1 subset

### Onboarding
- New page inserted at position 1 (after welcome, before exam structure)
- Two selectable cards: B1 and B2
- Each shows: license name, question count, brief description
- Selection stored immediately to AppStorage

### Settings
- New row: "Hạng bằng lái" with B1/B2 picker
- Confirmation alert when changing (different exam rules apply)

### Question Filtering
- `QuestionStore.questionsForLicense(_ type: String) -> [Question]`
- All existing methods (`randomExamQuestions`, `examSetQuestions`, topic queries) filter through this

---

## F2. Correct Exam Rules Per License Type

### LicenseConfig

| Rule | B1 | B2 |
|------|----|----|
| Questions per exam | 30 | 35 |
| Time limit | 20 min (1200s) | 22 min (1320s) |
| Pass threshold | 26 | 32 |
| Diem liet per exam | 1 | 1 |
| Question pool size | 300 | 600 |
| Exam sets | 10 (300/30) | 17 (600/35) |

### Implementation
- New `LicenseConfig` struct with `static var current: LicenseConfig`
- Reads `@AppStorage("licenseType")` and returns appropriate rules
- `AppConstants.Exam` delegates to `LicenseConfig`
- Consumers: `ExamResult.calculate()`, `BaseExamView`, timer, pass/fail checks, result views

### Exam Set Generation
- B1: 10 sets × 30 questions, using `b1` ordering (set 1 = positions 1-30, etc.)
- B2: 17 sets × 35 questions, sequential slicing of all 600

---

## F4. App Store Review Prompt

### Trigger
- After first exam pass (mock, simulation, or hazard)
- `@AppStorage("hasRequestedReview")` — default `false`

### Implementation
- In result views (`ExamResultView`, `SimulationResultView`, `HazardResultView`)
- On `.onAppear`, if passed AND `hasRequestedReview == false`:
  - 2-second delay
  - Call `SKStoreReviewController.requestReview(in:)`
  - Set `hasRequestedReview = true`
- Apple rate-limits to max 3 prompts per year — safe to call

---

## Files Touched

| Feature | Files |
|---------|-------|
| F1 | `AppConstants`, `Question`, `QuestionStore`, `OnboardingView`, `SettingsView` |
| F2 | New `LicenseConfig`, `AppConstants.Exam`, `BaseExamView`, `ExamResult`, result views |
| F4 | `ExamResultView`, `SimulationResultView`, `HazardResultView` |
