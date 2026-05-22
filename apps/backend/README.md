# CoffeeCall Backend

Status: ACTIVE
Last updated: 2026-05-16

CoffeeCall uses Firebase for the MVP backend.

## Active Docs

Use:

- `../../docs/CONTEXT.md`
- `../../docs/PLAN.md`
- `../../docs/ARCHITECTURE.md`
- `../../docs/STATUS.md`

## Backend Scope

- Firebase Authentication for phone signup.
- Firestore for users, posts/Drifts, acceptances, and messages.
- Firebase Storage for profile photos.
- Firebase Cloud Messaging for nearby Drift notifications.
- Cloud Functions for notification and acceptance side effects.

## Working Rule

Before backend changes, confirm behavior against `../../docs/ARCHITECTURE.md` and update `../../docs/STATUS.md` after meaningful work.
