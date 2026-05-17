# CoffeeCall AI Working Rules

Status: ACTIVE
Last updated: 2026-05-16

This file applies to every AI agent working in this repository.

## Start Here

Read these active files before making changes:

1. `docs/current/CONTEXT.md`
2. `docs/current/STATUS.md`
3. `docs/current/DESIGN.md` for UI/UX work
4. `docs/current/PLAN.md` for product scope
5. `docs/current/ARCHITECTURE.md` for system design

Archive files under `docs/archive/` are historical only. Do not use them as implementation truth unless the user explicitly asks to inspect history.

## Project Summary

CoffeeCall is an activity-based meetup app. Users create nearby activities called Drifts, other users join, and participants coordinate through in-app messages.

The product is not a dating app, people directory, coffee ordering app, or generic event dashboard.

## Documentation Precedence

When instructions conflict:

1. Latest user message.
2. This file and the active tool-specific starter file.
3. `docs/current/CONTEXT.md`.
4. `docs/current/STATUS.md`.
5. `docs/current/DESIGN.md`.
6. `docs/current/PLAN.md`.
7. `docs/current/ARCHITECTURE.md`.
8. Archive files only by explicit user request.

Before UI implementation, search active docs for conflicts and state the active spec being followed.

## Non-Negotiables

- Activity first, person second.
- The Drift is the unit of action.
- No cold direct messages.
- No person browsing from Around.
- Chat only after joining or hosting a Drift.
- No phone number exchange in MVP.
- Async messaging only.
- Posts stay active after acceptance.
- Fixed 10 km discovery radius.
- No reputation, scoring, reviews, penalties, followers, or dating mechanics in MVP.

## Design Rules

- Follow the Social Refresh system in `docs/current/DESIGN.md`.
- Use mint `#53B8A6`, pressed mint `#3D8D7A`, lavender `#8E7DBE`, peach `#E88C6B`, warm background `#F6F1EB`, card surface `#FFFDF9`, text primary `#243447`, and text secondary `#5F6368`.
- Use native iOS default typography.
- Keep glassmorphic top and bottom navigation where specified.
- Around must use the approved radar, Drift context card, interests grid, and floating bottom nav.
- CORE UX CHANGES: If a request involves a core UX change, ALWAYS ask the user for confirmation first, and update the relevant markdown file (e.g., `DESIGN.md`) ASAP.

## Engineering Rules

- Keep changes scoped to the user request.
- Do not touch unrelated dirty work.
- Do not reset, stash, discard, or revert user/agent changes unless explicitly requested.
- Do not commit unless the user asks.
- Use semantic SwiftUI design tokens and local helpers where practical.
- For meaningful work, update `docs/current/STATUS.md`.

## Verification

- For UI work, provide screenshot/build verification when practical.
- For doc work, run markdown inventory and stale-guidance searches.
- If a task cannot be verified, state the gap clearly.
