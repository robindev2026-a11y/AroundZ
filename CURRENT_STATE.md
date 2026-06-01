# CURRENT STATE - CoffeeCall

## Project Overview
CoffeeCall is an activity-based meetup app where users create "Drifts" (activities), others join, and coordination happens via in-app messages.
- **Goal:** Activity first, person second.
- **Unit of Action:** The Drift.

## Active Focus
- Resolving lingering bugs: sharing, reminders, profile photo features.
- Validating full flows (Around -> Drift -> Join -> Chat).
- Performance optimizations for Radar and Chat unread pulse dots.

## Architecture & Tech Stack
- **Frontend:** SwiftUI (using Skip for Kotlin transpilation) in `apps/frontend`.
- **Backend:** Firebase (Auth, Firestore, Storage, Messaging, Functions).
- **Store:** `GlobalDriftStore` (SwiftUI-native `@EnvironmentObject`) handles Firestore syncing and local caching.
- **Geohashing:** Used for location-based discovery (10km fixed radius).

## Non-Negotiables (Product Principles)
- No cold direct messages.
- No person browsing from Around (profiles hidden until Drift context).
- Chat only after joining/hosting a Drift.
- No phone number exchange in MVP.
- Async messaging only (2-5 sec latency).
- Posts stay active after acceptance (group support).
- Online/Offline presence toggle for Radar.

## Engineering Conventions
- **Naming:** camelCase (variables), PascalCase (Classes), UPPER_SNAKE_CASE (constants).
- **Structure:** Vertical slices per feature.
- **SwiftUI:** Pure stateless zero-exception architecture. Avoid `AnyView`, prefer generic composition and `@ViewBuilder`.
- **Validation:** User validates all builds; agents do NOT run `xcodebuild` or simulators.

## Active Goals
1. [Bugs] Fix sharing and reminder stubs.
2. [UI] Finalize Social Refresh UX in Around screen.
3. [Safety] Resilient "Leave Flow" implemented (Awaiting User Verification).

## Known Issues / Open Decisions
- Internal web admin panel planned for post-MVP.
- Swift access specifier audit and `final` keyword cleanup needed.
