# CURRENT STATE - CoffeeCall

## Project Overview
CoffeeCall is a native SwiftUI iOS app backed by Firebase. The Android strategy is now a separate native Kotlin + Jetpack Compose codebase, not Skip.
- **Mission:** Activity-first, person-second social meetup platform.
- **Drift Lifecycle:** Create -> Nearby Discovery -> Join/Accept -> Confirm -> Message -> Meet.

## Active Focus
- **Priority:** Android-first UI redesign matching the Figma "Social Refresh" design (`design-reference/`). Batches 1–4 (tokens, icons, shared components, Discovery screen) are DONE; Batches 5–10 (per-screen rewrites) remain. iOS rollout is LAST.
- **Handoff:** See `docs/ANDROID_UI_REFRESH_HANDOFF.md` — self-contained plan for completing Batches 5–10. Read it before doing UI work.
- **Native Migration Plan:** Completed (Batches 0 through 10 are all Done).
- **QA Checklist:** See `docs/ANDROID_QA_CHECKLIST.md` for release smoke testing.
- **iOS Mapper:** See `docs/IOS_SCREEN_WIDGET_MAPPER.md` for the point-to-point SwiftUI screen/widget responsibility map from Home/Around through Profile.

## Architecture & Tech Stack
- **iOS Frontend:** SwiftUI in `apps/frontend`.
- **Android Frontend:** Native Kotlin + Jetpack Compose app in `apps/android`.
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
- **Android:** Native Kotlin + Jetpack Compose. Do not use Skip for Android unless this decision is explicitly reopened.
- **Commits:** Use the standalone local AI commit tool `/Users/robingeorge/Documents/Projects/AICommit/ai_commit.py` to draft, review, and push git commits for project changes. Do not commit manually if the tool is available.

## Android Migration Status
- Decision made: build a separate native Android app in `apps/android`.
- Planning completed in `docs/ANDROID_NATIVE_MIGRATION_PLAN.md`.
- Agent workflow created in `docs/ANDROID_AGENT_WORKFLOW.md`.
- Sequential batch ledger created in `docs/ANDROID_BATCH_STATUS.md`.
- Batch 0 completed: Android Gradle Kotlin DSL scaffold builds with Compose and Material 3.
- Batch 1 completed: SwiftUI design tokens were ported into Compose with reusable components, previews, polished placeholder screens, top app bar, and floating bottom navigation.
- Batch 2 completed by explicit user request before Batch 1: Firebase Android dependencies, guarded initialization, DTOs, domain models, mappers, and repository skeletons are in place. No real `google-services.json` is committed.
- Batch 3 completed: Firebase Auth + DataStore-backed auth/onboarding routing is in place, including first-launch onboarding, returning-user shell routing, profile setup, sign out, and a documented mock path when Android Firebase config is absent.
- Batch 4 completed: Android location permission flow, Google Play Services location provider, on-demand 10km nearby Drift discovery, and privacy-safe anonymous Around radar are in place.
- Batch 5 completed: Compose Create Drift form, debounced Geocoder search, simulated radar map picker canvas, coordinates confirmation card, validation rules, and iOS-compatible Firestore writes are in place.
- Batch 6 completed: Drift Detail page, approximate pre-join maps, join/request/accept/reject flow, resilient leave transaction, Google Maps directions intent, share sheet, and calendar reminders are in place.
- Batch 7 completed: Chats list screen, real-time message bubble stream (self right-aligned primary color, others left-aligned name/initials, system centered), keyboard imePadding adjustments, sending text/image/location attachments, message deleting, and header drop-down safety actions.
- Batch 8 completed: Profile View and Edit screens, weekly availability switches, category tags chips, hosted/joined stats counters, scrollable past history tabs, geocoder reverse geocoding, photo picker uploading/deletion, and onboarding setup integration.
- Batch 9 completed: Android 13+ POST_NOTIFICATIONS permission prompt dialog, MyFirebaseMessagingService FCM push notifications token registration & channel alerts, deep linking routing (coffeecall://drift/{postId}), network monitor offline banner indicator, empty/error screen states, and Coil image caching integrations are fully in place.
- Batch 10 completed: R8 code obfuscation & resource shrinking enabled, secure release signing configs configured, Proguard rules created, Firebase Crashlytics & Analytics wired in, and a comprehensive release QA checklist written.
- **Android Native Migration is 100% complete!** The app is fully buildable, optimized, and ready for release.

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
