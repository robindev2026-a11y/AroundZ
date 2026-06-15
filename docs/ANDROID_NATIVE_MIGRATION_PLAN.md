# CoffeeCall Native Android Migration Plan

## Decision
CoffeeCall will keep the existing SwiftUI iOS app and add a separate native Android app written in Kotlin and Jetpack Compose.

Skip is not the active migration path. The current iOS app is a normal Xcode project, not a Skip project: there is no `Package.swift`, `Skip.env`, generated `Android/` folder, or `Sources/*/Skip/skip.yml`. The iOS app also uses several iOS-only APIs and SDKs (`UIKit`, `UIApplication`, `MapKit`, `PhotosUI`, `UserNotifications`, Firebase iOS SDKs), so a native Android implementation is the cleaner route for a reliable Android release.

## Current Repo State
- iOS app: `apps/frontend/Coffee_Call.xcodeproj`
- iOS source: `apps/frontend/Coffee_Call`
- Backend config/rules: `apps/backend`
- Android app home: `apps/android`
- Backend: Firebase Auth, Firestore, Storage, Functions
- Product lifecycle: Create Drift -> Nearby Discovery -> Join/Accept -> Confirm -> Message -> Meet

## Target Architecture
The repo will contain two first-class clients that share backend contracts:
- `apps/frontend`: existing SwiftUI iOS app.
- `apps/android`: new Kotlin + Jetpack Compose Android app.
- `apps/backend`: shared Firebase project, Firestore rules, Storage rules, Functions, indexes.

Android should mirror the iOS user-facing behavior, not copy iOS implementation details. Keep shared concepts aligned through Firestore schemas, naming, and product rules.

## Android Tech Stack
- Language: Kotlin
- UI: Jetpack Compose + Material 3
- Architecture: MVVM with feature packages
- Async: Kotlin coroutines + Flow
- DI: Hilt
- Navigation: Jetpack Navigation Compose
- Backend: Firebase Auth, Firestore, Storage, Cloud Messaging when needed
- Location: Google Play Services Location
- Maps: Google Maps Compose
- Images: Coil
- Local storage: DataStore for preferences
- Testing: JUnit, Turbine, MockK, Compose UI tests
- Build: Gradle Kotlin DSL

## Package Layout
Use this layout inside `apps/android/app/src/main/java/.../coffeecall`:

```text
app/
  CoffeeCallApplication.kt
  MainActivity.kt
core/
  common/
  design/
  firebase/
  location/
  navigation/
  permissions/
  storage/
domain/
  model/
  repository/
  usecase/
data/
  mapper/
  remote/
  repository/
feature/
  auth/
  onboarding/
  discovery/
  create/
  drifts/
  driftDetail/
  chat/
  profile/
```

## Shared Backend Contracts
Android must use the same Firestore collections as iOS:
- `users`
- `posts`
- `acceptances`
- `messageThreads`

Android agents must verify field names against the Swift models and Firebase service files before implementing each feature. Do not introduce parallel Android-only collection names unless the backend plan explicitly changes.

## Product Guardrails
- Activity-first: profiles stay hidden until there is Drift context.
- No cold DMs: chat opens only after hosting or joining a Drift.
- Privacy: no phone numbers shown in MVP; radar shows anonymous initials/interests.
- Maps: approximate 500m radius before joining; precise pin and external maps after join/accept.
- Android should feel native Android, not like an iOS skin.

## Implementation Batches

### Batch 0 - Project Scaffold
Goal: create a buildable Android skeleton.

Steps:
1. Create Android Studio project under `apps/android`.
2. Use Kotlin, Compose, Material 3, minSdk 26 or higher.
3. Add Gradle Kotlin DSL.
4. Add app id, for example `com.coffeecall.app` unless the release id is confirmed.
5. Add packages from the target architecture section.
6. Add placeholder screens for Auth, Discovery, Create, Drifts, Chat, Profile.
7. Add basic `CoffeeCallTheme` matching brand colors.
8. Add `.gitignore` entries for Android build outputs if missing.

Acceptance checks:
- `./gradlew assembleDebug` succeeds from `apps/android`.
- App launches to a placeholder shell on emulator.
- Navigation between placeholder tabs works.

### Batch 1 - Design System And App Shell
Goal: reproduce CoffeeCall's core visual language natively in Compose.

Steps:
1. Port brand tokens from `AppColors.swift` and `AppConstants.swift`.
2. Create Compose color, typography, spacing, shape, and elevation tokens.
3. Build reusable components: primary button, pill badge, activity chip, drift card, empty state, loading state, top app bar, bottom nav.
4. Implement the main authenticated app shell with bottom navigation.
5. Keep components screen-density friendly and Dynamic Type/font-scale safe.

Acceptance checks:
- Screens adapt at 320dp width, common phone width, and large phone width.
- No text clipping in buttons/cards.
- Core components have preview functions.

### Batch 2 - Firebase Foundation
Goal: connect Android to the same backend safely.

Steps:
1. Add Firebase Android Gradle plugin and dependencies.
2. Add `google-services.json` outside source control if it contains real secrets/config.
3. Implement Firebase initialization.
4. Create Firestore DTOs and mappers for `users`, `posts`, `acceptances`, `messageThreads`.
5. Create repository interfaces in `domain/repository`.
6. Create Firebase-backed repository implementations in `data/repository`.
7. Add emulator/test configuration notes.

Acceptance checks:
- App starts with Firebase initialized.
- Repository smoke tests can read/write against emulator or configured dev project.
- Field names match iOS service usage.

### Batch 3 - Auth And Onboarding
Goal: support the same login/onboarding decisions as iOS.

Steps:
1. Implement Auth screen flow.
2. Implement phone auth or the chosen MVP auth method using Firebase Auth for Android.
3. Implement onboarding state with DataStore.
4. Create user profile document on new account.
5. Route returning users past profile setup.
6. Mirror iOS behavior where sign-out users skip marketing slides after first completion.

Acceptance checks:
- New user can authenticate and lands in onboarding/profile setup.
- Returning user lands in the app shell.
- Sign out clears local session state correctly.

### Batch 4 - Discovery/Around
Goal: show nearby Drifts and anonymous radar presence.

Steps:
1. Implement location permission request flow.
2. Implement location provider and last-known/current location retrieval.
3. Implement 10km discovery query using existing geohash strategy.
4. Implement Discovery screen list/cards.
5. Implement Around radar using anonymous initials/interests.
6. Add pull-to-refresh/on-demand fetch behavior to avoid excessive Firestore billing.

Acceptance checks:
- Permission denied, limited/unavailable, and granted states are handled.
- Nearby Drifts load from `posts`.
- Radar does not expose private profile details.

### Batch 5 - Create Drift
Goal: create Drifts compatible with the iOS app.

Steps:
1. Implement create form with activity, hook, time, location, spots, and join mode.
2. Implement Google Places or map picker equivalent.
3. Validate required fields before submit.
4. Write Drift document to `posts`.
5. Create related message thread if iOS expects it at creation time.
6. Navigate to the created Drift or Drifts screen after success.

Acceptance checks:
- A Drift created on Android appears correctly on iOS.
- A Drift created on iOS appears correctly on Android.
- Invalid form states cannot write partial documents.

### Batch 6 - Drift Detail And Join Flow
Goal: implement view, join, accept, leave, share, and maps behavior.

Steps:
1. Implement Drift Detail screen.
2. Show approximate map/radius before join.
3. Show precise location and external maps action after accepted/joined.
4. Implement open join mode and request-to-join mode.
5. Implement host accept/reject of pending requests.
6. Implement leave flow with the same write order as the iOS resilient leave flow.
7. Implement basic share intent.

Acceptance checks:
- Android join/leave state stays consistent with iOS.
- Firestore security rules allow intended writes only.
- Detail screen recovers from partial network failures.

### Batch 7 - Chat
Goal: support Drift-tied messaging.

Steps:
1. Implement chat thread list.
2. Implement Drift chat screen.
3. Subscribe to `messageThreads` messages with realtime updates.
4. Send text messages.
5. Add image message support if still in MVP.
6. Enforce no cold DMs in navigation and repository checks.

Acceptance checks:
- Messages sent on Android appear on iOS.
- Messages sent on iOS appear on Android.
- Users outside the Drift cannot open/send to the thread.

### Batch 8 - Profile And Media
Goal: implement profile setup/edit and profile image flow.

Steps:
1. Implement profile setup.
2. Implement profile edit.
3. Implement image picker and optional camera capture.
4. Upload profile images to Firebase Storage.
5. Store download URL/path in user profile.
6. Keep profile visibility aligned with activity-first guardrails.

Acceptance checks:
- Android profile data appears correctly in iOS context cards.
- Image uploads are readable by iOS.
- Storage rules remain private enough for MVP.

### Batch 9 - Notifications, Reminders, And Polish
Goal: complete native Android platform integrations.

Steps:
1. Add notification permission flow for Android 13+.
2. Add FCM groundwork if push notifications are in scope.
3. Implement local reminders if they remain in MVP.
4. Implement deep links if needed for Drift shares.
5. Add empty/error/offline states across major screens.
6. Add performance pass for Firestore listener count and image loading.

Acceptance checks:
- Android 13+ notification permission is handled.
- No major flow is blocked by placeholder UI.
- App remains usable with transient network failures.

### Batch 10 - Release Readiness
Goal: prepare for internal testing and Play Store path.

Steps:
1. Add release signing plan; do not commit private keystores.
2. Configure build variants for dev/staging/prod if needed.
3. Add Proguard/R8 rules for Firebase/Compose as needed.
4. Add crash reporting/analytics decision.
5. Add internal QA checklist.
6. Produce debug APK/AAB and test on emulator plus at least one real Android device.

Acceptance checks:
- `assembleDebug` and release build task succeed.
- Smoke test checklist passes.
- Backend rules and indexes are deployed/compatible.

## Cross-Agent Work Rules
- Each agent must read `AI.md`, `CURRENT_STATE.md`, `CHANGELOG.md`, and this plan before coding.
- Work one batch at a time unless the user explicitly asks for multiple batches.
- Before changing a schema, compare Swift iOS services and backend rules.
- Do not rename Firestore fields casually.
- Keep Android code native Compose; do not introduce Skip, Flutter, React Native, or web views.
- Update this plan after every completed batch.
- Append `CHANGELOG.md` after meaningful architecture, product, or scope changes.
- Update `CURRENT_STATE.md` when the source of truth changes.

## First Recommended Next Step
Start Batch 0 by creating the Android Studio/Gradle Compose project in `apps/android`, then commit only the scaffold and placeholder app shell. After that, Batch 1 can proceed independently on design-system parity.
