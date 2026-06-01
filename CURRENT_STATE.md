# CURRENT STATE - CoffeeCall

## Project Overview
CoffeeCall is a native SwiftUI iOS app (using Skip for Kotlin transpilation) backed by Firebase.
- **Mission:** Activity-first, person-second social meetup platform.
- **Drift Lifecycle:** Create -> Nearby Discovery -> Join/Accept -> Confirm -> Message -> Meet.

## Active Focus
- **Priority:** Resolving lingering bugs in sharing and reminder stubs.
- **Safety:** Resilient "Leave Flow" implemented (Awaiting User Verification).
- **UX:** Finalizing Social Refresh UX in Around screen.

## Architecture & Tech Stack
- **Frontend:** SwiftUI (Skip) in `apps/frontend`.
- **Backend:** Firebase (Auth, Firestore, Storage, Functions).
- **Primary Pattern:** Vertical slices; pure stateless SwiftUI; zero-exception architecture.
- **Data Model:**
  - `users`: Profile, lastLocation (geohash), isRadarVisible.
  - `posts` (Drifts): creatorId, purpose, location, hook, participants, spotsLeft.
  - `acceptances`: Join request tracking (postId, acceptorId, status).
  - `messageThreads`: Drift-tied conversations.
- **Discovery:** 10km fixed radius geohashing. Around radar uses anonymous ambient signals (initials/interests).

## Design System (The Design Contract)
- **Personality:** Warm, social, premium, native iOS. NOT a dating app.
- **Colors (Assets only):**
  - `coffeePrimary` (#53B8A6): Mint accents/actions.
  - `coffeePurple` (#8E7DBE): Secondary lavender accent.
  - `coffeePeach` (#E88C6B): Warm peach accent.
  - `coffeeBackground` (#F6F1EB): Main background.
- **Typography:** Outfit (Headlines/Buttons) + SF Pro (Body/Metadata).
- **Engineering Rules:**
  - No raw HEX strings; use `AppColors.swift`.
  - No hardcoded paddings; use `AppConstants.Layout` tokens.
  - Mandatory Dynamic Type support; use `@ScaledMetric` for spacing.

## Product Guardrails (Non-Negotiables)
- **Activity-First:** Profiles hidden until Drift context.
- **No Cold DMs:** Chat unlocks only after joining/hosting a Drift.
- **Privacy:** No phone numbers in MVP; Radar uses anonymous initials.
- **Maps:** 500m radius ring pre-join; precise pin + "Open in Maps" post-join.

## Engineering Conventions
- **Naming:** camelCase (variables), PascalCase (Classes), UPPER_SNAKE_CASE (constants).
- **Navigation:** Floating glass bottom nav; avoid nested stacks.
- **Validation:** User validates all builds; agents do NOT run `xcodebuild`.
- **Commits:** Use the standalone local AI commit tool `/Users/robingeorge/Documents/Projects/AICommit/ai_commit.py` to draft, review, and push git commits for project changes. Do not commit manually if the tool is available.

## Open Issues (Screen Ledger)
- **Around:** Issue-039 (Notification icon/data), Issue-040 (Notification sheet), Issue-041 (Location refresh).
- **Drifts:** Issue-042 (Radius filter verification).
- **Create:** Issue-055 (Layout overflow), Issue-056 (Map picker implementation).
- **Chat:** Issue-053 (View Drift back-nav), Issue-054 (Inline image rendering).
- **Detail:** Issue-012 (Share/Reminder stubs), Issue-044 (Map preview implementation), Issue-049 (iOS 16.2 simulator freeze).
- **Profile:** Issue-022 (Image capture/upload flow).

## Known Issues / Open Decisions
- Internal web admin panel planned post-MVP.
- Swift access specifier audit and `final` keyword cleanup needed.
