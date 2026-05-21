# CoffeeCall Architecture

Status: ACTIVE
Last updated: 2026-05-16

## System Overview

CoffeeCall is a native SwiftUI iOS app backed by Firebase. The MVP focuses on one platform, one backend, and a tight Drift lifecycle:

create Drift -> nearby discovery -> join/accept -> confirm -> message -> meet.

## Frontend

- Platform: iOS.
- Framework: SwiftUI.
- Main UI shell: floating bottom navigation with Around, Drifts, Create, Chats, and You.
- Design implementation must use semantic color and typography helpers already present in the SwiftUI app where practical.
- Avoid nested navigation stacks unless a screen genuinely needs an isolated stack.
- Keep full-screen background treatment behind paged content; do not apply full safe-area ignoring to pager containers.

## Backend

- Firebase Authentication for phone signup.
- Firestore for users, Drifts/posts, acceptances, and messages.
- Firebase Storage for profile images.
- Firebase Cloud Messaging for nearby Drift notifications.
- Cloud Functions for notification and acceptance side effects.

## Data Model

Core collections:

```text
users
  uid
  phoneNumber
  name
  profilePhotoUrl
  lastLocation
  lastLocationGeoHash
  lastLocationUpdate
  createdAt

posts
  creatorId
  purpose
  location
  locationGeoHash
  time
  hookText
  interestTags
  createdAt
  expiresAt
  isActive
  participantCount

acceptances
  postId
  acceptorId
  acceptedAt
  status

messageThreads
  postId
  participants
  createdAt

messageThreadMessages
  senderId
  text
  timestamp
```

The product may call user-facing posts "Drifts"; storage can keep the existing collection naming until a deliberate migration is planned.

## Discovery

- Discovery radius is fixed at 10 km.
- Location queries use geohashing-friendly data.
- Around shows ambient signals and category counts.
- Around radar may use nearby user presence as an anonymous ambient signal.
- Around radar presence uses explicit one-time snapshots cached in the UI, not a continuous live user listener.
- Current-user location refreshes are one-shot and should be throttled to a one-hour interval, with manual radar refresh allowed to force a fresh location request.
- Drifts listing shows concrete nearby meetups.
- Radar initials are not public profiles and must not provide direct contact entry points.

## Messaging

- Messaging is async and Drift-tied.
- Chat unlocks only after joining or hosting a Drift.
- No standalone direct message entry point exists in MVP.
- Message delivery can be near-real-time or polled as implementation allows, but product behavior remains async coordination.

## Notifications

- Drift creation can trigger nearby notifications within 10 km.
- Acceptance can notify the host.
- Notifications should open into Around or the relevant Drift context.

## Build And Verification

- Use Xcode for iOS app builds.
- Clean DerivedData when Xcode shows stale package or build metadata.
- Firebase package cycles usually indicate malformed build phases, package state, or target membership issues.
- Documentation-only changes should not modify Swift, Firebase, Xcode, or generated project files.
