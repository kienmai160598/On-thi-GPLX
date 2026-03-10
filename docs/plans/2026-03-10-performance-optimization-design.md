# Performance Optimization Design

**Date:** 2026-03-10
**Scope:** PERF2, PERF3, PERF4, PERF5 from comprehensive audit
**Skipped:** PERF1 (AnimatedBackground — opt-in only), PERF6 (AVPlayer — already handled)

---

## PERF2: Remove `dataVersion`, use native `@Observable` tracking

**Problem:** Every computed property reads `_ = dataVersion`, so ANY mutation invalidates ALL views. `recordQuestionAnswer` triggers 4+ increments per answer.

**Fix:**
- Remove `dataVersion` stored property entirely
- Remove all `_ = dataVersion` reads from computed properties
- Remove all `dataVersion += 1` from mutation methods
- The in-memory caches (`_examHistoryCache`, `_bookmarksCache`, etc.) are already stored properties — `@Observable` tracks them automatically
- For `topicProgress(for:)` — `_topicProgressCache` dict is a stored property, writes trigger observation
- For UserDefaults-backed values (streak, lastStudyDate, lastTopicKey, lastQuestionIndex) — convert to cached stored properties like the others
- `recordQuestionAnswer` currently triggers 4 separate bumps → now each sub-method just updates its own cache (natural batching)

**Files:** `ProgressStore.swift`, `ProgressStore+Activity.swift`

---

## PERF3: Cache `readinessStatus()` result

**Problem:** `readinessStatus()` runs O(N*T) iterating all topics and decoding progress dicts on every HomeTab body evaluation.

**Fix:**
- Add private `_readinessCache: ReadinessStatus?` stored property
- `readinessStatus()` returns cache if available, otherwise computes and stores
- Invalidate `_readinessCache = nil` only in methods that affect its inputs (topic progress, exam history)
- `_readinessCache` is a stored `@Observable` property, so SwiftUI tracks it correctly

**Files:** `ProgressStore+Analytics.swift`, `ProgressStore.swift`

---

## PERF4: Replace per-download URLSession with `URLSession.bytes`

**Problem:** Each of 120 downloads creates its own `URLSession` with delegate — session creation overhead × 120.

**Fix:**
- Create one shared `URLSession` on the class (lazy)
- Replace delegate-based download with `session.bytes(for: request)`
- Track progress via `expectedContentLength` from `URLResponse` + byte counting
- Write bytes to temp file incrementally
- Remove `DownloadProgressTracker` delegate class entirely
- Use `Task` handles for cancellation instead of `URLSessionTask`

**Files:** `HazardVideoCache.swift`

---

## PERF5: Lazy background cache stats

**Problem:** `refreshCacheStats()` iterates 120 files + directory listing synchronously on `@MainActor` in `init()` and after each download.

**Fix:**
- Remove `refreshCacheStats()` from `init()`
- Lazy computation: `cachedCount` and `cacheSizeMB` trigger background computation on first access
- After download completes, update `cachedIds` incrementally (insert new id, bump count) instead of re-scanning all 120 files
- Full rescan (`computeCacheSizeMB`) only on `clearCache()`, done in background

**Files:** `HazardVideoCache.swift`
