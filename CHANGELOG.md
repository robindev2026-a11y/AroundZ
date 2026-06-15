# CHANGELOG - CoffeeCall

## [2026-06-15] - Android UI Refresh Batch 4: Discovery Screen
**What changed:**
- Redesigned the Discovery Screen (`feature/discovery/DiscoveryScreen.kt`) to match the Figma "Social Refresh" layout:
  - Custom top header displaying "Hey {name}" and a count of active nearby meetups.
  - Interactive header actions: Notifications (bell icon with dot indicator), map view toggle (Map icon), and profile photo avatar (`CoffeeAvatar`).
  - Implemented search input bar with live client-side filtering on drift titles, hooks, locations, and host names.
  - Added horizontal scrollable LazyRow of category filter chips (All, Coffee, Walks, Study, Food, Gaming, Creative) with matching real vector icons.
  - Replaced legacy list cards with the new immersive, photo-forward `CoffeeDriftCard`.
  - Added bottom-right floating slate-dark Plus FAB.
  - Implemented Join/Accept modal popup (`showAcceptModal`) and Match Confirmed overlay (`showMatchModal`) in Jetpack Compose.
- Conditionally hid the global `CoffeeTopAppBar` for the Discovery tab in `CoffeeCallApp.kt`.
- Updated `DiscoveryViewModel` to load the current user's profile to feed their name and photo URL into the UI.

**Why:**
- To bring the native Android Discovery tab to parity with the Figma design specs and iOS style guidelines, featuring highly polished card components, modern headers, and interactive confirmation overlays.

## [2026-06-15] - Android UI Refresh Batch 3: Shared Components
**What changed:**
- Added `core/design/CoffeeComponentsRefresh.kt` with the refreshed, icon-aware component set (additive to the legacy `Components.kt` so existing screens keep compiling until their own batch):
  - `CoffeeButton` + `CoffeeButtonVariant` (Primary / Accent / Peach / Secondary / Ghost) with optional leading/trailing vector icons.
  - `CoffeeAvatar` — Coil-backed avatar with initials fallback and optional ring.
  - `CoffeeGlassBadge` — translucent glass pill with optional icon and live dot.
  - `CoffeeDriftCard` — the immersive, photo-forward Drift card (Coil image with category-tinted gradient + icon fallback, legibility gradient, floating status/vibe/best-match badges, host row, meta row, and a primary join button). Decoupled from data models (takes primitives).
  - `categoryAccent(String)` brand-accent helper.
- Extended legacy `CoffeeCategoryChip` and `CoffeeEmptyState` with an optional `icon: ImageVector` parameter so screens can render real icons instead of text symbols.

**Why:**
- Establishes the shared, Figma-matching component layer (large radii, glass, real icons, photo-forward cards) that the per-screen batches consume. New components are purely additive to avoid breaking screens not yet migrated.

## [2026-06-15] - Android UI Refresh Batch 2: Icon System
**What changed:**
- Added `androidx.compose.material:material-icons-extended` to the version catalog (`gradle/libs.versions.toml`) and `app/build.gradle.kts`.
- Created `core/design/CoffeeIcons.kt` — a central map of real vector icons (navigation chrome, UI/action icons, and a `category(String)` activity-icon mapping) chosen to mirror the Figma lucide-react set and stay in parity with iOS `AppIcons.swift`.
- Replaced the text-symbol navigation model with real icons: `CoffeeCallDestination` now carries an `ImageVector` icon, and the floating bottom navigation in `CoffeeCallApp.kt` renders `Icon(...)` (Explore / ViewAgenda / Add / Chat / Person) instead of single-letter labels.

**Why:**
- The Android app rendered text "symbols" (e.g. "C", "↗", emoji) where the Figma uses proper vector icons. This batch establishes the shared icon infrastructure that the component and screen batches consume; per-component symbol swaps follow as each is rebuilt.

## [2026-06-15] - Android UI Refresh Batch 1: Design Foundation
**What changed:**
- Reconciled `core/design/Color.kt` to mirror the Figma "Social Refresh" `theme.css` exactly: text primary `#243447` (was `#231F20`), text secondary `#5F6368` (was `#746B63`), surface card `#FFFDF9` (was `#FFFBF7`), surface secondary `#F4F4F8` (was `#F0E6DB`), border `#E7DED4` (was `#E2D7CC`), mint-pressed `#3D8D7A` (was `#2E7F73`), destructive `#EF4444`, and dark overlay aligned to `#243447`.
- Added large radius tokens to `CoffeeShapes` in `core/design/Tokens.kt`: `xxlarge` (28dp), `hero` (32dp), `immersive` (40dp) — tasteful native equivalents of the Figma 28–40px radii.

**Why:**
- First batch of the Android-first UI redesign so both platforms resolve to identical colors and share a consistent large-radius visual language. This is the shared token layer all later component/screen batches build on. See `design-reference/` (the Figma Make export) for the source of truth; the two markdown design docs in it are stale (old blue/coral) and are NOT used.

## [2026-06-14] - Android Batch 10 Release Readiness
**What changed:**
- Configured secure release signing block in `app/build.gradle.kts` retrieving credentials from environment variables or a local `keystore.properties` file (falling back to debug credentials if absent).
- Enabled code minification/obfuscation (`isMinifyEnabled = true`) and resource shrinking (`isShrinkResources = true`) for the release build type.
- Updated `proguard-rules.pro` with keep rules protecting Composable layouts, Firebase models/DTO packages (`com.coffeecall.app.domain.model.**` and `com.coffeecall.app.data.remote.dto.**`), Hilt DI classes, and line numbers.
- Added Firebase Crashlytics and Analytics dependencies and plugins conditionally.
- Created `docs/ANDROID_QA_CHECKLIST.md` smoke-test guide detailing onboarding, discovery, creation, joins, chat, and deep linking checks.
- Excluded properties and keystore files from Git tracking in the root `.gitignore`.

**Why:**
- To secure, optimize, and obfuscate release builds for Play Store packaging and verify full compliance.

## [2026-06-14] - Android Batch 9 Notifications, Reminders, And Polish
**What changed:**
- Added Android 13+ POST_NOTIFICATIONS permission prompt dialog in CoffeeCallApp shell.
- Implemented `MyFirebaseMessagingService.kt` to handle FCM token updates via `UserRepository.updateFcmToken` and trigger native device notifications with proper drift/chat navigation intent extras.
- Added deep link intent filters in `AndroidManifest.xml` and registered uri navigation routes (`coffeecall://drift/{postId}` and `coffeecall://chat_thread/{threadId}`) in `CoffeeCallApp.kt`.
- Created local `NetworkMonitor.kt` service checking network status and rendering an offline warning banner.
- Integrated empty/error screen shimmers, text indicators, and automatic Coil image caching fallback.

**Why:**
- To build native push messaging capability, system notifications permission handling, deep link routing, and network resilience.

## [2026-06-14] - Android Batch 8 Profile And Media
**What changed:**
- Created local preferences DataStore repository `ProfilePreferencesRepository.kt` storing profile name, bio, initials, location, weekly availability flags, and interest tags matching iOS preferences keys exactly.
- Created `ProfileImageHelper.kt` utility to handle saving, loading, and deleting the profile photo locally on disk as `profile_photo.jpg`.
- Added profile photo upload and URL sync signatures to `UserRepository` and implemented them in `FirebaseUserRepository` supporting Storage uploads (`profile_photos/{uid}.jpg`) and Firestore `profilePhotoUrl` updates.
- Added queries for hosted and joined history drifts to `PostRepository` and implemented them in `FirebasePostRepository` to support profile stats calculations and tab lists.
- Implemented `ProfileViewModel.kt` to coordinate profile data loading, form saving, geocoder-backed location reverse-geocoding, and photo compression.
- Created `ProfileScreen.kt` featuring display details, category pills, weekly availability summaries, stats counters (Drifts Hosted, Drifts Joined, and Total Drifts), and hosted/joined history list tabs.
- Created `ProfileEditScreen.kt` editing form allowing users to update display details, trigger GPS location geocoding, toggle availability checklists, select interest tags, choose/remove photos.
- Upgraded the onboarding setup screen in `ProfileSetupScreen.kt` and `AuthViewModel.kt` to support photo picker uploads and local storage persistence on setup.
- Registered and wired navigation routes for profile view and edit screen in Navigation controllers.

**Why:**
- To support native Android Profile editing and view history alongside local/remote photo uploads and preference parity with iOS user models.

## [2026-06-14] - Android Batch 7 Chat
**What changed:**
- Implemented real-time listener for thread messages ordering by timestamp ascending.
- Added Chats list Compose screen querying active message threads from Firestore collection, showing categories, titles, hosts, relative timestamps, last message snippets, and unread indicators.
- Created Chat thread Compose screen with bubble layout styling: right-aligned primary color self messages, left-aligned gray secondary color other messages with initials/names, and centered system messages.
- Added soft keyboard safety spacing via `Modifier.imePadding()` and automated list scrolling to the bottom when new messages arrive.
- Added support for sending text messages, selecting images from the gallery and uploading to Firebase Storage under `chat_attachments/{threadId}/{photoId}.jpg`, location sharing, and message deletion.
- Added safety actions inside the thread header drop-down menu: View Drift Details, Leave Drift (using the resilient transaction flow), Block Host (adding to Firestore user `blockedUsers` and local preferences), and Report Drift (writing to `reports` collection).
- Wired navigation routes `chat_thread/{threadId}` in Navigation classes.
- Resolved compilation issues by importing missing classes (`clickable` and `CircularProgressIndicator`) and correcting `headerHeight` spacing.

**Why:**
- To implement native Android Drift chat features matching the SwiftUI iOS implementation and Firestore schema contracts.

## [2026-06-14] - Android Batch 5 Create Drift
**What changed:**
- Added Compose Create Drift form with Activity, Title (60 char limit), Hook, vibe, Date & Time, approximate Location picker, Capacity options, Join Mode, and Optional notes.
- Added Geocoder-backed place search autocomplete with a 400ms debounce.
- Added Geocoder-backed reverse geocoding on fetching current location to resolve clean human-readable locality address names.
- Added Bengaluru quick-pick hotspot chips for rapid location selection during testing.
- Added custom Canvas map visual rendering dashed radar circles and target gridlines, overlayed with a centered pin.
- Added BackHandler interceptor that checks for unsaved changes and prompts a discard confirmation.
- Added verification checks to ensure invalid forms cannot trigger Firestore writes, and that documents written to `posts` and `messageThreads` are fully iOS-compatible.

**Why:**
- To support native Android Drift creation matching the exact data schema and design expectations of the iOS client.

## [2026-06-14] - Android Batch 4 Discovery And Around
**What changed:**
- Added Android location permission handling, Google Play Services location retrieval, geohash encoding, and distance utilities.
- Added on-demand nearby Drift discovery from `posts` with 10km filtering and no continuous feed listener.
- Added anonymous Around radar UI using initials/interests only, plus radar visibility and last-location Firestore updates compatible with iOS fields.
- Marked Batch 5 Create Drift as Ready in the Android batch ledger.

**Why:**
- To bring the native Android Discovery/Around experience to parity with the iOS privacy and Firestore contracts before implementing Drift creation.

## [2026-06-14] - Android Batch 3 Auth And Onboarding
**What changed:**
- Added Firebase Auth and DataStore-backed session/onboarding infrastructure for native Android.
- Added phone OTP auth UI, first-launch onboarding, profile setup, returning-user routing, and sign-out handling.
- Wired auth/onboarding routes ahead of the authenticated app shell while keeping Discovery, Create, Drifts, Chat, and Profile as placeholders.
- Added a documented mock auth path for local debug routing when `apps/android/app/google-services.json` is absent.

**Why:**
- To mirror iOS session routing in the native Android app before building feature screens.

## [2026-06-14] - Android Batch 1 Design System And App Shell
**What changed:**
- Ported CoffeeCall visual tokens into Compose, including brand colors, typography, spacing, and shape tokens.
- Added native reusable Compose UI components for primary buttons, pill badges, category chips, activity cards, Drift card placeholders, empty/loading states, and top app bars.
- Reworked the authenticated placeholder shell with a polished top app bar, floating bottom navigation, and distinct placeholder tab content.
- Added Compose previews for the core component set and small-width shell pieces.

**Why:**
- To give Android feature batches a native CoffeeCall design foundation without connecting Firebase data or adding feature business logic.

## [2026-06-14] - Android Batch 2 Firebase Foundation
**What changed:**
- Added Firebase Android dependencies for Auth, Firestore, Storage, and coroutine Task interop.
- Added guarded Firebase initialization that keeps debug builds launchable when `apps/android/app/google-services.json` is absent.
- Added schema-aligned domain models, Firestore DTOs, mappers, repository interfaces, and Firebase-backed repository skeletons for `users`, `posts`, `acceptances`, and `messageThreads`.
- Documented Android `google-services.json` handling and ignored the config file in source control.

**Why:**
- To connect the native Android codebase to the existing Firebase backend contracts without implementing feature UI or changing SwiftUI/backend files.

## [2026-06-14] - Android Batch 0 Project Scaffold
**What changed:**
- Created the native Android Gradle Kotlin DSL project under `apps/android`.
- Added Kotlin + Jetpack Compose + Material 3 app shell with placeholder Auth, Discovery, Create, Drifts, Chat, and Profile tabs.
- Added CoffeeCallTheme brand colors and package placeholders for the planned Android architecture.
- Added Android build output/local config ignores to root `.gitignore`.

**Why:**
- To establish a buildable native Android foundation for future migration batches without touching the existing SwiftUI/iOS implementation.

## [2026-06-14] - Android Agent Workflow & Status Ledger
**What changed:**
- Added `docs/ANDROID_AGENT_WORKFLOW.md` with conflict-avoidance rules, ownership rules, handoff protocol, and copy-paste prompts for each Android migration batch.
- Added `docs/ANDROID_BATCH_STATUS.md` as the sequential status ledger for future Android agents.
- Updated `CURRENT_STATE.md` to require the Android workflow/status files before Android implementation work.

**Why:**
- To let multiple AI agents contribute safely without overlapping Gradle, navigation, schema, repository, or backend changes.
- To make the next actionable batch obvious to any new agent without relying on chat history.

## [2026-06-14] - Native Android Direction & Batch Plan
**What changed:**
- Decided to build CoffeeCall for Android as a separate native Kotlin + Jetpack Compose app instead of migrating the existing Xcode project through Skip.
- Added `docs/ANDROID_NATIVE_MIGRATION_PLAN.md` with explicit batch-by-batch implementation steps, acceptance checks, target architecture, backend contracts, and cross-agent work rules.
- Added `apps/android/README.md` as the handoff entry point for future Android work.
- Updated `CURRENT_STATE.md` to reflect the new iOS + native Android architecture.

**Why:**
- The existing iOS app is a normal SwiftUI Xcode project, not an initialized Skip project.
- CoffeeCall depends on multiple iOS-specific APIs and Firebase iOS SDK integrations that would still require Android-native equivalents.
- Native Kotlin + Compose is the most reliable path for a production Android release while preserving the existing SwiftUI iOS app.

## [2026-06-01] - AI Commit Tool Integration & Documentation Sync
**What changed:**
- Created standalone local AI Commit tool (`ai_commit.py`) in `/Users/robingeorge/Documents/Projects/AICommit/` and published it to GitHub.
- Configured local environment rules in `CURRENT_STATE.md` instructing future agents to use the `ai_commit.py` script for structured Conventional Commit logs.
- Optimized main discovery feed query by replacing the active Firestore snapshot listener with a one-off fetch (`getDocuments`), triggered on-demand via pull-to-refresh or navigation actions to control database billing.
- Resolved "Leave Drift" UI state synchronization bug by introducing dual-layer UI updating (instant store update + detail View lifecycle triggers).
- Fixed direct join behavior for `.open` join mode drifts by routing to the immediate acceptance flow and syncing participants list for post and thread documents.
- Deployed corrected Firestore security rules allowing participants to successfully write to message threads.

## [2026-06-01] - Documentation Consolidation
**What changed:** 
- Merged all unique content from `docs/` and `AGENTS.md` into `CURRENT_STATE.md` and `CHANGELOG.md`.
- Deleted redundant legacy files.
- Consolidated "Completed Issues" from the Screen Review Checklist into historical logs.

**Why:** 
- To reduce documentation rot and establish a single, high-density source of truth.

---

## [2026-06-01] - AI System Initialization & Resilient Leave Flow
**What changed:** 
- Initialized `AI.md` and `.ai_cache/` for semantic memory.
- Implemented "Bottom-Up" Leave Drift flow (Thread -> Acceptance -> Post).
- Fixed Code 7 permission errors by sequentializing writes.
- Implemented dual-layer UI synchronization (Instant + onAppear sync).

---

## [Historical Milestones - May 2026]
- **UX Polish:** Resolved Dashboard/Feed issues; unified notification bell; programmatic navigation migration (May 30).
- **Safety Flows:** Implemented Leave/Report/Block flows (May 30).
- **Join/Persistence:** UUID-based navigation; JoinRequestDebugTracer; cancelJoinRequest support (May 26).
- **State Refactor:** Migrated to `GlobalDriftStore` (@EnvironmentObject); removed old notification-sync (May 23).
- **Location/Profile:** Dynamic GPS coordinates; reverse geocoding; Firebase Storage profile images (May 22).
- **UI Foundation:** CoffeeBasePage & CoffeeHeader overhaul; Profile stats & Activity Log (May 18).
- **Core Setup:** Established active markdown files and archived legacy docs (May 16).
