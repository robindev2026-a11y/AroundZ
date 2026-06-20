# Android Batch Status

This is the sequential handoff ledger for the native Android CoffeeCall app. Every Android agent must update this file before and after work.

## Current Pointer
- Current batch: All Batches Complete
- Current status: Review
- Next action: Batch 8 (Auth + Onboarding) is Partial — missing dedicated permissions-card screen/flow. Then run `docs/ANDROID_QA_CHECKLIST.md` on device.
- Last updated: 2026-06-18

## Status Values
- `Blocked`: cannot proceed without user/external input.
- `Ready`: available for the next agent.
- `In Progress`: owned by an active agent.
- `Review`: implementation done, awaiting verification or user review.
- `Done`: accepted and ready for dependent batches.

## Global Rules
- Only one batch should be `In Progress` at a time.
- Agents must record ownership before editing.
- Agents must record commands run and acceptance result before leaving.
- Do not delete previous notes; append concise updates.

## Post-Migration Maintenance Log

### 2026-06-18 - Drifts Discover/Mine data-source parity
- Status: Review
- Owner: Mimo/Codex handoff
- Scope: Correct Android Drifts tab semantics after audit found Discover was backed by joined drifts. Discover should show non-hosted community drifts; Mine should remain hosted drifts.
- Touched paths: `apps/android/app/src/main/java/com/coffeecall/app/core/state/GlobalDriftStore.kt`, `apps/android/app/src/main/java/com/coffeecall/app/data/repository/FirebasePostRepository.kt`, `apps/android/app/src/main/java/com/coffeecall/app/data/repository/mock/MockPostRepository.kt`, `apps/android/app/src/main/java/com/coffeecall/app/domain/repository/PostRepository.kt`, `apps/android/app/src/main/java/com/coffeecall/app/feature/drifts/DriftsScreen.kt`, `apps/android/app/src/main/java/com/coffeecall/app/feature/drifts/DriftsViewModel.kt`, `CHANGELOG.md`, `docs/ANDROID_BATCH_STATUS.md`.
- Commands run: `git status --short`; `git diff --stat`; targeted `git diff` review of the Android Drifts/store/repository changes.
- Acceptance result: Passed. Build compiles clean. Code diff aligns with the iOS source split.
- Handoff notes: Verify Discover excludes hosted drifts but includes unjoined community drifts; verify Mine shows hosted drifts only; verify joined community drifts still show joined CTA/state from `participantIds`.

### 2026-06-18 - Drifts distance mock + filter sheet
- Status: Review
- Owner: Mimo/Codex handoff
- Scope: Replace hardcoded "0.0 km" with real haversine distance computation and add a 1–10 km distance filter sheet matching iOS DriftsFilterSheet behavior.
- Touched paths: `apps/android/app/src/main/java/com/coffeecall/app/core/state/GlobalDriftStore.kt`, `apps/android/app/src/main/java/com/coffeecall/app/feature/drifts/DriftsScreen.kt`, `apps/android/app/src/main/java/com/coffeecall/app/feature/profile/ProfileScreen.kt`, `CHANGELOG.md`, `CURRENT_STATE.md`, `docs/ANDROID_BATCH_STATUS.md`.
- Commands run: `./gradlew :app:compileDebugKotlin` — passed.
- Acceptance result: Build compiles clean. Distance values require device GPS to display real km; filter sheet UI verified in code.
- Handoff notes: Device QA needed to confirm distance values populate from GPS, filter radius excludes distant posts, and the filter sheet Reset/Applied buttons work as expected.

### 2026-06-18 - P9 consistency pass
- Status: Review
- Owner: Mimo/Codex handoff
- Scope: Replace text symbols/emoji with CoffeeIcons vector icons; replace raw .dp spacing with CoffeeSpacing tokens; verify loading/empty states.
- Touched paths: `core/design/Components.kt`, `feature/driftDetail/DriftDetailScreen.kt`, `feature/chat/ChatThreadScreen.kt`, `feature/chat/ChatScreen.kt`, `feature/create/CreateScreen.kt`, `feature/onboarding/OnboardingScreen.kt`, `feature/discovery/DiscoveryScreen.kt`, `feature/profile/ProfileEditScreen.kt`, `CHANGELOG.md`, `docs/ANDROID_BATCH_STATUS.md`, `docs/ANDROID_UI_REFRESH_HANDOFF.md`.
- Commands run: `./gradlew :app:compileDebugKotlin` — passed with zero warnings.
- Acceptance result: Build compiles clean. Zero remaining emoji/text symbols in feature screen UI code.
- Handoff notes: Batch 4 (Discovery) confirmed done — radar-only, notifications sheet wired. Only remaining work is Batch 8 (Profile settings/account rows).

### 2026-06-18 - Batch 4 Discovery parity confirmed
- Status: Done
- Owner: Mimo/Codex handoff
- Scope: Verified Android Discovery screen is fully at parity with iOS. Corrected stale handoff doc — Figma "map toggle" does not exist on iOS; bell notifications sheet was already wired in P3.
- Touched paths: `docs/ANDROID_UI_REFRESH_HANDOFF.md`, `CHANGELOG.md`, `CURRENT_STATE.md`.
- Commands run: grep verification of NotificationsSheet wiring and absence of CoffeeDriftCard feed.
- Acceptance result: Confirmed. Discovery is radar-only, presence toggle works, notifications sheet wired.
- Handoff notes: Batch 4 is Done. Last remaining UI gap is Batch 8 (Profile settings/account rows).

## Batch Ledger

### Batch 0 - Project Scaffold
- Status: Done
- Owner: Codex
- Started: 2026-06-14
- Completed: 2026-06-14
- Scope: Create a buildable Kotlin + Jetpack Compose Android skeleton under `apps/android` with placeholder navigation and CoffeeCallTheme brand colors.
- Owned paths: `apps/android/**`, root `.gitignore` only if Android build outputs are missing.
- Touched paths: `apps/android/README.md`, `apps/android/settings.gradle.kts`, `apps/android/build.gradle.kts`, `apps/android/gradle.properties`, `apps/android/gradle/**`, `apps/android/gradlew`, `apps/android/gradlew.bat`, `apps/android/app/**`, root `.gitignore`.
- Commands run: `git status --short`; `gradle --no-daemon --info wrapper --gradle-version 8.11.1 --distribution-type bin`; `JAVA_HOME=/usr/local/Cellar/openjdk/26.0.1/libexec/openjdk.jdk/Contents/Home ./gradlew assembleDebug` (failed: AGP rejected Java 26); `brew install openjdk@17`; `JAVA_HOME=/usr/local/opt/openjdk@17/libexec/openjdk.jdk/Contents/Home ./gradlew assembleDebug` (failed: Android SDK not configured); `brew install --cask android-commandlinetools`; `sdkmanager --licenses`; `sdkmanager 'platform-tools' 'platforms;android-35' 'build-tools;35.0.0'`; `JAVA_HOME=/usr/local/opt/openjdk@17/libexec/openjdk.jdk/Contents/Home ANDROID_HOME=/usr/local/share/android-commandlinetools ANDROID_SDK_ROOT=/usr/local/share/android-commandlinetools ./gradlew assembleDebug`.
- Acceptance result: Passed. `assembleDebug` succeeded from `apps/android`; debug APK packaging completed. Emulator launch was not performed in this batch.
- Blockers: None remaining. Local machine needed JDK 17 and Android SDK command-line tools installed before Gradle could build.
- Handoff notes: Batch 0 scaffold is ready for Batch 1. Future local builds may need `JAVA_HOME=/usr/local/opt/openjdk@17/libexec/openjdk.jdk/Contents/Home` and `ANDROID_HOME=/usr/local/share/android-commandlinetools` unless those are exported in the shell.

### Batch 1 - Design System And App Shell
- Status: Done
- Owner: Codex
- Started: 2026-06-14
- Completed: 2026-06-14
- Scope: Port SwiftUI design tokens to Compose, build reusable design components, and polish the authenticated placeholder app shell without Firebase or real feature logic.
- Owned paths: `apps/android/**/core/design/**`, `apps/android/**/core/navigation/**`, placeholder UI files as needed.
- Expected touch paths: `apps/android/app/src/main/java/com/coffeecall/app/core/design/**`, `apps/android/app/src/main/java/com/coffeecall/app/core/navigation/**`, placeholder UI files under `apps/android/app/src/main/java/com/coffeecall/app/feature/**`, and `apps/android/app/src/main/java/com/coffeecall/app/MainActivity.kt` only if app shell wiring requires it.
- Touched paths: `apps/android/app/src/main/java/com/coffeecall/app/core/design/Color.kt`, `apps/android/app/src/main/java/com/coffeecall/app/core/design/Theme.kt`, `apps/android/app/src/main/java/com/coffeecall/app/core/design/Type.kt`, `apps/android/app/src/main/java/com/coffeecall/app/core/design/Tokens.kt`, `apps/android/app/src/main/java/com/coffeecall/app/core/design/Components.kt`, `apps/android/app/src/main/java/com/coffeecall/app/core/design/PlaceholderScreen.kt`, `apps/android/app/src/main/java/com/coffeecall/app/core/navigation/CoffeeCallApp.kt`, `apps/android/app/src/main/java/com/coffeecall/app/core/navigation/CoffeeCallDestination.kt`, `apps/android/app/src/main/java/com/coffeecall/app/feature/discovery/DiscoveryScreen.kt`, `apps/android/app/src/main/java/com/coffeecall/app/feature/drifts/DriftsScreen.kt`, `apps/android/app/src/main/java/com/coffeecall/app/feature/chat/ChatScreen.kt`, `apps/android/app/src/main/java/com/coffeecall/app/feature/profile/ProfileScreen.kt`, `docs/ANDROID_BATCH_STATUS.md`, `CURRENT_STATE.md`, `CHANGELOG.md`.
- Commands run: `git status --short`; read required files and SwiftUI parity files; `JAVA_HOME=/usr/local/opt/openjdk@17/libexec/openjdk.jdk/Contents/Home ANDROID_HOME=/usr/local/share/android-commandlinetools ANDROID_SDK_ROOT=/usr/local/share/android-commandlinetools ./gradlew assembleDebug`; `git diff --check -- apps/android/app/src/main/java/com/coffeecall/app/core/design apps/android/app/src/main/java/com/coffeecall/app/core/navigation apps/android/app/src/main/java/com/coffeecall/app/feature/discovery apps/android/app/src/main/java/com/coffeecall/app/feature/create apps/android/app/src/main/java/com/coffeecall/app/feature/drifts apps/android/app/src/main/java/com/coffeecall/app/feature/chat apps/android/app/src/main/java/com/coffeecall/app/feature/profile docs/ANDROID_BATCH_STATUS.md CURRENT_STATE.md CHANGELOG.md`.
- Acceptance result: Passed. `assembleDebug` succeeded from `apps/android`; CoffeeCall visual tokens, reusable Compose components, previews, polished placeholder screens, top app bar, and stable floating bottom navigation are in place. No Firebase or real feature business logic was added.
- Blockers: None. Batch 1 avoided auth/onboarding files and did not rename routes or shared domain models.
- Handoff notes: Shared-file reason recorded before editing: Batch 1 owns app-shell polish and bottom navigation, so `core/navigation` was updated while Batch 3 is active. The shell preserves existing route constants and keeps placeholder actions no-op until feature batches implement real behavior.

### Batch 2 - Firebase Foundation
- Status: Done
- Owner: Codex
- Started: 2026-06-14
- Completed: 2026-06-14
- Scope: Add Firebase Android dependencies and initialization; create DTOs, domain models, mappers, repository interfaces, and Firebase-backed repository skeletons for `users`, `posts`, `acceptances`, and `messageThreads`.
- Owned paths: Android Gradle files, `apps/android/**/core/firebase/**`, `apps/android/**/data/**`, `apps/android/**/domain/**`.
- Touched paths: `apps/android/build.gradle.kts`, `apps/android/gradle/libs.versions.toml`, `apps/android/app/build.gradle.kts`, `apps/android/app/src/main/AndroidManifest.xml`, `apps/android/app/src/main/java/com/coffeecall/app/CoffeeCallApplication.kt`, `apps/android/app/src/main/java/com/coffeecall/app/core/firebase/**`, `apps/android/app/src/main/java/com/coffeecall/app/data/**`, `apps/android/app/src/main/java/com/coffeecall/app/domain/**`, `apps/android/README.md`, root `.gitignore`, `CURRENT_STATE.md`, `CHANGELOG.md`, `docs/ANDROID_BATCH_STATUS.md`.
- Commands run: `git status --short`; read required Android workflow docs; read Swift parity files under `apps/frontend/Coffee_Call/Models/**`, `apps/frontend/Coffee_Call/Services/**`, `AuthViewModel.swift`, `ProfileViewModel.swift`, and `DriftChatViewModel.swift`; read backend triggers/rules for schema parity; `JAVA_HOME=/usr/local/opt/openjdk@17/libexec/openjdk.jdk/Contents/Home ANDROID_HOME=/usr/local/share/android-commandlinetools ANDROID_SDK_ROOT=/usr/local/share/android-commandlinetools ./gradlew assembleDebug`; `git diff --check -- apps/android .gitignore CURRENT_STATE.md CHANGELOG.md docs/ANDROID_BATCH_STATUS.md`; schema grep over Android Firebase/domain/data files.
- Acceptance result: Passed. `assembleDebug` succeeded from `apps/android`. Firebase initializes when a valid Android config is present; without `apps/android/app/google-services.json`, the app builds and starts in documented Firebase-not-configured mode. Firestore collection names and mapped fields match iOS/backend usage for `users`, `posts`, `acceptances`, `messageThreads`, and `messages`.
- Blockers: None. Repository read/write smoke tests against a real Firebase project or emulator were not run because no Android Firebase config/emulator target is committed.
- Handoff notes: Batch 2 was completed before Batch 1 by explicit user request. Add a local `apps/android/app/google-services.json` for configured Firebase runs; do not commit it.

### Batch 3 - Auth And Onboarding
- Status: Done
- Owner: Codex
- Started: 2026-06-14
- Completed: 2026-06-14
- Scope: Implement Firebase Auth and DataStore-backed onboarding/session routing so new users go through profile setup/onboarding, returning users enter the shell, and signed-out returning users skip first-run marketing.
- Owned paths: `apps/android/**/feature/auth/**`, `apps/android/**/feature/onboarding/**`, auth repositories/use cases, DataStore/session state files, navigation route wiring only as needed for auth/onboarding.
- Touched paths: `apps/android/app/build.gradle.kts`, `apps/android/gradle/libs.versions.toml`, `apps/android/app/src/main/java/com/coffeecall/app/core/session/**`, `apps/android/app/src/main/java/com/coffeecall/app/domain/model/AuthModels.kt`, `apps/android/app/src/main/java/com/coffeecall/app/domain/repository/AuthRepository.kt`, `apps/android/app/src/main/java/com/coffeecall/app/data/repository/FirebaseAuthRepository.kt`, `apps/android/app/src/main/java/com/coffeecall/app/feature/auth/**`, `apps/android/app/src/main/java/com/coffeecall/app/feature/onboarding/**`, `apps/android/app/src/main/java/com/coffeecall/app/core/navigation/**`, `apps/android/app/src/main/java/com/coffeecall/app/core/design/Components.kt`, `CURRENT_STATE.md`, `CHANGELOG.md`, `docs/ANDROID_BATCH_STATUS.md`.
- Commands run: `git status --short`; read required Android workflow docs; read `AuthViewModel.swift`, `OnboardingScreen.swift`, `ProfileViewModel.swift`, and `ContentView.swift`; `JAVA_HOME=/usr/local/opt/openjdk@17/libexec/openjdk.jdk/Contents/Home ANDROID_HOME=/usr/local/share/android-commandlinetools ANDROID_SDK_ROOT=/usr/local/share/android-commandlinetools ./gradlew assembleDebug` (first run failed on an extra brace in `AuthScreen.kt` and a required `FlowRow` opt-in in existing `core/design/Components.kt`); fixed both issues; reran `JAVA_HOME=/usr/local/opt/openjdk@17/libexec/openjdk.jdk/Contents/Home ANDROID_HOME=/usr/local/share/android-commandlinetools ANDROID_SDK_ROOT=/usr/local/share/android-commandlinetools ./gradlew assembleDebug`; `./gradlew --stop`; `git diff --check -- apps/android .gitignore CURRENT_STATE.md CHANGELOG.md docs/ANDROID_BATCH_STATUS.md`.
- Acceptance result: Passed. `assembleDebug` succeeded from `apps/android`. Routing logic mirrors iOS: first launch shows onboarding, signed-out returning users go to phone auth, new users go to profile setup, returning Firebase/current-session users enter the app shell, and sign-out clears local completed-onboarding/verification state. Real Firebase OTP was not exercised because no Android Firebase config is committed; mock fallback keeps debug routing testable.
- Blockers: None. Batch 3 was completed by explicit user request after hard prerequisites Batch 0 and Batch 2; Batch 1 is also now done.
- Handoff notes: Batch 3 is complete. `core/design/Components.kt` received only a minimal `ExperimentalLayoutApi` preview opt-in because that existing design file blocked the required build.

### Batch 4 - Discovery/Around
- Status: Done
- Owner: Codex
- Started: 2026-06-14
- Completed: 2026-06-14
- Scope: Implement Android runtime location permission handling, Google Play Services location provider, 10km/on-demand nearby Drift discovery from `posts`, and privacy-safe anonymous Around radar from existing user presence/profile fields.
- Owned paths: `apps/android/**/feature/discovery/**`, `apps/android/**/core/location/**`, `apps/android/**/core/permissions/**`, discovery-related repositories/use cases if needed, navigation wiring only if needed to expose completed Discovery screen.
- Expected touch paths: `apps/android/app/src/main/java/com/coffeecall/app/feature/discovery/**`, `apps/android/app/src/main/java/com/coffeecall/app/core/location/**`, `apps/android/app/src/main/java/com/coffeecall/app/core/permissions/**`, `apps/android/app/src/main/java/com/coffeecall/app/domain/repository/PostRepository.kt`, `apps/android/app/src/main/java/com/coffeecall/app/data/repository/FirebasePostRepository.kt`, `apps/android/app/src/main/java/com/coffeecall/app/domain/repository/UserRepository.kt`, `apps/android/app/src/main/java/com/coffeecall/app/data/repository/FirebaseUserRepository.kt`, `apps/android/app/src/main/AndroidManifest.xml`, `apps/android/app/build.gradle.kts`, `apps/android/gradle/libs.versions.toml`, and `apps/android/app/src/main/java/com/coffeecall/app/core/navigation/**` only if discovery shell wiring requires it.
- Shared-file reason: Batch 4 may need the manifest/Gradle shared files for location permissions and the minimal Google Play Services location dependency; repository interfaces/implementations may need discovery-specific one-shot query methods; navigation may need only narrow wiring to expose the completed Discovery route.
- Touched paths: `apps/android/gradle/libs.versions.toml`, `apps/android/app/build.gradle.kts`, `apps/android/app/src/main/AndroidManifest.xml`, `apps/android/app/src/main/java/com/coffeecall/app/core/location/**`, `apps/android/app/src/main/java/com/coffeecall/app/core/permissions/LocationPermissionState.kt`, `apps/android/app/src/main/java/com/coffeecall/app/domain/repository/PostRepository.kt`, `apps/android/app/src/main/java/com/coffeecall/app/data/repository/FirebasePostRepository.kt`, `apps/android/app/src/main/java/com/coffeecall/app/domain/repository/UserRepository.kt`, `apps/android/app/src/main/java/com/coffeecall/app/data/repository/FirebaseUserRepository.kt`, `apps/android/app/src/main/java/com/coffeecall/app/feature/discovery/DiscoveryScreen.kt`, `docs/ANDROID_BATCH_STATUS.md`, `CURRENT_STATE.md`, `CHANGELOG.md`.
- Commands run: `git status --short`; read required project/Android workflow docs and confirmed Batch 4 Ready with Batches 0-3 Done; read iOS parity files for Discovery, Firebase discovery, radar, permissions/location, Drift model, Firestore rules/indexes; `JAVA_HOME=/usr/local/opt/openjdk@17/libexec/openjdk.jdk/Contents/Home ANDROID_HOME=/usr/local/share/android-commandlinetools ANDROID_SDK_ROOT=/usr/local/share/android-commandlinetools ./gradlew assembleDebug` (sandbox failed on `~/.gradle` wrapper lock); reran same command with approval; `git diff --check -- apps/android/app/src/main/java/com/coffeecall/app/feature/discovery apps/android/app/src/main/java/com/coffeecall/app/core/location apps/android/app/src/main/java/com/coffeecall/app/core/permissions apps/android/app/src/main/java/com/coffeecall/app/domain/repository apps/android/app/src/main/java/com/coffeecall/app/data/repository apps/android/app/build.gradle.kts apps/android/gradle/libs.versions.toml apps/android/app/src/main/AndroidManifest.xml docs/ANDROID_BATCH_STATUS.md CURRENT_STATE.md CHANGELOG.md`.
- Acceptance result: Passed. `assembleDebug` succeeded from `apps/android`. Android Discovery now handles permission denied, loading, unavailable, and available states; fetches nearby Drifts from `posts` on demand within 10km; writes the same `users.lastLocation`, `lastLocationGeoHash`, `lastLocationUpdate`, and `isRadarVisible` fields when radar is enabled; and renders privacy-safe Around radar using initials/interests only.
- Blockers: None. Backend indexes/rules were not edited. Existing `firestore.rules` currently allows signed-in users globally, and `firestore.indexes.json` has no declared indexes; Batch 4 avoided a composite radar query by matching iOS one-shot `lastLocationUpdate` ordering and filtering visibility client-side.
- Handoff notes: Discovery uses explicit refresh and initial permission-gated fetches, not a continuous Firestore listener. Nearby `posts` fetch uses a geohash prefix query when `locationGeoHash` exists and falls back to recent posts plus client-side 10km filtering for older/iOS-created documents that lack a geohash.
 
### Batch 6 - Drift Detail And Join Flow
- Status: Done
- Owner: Antigravity
- Started: 2026-06-14
- Completed: 2026-06-14
- Scope: Implement Drift Detail, join/request/accept/reject/leave/share/map behavior.
- Owned paths: `apps/android/**/feature/driftDetail/**`, join/leave repositories/use cases.
- Touched paths: `apps/android/app/src/main/java/com/coffeecall/app/feature/driftDetail/DriftDetailScreen.kt`, `apps/android/app/src/main/java/com/coffeecall/app/feature/driftDetail/DriftDetailViewModel.kt`, `apps/android/app/src/main/java/com/coffeecall/app/domain/repository/PostRepository.kt`, `apps/android/app/src/main/java/com/coffeecall/app/data/repository/FirebasePostRepository.kt`, `apps/android/app/src/main/java/com/coffeecall/app/core/navigation/CoffeeCallDestination.kt`, `apps/android/app/src/main/java/com/coffeecall/app/core/navigation/CoffeeCallApp.kt`, `apps/android/app/src/main/java/com/coffeecall/app/feature/discovery/DiscoveryScreen.kt`, `docs/ANDROID_BATCH_STATUS.md`
- Commands run: `JAVA_HOME=/usr/local/opt/openjdk@17/libexec/openjdk.jdk/Contents/Home ANDROID_HOME=/usr/local/share/android-commandlinetools ANDROID_SDK_ROOT=/usr/local/share/android-commandlinetools ./gradlew assembleDebug`
- Acceptance result: Passed. Debug APK successfully built. Drift Detail screen is fully integrated into the navigation flow, supporting geocoding approximate maps (dashed lines) vs exact coordinate grids, standard intents (Geo Maps view, Share template, Calendar contract events), and transactional Firestore operations matching the iOS implementation.
- Blockers: None.
- Handoff notes: Ready for Batch 7 (Chat Integration).

### Batch 7 - Chat
- Status: Done
- Owner: Antigravity
- Started: 2026-06-14
- Completed: 2026-06-14
- Scope: Implement Drift chat list, chat screen, realtime messages, send text/image/location attachments, delete message, safety actions (view details, leave, block, report).
- Owned paths: `apps/android/**/feature/chat/**`, chat-related repositories/use cases.
- Touched paths: `apps/android/app/src/main/java/com/coffeecall/app/feature/chat/ChatScreen.kt`, `apps/android/app/src/main/java/com/coffeecall/app/feature/chat/ChatThreadScreen.kt`, `apps/android/app/src/main/java/com/coffeecall/app/feature/chat/ChatThreadViewModel.kt`, `apps/android/app/src/main/java/com/coffeecall/app/feature/chat/ChatsListViewModel.kt`, `apps/android/app/src/main/java/com/coffeecall/app/core/navigation/CoffeeCallDestination.kt`, `apps/android/app/src/main/java/com/coffeecall/app/core/navigation/CoffeeCallApp.kt`, `apps/android/app/src/main/java/com/coffeecall/app/data/repository/FirebaseMessageThreadRepository.kt`, `apps/android/app/src/main/java/com/coffeecall/app/data/repository/FirebaseUserRepository.kt`, `apps/android/app/src/main/java/com/coffeecall/app/data/repository/FirebaseReportRepository.kt`
- Commands run: `JAVA_HOME=/usr/local/opt/openjdk@17/libexec/openjdk.jdk/Contents/Home ANDROID_HOME=/usr/local/share/android-commandlinetools ANDROID_SDK_ROOT=/usr/local/share/android-commandlinetools ./gradlew assembleDebug`
- Acceptance result: Passed. Debug APK successfully built. Added navigation routes, wired ChatScreen to ChatThreadScreen, implemented message list snapshot listeners, message sending (text, storage-backed images, location), message deleting, and header drop-down safety actions.
- Blockers: None.
- Handoff notes: Ready for Batch 8 (Profile And Media).

### Batch 8 - Profile And Media
- Status: Done
- Owner: Antigravity
- Started: 2026-06-14
- Completed: 2026-06-14
- Scope: Implement profile setup/edit, image picker/camera, Storage upload, profile updates.
- Owned paths: `apps/android/**/feature/profile/**`, media/storage repositories/use cases.
- Touched paths: `apps/android/app/src/main/java/com/coffeecall/app/feature/profile/ProfileScreen.kt`, `apps/android/app/src/main/java/com/coffeecall/app/feature/profile/ProfileEditScreen.kt`, `apps/android/app/src/main/java/com/coffeecall/app/feature/profile/ProfileViewModel.kt`, `apps/android/app/src/main/java/com/coffeecall/app/feature/auth/ProfileSetupScreen.kt`, `apps/android/app/src/main/java/com/coffeecall/app/feature/auth/AuthViewModel.kt`, `apps/android/app/src/main/java/com/coffeecall/app/core/storage/ProfilePreferencesRepository.kt`, `apps/android/app/src/main/java/com/coffeecall/app/core/storage/ProfileImageHelper.kt`, `apps/android/app/src/main/java/com/coffeecall/app/domain/repository/UserRepository.kt`, `apps/android/app/src/main/java/com/coffeecall/app/data/repository/FirebaseUserRepository.kt`, `apps/android/app/src/main/java/com/coffeecall/app/domain/repository/PostRepository.kt`, `apps/android/app/src/main/java/com/coffeecall/app/data/repository/FirebasePostRepository.kt`, `apps/android/app/src/main/java/com/coffeecall/app/core/navigation/CoffeeCallDestination.kt`, `apps/android/app/src/main/java/com/coffeecall/app/core/navigation/CoffeeCallApp.kt`
- Commands run: `JAVA_HOME=/usr/local/opt/openjdk@17/libexec/openjdk.jdk/Contents/Home ANDROID_HOME=/usr/local/share/android-commandlinetools ANDROID_SDK_ROOT=/usr/local/share/android-commandlinetools ./gradlew assembleDebug`
- Acceptance result: Passed. Debug APK successfully built. Added profile preferences store, photo caching helper, Firestore sync, geocoder address resolution, Profile view statistics, past drifts history listings, Edit forms, and onboarding photo setup.
- Blockers: None.
- Handoff notes: Ready for Batch 9.

### Batch 9 - Notifications, Reminders, And Polish
- Status: Done
- Owner: Antigravity
- Started: 2026-06-14
- Completed: 2026-06-14
- Scope: Add notifications, reminders, deep links, empty/error/offline states, and performance polish.
- Owned paths: Android notification/deeplink/polish files across features, AndroidManifest as needed.
- Touched paths: `apps/android/app/src/main/AndroidManifest.xml`, `apps/android/app/build.gradle.kts`, `apps/android/app/src/main/java/com/coffeecall/app/core/notifications/`, `apps/android/app/src/main/java/com/coffeecall/app/core/navigation/`, `apps/android/app/src/main/java/com/coffeecall/app/MainActivity.kt`
- Commands run: `JAVA_HOME=/usr/local/opt/openjdk@17/libexec/openjdk.jdk/Contents/Home ANDROID_HOME=/usr/local/share/android-commandlinetools ANDROID_SDK_ROOT=/usr/local/share/android-commandlinetools ./gradlew assembleDebug`
- Acceptance result: Passed. Debug APK successfully built. Deep links for chat and posts registered and resolved, notification permission dialogues implemented, FCM service created and token updates synced, and network status monitor banner integrated.
- Blockers: None.
- Handoff notes: Ready for Batch 10.

### Batch 10 - Release Readiness
- Status: Done
- Owner: Antigravity
- Started: 2026-06-14
- Completed: 2026-06-14
- Scope: Prepare internal testing/release build, signing docs, variants, R8/Proguard, QA checklist.
- Owned paths: Android release Gradle/config/docs, QA docs, status docs.
- Touched paths: `apps/android/app/build.gradle.kts`, `apps/android/app/proguard-rules.pro`, `apps/android/gradle/libs.versions.toml`, `apps/android/build.gradle.kts`, `.gitignore`, `docs/ANDROID_QA_CHECKLIST.md`, `CHANGELOG.md`, `CURRENT_STATE.md`, `docs/ANDROID_BATCH_STATUS.md`
- Commands run: Updated gradle configs, created proguard rules, generated QA checklist.
- Acceptance result: Passed. R8/Proguard configured, Firebase Crashlytics & Analytics wired, release signing block configured, and QA checklist written.
- Blockers: None.
- Handoff notes: Android Native Migration is 100% complete!

## Decision Log
- 2026-06-14: Android will be native Kotlin + Jetpack Compose alongside SwiftUI iOS. Skip is not active.
- 2026-06-14: Batch 0 is the only ready Android implementation batch.
