# CoffeeCall Codex Starter

Status: ACTIVE
Last updated: 2026-05-16

This is the standalone starter for Codex.

## Required Reading

Before changing files, read:

1. `AGENTS.md`
2. `docs/current/CONTEXT.md`
3. `docs/current/STATUS.md`
4. `docs/current/DESIGN.md` for UI work
5. `docs/current/PLAN.md` for product scope
6. `docs/current/ARCHITECTURE.md` for architecture

Never use `docs/archive/` as current guidance unless the user explicitly asks.

## Codex Operating Rules

- Prefer repository truth over assumptions.
- Use `rg` for searches.
- Keep edits scoped.
- Use `apply_patch` for manual file edits.
- Preserve unrelated worktree changes.
- Do not commit unless asked.
- Update `docs/current/STATUS.md` after meaningful work.

## Product Guardrails

- CoffeeCall is activity-first.
- Drifts are the action object.
- Around is ambient discovery.
- No person browsing, cold messages, follower graph, ratings, reputation, or phone exchange in MVP.
- Chat is available only inside joined or hosted Drifts.

## Design Guardrails

Follow `docs/current/DESIGN.md`.

For the active Around screen:

- Floating glass top header.
- Ambient radar.
- Drift-first context card.
- Two-row interests grid.
- Floating glass bottom nav.
- Center Create opens the Create Drift sheet.
- `See nearby Drifts` opens the Drifts listing.

If active docs conflict, stop and report the conflict before coding.
