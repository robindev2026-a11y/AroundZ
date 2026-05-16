---
version: 1.0.0
author: Codex
date: 2026-05-10
status: historical
model: gpt-5.5
parameters:
  temperature: 0.5
  max_tokens: 4000
description: Backend code generation for Firebase Cloud Functions
tested_with: Firebase Emulator, Jest
---

# CoffeeCall Backend Prompt

Historical note: this prompt belongs to the earlier prompt-generation phase. Do not use it as current execution guidance unless the user explicitly asks to regenerate backend code from prompts.

You are generating the backend for CoffeeCall MVP. Build a production-ready Firebase backend in `apps/backend/` using TypeScript and Firebase Cloud Functions. Read and follow:

- `Planning/spec.md`
- `Planning/architecture.md`
- `Planning/decisions.md`
- `Planning/features.md`

If any detail is ambiguous, prefer the documented MVP constraints over adding scope.

## Product Summary

CoffeeCall is an activity-based meetup platform, not a dating app. Users create activity posts, nearby users are notified within a fixed 10km radius, users accept or reject posts, acceptance opens an in-app message thread, and posters can see all acceptances in a dashboard.

## Non-Negotiable MVP Constraints

- Posts stay active after the first acceptance. Do not auto-close posts.
- Messaging is async only. Do not implement WebSockets or real-time chat semantics.
- No phone number exchange in MVP. Do not expose raw phone numbers to other users.
- 10km radius is fixed. Do not make it configurable.
- No scoring, reputation, reviews, penalties, or friend/follow systems.
- No maps UI or map-based query experience in backend logic.

## Target Stack

- Firebase Authentication for phone signup.
- Firestore for persistence.
- Cloud Functions for all server-side logic.
- Firebase Cloud Messaging for notifications.
- Firebase Storage only if the backend needs to support profile photo upload flows or signed upload coordination.
- TypeScript strict mode.
- Jest or the project test runner used by the generated backend.
- Firebase Emulator support for local testing.

## Required Firestore Model

Implement the documented logical collections and fields. If you need to split public and private user data to satisfy Firestore security limitations, do so without changing the product behavior.

### `/users/{userId}`

Logical fields:

- `uid`
- `phoneNumber`
- `name`
- `profilePhotoUrl`
- `lastLocation`
- `lastLocationGeoHash`
- `lastLocationUpdate`
- `createdAt`

Privacy requirement:

- Other users must not be able to read raw phone numbers.
- Other users must not be able to read raw location history.
- The public-facing backend responses must include only the fields needed for discovery and dashboards.

### `/posts/{postId}`

Fields:

- `creatorId`
- `purpose`
- `location`
- `locationGeoHash`
- `time`
- `createdAt`
- `expiresAt`
- `isActive`
- `acceptanceCount`

### `/acceptances/{acceptanceId}`

Fields:

- `postId`
- `acceptorId`
- `acceptedAt`
- `status`

Use a uniqueness strategy so the same user cannot accept the same post twice.

### `/messageThreads/{threadId}`

Fields:

- `postId`
- `participants`
- `createdAt`

### `/messageThreads/{threadId}/messages/{messageId}`

Fields:

- `senderId`
- `text`
- `timestamp`

## Cloud Function API Contract

Implement these callable or HTTP endpoints with clear validation, auth checks, and structured error responses.

### `POST /createPost`

Responsibility:

- Validate authenticated user.
- Validate required input: purpose, latitude, longitude, time.
- Normalize and geohash the location.
- Write the post document.
- Set `isActive` to `true`.
- Set `acceptanceCount` to `0`.
- Set `createdAt` and `expiresAt` with a 24 hour TTL policy.
- Persist any derived values needed for discovery.
- Trigger notifications for users within the 10km radius.

Behavior:

- Reject invalid payloads with 400-level errors.
- Reject unauthenticated requests.
- Never require real-time client listeners.
- Return `postId` and a success status.

### `POST /acceptPost`

Responsibility:

- Validate authenticated user.
- Validate `postId`.
- Verify the post exists and is active.
- Prevent duplicate acceptance by the same user.
- Create an acceptance record.
- Create or reuse a message thread for the post and acceptor relationship.
- Increment the post acceptance count atomically.
- Notify the poster that a new acceptance happened.

Behavior:

- The post remains active after acceptance.
- Multiple users may accept the same post.
- Return `acceptanceId` and `threadId`.

### `POST /sendMessage`

Responsibility:

- Validate authenticated sender.
- Validate `threadId` and `text`.
- Verify sender is a participant in the thread.
- Persist the message in the thread subcollection.
- Update any thread metadata required for sorting or last-message display.

Behavior:

- Keep delivery async. The frontend will poll or refresh.
- Return `messageId` and success status.

### `GET /getNearbyPosts`

Responsibility:

- Validate authenticated user and request coordinates.
- Use geohashing and Firestore-friendly querying to find active posts within 10km.
- Exclude expired or inactive posts.
- Return the post summary and only public creator profile fields needed for the discovery UI.

Behavior:

- Do not scan the full collection if avoidable.
- Sort results in a sensible order for the MVP, ideally time ascending or soonest first.

### `GET /getPosterDashboard`

Responsibility:

- Validate authenticated user.
- Return the authenticated user’s posts.
- For each post, return acceptance summaries and acceptor public profile info.
- Support dashboard views that show acceptance counts and acceptance timestamps.

Behavior:

- Only the poster can access their dashboard data.

## Notification Requirements

Use Firebase Cloud Messaging for two notification flows:

1. New post creation within the 10km radius
2. New acceptance for the poster

Requirements:

- Only notify opted-in users.
- Use location-safe targeting logic. Do not expose other users’ precise locations in notification payloads.
- Include only the minimum data needed to deep-link into the relevant in-app screen.
- Keep payloads small and stable.

## Security Rules Expectations

Generate Firestore rules that enforce:

- Authenticated access only where required.
- Users can read and update their own private profile data.
- Users can read active public posts and public profile summaries needed for discovery.
- Only participants can read and write thread messages.
- Only the poster can read dashboard acceptance data for their own posts.
- Clients cannot directly bypass backend validation for sensitive writes.

If the logical data model requires a private/public split to make security rules correct, implement it in a way that preserves the documented user experience.

## Data Integrity Requirements

Use transactions or batched writes where needed for:

- Post creation side effects
- Acceptance creation and thread creation
- Acceptance count updates
- Message thread metadata updates

Prevent duplicate documents, race conditions, and double counts.

## Geolocation Requirements

- Use geohashes for Firestore queries.
- Support fixed 10km radius queries.
- Keep location math server-side or in shared helpers.
- Do not rely on naive full-collection scans.

## Error Handling Requirements

Return structured errors with meaningful codes for:

- unauthenticated
- permission denied
- invalid payload
- post not found
- post inactive
- duplicate acceptance
- thread access denied
- message validation failure
- location validation failure
- notification failure

Prefer deterministic backend behavior over silent failure.

## Testing Requirements

Generate tests for:

- `createPost` success and validation failure cases
- `acceptPost` duplicate prevention and thread creation
- `sendMessage` participant enforcement
- `getNearbyPosts` filtering logic
- `getPosterDashboard` access control
- security rule coverage for read/write boundaries
- notification trigger behavior with mocked Firebase services

All major logic should be testable with Firebase Emulator or isolated unit tests.

## Implementation Structure

Create a clean backend structure under `apps/backend/` with modules for:

- function entry points
- business logic handlers
- Firestore repositories
- geohash/location helpers
- notification service
- auth and validation utilities
- shared types and models

Use naming that is clear and stable. Keep imports sorted. Keep line length reasonable.

## Acceptance Criteria

The generated backend is complete only when:

- All five API endpoints are implemented.
- Firestore schema and security rules match the MVP behavior.
- FCM notifications work for post creation and acceptances.
- Geohash-based discovery supports the fixed 10km radius.
- Async messaging works without real-time listeners.
- Posts remain active after acceptance.
- Phone numbers are not exposed to other users.
- Tests exist and pass in emulator-friendly conditions.

## Deliverable

Generate the backend code only. Do not generate frontend code here. Keep the implementation aligned with `Planning/spec.md` and `Planning/architecture.md`.
