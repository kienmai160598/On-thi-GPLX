# 0008 UI Rebuild: 4-Tab Navigation and 4-Step Onboarding

Date: 2026-06-22

## Status

Accepted

## Context

The full-UI rebuild from `design/GPLX2026.pen` (story
`US-001-ui-rebuild-from-design`) surfaces two structural divergences between the
shipped app and the design that change navigation/IA, not just styling:

1. The app uses **3 native tabs** (Trang chủ, Luyện tập, Thi thử) with
   Simulation/Hazard reached as modals; the design uses a **4-tab custom frosted
   tab bar** that promotes **Mô phỏng** to a top-level tab.
2. Onboarding is a **7-page** flow in code vs a **4-step** flow in the design.

## Decision

Adopt the design's navigation: **four tabs** (Trang chủ / Luyện tập / Thi thử /
Mô phỏng) on iPhone, and collapse onboarding to the design's four steps. iPad
keeps `NavigationSplitView` (no iPad mocks exist). The `ExamScreen`
`fullScreenCover` routing for exam/player/result flows is retained; reminder
deep-links (`NotificationRouter`) are remapped to the new tab set.

**Update (2026-06-23):** The four tabs use the **native SwiftUI `TabView`**, not
a custom floating `AppTabBar`. An initial custom frosted bar was built and then
reverted because, floating over the content via `safeAreaInset`, it prevented
scrolling content from clearing the bar (the last items stayed hidden). The
native tab bar reserves the bottom safe area automatically and is Liquid Glass
on iOS 26, so it matches the design intent without the scroll bug. `AppTabBar`
was deleted.

## Alternatives Considered

1. Keep 3 native tabs + modals — rejected: diverges from the approved design and
   buries the hazard/simulation practice that the design elevates.
2. iPhone-only rebuild that drops iPad split layouts — rejected: regresses iPad.

## Consequences

Positive:

- UI/IA matches the design source of truth.
- Hazard/simulation practice gets first-class discoverability.

Tradeoffs:

- Custom tab bar replaces native `TabView` on iPhone (we own its styling/state).
- Deep-link routing must be re-mapped and re-tested.

## Follow-Up

- Verify reminder deep-links land on the correct tab after the shell rebuild
  (Stage 2).
