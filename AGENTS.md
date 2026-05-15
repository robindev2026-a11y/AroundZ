# AGENTS.md: CoffeeCall AI Working Rules

**Project:** CoffeeCall MVP
**Current phase:** Coding and verification
**Last updated:** 2026-05-13

This file is the first-stop context for AI tools working inside this repository.

---

## Project Summary

CoffeeCall is an activity-based meetup platform. Users post nearby activities, people join, then coordinate through in-app messages and meet in real life.

Not a dating app. Not a coffee ordering app. Focus on lightweight, local, activity-first social meetups.

---

## Current Source Of Truth

Read these before changing code:

| File | Purpose |
|---|---|
| `Planning/context.md` | Latest session history and recent fixes |
| `Planning/spec.md` | Product scope and acceptance criteria |
| `Planning/architecture.md` | System design and Firebase approach |
| `Planning/decisions.md` | Architecture decision records |
| `docs/Planning/build-guidelines.md` | Recurring Xcode/Firebase build gotchas |
| `Design/design-tokens.md` | Active colors, typography, spacing, radius |
| `Design/design-system.md` | Active visual direction |
| `Design/screens.md` | Current screen direction |
| `Design/component-specs.md` | Active component direction |

Figma prototype reference: `/Users/development/Downloads/figmaCoffe`

Important: the current Figma-derived design is the Social Refresh system:
- Mint `#53B8A6`
- Pressed mint `#3D8D7A`
- Lavender `#8E7DBE`
- Peach `#E88C6B`
- Warm background `#F6F1EB`
- Card surface `#FFFDF9`
- Secondary surface `#F4F4F8`
- Text primary `#243447`
- Text secondary `#5F6368`
- Border `#E7DED4`

Do not use older blue/coral/placeholder design documents as implementation truth.

---

## Tech Stack

- Frontend: SwiftUI iOS app in `apps/frontend/Coffee_Call`
- Backend: Firebase Auth, Firestore, Cloud Messaging, Storage
- Geolocation: CoreLocation
- Notifications: Firebase Cloud Messaging

---

## Core Product Constraints

- Async messaging only.
- Posts stay active after acceptance.
- Group meetups are allowed.
- No direct person-to-person pings, cold outreach, or random DM entry points.
- The Around screen should convert ambient interest into a Drift, not expose people for unsolicited contact.
- No phone exchange in MVP.
- 10km radius fixed unless the product spec changes.
- No scoring, reputation, reviews, penalties, follow/friend graph, or dating mechanics in MVP.

---

## Coding Rules

- Code changes are allowed in the current phase.
- Keep changes scoped to the user request.
- Use semantic SwiftUI color tokens from `Color+Extensions.swift`.
- Use typography helpers from `Font+Extensions.swift` where practical.
- Do not hardcode visual tokens inside screens unless adding a new token is not justified.
- Do not use `.rounded` fonts unless Figma changes to require it.
- If design tokens change, update `Design/design-tokens.md` in the same session.
- After meaningful work, append a compact entry to `Planning/context.md`.

---

## SwiftUI Design Gotchas

- For page `TabView`, do not apply `.ignoresSafeArea()` to the entire `TabView`.
- For full-screen onboarding imagery, place the image/gradient in a background layer behind the `TabView` and apply `.ignoresSafeArea()` only to that background layer.
- Keep navigation rooted in the main app container; avoid nested `NavigationStack` unless there is a clear reason.
- Use `.toolbar(.hidden, for: .navigationBar)` to hide navigation chrome instead of safe-area hacks.

---

## Build Notes

- Use Xcode for the iOS app in `apps/frontend/Coffee_Call`.
- Firebase package cycles can be caused by malformed build phases or target membership; check `docs/Planning/build-guidelines.md`.
- Clean DerivedData when Xcode keeps stale package/build metadata.

---

## Shared Session Log

All AI tools should use `Planning/context.md` as the rolling session log.

Rules:
- Put newest session at the top.
- Include what changed, why, files updated, and verification.
- Keep entries short.
- Do not rewrite old session history unless the user asks.

---

## What Not To Do

- Do not modify `DiscoveryScreen.swift` or `DiscoveryViewModel.swift` (Around screen is locked).
- Do not treat old prompt-generation docs as current implementation rules.
- Do not use the old blue/coral design palette.
- Do not change architecture without updating `Planning/decisions.md`.
- Do not commit unless the user asks.
- Do not reset, stash, or discard work unless the user asks.
