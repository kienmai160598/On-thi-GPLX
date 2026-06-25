# Validation

## Proof Strategy

The app must build warning-clean under `SWIFT_STRICT_CONCURRENCY: complete`
after every screen, pass the existing unit/UI tests, and visually match the
design on iPhone while preserving iPad layouts.

## Test Plan

| Layer | Cases |
| --- | --- |
| Unit | Existing `GPLX2026Tests` (Question, HazardSituation, ProgressStore) stay green; add coverage for any new pure logic in widgets. |
| Integration | Store-driven screen states (loading, empty, populated) render without crashes. |
| E2E | `GPLX2026UITests` launch + core flows. |
| Platform | iPhone (design match) + iPad (split-view preserved); light/dark; Dynamic Type. |
| Performance | `View.body` stays allocation-light; no per-render formatters; off-main work preserved. |
| Logs/Audit | No behavior change; existing logs intact. |

## Fixtures

Bundled `questions.json` / `memory_tips.json`; simulator devices from `Makefile`
(`SIM_ID`, `IPHONE_ID`, `IPAD_ID`).

## Commands

```text
make build                 # compile (generic iOS) after each screen
xcodebuild -project GPLX2026.xcodeproj -scheme GPLX2026 \
  -destination 'platform=iOS Simulator,id=720AD619-4FF4-43A9-B772-7EF4B9354A3F' test
```

## Acceptance Evidence

Recorded per stage in the trace and `docs/TEST_MATRIX.md`. Baseline before work:
`make build` = BUILD SUCCEEDED (14 pre-existing warnings).
