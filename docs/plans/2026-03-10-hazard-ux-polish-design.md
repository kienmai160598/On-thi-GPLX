# Hazard Flow UX Polish + QuestionView Light Touch

Date: 2026-03-10

## Goal
Deep polish on the hazard test experience (landscape layout, guide overlay, score reveal, video error handling), lighter touch on QuestionView.

## 1. Landscape Guide Overlay Redesign

**Problem:** Current animation rotates an `iphone.landscape` SF Symbol by -90° in an infinite loop — visually confusing.

**Solution:**
- Use `iphone.gen3` (portrait icon) that smoothly rotates 90° clockwise with a spring animation
- Single animation: 0° → 90° (not looping), delayed 0.5s after appear
- Keep the dark overlay, title "Xoay ngang điện thoại", subtitle, and "Đã hiểu" button
- On tap "Đã hiểu": force rotate to landscape via OrientationManager

## 2. Landscape Layout — Adaptive Panel Width

**Problem:** Right panel is fixed at 38% width. Too wide during playback (wastes video space), too narrow for score card (cramped ScrollView).

**Solution — Two-phase panel:**
- **Playback phase** (video playing, not finished): Right panel shrinks to ~28% width, max 240pt. Contains only: chapter label, timer, progress bar, danger button, question counter. Video gets ~72% width.
- **Score phase** (video finished, score revealed): Right panel expands to ~45% width, max 360pt. Contains: compact score display, timeline, tip, navigation buttons. Animate width change with spring.
- **Transition:** `.spring(duration: 0.4, bounce: 0.15)` on panel width change
- Video error state: add "Thử lại" button that calls `retryCurrent()` equivalent for video reload

## 3. Danger Button & Tap Feedback

**Problem:** Tap feedback is only haptic + color change. In landscape with big video, user may not notice the small button changed.

**Solution:**
- On tap: show a brief white flash overlay (opacity 0→0.4→0, duration 0.2s) on the video frame
- Landscape: reduce button height from 64pt to 52pt to save vertical space
- Keep existing pulsing glow animation and haptic feedback

## 4. Video Error Retry

**Problem:** When video fails to load, only shows error message. No retry option — user must exit and re-enter.

**Solution:**
- Add "Thử lại" button below error message in `videoErrorOverlay`
- Button resets `playerState` and increments `restartToken` to force video reload
- Works in both portrait and landscape

## 5. Score Reveal in Landscape — Compact Design

**Problem:** Full HazardScoreCard with HazardScoreReveal + HazardTimeline + tip doesn't fit in narrow landscape panel.

**Solution (already partially implemented as `landscapeScoreView`):**
- Keep the compact horizontal score display (score number + /5 + dots)
- Timeline fits well horizontally
- Tip text may need truncation with "..." and tap to expand
- Ensure ScrollView in landscape score panel has proper content insets

## 6. QuestionView Light Touch

**Problem:** Answer cards have generous spacing that could be tightened. Confirmed state could be visually clearer.

**Solution:**
- Reduce spacing between answer option cards from current value
- After confirmation: add subtle background tint to the entire answer area (green tint if correct, red if wrong) to make the result more immediately visible
- No landscape support needed (text-based quiz, portrait is fine)

## Files to Modify
- `GPLX2026/Features/Hazard/HazardTestView.swift` — Sections 1-5
- `GPLX2026/Features/Learn/QuestionView.swift` — Section 6
- `GPLX2026/Core/Common/Cards/AnswerOptionCard.swift` — Section 6 (if spacing is here)
- `GPLX2026/Core/Common/Lists/AnswerTileList.swift` — Section 6 (if spacing is here)

## Non-Goals
- No new screens or navigation changes
- No data model changes
- No changes to scoring logic
- No iPad-specific layout work
