# CoffeeCall Shared AI Context

Status: ACTIVE
Last updated: 2026-05-16

This is the shared ground truth for every AI agent working on CoffeeCall.

## Project Identity

CoffeeCall is an activity-based meetup app. A user creates a nearby activity called a Drift, others join it, and participants coordinate through in-app messages before meeting in real life.

CoffeeCall is not a dating app, a coffee ordering app, a generic event dashboard, or a people-browsing product.

## Current Phase

The project is in coding, verification, and design alignment. Code changes are allowed when requested, but changes must stay scoped and must follow the active docs in `docs/current/`.

## Documentation Precedence

When instructions conflict, follow this order:

1. The user's latest message in the current conversation.
2. `AGENTS.md` and the active agent starter for the tool being used.
3. `docs/current/CONTEXT.md`.
4. `docs/current/STATUS.md`.
5. `docs/current/DESIGN.md`.
6. `docs/current/PLAN.md`.
7. `docs/current/ARCHITECTURE.md`.
8. Archive files only when the user explicitly asks to inspect history.

Before making UI changes, search active docs for conflicts and state which active spec will be followed. Do not silently blend archived guidance with current guidance.

## Active Docs

- `docs/current/CONTEXT.md` - shared AI ground truth and precedence rules.
- `docs/current/PLAN.md` - product scope, active work order, and MVP boundaries.
- `docs/current/ARCHITECTURE.md` - system architecture and implementation constraints.
- `docs/current/DESIGN.md` - design contract, UX rules, tokens, and screen specs.
- `docs/current/STATUS.md` - current progress, known mismatches, and verification state.

## Archive Rule

Historical markdown lives under `docs/archive/2026-05-16-md-reset/`. Archive files are not implementation truth. Use them only if the user explicitly asks for historical comparison.

## Non-Negotiables

- Activity first, person second.
- The Drift is the unit of action.
- No cold direct messages.
- No person browsing from Around.
- No phone number exchange in MVP.
- Async messaging only.
- Posts stay active after acceptance so group meetups are possible.
- Fixed 10 km discovery radius unless product scope changes.
- No scoring, reputation, reviews, penalties, followers, or dating mechanics in MVP.

## Agent Workflow

1. Read the relevant starter file: `AGENTS.md`, `CODEX.md`, `CLAUDE.md`, or `ANTIGRAVITY.md`.
2. Read `docs/current/CONTEXT.md` and `docs/current/STATUS.md`.
3. For UX/UI work, read `docs/current/DESIGN.md`.
4. For product or data behavior, read `docs/current/PLAN.md` and `docs/current/ARCHITECTURE.md`.
5. Before changing files, identify active conflicts if any.
6. After meaningful work, update `docs/current/STATUS.md` with what changed, files touched, verification, and remaining gaps.

## Current Design Focus

The first post-login screen is Around. It must use the updated Social Refresh UX:

- Floating glass top header.
- Ambient radar.
- Drift-first context card.
- Two-row interests grid.
- Floating glass bottom navigation.
- Center Create remains reserved for the future Create sheet design.

The active screen spec is in `docs/current/DESIGN.md`.
