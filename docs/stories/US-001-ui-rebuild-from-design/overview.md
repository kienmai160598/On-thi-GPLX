# Overview

## Current Behavior

The SwiftUI UI has drifted from `design/GPLX2026.pen`: 3 native tabs with
Simulation/Hazard as modals, a 7-page onboarding flow, and several screens
styled ad-hoc. Tokens (terracotta, gradient, Be Vietnam Pro, flat cards) and the
`Core/Common` widget library already match the design.

## Target Behavior

The whole View layer is rebuilt to match the design: a 4-tab frosted tab bar
(Trang chủ, Luyện tập, Thi thử, Mô phỏng), a 4-step onboarding, and every screen
recomposed from shared widgets. The data/domain layer is unchanged.

## Affected Users

- Vietnamese GPLX learners (all app users, iPhone + iPad).

## Affected Product Docs

- `docs/product/*` (app overview), `design/GPLX2026.pen`.

## Non-Goals

- No change to stores/models/persistence, networking/cert validation,
  notifications, or `project.yml`.
- No new product features; visual/IA rebuild only.
- iPad gets preserved adaptive layouts (no design mocks exist for iPad).
