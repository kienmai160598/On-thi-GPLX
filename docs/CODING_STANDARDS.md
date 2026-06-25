# Coding Standards & Constraints

Constraints that every feature and code change in **GPLX2026** must satisfy.
These are not aspirations — treat each "MUST" as a gate. If a change cannot meet
a MUST, that is a design problem to raise, not a rule to skip.

This document is lane-independent context: read it during the **Planning** and
**Implementation** phases for any code change (see `docs/CONTEXT_RULES.md`).
`AGENTS.md` carries the short summary; this file is the detail.

Sources: Swift API Design Guidelines, Apple Swift Concurrency docs, OWASP Mobile
Top 10 / MASVS, and Apple Human Interface Guidelines — adapted to this codebase.

---

## How to apply these

- **MUST** — a hard gate. A reviewer should reject the change if it is violated.
- **SHOULD** — strong default. Deviating requires a one-line reason in the PR /
  trace.
- **AVOID** — a known foot-gun in this codebase; do it only with justification.

When a standard conflicts with an existing pattern in the file you are editing,
follow the surrounding code and note the inconsistency in the trace rather than
mixing two styles in one file.

---

## 1. Swift 6 & SwiftUI

The project builds under **Swift 6 with `SWIFT_STRICT_CONCURRENCY: complete`**.
Concurrency correctness is enforced by the compiler — do not silence it.

- **MUST** keep the build warning-clean under strict concurrency. Do not reach
  for `@unchecked Sendable`, `nonisolated(unsafe)`, or `@preconcurrency` to quiet
  a data-race diagnostic — fix the isolation instead. The one sanctioned
  exception is a type that genuinely bridges a callback-based API (e.g.
  `SharedDownloadDelegate` wrapping a `URLSession` delegate): it is allowed only
  with an explicit, documented thread-safety contract (all mutable state behind a
  lock, `@Sendable` closures). No undocumented `@unchecked Sendable`.
- **MUST** keep UI-facing state and observable stores on the main actor. The
  `@Observable` stores (`QuestionStore`, `ProgressStore`, `HazardVideoCache`,
  `SecureStorage`) are injected through the SwiftUI environment and read during
  render — they belong to `@MainActor`.
- **MUST** run heavy work (JSON decode, file I/O, network, image/video
  processing) off the main thread via `Task.detached` / async APIs, then hop back
  to the main actor to publish results — mirror `QuestionStore`'s detached
  decode. Never block the main thread.
- **MUST NOT** force-unwrap (`!`) or force-`try!` on values that can be absent at
  runtime (network results, decoded JSON, optional lookups, dictionary subscripts).
  Use `guard let` / `if let`, `??`, or typed throwing. `!` is acceptable only for
  values that are provably non-nil at the call site (e.g. a static asset name).
- **MUST** parse unknown input into typed values at the boundary before it
  reaches feature logic — decoded JSON, deep links, signed URLs, persisted blobs.
  Inner code works with `Question`, `HazardSituation`, `ExamResult`, … not raw
  dictionaries or strings (see `docs/ARCHITECTURE.md` → Parse-First Boundary).
- **SHOULD** prefer value types (`struct`/`enum`) for models and pure logic;
  reserve reference types for shared mutable stores and identity-bearing objects.
- **SHOULD** make illegal states unrepresentable with `enum`s and non-optional
  properties instead of validating loose flags at every call site.
- **SHOULD** keep SwiftUI views small and composable; extract subviews and lift
  derived values out of `body`. A `body` that does real computation per render is
  a bug (see Performance).
- **SHOULD** use `@State` / `@Bindable` / `@Environment` per their intended
  ownership; do not store derived data in `@State` that can be recomputed.
- **AVOID** business logic in views. Logic belongs in models/stores so it is
  testable without the UI.

## 2. Security & privacy

This app downloads public video content over TLS and stores user data locally.
Treat changes to the trust model or data-at-rest as high-risk (they are a hard
gate in `docs/FEATURE_INTAKE.md`).

- **MUST** validate the server trust for hazard-video traffic against the system
  trust store (`CertificatePinner.validate` → `SecTrustEvaluateWithError`).
  Never accept invalid certs or add an "allow all" `URLSession` delegate, even
  temporarily for debugging. (Note: SHA-256 public-key pinning was deliberately
  removed — the videos are public, non-sensitive content; see
  `docs/ARCHITECTURE.md`. Re-introducing pinning is a high-risk decision, not a
  drive-by.)
- **MUST NOT** commit secrets, API keys, tokens, pinned-hash private material, or
  credentials to the repo or to source. Configuration that must vary by build
  belongs outside tracked source.
- **MUST** route sensitive persisted data through `SecureStorage` (Keychain),
  not `UserDefaults` or plaintext files. `UserDefaults` is for non-sensitive
  preferences only.
- **MUST** use `https://` for all network requests and validate/encode any
  dynamic component of a URL. No plaintext HTTP, no string-built URLs with
  untrusted input.
- **MUST** fail safe: on a network, decode, or pinning failure, surface the error
  gracefully (e.g. `HazardVideoCache.failedIds` + buffering timeout) — never
  crash, never silently fall back to an insecure path.
- **SHOULD** log no PII or secrets. Keep operational logs free of user content;
  user-facing records are a separate concern.
- **SHOULD** request the minimum data and permissions a feature needs; do not add
  capabilities or entitlements speculatively.

## 3. Performance

The app renders lists, plays video, and decodes a large question bank. Keep the
main thread free and avoid per-frame waste.

- **MUST** keep `View.body` allocation-light: no `DateFormatter`, `Calendar`,
  `JSONDecoder`, regex compilation, or sorting/filtering of large collections
  inside `body` or in a per-row closure. Precompute and cache (the project
  already does this — e.g. cached fonts, `_readinessCache`).
- **MUST** invalidate any derived/cached value in the *same* write path as the
  data it derives from. `ProgressStore` keeps in-memory caches invalidated on
  write — a new cache MUST follow that pattern or it will go stale.
- **MUST** use `.appSans / .appSerif / .appMono(size:weight:)` (cached font
  instances), never `.system(...)` directly — constructing fonts per render is a
  measurable cost this project explicitly avoids.
- **SHOULD** load large/lazy content lazily: `LazyVStack`/`LazyHStack`/`List`
  for long collections, and stream/cache video rather than loading it all.
- **SHOULD** give list/`ForEach` rows stable identities to avoid needless
  rebuilds; avoid index-based ids for mutable collections.
- **SHOULD** decode and transform data once, off-main, and hand finished value
  types to the UI.
- **AVOID** premature micro-optimization that hurts clarity — measure first, then
  optimize the hot path the profiler points at.

## 4. General best practices

- **MUST** make the smallest change that satisfies the request (the smallest
  vertical slice) — do not refactor unrelated code in the same change.
- **MUST** keep user-facing strings in **Vietnamese**, consistent with the rest
  of the app.
- **MUST** add or update tests for new logic that can be unit-tested
  (`GPLX2026Tests`); UI-level behavior goes in `GPLX2026UITests`. Bug fixes get a
  regression test where feasible. Record proof in the test matrix.
- **MUST** run `xcodegen generate` after changing `project.yml` or adding/removing
  files, and never hand-edit `project.pbxproj`.
- **MUST** verify compilation with `make build` before claiming a change is done;
  report failures with their output rather than asserting success.
- **MUST** handle errors explicitly — no empty `catch {}` that swallows failures.
  Either recover, surface to the user (in Vietnamese), or propagate.
- **SHOULD** name things per the Swift API Design Guidelines: clarity at the call
  site, no abbreviations, methods read as phrases. Match the surrounding file's
  naming and comment density.
- **SHOULD** keep functions short and single-purpose; extract rather than nest
  deeply. Prefer early `guard` returns over pyramids.
- **SHOULD** write comments that explain *why*, not *what*; delete dead code
  rather than commenting it out (git is the history).
- **SHOULD** keep accessibility working: meaningful labels, Dynamic Type support
  via the app fonts, and sufficient contrast.
- **AVOID** introducing new third-party dependencies. Lottie is the only declared
  SPM dependency (pinned in `project.yml`); adding another is a decision, not a
  drive-by.

---

## Pre-merge checklist

Before claiming a code change is complete:

- [ ] Builds warning-clean under strict concurrency (`make build`).
- [ ] No new force-unwraps / `try!` on runtime-optional values.
- [ ] Heavy work is off the main thread; `body` is allocation-light.
- [ ] Caches invalidated in the same write path as their source data.
- [ ] Cert pinning and `SecureStorage` boundaries untouched (or change is
      high-risk and went through the intake gate).
- [ ] No secrets committed.
- [ ] Tests added/updated; proof recorded in the test matrix.
- [ ] `xcodegen generate` run if `project.yml` or the file set changed.
- [ ] User-facing strings are Vietnamese.
