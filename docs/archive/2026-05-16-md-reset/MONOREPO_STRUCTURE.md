# CoffeeCall Monorepo Structure

Status: active. Updated for the coding phase.

---

## Layout

```text
CoffeeCall/
├── AGENTS.md
├── CLAUDE.md
├── README.md
├── Planning/
│   ├── spec.md
│   ├── architecture.md
│   ├── decisions.md
│   ├── features.md
│   └── context.md
├── Design/
│   ├── design-tokens.md
│   ├── design-system.md
│   ├── screens.md
│   └── component-specs.md
├── docs/
│   └── Planning/
│       └── build-guidelines.md
├── Prompts/
│   └── production/
│       ├── backend-prompt.v1.0.0.md
│       └── frontend-prompt.v1.0.0.md
└── apps/
    ├── frontend/
    │   └── Coffee_Call/
    └── backend/
```

---

## Current Phase

Coding and verification.

The old flow of "design finalization → prompt generation → code generation" is no longer the active workflow. Treat old prompt-generation documents as historical unless the user explicitly asks to regenerate from them.

---

## Active Source-Of-Truth Files

| Need | File |
|---|---|
| Latest session state | `Planning/context.md` |
| Product scope | `Planning/spec.md` |
| Architecture | `Planning/architecture.md` |
| Decisions | `Planning/decisions.md` |
| Build gotchas | `docs/Planning/build-guidelines.md` |
| Visual tokens | `Design/design-tokens.md` |
| Visual direction | `Design/design-system.md` |
| Screen direction | `Design/screens.md` |
| Component direction | `Design/component-specs.md` |
| Frontend design context | `apps/frontend/Coffee_Call/DESIGN_CONTEXT.md` |

---

## Active Design Reference

Figma export/prototype:
- `/Users/development/Downloads/figmaCoffe`

Use the Social Refresh design tokens documented in `Design/design-tokens.md`. Do not use older blue/coral or placeholder palette docs.

---

## Application Code

Frontend:
- SwiftUI iOS app lives in `apps/frontend/Coffee_Call`.
- Use Xcode for regular app builds.

Backend:
- Firebase backend lives in `apps/backend`.
- Firebase CLI commands should be run from the correct backend/root context depending on the task.
