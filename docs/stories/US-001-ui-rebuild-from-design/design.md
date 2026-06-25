# Design

## Domain Model

Unchanged. Views keep consuming the existing `@Observable` stores
(`QuestionStore`, `ProgressStore` + extensions, `HazardVideoCache`,
`ThemeStore`, `LayoutMetrics`) and value-type models.

## Application Flow

Unchanged store APIs. Navigation: iPhone uses a custom 4-tab frosted bar
(`AppTabBar`) over `Trang chủ / Luyện tập / Thi thử / Mô phỏng`; iPad keeps
`NavigationSplitView`. Exam/player/result flows keep the `ExamScreen`
`fullScreenCover` routing. Reminder deep-links via `NotificationRouter` are
re-mapped to the new tab set.

## Interface Contract

No network/API contract. UI-only.

## Data Model

No schema/persistence change. `UserDefaults`/Keychain/`SecureStorage` untouched.

## UI / Platform Impact

iPhone screens rebuilt to the design; iPad adaptive layouts preserved. New/
extended widgets in `Core/Common`: `AppTabBar`, dark `FeatureCard` variant,
`TimingBar`, glassmorphism summary card, onboarding primitives,
`DeprecationModal`, download-state row.

## Observability

Existing `os.Logger` usage unchanged.

## Alternatives Considered

1. Keep 3 native tabs + modals (rejected: diverges from design).
2. iPhone-only rebuild dropping iPad layouts (rejected: regresses iPad).
