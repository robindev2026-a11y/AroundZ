# CoffeeCall Product And Build Plan

Status: ACTIVE
Last updated: 2026-05-16

## Product Summary

CoffeeCall helps people turn nearby casual interest into real-world meetups. Users create Drifts for activities such as coffee, walks, movies, food, study, gaming, books, or workouts. Nearby users can discover and join those Drifts, then coordinate through in-app messages.

## MVP Goal

Ship a focused iOS MVP that supports:

- Phone signup and profile creation.
- Create sheet as an implemented UX surface launched from the center tab bar action.
- Around discovery with ambient nearby interest.
- Drifts listing for concrete meetups.
- Join or accept flow.
- Async Drift-tied messaging.
- Host management for created Drifts.
- Basic profile/settings surface.

## Product Rules

- Around is ambient discovery, not a people directory.
- Interest should lead to seeing or creating Drifts.
- Chat only exists inside a joined or hosted Drift.
- Exact coordination is unlocked only after joining or acceptance.
- Posts remain active after someone joins.
- Group meetups are allowed.
- Safety and privacy are more important than growth mechanics.

## Current Active Work Order

1. Align Around with the active Social Refresh screen spec.
2. Verify Drifts listing receives navigation from Around.
3. Keep the Create sheet aligned with the active design spec and verify runtime behavior.
4. Align Profile with lightweight identity, participation, privacy, and settings.
5. Align Drift Detail and Chat around post-join coordination.
6. Continue Firebase and build verification after UI flow is stable.

## Active Navigation Model

Primary app destinations:

- Around - ambient nearby activity and interest discovery.
- Drifts - concrete nearby Drifts plus user's hosted/joined Drifts.
- Create - center action opens the Create Drift sheet.
- Chats - Drift-tied conversations only.
- You - profile, settings, privacy, and active involvement.

## MVP Out Of Scope

- Person-to-person cold outreach.
- Public people directory.
- Follow/friend graph.
- Ratings, reviews, score, reputation, or penalties.
- Phone number exchange.
- Real-time chat complexity.
- Payments or coupons as a marketplace.
- Map-first browsing.

## Future Plans

- Build a simple internal web admin panel for moderation, user review, and safety operations after the MVP is stable.
- Keep this panel separate from the consumer app and restrict it with admin-only auth claims.

## Acceptance Criteria

- A new user can sign in, create a profile, and land on Around.
- Around communicates nearby activity without offering direct contact.
- A user can navigate from Around to Drifts.
- The Create action opens the Create Drift sheet from the bottom navigation.
- A user can create a Drift and nearby users can discover it.
- A user can join/accept a Drift and coordinate through chat.
- A host can see and manage involvement in their Drifts.
- UI uses the active Social Refresh design system.
