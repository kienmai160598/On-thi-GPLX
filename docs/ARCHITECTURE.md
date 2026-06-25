# Architecture

**GPLX2026** is a native iOS app (SwiftUI) for practising the Vietnamese
driving-licence theory exam. There is no backend the app owns: question and tip
data ship in the bundle as JSON, user progress lives on-device, and the only
network traffic is downloading hazard-perception videos from a public CDN.

This document describes the architecture as it exists. For per-rule constraints
see `docs/CODING_STANDARDS.md`; for layout and gotchas see `AGENTS.md`.

## Stack

- **Platform:** iOS 18.0+, SwiftUI, UIKit only where SwiftUI lacks coverage
  (app/scene delegate, nav-bar appearance, orientation, notifications).
- **Language:** Swift 6.0 with `SWIFT_STRICT_CONCURRENCY: complete`.
- **Project generation:** XcodeGen — `project.yml` is the source of truth;
  `GPLX2026.xcodeproj` is generated. Run `xcodegen generate` after changing
  `project.yml` or the file set. Do **not** hand-edit `project.pbxproj`.
- **Dependencies:** Lottie 4.6.0 (SPM, pinned). No other third-party packages.
- **Data:** `Resources/Data/questions.json` (~460 KB) and `memory_tips.json`
  bundled; hazard videos fetched on demand and cached on disk.

## Architectural Style

This is a **feature-oriented SwiftUI app with observable stores**, not a layered
backend. The shape is:

```text
GPLX2026App (@main)
  owns @Observable stores as @State
  injects them into the environment
        |
        v
  ContentView / OnboardingView
        |
        v
  Features/* views  --read/-write-->  Core/Storage stores
        |                                   |
        v                                   v
  Core/Common reusable views        Core/Models value types
  Core/Theme                        UserDefaults / Keychain / disk cache
```

- **Composition root:** `GPLX2026/GPLX2026App.swift` constructs the stores
  (`QuestionStore`, `ProgressStore`, `HazardVideoCache`, `ThemeStore`,
  `LayoutMetrics`) once as `@State` and injects them with `.environment(...)`.
  An `AppDelegate` adaptor handles notification presentation/routing and
  supported orientations.
- **Views** read stores via `@Environment(StoreType.self)` and never construct
  their own store instances. Business logic lives in stores and models so it is
  testable without the UI.

## Directory Layout

```text
GPLX2026/
  GPLX2026App.swift     composition root, font registration, AppDelegate
  ContentView.swift     root view (loading state -> HomeView)

  Core/
    Models/             value types: Question, HazardSituation, ExamResult,
                        SimulationResult, HazardResult, Topic, ExamSet,
                        LicenseType, MemoryTip — Codable structs/enums
    Storage/            @Observable stores + SecureStorage (see below)
    Theme/              AppTheme, ThemeStore (colors, theme mode)
    Common/             reusable views (Buttons, Cards, Display, Exam, Layout,
                        Lists, Media) and Utilities (CertificatePinner,
                        DateFormatters, Haptics, Notification*, Orientation*,
                        AppConstants)
    Services/           (currently empty — reserved)

  Features/             one folder per area: Home, Exam, Hazard, Learn,
                        Reference, Search, Settings, Simulation, Onboarding,
                        Topics, Bookmarks, Engagement

  Resources/            Data/*.json, Fonts (Be Vietnam Pro), Images, Assets
```

Dependency direction: `Features` depend on `Core` (Models, Storage, Common,
Theme); `Core` does not depend on `Features`. Models are leaf value types with
no dependency on stores or views.

## Stores (Core/Storage)

All stores are `@Observable` reference types injected through the SwiftUI
environment. They are the single source of truth for app state.

| Store | Role | Notes |
| --- | --- | --- |
| `QuestionStore` | Loads and queries the bundled question bank | Decodes `questions.json` off-main via `Task.detached`; holds derived caches (`_diemLietCache`, `_simulationCache`, `_b1Cache`, `_questionsByNo`) rebuilt in `rebuildCaches()`. |
| `ProgressStore` | All user progress, history, bookmarks, streaks | `UserDefaults`-backed; writes serialized through a private `writeQueue` (`safeWrite`); many in-memory caches invalidated on write (e.g. `_readinessCache`). Split across `ProgressStore+*.swift` extensions by concern (Activity, Analytics, Engagement, ExamDate, ExamHistory, SmartNudge, SpacedRepetition). |
| `HazardVideoCache` | Downloads/caches hazard videos | `@MainActor`; shared `URLSession` + `SharedDownloadDelegate`; concurrent download window of 4; failures surface via `failedIds`, never crash. |
| `ThemeStore` | Theme mode and primary color | Drives `preferredColorScheme` and accent. |
| `LayoutMetrics` | Layout/size-class metrics | Injected for adaptive layout. |
| `SecureStorage` | Encrypts sensitive values before persistence | A `struct`, not a store: AES-GCM (CryptoKit) with a key generated once and kept in the Keychain; transparent migration fallback for legacy plaintext. |

## Data Flow on Launch

1. `GPLX2026App` builds the stores and shows `SplashView` over the content.
2. `SplashView.task` calls `questionStore.loadQuestions()` — reads and decodes
   the JSON on a detached task, then publishes results on the main actor and
   rebuilds caches.
3. Reminders are reconciled (`syncReminders`) against current settings and
   notification authorization; the splash fades to reveal `ContentView`.
4. `ContentView` shows a loading state while `isLoading`, then `HomeView`.
5. On every foreground (`scenePhase == .active`) reminders re-sync so the UI
   stays honest if permission was revoked in iOS Settings.

## Networking & Security

- **Hazard videos** stream/download from a **public** CDN
  (`https://raw.githubusercontent.com/.../video`, see
  `HazardSituation.videoBaseURL`). The content is public, non-sensitive.
- **TLS:** `CertificatePinner.validate` evaluates the server trust against the
  **system trust store** (`SecTrustEvaluateWithError`) — standard TLS. It does
  **not** do SHA-256 public-key pinning. Pinning was removed deliberately: the
  earlier pin was computed over a different key encoding than the pinned value,
  so it never matched and rejected every download; for public video content,
  system-trust validation is the correct trade-off. The `URLSession` delegate
  still rejects challenges that fail validation (no "allow all" path).
- **Failure handling** is graceful: network/server/cert failures land in
  `HazardVideoCache.failedIds` (user-initiated cancels are excluded) and surface
  in the UI; nothing crashes and there is no insecure fallback.
- **Sensitive on-device data** goes through `SecureStorage` (AES-GCM, Keychain
  key). Non-sensitive preferences use `UserDefaults`/`@AppStorage`.

When changing any of the above (re-introducing pinning, changing the host or
trust model, moving data between `SecureStorage` and `UserDefaults`), treat it
as **high-risk** per `docs/FEATURE_INTAKE.md` and record a decision.

## Concurrency Model

- The app builds under **strict concurrency = complete**; keep it warning-clean.
- UI-facing stores and state are main-actor isolated; `loadQuestions()` and
  `HazardVideoCache` hop to `@MainActor` to publish results.
- Heavy work runs off-main: JSON decode (`Task.detached`), video download
  (`URLSession` + `withTaskGroup`), and disk stats scanning.
- `@unchecked Sendable` is avoided by default. The one deliberate use —
  `SharedDownloadDelegate` — carries an explicit thread-safety contract: every
  mutable field is accessed only inside `lock.withLock { … }`, and the stored
  closures are `@Sendable`. Any future use must come with the same kind of
  documented contract; it is not an escape hatch to silence a diagnostic.

## Persistence

- **Progress/history:** `UserDefaults`, written through `ProgressStore.safeWrite`
  on a serial queue to avoid corruption; reads served from invalidate-on-write
  in-memory caches.
- **Sensitive values:** `SecureStorage` (encrypted blobs in `UserDefaults`, key
  in Keychain).
- **Hazard videos:** files under the app's Caches directory
  (`HazardVideoCache.cacheDir`), addressable by `videoFileName`.
- **Bundled data:** read-only `questions.json` / `memory_tips.json`.

## Boundaries (Parse-First)

Unknown input is decoded into typed models at the edge before feature code uses
it:

- Bundled JSON → `[Question]` / `[String: [MemoryTip]]` via `Codable` at load.
- Notification payloads → a typed route via `NotificationRouter`.
- Persisted blobs → typed values via `SecureStorage` / `Codable`.

Inner code works with `Question`, `HazardSituation`, `ExamResult`, `Topic`, …,
not raw dictionaries or strings.

## Conventions

See `AGENTS.md` (fonts, persistence/cache invalidation, Vietnamese strings) and
`docs/CODING_STANDARDS.md` for the enforceable rules. Key ones that shape the
architecture: use the cached `.appSans/.appSerif/.appMono` fonts (never
`.system`), invalidate derived caches in the same write path as their source,
and keep `View.body` allocation-light.
