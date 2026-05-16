# CoffeeCall

CoffeeCall is an activity-based meetup app for nearby spontaneous plans.

## Active Documentation

Use only the active docs in `docs/current/`:

- `docs/current/CONTEXT.md`
- `docs/current/PLAN.md`
- `docs/current/ARCHITECTURE.md`
- `docs/current/DESIGN.md`
- `docs/current/STATUS.md`

Agent starter files:

- `AGENTS.md`
- `CODEX.md`
- `CLAUDE.md`
- `ANTIGRAVITY.md`

Historical markdown has been archived under `docs/archive/2026-05-16-md-reset/` and is not current guidance.

## Stack

- iOS frontend: SwiftUI.
- Backend: Firebase Auth, Firestore, Cloud Messaging, Storage, and Functions.

## Repo Layout

```text
apps/frontend/      SwiftUI iOS app
apps/backend/       Firebase backend
docs/current/       Active project documentation
docs/archive/       Historical documentation
```

## Working Rule

Before changing UI or product behavior, read the active docs and ignore archive files unless the user explicitly asks for historical context.
