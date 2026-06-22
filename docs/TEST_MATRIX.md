# Test Matrix

This file maps product behavior to proof. See `docs/product/overview.md` for the
product context. Unit tests live in `GPLX2026Tests/` (XCTest); run with
`xcodebuild test -scheme GPLX2026 -destination 'platform=iOS Simulator,name=iPhone 17 Pro Max'`.

## Status Values

| Status | Meaning |
| --- | --- |
| planned | Accepted as intended behavior, not implemented |
| in_progress | Actively being built |
| implemented | Implemented and proof exists |
| changed | Contract changed after earlier implementation |
| retired | No longer part of the product contract |

## Matrix

| Story | Contract | Unit | Integration | E2E | Platform | Status | Evidence |
| --- | --- | --- | --- | --- | --- | --- | --- |
| Hazard videos | `videoURL` points at the live host with unpadded filename (`th1…th120.mp4`); never `gmec.vn` | yes | no | no | no | implemented | `HazardSituationTests.testVideoFileNameIsUnpadded`, `…testVideoURLPointsAtLiveHostWithUnpaddedName` |
| Hazard scoring | Tap score is 5 at perfect-start, 0 at perfect-end, linear between, 0 outside the window or on no-tap | yes | no | no | no | implemented | `HazardSituationTests.testPerfectStartScoresFive`, `…testPerfectEndScoresZero`, `…testLinearInterpolationWithinWindow`, `…testTapBeforeOrAfterWindowScoresZero`, `…testNoTapScoresZero` |
| Answer order | `shuffledAnswers` is deterministic per question and a permutation of the answers | yes | no | no | no | implemented | `QuestionTests.testShuffledAnswersIsDeterministicPerQuestion`, `…testShuffledAnswersIsAPermutationOfAnswers` |
| Study activity | `recordStudyActivity` increments today's count; `totalActivity(lastDays:)` sums the window (0 for non-positive days) | yes | no | no | no | implemented | `ProgressStoreTests.testTotalActivityStartsAtZero`, `…testRecordStudyActivityCountsTowardTotal`, `…testTotalActivityWithNonPositiveDaysIsZero` |
| Progress state | Wrong-answers add/remove, bookmark toggle, and topic answer-status reflect saved results | yes | no | no | no | implemented | `ProgressStoreTests.testAddAndRemoveWrongAnswer`, `…testToggleBookmark`, `…testAnswerStatusReflectsSavedResults` |
| Reminders | Local notifications schedule/cancel per settings; taps deep-link; revoked permission resets toggles | no | no | no | yes | planned | needs device/integration (UNUserNotificationCenter side effects) — see manual checklist |
| Graceful video download | Failed downloads tracked in `failedIds` + surfaced; buffering timeout → retry overlay | no | yes | no | no | planned | needs network/device integration |

## Evidence Rules

- Unit proof covers pure domain and application rules.
- Integration proof covers backend enforcement, data integrity, provider
  behavior, jobs, or service contracts.
- E2E proof covers user-visible browser flows.
- Platform proof covers only shell, deployment, mobile, desktop, or runtime
  behavior that cannot be proven in lower layers.
- A story can be implemented without every proof column if the story packet
  explains why.
