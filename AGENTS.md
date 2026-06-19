# Agent Instructions

## What this is

**GPLX2026** ("Ôn Thi Lái Xe 2026") — an iOS app for practising the Vietnamese
driving-licence theory exam: question banks, mock exams, simulation (sa hình),
and hazard-perception (tình huống) video tests.

- **Platform:** iOS 18.0+, SwiftUI, **Swift 6.0 with `SWIFT_STRICT_CONCURRENCY: complete`**.
- **Project generation:** XcodeGen — `project.yml` is the source of truth.
  `GPLX2026.xcodeproj` is generated; do **not** hand-edit `project.pbxproj`.
  Run `xcodegen generate` after changing `project.yml` or adding/removing files.
- **Dependencies:** Lottie 4.6.0 (SPM, pinned in `project.yml`).

## Build, run, test

- `make build` — compile for generic iOS device (verifies compilation).
- `make iphone` / `make ipad` — install the built `.app` to the paired device.
- `make install` — install to both. Device IDs live in the `Makefile`.
- Tests: `GPLX2026Tests` (unit) and `GPLX2026UITests` (UI). Run via Xcode or
  `xcodebuild ... -scheme GPLX2026 test`.

## Layout & boundaries

- `GPLX2026/Core/` — shared foundation:
  - `Models/` value types (`Question`, `HazardSituation`, `ExamResult`, …)
  - `Storage/` observable stores: `QuestionStore`, `ProgressStore` (+ many
    `ProgressStore+*.swift` extensions), `HazardVideoCache`, `SecureStorage`.
    These are `@Observable` and injected via the SwiftUI environment.
  - `Theme/` (`AppTheme`, fonts), `Common/` reusable views/components.
- `GPLX2026/Features/` — one folder per feature area (Exam, Hazard, Home, Learn,
  Reference, Search, Settings, Simulation, Onboarding, Topics, Bookmarks).
- `GPLX2026/Resources/` — bundled assets and JSON data (`questions.json`,
  `memory_tips.json`), fonts, Lottie animations.
- `docs/plans/` — historical design/implementation notes (pre-harness).

## Conventions & gotchas

- **Fonts:** always use `.appSans / .appSerif / .appMono(size:weight:)`, never
  `.system(...)` directly. Font instances are cached — see `GPLX2026App.swift`.
- **Persistence** goes through `ProgressStore`; it keeps in-memory caches that
  are invalidated on write. If you add a derived/cached value, invalidate it in
  the same record/save paths as the existing caches (e.g. `_readinessCache`).
- **Hazard videos** stream/download from `https://gmec.vn` under SHA-256
  certificate pinning (`CertificatePinner`); failures surface via
  `HazardVideoCache.failedIds` and a buffering timeout — keep that graceful.
- Keep heavy work off the main thread (e.g. JSON decode in `QuestionStore`
  runs on a detached task); avoid per-render `DateFormatter`/`Calendar` loops —
  precompute and cache.
- UI language and user-facing strings are **Vietnamese**.

<!-- HARNESS:BEGIN -->
## Harness

This repo uses Harness. Before work, read:

- `README.md`
- `docs/HARNESS.md`
- `docs/FEATURE_INTAKE.md`
- `docs/ARCHITECTURE.md`
- `docs/CONTEXT_RULES.md`
- `docs/TOOL_REGISTRY.md`
- `scripts/bin/harness-cli query matrix` on macOS/Linux, or `.\scripts\bin\harness-cli.exe query matrix` on Windows

Use the Rust Harness CLI at `scripts/bin/harness-cli` on macOS/Linux or
`scripts/bin/harness-cli.exe` on Windows as the main operational tool. Before a
step that could use an external tool, run `scripts/bin/harness-cli query tools
--capability <name> --status present` to see what is equipped; an absent
capability is a clean skip.
<!-- HARNESS:END -->
