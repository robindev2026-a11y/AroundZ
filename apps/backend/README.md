# CoffeeCall Backend

Status: ACTIVE
Last updated: 2026-05-16

CoffeeCall uses Firebase for the MVP backend.

## Active Docs

Use:

- `../../docs/current/CONTEXT.md`
- `../../docs/current/PLAN.md`
- `../../docs/current/ARCHITECTURE.md`
- `../../docs/current/STATUS.md`

Historical backend prompts and earlier planning notes are archived under `../../docs/archive/2026-05-16-md-reset/` and are not implementation guidance unless the user explicitly asks.

## Backend Scope

- Firebase Authentication for phone signup.
- Firestore for users, posts/Drifts, acceptances, and messages.
- Firebase Storage for profile photos.
- Firebase Cloud Messaging for nearby Drift notifications.
- Cloud Functions for notification and acceptance side effects.

## Working Rule

Before backend changes, confirm behavior against `docs/current/ARCHITECTURE.md` and update `docs/current/STATUS.md` after meaningful work.
