# CoffeeCall: AI Execution Context

**Current phase:** Coding and verification
**Last updated:** 2026-05-13

This file is for AI tools that need project context. It supersedes the older planning-only workflow.

---

## Current Workflow

1. Read `Planning/context.md` for the latest session state.
2. Read `AGENTS.md` for active working rules.
3. For product behavior, use `Planning/spec.md`, `Planning/architecture.md`, and `Planning/decisions.md`.
4. For visual implementation, use `Design/design-tokens.md`, `Design/design-system.md`, `Design/screens.md`, and `Design/component-specs.md`.
5. For Figma parity, compare against `/Users/development/Downloads/figmaCoffe`.
6. Make scoped code/doc changes only for the user-requested task.
7. Log meaningful changes in `Planning/context.md`.

---

## Active Design Direction

CoffeeCall follows the Figma Social Refresh direction:

- Warm neutral app background.
- Mint primary actions.
- Lavender and peach accents.
- Slate text.
- Layered cards.
- Full-bleed photographic onboarding where Figma uses background images.
- Native iOS default system typography, not rounded fonts.

Active tokens:
- Primary mint: `#53B8A6`
- Pressed mint: `#3D8D7A`
- Lavender: `#8E7DBE`
- Peach: `#E88C6B`
- Background: `#F6F1EB`
- Card surface: `#FFFDF9`
- Secondary surface: `#F4F4F8`
- Text primary: `#243447`
- Text secondary: `#5F6368`
- Border: `#E7DED4`

Do not use the older blue/coral MVP palette.

---

## Product Summary

CoffeeCall is an activity-based meetup app. Users post activities, nearby people join, and participants coordinate through in-app messages.

Core constraints:
- Not a dating app.
- Async messaging only.
- Posts stay active after acceptance.
- Group meetups are allowed.
- No phone number exchange in MVP.
- No reputation/scoring/friend system in MVP.
- Firebase backend, SwiftUI iOS frontend.

---

## Important Files

| File | Use |
|---|---|
| `AGENTS.md` | Active AI working rules |
| `Planning/context.md` | Latest session log |
| `Planning/spec.md` | Product requirements |
| `Planning/architecture.md` | System architecture |
| `Planning/decisions.md` | Decision records |
| `docs/Planning/build-guidelines.md` | Xcode/Firebase gotchas |
| `Design/design-tokens.md` | Active visual tokens |
| `Design/design-system.md` | Current design philosophy |
| `Design/screens.md` | Screen direction |
| `Design/component-specs.md` | Component direction |
| `apps/frontend/Coffee_Call/DESIGN_CONTEXT.md` | Frontend design context |

---

## Notes For Implementation

- Code changes are allowed in this phase.
- Keep scope tight.
- Use semantic design tokens from Swift files.
- Do not hardcode old design values.
- Do not use old prompt-generation docs as current instructions.
- Avoid nested navigation stacks unless required.
- For onboarding `TabView`, keep full-screen backgrounds behind the pager, not applied to the pager itself.
