# CoffeeCall AI Working Rules

Status: ACTIVE
Last updated: 2026-05-18

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

### SwiftUI Composable Design Principles

1. **Avoid Early Over-Engineering**: Do not create protocols, enums, and `AnyView`-based configuration layers unless high structural complexity is truly required.
2. **Prefer Generic Composition**: Build with generic view parameters (e.g., `Header: View`, `Content: View`, `RightView: View`) to keep views compile-time type-safe and highly reusable.
3. **Avoid `AnyView`**: `AnyView` erases compiler type information and slows down rendering performance. Prefer `@ViewBuilder` and generic type constraints.
4. **Flexible & Simple APIs**: Design components to support both a simple default implementation and custom advanced overrides (e.g., a default notification header overload alongside custom right-action slot builders).
5. **No Hardcoded Mock Data**: Reusable layout elements must receive data dynamically from state, models, or bindings rather than using fixed constants.
6. **No Debug Visuals in Production**: Purge debugging highlights like `Color.red` and testing visuals before closing a task.
7. **Consolidate Duplicate Views**: Merge views with highly overlapping responsibilities or clearly separate them into focused components.
8. **Preserve Backward Compatibility**: Retain legacy layout wrappers (like `CoffeeHeaderButton`) temporarily during migrations to avoid breaking the rest of the application.
9. **Align with Design Language**: SwiftUI views must feel premium, modern, social, soft, layered, and human-centered.
10. **Lightweight Composable Wrappers**: Custom page structures must be lightweight, modular lego blocks, not rigid protocol-bound configuration systems.
11. **Refactor the Core, Never Create Exceptions**: Never create ad-hoc layouts (such as manual scroll wrappers or local sub-page headers) to solve a single layout variation. If a root component or unified modifier (e.g., `.asCoffeePage`) lacks a needed parameter (such as non-scrollable behavior or zero safe area padding), refactor the core modifier itself rather than writing a file-specific layout exception. Keep the application 100% DRY.
12. **Pure Stateless Zero-Exception Architecture**: Ensure all main views and drill-down subviews adhere strictly to the central styling modifiers without legacy typealiases or custom wrappers. The core modifiers must be robust enough to handle all page layouts natively.

* **Final Rule**: Build SwiftUI like Lego blocks — small, composable, type-safe components — not like a locked configuration system.

## Centralized Learning & Skills Vault

To prevent repository clutter while maintaining deep architectural, styling, and engineering memory:
* **The Vault Location**: `/Users/developer/Documents/Projects/ObsidianVault/`
* **Your Action**: Before making any UI, typography, or architectural changes, read the markdown notes inside this Obsidian vault (specifically under `Software Engineering/SwiftUI/` and `Software Engineering/Apple HIG/`).
* **Your Contribution**: Whenever you discover a new reusable pattern, design principle, or coding standard during development, **always write or update a corresponding markdown note inside the Obsidian vault** with proper categories and frontmatter tags (e.g., `#swiftui`, `#architecture`).


