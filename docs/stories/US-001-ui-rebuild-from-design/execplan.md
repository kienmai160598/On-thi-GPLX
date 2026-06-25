# Exec Plan

Full detail: `~/.claude/plans/rustling-giggling-thompson.md` (approved plan).

## Goal

Rebuild the GPLX2026 UI to match `design/GPLX2026.pen`, then audit quality and
fix issues — without touching the data/domain layer.

## Scope

In scope:

- View layer: `GPLX2026/Features/**`, shared widgets `GPLX2026/Core/Common/**`,
  app shell (`GPLX2026App.swift`, `ContentView.swift`, `HomeView.swift`).

Out of scope:

- `Core/Storage/**`, `Core/Models/**`, `Core/Theme` tokens, notifications,
  `CertificatePinner`, `project.yml`. No data/security/persistence change.

## Risk Classification

Risk flags: Cross-platform (iPhone/iPad), Existing behavior (tested screens),
Multi-domain (every feature area). No Auth/Authorization/Data-model/Audit/
External-provider change.

Hard gates: none triggered (security/data/persistence untouched).

## Work Phases

1. Stage 0 — foundation widgets & tokens.
2. Stages 1–7 — rebuild screens in user-flow order, build after each.
3. Stage 8 — quality audit + fixes.

## Stop Conditions

Pause for human confirmation if:

- A screen requires changing store/persistence behavior to match the design.
- The 4-tab navigation breaks reminder deep-links in a way needing a UX call.
- iPad adaptivity cannot be preserved without a design decision.
