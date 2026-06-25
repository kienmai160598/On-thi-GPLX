# Reminder Feature — Re-implementation Plan & Design

Date: 2026-06-19

## Problem

The local-notification "reminder" feature was half-wired:

- No `UNUserNotificationCenterDelegate` → foreground reminders suppressed, taps did nothing.
- Only (re)scheduled from the Settings screen → silently lost after reinstall / OS purge.
- Toggle stayed "on" even after the user revoked permission in iOS Settings.
- Exam date and daily goal were tracked but never produced notifications.
- `center.add()` errors were swallowed; `SmartNudge` logic duplicated.

Note: local notifications need **no** `Info.plist` usage-description string — the
permission prompt text is system-provided. (Corrects an earlier assumption.)

## Best practices applied

Sources: Apple "Notification Best Practices"; tanaschita iOS local notifications
guide; "Complete Guide to iOS Notifications (2026)".

- Set the delegate; present in foreground via `willPresent`; deep-link taps via
  `didReceive` + `userInfo`.
- Ask permission at a meaningful moment (onboarding, after value), check
  `getNotificationSettings()` before scheduling, re-sync on launch / foreground,
  and reset UI state when permission is revoked.
- One **idempotent** sync entry point that cancels + reschedules.
- Respect the **64 pending-notification cap** → exam countdown is a small bounded set.

## Design

- **`NotificationManager`** (rewritten): `authorizationStatus()`,
  `requestAuthorization()`, and `syncReminders(...)` — the single source of
  truth that clears all managed identifiers and reschedules from settings.
  Async `add(_:)` with error logging. Schedules: daily reminder (repeating,
  progress-aware copy), exam countdown (T-7/T-3/T-1 at 09:00 + morning-of at
  07:00, only future dates), daily-goal evening nudge (one-shot at 20:30,
  refreshed each sync, only when today's goal is unmet).
- **`NotificationRouter.shared`** (`@Observable @MainActor`): taps set
  `pendingDestination`; `HomeView` observes and switches tab. Mirrors the
  existing `OrientationManager.shared` pattern.
- **`AppDelegate`**: conforms to `UNUserNotificationCenterDelegate`
  (`nonisolated` methods under Swift 6 strict concurrency); sets the delegate;
  foreground presentation; tap routing.
- **App lifecycle** (`GPLX2026App`): initial sync after questions load, and a
  re-sync on every `scenePhase == .active` that also flips the toggles off if
  permission was revoked.
- **Settings**: toggles routed through a shared permission gate + `syncReminders`;
  new "exam countdown" and "daily-goal nudge" toggles; a "Mở Cài đặt" alert when
  permission is denied.
- **Onboarding**: a dedicated permission page (id 5) that requests authorization
  and, if granted, enables the daily reminder by default.

## Deep-link map

| Reminder            | `userInfo[route]` | Tab      |
|---------------------|-------------------|----------|
| Daily practice      | `practice`        | Luyện tập |
| Daily-goal nudge    | `practice`        | Luyện tập |
| Exam countdown      | `exam`            | Thi thử  |

## Files touched

- New: `Core/Common/Utilities/NotificationRouter.swift`
- Rewritten: `Core/Common/Utilities/NotificationManager.swift`
- `Core/Common/Utilities/AppConstants.swift` (2 new storage keys)
- `GPLX2026App.swift` (delegate + lifecycle sync)
- `Features/Home/HomeView.swift` (tab selection + deep-link)
- `Features/Settings/SettingsView.swift` (toggles + permission UX)
- `Features/Onboarding/OnboardingView.swift` (permission page)

## Verification

- `make build` / `xcodebuild ... build` → BUILD SUCCEEDED.
- Manual: enable in onboarding/Settings; revoke in iOS Settings → toggles reset on
  foreground; set exam date → countdown scheduled; tap a reminder → correct tab.
