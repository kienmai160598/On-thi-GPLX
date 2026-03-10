# GPLX2026 Comprehensive Audit Report

**Date:** 2026-03-10
**Agents:** QA Engineer, UX/UI Designer, Business Analyst, Client/End-User, Code Architect, Performance Engineer

---

## EXECUTIVE SUMMARY

| Agent | Critical | Major | Minor/Polish |
|-------|----------|-------|--------------|
| QA Engineer | 4 | 8 | 8 |
| UX/UI Designer | 5 | 9 | 13 |
| Business Analyst | 3 blocking | 8 growth | 6 strengths |
| Code Architect | 1 bug | 5 high | 9 medium/low |
| Performance & A11y | 4 perf + 3 a11y critical | 6 perf warnings | 6 a11y warnings |
| Client (4.2/5) | — | — | — |

**Overall app rating (client perspective): 4.2 / 5**

---

## PRIORITY 1: BUGS (Fix immediately)

### B1. Smart nudge hazard score division is wrong
- **File:** `ProgressStore+SmartNudge.swift:147`
- **Issue:** `averageHazardScore / 100.0` but value is already 0.0-1.0 → always near zero
- **Impact:** Smart nudge ignores hazard progress, gives wrong recommendations

### B2. Simulation timeout records `-1` instead of `nil`
- **File:** `BaseExamView.swift:320`
- **Issue:** `answers[currentIndex] = -1` but `SimulationResult.calculate()` checks for `nil`
- **Impact:** "Hết thời gian" count always shows 0 in simulation results

### B3. UserDefaults.standard used instead of injected `defaults`
- **Files:** `ProgressStore+Activity.swift:9,23`, `ProgressStore+ExamDate.swift:10,25`
- **Issue:** Bypasses injected defaults, breaks testability
- **Impact:** Data goes to wrong store during tests

### B4. Timer exploit in simulation — navigating away resets 60s timer
- **File:** `BaseExamView.swift:336-340`
- **Issue:** `restoreStateForCurrentIndex()` calls `startScenarioTimer()` with fresh 60s
- **Impact:** Users get unlimited time by navigating away and back

### B5. QuestionView `questions` is computed live — shrinks mid-session
- **File:** `QuestionView.swift:35-37`
- **Issue:** Wrong answers list changes as user answers correctly → questions disappear
- **Impact:** UI jumps, questions skip, possible empty state mid-practice

### B6. Timer pauses during scroll (wrong RunLoop mode)
- **File:** `BaseExamView.swift:236,284`
- **Issue:** `Timer.scheduledTimer` uses `.default` mode, stops during scroll
- **Fix:** Add timer to `.common` RunLoop mode

### B7. `fatalError` in production for invalid video URL
- **File:** `HazardSituation.swift:20`
- **Fix:** Return optional or fallback URL

### B8. Result ID collision — `Date` as `Identifiable.id`
- **Files:** `HazardResult.swift:7`, `ExamResult.swift:8`, `SimulationResult.swift:7`
- **Fix:** Use `UUID` instead of `Date`

---

## PRIORITY 2: CRITICAL UX FIXES

### U1. Landscape guide shows every time (not persisted)
- **File:** `HazardTestView.swift:29`
- **Fix:** Use `@AppStorage` to remember dismissal

### U2. RecentResultRow — pass/fail use same color
- **File:** `HomeTab.swift:514-517`
- **Fix:** Use `.appSuccess` for pass, `.appError` for fail

### U3. 3-second countdown has no visual indicator
- **File:** `HazardDangerButton`
- **Fix:** Add visible countdown ("3... 2... 1...") or label

### U4. No back navigation to previous hazard situation
- **Issue:** `goToPrevious()` exists but no UI calls it
- **Fix:** Add "Previous" button in practice/chapter modes

### U5. AppButton iOS 26 uses `.white` instead of `.appOnPrimary`
- **File:** `AppButton.swift:24`
- **Fix:** Use `Color.appOnPrimary` for proper contrast in all themes

### U6. ExamBottomBar no safe area inset
- **File:** `ExamBottomBar.swift:55-57`
- **Fix:** Add proper bottom safe area padding

---

## PRIORITY 3: BUSINESS-CRITICAL FEATURES

### F1. License type selection (A1/A2/B1/B2)
- **Status:** Question data already has `a1`, `a2`, `b1` fields
- **Impact:** Without this, app serves only ~20% of market
- **Action:** Add onboarding step + filter questions by license type

### F2. Correct exam rules per license type
- **Current:** Hardcoded 30 questions / 28 pass (doesn't match any official format)
- **B2 should be:** 35 questions, 22 min, pass at 32
- **A1/A2:** 25 questions, 19 min, pass at 21

### F3. Remove bank transfer donation (App Store violation)
- **Issue:** Violates guideline 3.1.1
- **Fix:** Replace with IAP tip jar or remove before submission

### F4. Add App Store review prompt
- **Action:** `SKStoreReviewController` after first exam pass or 7-day streak

---

## PRIORITY 4: ARCHITECTURE IMPROVEMENTS

### A1. ProgressStore is a God Object
- **Impact:** Every `dataVersion += 1` triggers all views
- **Fix:** Split into `StudyProgressStore`, `ExamHistoryStore`, `StudyPlanStore`

### A2. Business logic in views (untestable)
- **Files:** `QuestionView`, `BaseExamView`, `HazardTestView`
- **Fix:** Extract `@Observable` view models for exam state, scoring, timer

### A3. ExamResultView / SimulationResultView 90% identical
- **Fix:** Create shared `GenericExamResultView` with configuration struct

### A4. No test target
- **Fix:** Add test target, start with `ExamResult.calculate()`, `SmartNudge`, `ReadinessStatus`

### A5. `Color.appPrimary` reads UserDefaults on every access
- **Fix:** Cache in `@Observable` theme store

---

## PRIORITY 5: ENGAGEMENT & RETENTION

### E1. No achievements/badges system
- Milestones: complete all diem liet, 7-day streak, first exam passed

### E2. No activity calendar/heatmap
- Data already collected in `ProgressStore+Activity.swift` but never displayed

### E3. No spaced repetition for wrong answers
- Currently binary (wrong/right) — add interval-based review

### E4. No iOS home screen widgets
- Streak, daily progress, exam countdown

### E5. No score trend charts
- Users can't see if they're improving over time

### E6. No celebration when daily goal is reached
- Just shows "Xong" — add brief animation

---

## PRIORITY 6: PERFORMANCE

### PERF1. AnimatedBackground renders every frame on every screen (GPU critical)
- **File:** `AnimatedBackground.swift`
- Uses `TimelineView(.animation)` with blur(radius:40) on 8 circles at 60-120fps
- Applied via `.screenHeader()` on EVERY screen
- **Impact:** 100% GPU, thermal throttling, battery drain, competes with video decoder
- **Fix:** Lower frame rate (30fps), disable during video playback, reduce blur

### PERF2. ProgressStore `dataVersion` causes global invalidation
- **File:** `ProgressStore.swift:33`
- Every computed property reads `_ = dataVersion` → ANY mutation invalidates ALL views
- `recordQuestionAnswer` triggers 4+ dataVersion increments per answer
- **Fix:** Remove dataVersion, rely on @Observable's built-in property tracking, or batch mutations

### PERF3. `readinessStatus()` runs O(N*T) on every HomeTab render
- **File:** `ProgressStore+Analytics.swift`
- Iterates all topics, decodes all progress dictionaries on every body evaluation
- **Fix:** Cache result, recompute only when data changes

### PERF4. New URLSession created per video download (120 sessions)
- **File:** `HazardVideoCache.swift:127-131`
- Each of 120 downloads creates its own URLSession
- **Fix:** Share a single URLSession, map tasks by identifier

### PERF5. HazardVideoCache.refreshCacheStats() blocks main thread
- Iterates 120 files + directory listing synchronously on @MainActor
- **Fix:** Move to background task

### PERF6. AVPlayer not explicitly released between hazard situations
- Old AVPlayer stays in memory until ARC collects
- **Fix:** Set `vc.player = nil` before creating new player

---

## PRIORITY 7: ACCESSIBILITY

### A11Y1. Zero accessibility labels on core screens (Critical)
- Only Settings has accessibility annotations
- HomeTab, QuestionView, HazardTestView, AnswerOptionCard — all zero
- **Impact:** App unusable for VoiceOver users

### A11Y2. Hazard perception completely inaccessible
- No audio cues, no alt descriptions, no alternative interaction
- Danger button has no accessibility label
- **Impact:** VoiceOver users cannot take hazard test at all

### A11Y3. Vietnamese text not annotated with language
- No `.accessibilityLanguage("vi")` or locale set
- VoiceOver may use English voice for Vietnamese text
- **Fix:** Set `.environment(\.locale, Locale(identifier: "vi"))` at app root

### A11Y4. Animations don't respect Reduce Motion
- Only AnimatedBackground checks `accessibilityReduceMotion`
- Pulsing danger button, spring animations, score count-up all ignore it
- **Fix:** Check `accessibilityReduceMotion` for prominent animations

### A11Y5. No screen reader grouping
- Composite views (AnswerOptionCard, ProgressOverview) read as fragmented elements
- **Fix:** Use `.accessibilityElement(children: .combine)` with summary labels

### A11Y6. Color-only status indicators
- Topic rings, hazard zones, answer correctness rely on color alone
- **Impact:** ~8% of male users (color-blind) can't distinguish states

---

## PRIORITY 8: POLISH

### P1. Dynamic Type completely ignored
- All fonts use hardcoded `.system(size:)` — won't scale with accessibility settings
- **Fix:** Use `@ScaledMetric` or semantic font styles

### P2. No VoiceOver labels on interactive elements
- Score dots, progress rings, timeline bars lack accessibility labels

### P3. Inconsistent horizontal padding (16/20/40pt)
- **Fix:** Define `AppTheme.contentPadding` constants

### P4. `StaggeredItem` modifier is dead code
- **File:** `AppTheme.swift:226-238` — does nothing

### P5. Duplicate color aliases
- `appTextDark`/`textDark`, `appScaffoldBg`/`scaffoldBg` — consolidate

### P6. AnswerOptionCard double background layering
- `.background(bgColor)` + `.glassCard()` creates two backgrounds

### P7. ExamTab "Lịch sử" sections all have identical titles
- **Fix:** Differentiate: "Lịch sử thi câu hỏi", "Lịch sử sa hình", etc.

### P8. Settings "Delete All" button lacks visual separation
- **Fix:** Stronger red background, more spacing, warning icon

---

## CLIENT FEEDBACK HIGHLIGHTS (4.2/5)

| Area | Rating | Key Feedback |
|------|--------|-------------|
| First Impression | 4.5/5 | Dashboard is clear, but no onboarding for new users |
| Learning Flow | 4.0/5 | Good progress rings, but no "study first" mode |
| Exam Practice | 4.5/5 | Realistic, but no pause, no diem liet marking during test |
| Hazard Perception | 4.0/5 | Innovative, but scoring not explained upfront |
| Results | 4.5/5 | Detailed review, but no score trend graph |
| Motivation | 3.5/5 | Streaks exist but no achievements, flat celebrations |
| Frustrations | 3.5/5 | Terminology inconsistency, no exam start confirmation |
| Missing Info | 3.5/5 | No exam day logistics, no license type clarity |
| Vietnamese | 4.5/5 | Natural and correct terminology |

---

## RECOMMENDED ROADMAP

### Phase 1: Bug Fixes (1-2 days)
- B1-B8: All critical bugs

### Phase 2: UX Fixes (2-3 days)
- U1-U6: Critical UX issues

### Phase 3: Business Features (1 week)
- F1: License type selection
- F2: Correct exam rules
- F3: Remove bank transfer
- F4: App Store review prompt

### Phase 4: Architecture (ongoing)
- A1-A5: Refactoring for maintainability

### Phase 5: Engagement (post-launch)
- E1-E6: Retention features

### Phase 6: Polish (ongoing)
- P1-P8: Accessibility and visual consistency
