# GPLX 2026 — Product Overview

Context for engineers and agents working in this repo: what the app is, who it's
for, the business, and the design rules. The same brief lives on the Pencil
canvas (`design/GPLX2026.pen` → "App Context" panel) for design work.

## Product

**GPLX 2026** ("Ôn Thi Lái Xe 2026") — an iOS app (SwiftUI, iPhone + iPad,
Vietnamese) for passing the Vietnamese car driving-licence theory exam
(hạng **B1 & B2**). Goal: help learners pass the Bộ GTVT test on the first try by
practising every part of the exam in one calm, modern app — and by knowing when
they're ready.

## Users

Vietnamese adults studying for the car licence, mostly on mobile in short daily
sessions; first-timers and re-testers. Pain points addressed:

- The 600-question bank is overwhelming.
- "Điểm liệt" (critical/disqualifying) questions cause an instant fail.
- The new 120 hazard-perception video section is unfamiliar.
- Learners don't know whether they're ready.

## Exam parts covered (mirrors the real test)

1. **Lý thuyết** (theory): 600 multiple-choice questions — fixed mock-exam sets +
   random exams with timer & pass threshold.
2. **Mô phỏng / Sa hình** (simulation): situational / diagram questions.
3. **Tình huống** (hazard perception): 120 video situations — tap when you spot
   the hazard; scored by timing window (perfect / late / miss).

## Core features

- **Practice**: by topic, all questions, "điểm liệt" set, wrong-answers,
  bookmarks, full-text search.
- **Mock exams**: random + fixed sets, countdown timer, pass/fail, exam history,
  score-trend chart.
- **Hazard videos**: per-chapter & exam-set practice; offline download manager
  (all / by chapter, progress, cache size). Videos are hosted remotely (see
  `HazardSituation.videoURL`).
- **Engagement**: daily challenge, study streak, activity heatmap, daily question
  goal, exam-date countdown, "smart nudge" (best next action), readiness status.
- **Reminders**: local notifications — daily study reminder, exam-countdown
  (T-7 / T-3 / T-1 / day-of), evening daily-goal nudge; taps deep-link to the
  relevant screen.
- **Settings**: licence type (B1/B2), theme, font size, haptics, accent colour,
  offline-video management, data reset.

## Information architecture

Three main tabs + modal flows:

- **Trang chủ** (Home): greeting, readiness/progress hero, smart-nudge +
  exam-countdown attention cards, quick actions, recent results.
- **Luyện tập** (Practice): question topics + hazard chapters as startable cards.
- **Thi thử** (Exam): random-exam CTA + fixed exam-set list with scores.
- **Modals**: in-exam question view, result screen, hazard video player, settings,
  onboarding.

## Business / positioning

- **Market**: large, recurring audience of Vietnamese GPLX learners. Existing free
  tools are cluttered / ad-heavy and weak on the new hazard-video section and on
  "am I ready" guidance.
- **Differentiator**: one calm, offline-capable app covering theory + simulation +
  hazard video that actively tells the learner what to study next and whether
  they'll pass.
- **Success metric**: exam pass-rate / learner confidence; retention via streaks,
  reminders, daily goals.
- **Monetisation**: currently a free utility (**assumption — confirm**). Natural
  future paths: one-time unlock / remove-ads / premium HD video pack.

## Design language (keep work on-brand)

- **Tone**: warm, calm, trustworthy, modern — not exam-stressful. All copy in
  Vietnamese.
- **Colour**: gradient background `#FBF8F0 → #EEECE6 → #DAD3C4`; cards `#FAF9F7`;
  accent terracotta `#D4714E` (text-on-accent white); semantic green `#22C55E` /
  amber `#F59E0B` / red `#EF4444`; text `#171717` / `#737373` / `#A3A3A3`.
- **Type**: **Be Vietnam Pro** (bold titles, regular/medium body); system
  monospaced for numbers / timers. Routed through `Font.appSans/.appSerif/.appMono`.
- **Style**: **flat** cards (solid fill, ~20 radius, no glass/shadow). **Liquid
  Glass only** on buttons + the tab bar. "Attention" cards add a soft accent/amber
  tint + hairline border (smart nudge, urgent countdown) via `glassCard(tint:)`.
- **Signature card**: bold title → row of **pill tags** (e.g. "120 câu", "82%
  đúng", "12/20 video") → trailing filled **circular play button** (terracotta).
  No leading icons, no chevrons. Built from `TagPill` + `CircularActionButton`.
