# CoffeeCall Status

Status: ACTIVE
Last updated: 2026-05-16

This file is the current progress ledger. Update it after meaningful work.

## Current Focus

Align the live app and all AI guidance around a single active source of truth. The immediate UI focus is the updated Around screen.

## UX Status

| Area | Status | Notes |
|---|---|---|
| Design doc reset | Complete | Active docs now live in `docs/current/`; prior markdown is archived. |
| Around UX | Approved design direction | Spec lives in `docs/current/DESIGN.md`. |
| Around implementation | Needs verification | Recent app screenshots did not fully match the approved UX. |
| Drifts listing | Existing / needs route verification | `See nearby Drifts` should open this surface. |
| Create Drift sheet | Existing / needs route verification | Center Create action should present the sheet. |
| Profile UX | Concept direction only | Should stay lightweight and privacy-first. |

## App Status

| Area | Status | Notes |
|---|---|---|
| iOS app | In progress | SwiftUI frontend under `apps/frontend/Coffee_Call`. |
| Backend | In progress | Firebase Auth, Firestore, Storage, Messaging, Functions. |
| Messaging | MVP async model | Chat should be Drift-tied only. |
| Notifications | Planned/in progress | Nearby Drift notifications use the 10 km rule. |

## Known Mismatches

- The live Around implementation may be a partial match to the approved design.
- The approved Around design requires the full two-row interests grid to remain visible above the floating bottom nav.
- Archive files may contain outdated patterns; they are not active guidance.

## Documentation Reset Log

2026-05-16:

- Archived previous markdown under `docs/archive/2026-05-16-md-reset/`.
- Created the new active doc set under `docs/current/`.
- Created standalone starter files for Codex, Claude, and Antigravity.
- Preserved existing non-document app changes.
- Verified active markdown inventory contains only the approved starter files, minimal READMEs, and `docs/current/`.
- Verified active markdown has no stale Around guidance from the previous docs.

## How To Update This File

When an agent changes the project, add a short entry with:

- What changed.
- Why it changed.
- Files touched.
- Verification performed.
- Remaining gaps.
