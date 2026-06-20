# CHANGELOG - CoffeeCall

## [2026-06-19] - Android ↔ iOS UI Parity Pass
**What changed:**
- **Bottom nav:** Redesigned to show text labels under all icons (matching iOS FloatingTabBar). Removed pill-shaped selected state.
- **Header "Sign out":** Removed "Sign out" button from Drifts, Chats, and Profile headers. Sign out now only accessible via Profile > Account section (matching iOS).
- **Drifts filter chips:** Removed "Tonight" chip (matching iOS). Added active filter count badge on filter icon.
- **Drifts filter sheet:** Enhanced with Time chips (All, Today, Tomorrow, This Weekend) and Activity Types grid (9 categories) matching iOS filter sheet.
- **Drifts card CTA:** Changed "Manage" to "Hosting" on Mine tab cards (matching iOS).
- **Drift Detail:** Restructured from hero image layout to compact header with action icons (share, calendar, bell) and summary grid cards (Date, Location, Distance, Participants) matching iOS.
- **Drift Detail CTA:** Renamed "Chat Room" to "Open Chat" with chat icon (matching iOS).
- **Create Drift:** Verified phone layout already uses full-width sections matching iOS.
- **iOS FloatingTabBar:** Fixed bottom nav being cut off on iPhones with Face ID by using GeometryReader to respect safe area insets.

**Why:**
- Screenshot comparison revealed Android had diverged from iOS in bottom nav styling, header elements, filter sheet completeness, and Drift Detail layout. This pass brings Android to visual parity with iOS as the canonical design. iOS had a safe area bug causing the tab bar to be clipped by the home indicator.

**Verification:**
- Build passes (`compileDebugKotlin`) with zero errors. Device verification needed for visual confirmation.

## [2026-06-18] - Android iOS UI alignment pass
**What changed:**
- **Bottom nav bar:** Removed solid `CoffeePrimary` pill on active tabs. Active tab now shows colored icon + text label (matching iOS glass-style nav).
- **Profile — stats:** Converted from single-row 4-column layout to 2x2 grid with "Your stats" section header. Added "Stats are private to you" lock note. Changed "Score" to "Coming soon" / "Reputation Score" (matching iOS). Added colored icon circles to stat tiles.
- **Profile — edit:** Changed from `CoffeeButton` to text link "Edit Profile" with pencil icon (matching iOS).
- **Profile — header:** Changed subtitle from "Your CoffeeCall presence" to "Your profile". Replaced "Sign out" button with gear icon (sign out moved to Account settings).
- **Settings rows:** Added `iconTint` and `iconBackground` params. Each row now has distinct colors: Interests=green, Availability=purple, Notifications=peach, Safety & Privacy=green, Location=green, Help=purple, Sign out=red.
- **Chats:** Updated filter tabs from Active/Upcoming/Past to Active/Joined/Hosted/Expired. Changed subtitle from "Drift-tied messages" to "Drift rooms".
- **Drifts:** Changed "Joined" CTA color from `CoffeePrimary` (mint) to `CoffeePeach` (orange).
- **Label fix:** Renamed "Privacy & Safety" to "Safety & Privacy" (matching iOS).
- Added `settings` icon to `CoffeeIcons.kt`. Added `actionIcon` param to `CoffeeTopAppBar`.

**Why:**
- Side-by-side screenshot comparison with iOS revealed visual drift in bottom nav styling, profile layout, settings row colors, chats filter tabs, and CTA colors. This pass aligns Android to match iOS pixel-for-pixel where possible.

**Verification:**
- Build passes (`compileDebugKotlin`) with zero errors. Device unlock needed for visual verification.

## [2026-06-18] - Android P9 consistency pass
**What changed:**
- Replaced all text symbols and emoji icons with real vector icons from `CoffeeIcons` across 8 feature screens: DriftDetailScreen (✓, 🔥, →), ChatThreadScreen (📍), CreateScreen (✕), OnboardingScreen (✨, ☕, 🚶, 🎮, 🎨, 🔒, 👥, ❤️), ChatScreen (☕, 🚶, 🎮, etc.), DiscoveryScreen (☕, 🚶, 🎬, ✨), ProfileEditScreen (☕, 🚶, 🎮).
- Updated component APIs in `Components.kt`: added `icon: ImageVector?` param to `CoffeePillBadge`, `trailingIcon: ImageVector?` to `CoffeePrimaryButton`, `icon: ImageVector?` to `CoffeeActivityChip`.
- Updated `OnboardingScreen.kt` internal composables: `ActivityChip` and `SafetyFeatureRow` now accept `ImageVector` instead of `String`.
- Replaced 50+ raw `.dp` spacing values with `CoffeeSpacing` tokens in `CreateScreen.kt` (34 instances) and `DiscoveryScreen.kt` (16 instances).
- Fixed 2 raw `32.dp` spacing values in `OnboardingScreen.kt` to use `CoffeeSpacing.xxl`.

**Why:**
- The Android app rendered text symbols (e.g. "C", "W", "✓", "→") and emoji ("☕", "🚶", "📍") where the Figma design uses proper vector icons. This brings Android to visual parity with iOS `AppIcons.swift` and eliminates inconsistent icon rendering across screens.

**Verification:**
- Build passes (`compileDebugKotlin`) with zero warnings.
- Grep confirms zero remaining emoji/text symbols in feature screen UI code.

## [2026-06-18] - Android Drifts distance mock + filter sheet
**What changed:**
- Wired real haversine distance computation into `GlobalDriftStore.fetch()` using `AndroidLocationProvider` — each post now gets a computed distance (km) from the user's GPS location instead of defaulting to `0.0`.
- Replaced hardcoded `"0.0 km"` in `DriftsScreen.kt` and `ProfileScreen.kt` with `String.format("%.1f km", drift.distance)`.
- Added distance filter state (`selectedDistanceRadius`, 1–10 km, default 10) to `DriftsScreen`.
- Added `ModalBottomSheet` filter sheet with a distance slider, Reset, and Apply buttons — matches iOS `DriftsFilterSheet` behavior.
- Distance filter is applied in the `visibleList` computation: posts beyond the selected radius are excluded.
- Updated `GlobalDriftStore` singleton to accept `AndroidLocationProvider` via `getInstance(application)`.

**Why:**
- Android Drifts cards always showed "0.0 km" even when posts had real lat/lng coordinates. iOS computes distance via haversine at merge time and filters by a user-adjustable km radius. This closes that parity gap.

**Verification:**
- Build passes (`compileDebugKotlin`). Device QA needed to confirm GPS distance values appear correctly.

## [2026-06-18] - Android Drifts tab source parity
**What changed:**
- Updated the Android Drifts tab data split so Discover reads non-hosted community drifts instead of the current user's joined drifts, while Mine remains hosted drifts.
- Added a repository-level `fetchAllPosts()` path for Android posts and wired `GlobalDriftStore.fetch()` to hydrate the shared store from all posts ordered by `createdAt`, matching the current iOS Drifts service behavior more closely.
- Added derived `discoveryDrifts` state alongside hosted/joined drifts and updated Drifts cards so joined state affects the CTA label instead of defining the Discover list.
- Mirrored the new post-fetch API in the mock post repository for Firebase-unconfigured/offline runs.

**Why:**
- The Android Drifts screen had Discover backed by joined drifts, which inverted the intended iOS behavior. iOS Discover filters the shared posts list to non-owned drifts, while Mine filters to owned/hosted drifts.

**Verification:**
- Not yet run in this logging pass. Needs Android build and manual Drifts tab QA after the in-progress code changes settle.

## [2026-06-16] - Android Arch Batch A5: DI standardization via RepositoryProvider
**What changed:**
- Migrated all ViewModels to use `RepositoryProvider` for repository injection instead of creating Firebase instances directly: `ChatsListViewModel`, `ChatThreadViewModel`, `AuthViewModel`, `ProfileViewModel`, `DiscoveryViewModel`, `DriftDetailViewModel`, `CreateDriftViewModel`.
- Removed direct `FirebasePostRepository()`, `FirebaseUserRepository()`, `FirebaseAuthRepository()`, `FirebaseMessageThreadRepository()`, `FirebaseReportRepository()` imports from all ViewModels.
- Fixed DiscoveryViewModel to use `store.notifications` (via `observeNotifications()`) instead of the old `loadNotifications()` method that called `PostRepository` directly — completing the A1 migration that was partially applied.
- All ViewModels now follow a consistent pattern: repositories via `RepositoryProvider`, `GlobalDriftStore` via `GlobalDriftStore.getInstance(application)`, `NavigationManager` via `NavigationManager.getInstance()`.

**Why:**
- iOS uses `@EnvironmentObject` for consistent dependency injection. Android previously had each ViewModel creating its own Firebase repository instances, which bypassed the mock/offline path and created inconsistent behavior. This standardizes injection through `RepositoryProvider`, ensuring all ViewModels use the correct Firebase or mock implementation based on config state.

## [2026-06-16] - Android Arch Batch A4: design-token compliance sweep
**What changed:**
- Replaced 165 raw `.dp` values with `CoffeeSpacing.*` tokens across all feature screens: CreateScreen (3), DriftsScreen (17), DriftDetailScreen (28), DiscoveryScreen (23), ChatScreen (4), ChatThreadScreen (11), ProfileScreen (3), ProfileEditScreen (10), AuthScreen (19), ProfileSetupScreen (1), OnboardingScreen (43), CoffeeCallApp (3).
- Replaced spacing values like `padding(16.dp)` → `padding(CoffeeSpacing.md)`, `height(56.dp)` → `height(CoffeeSpacing.primaryButtonHeight)`, `size(44.dp)` → `size(CoffeeSpacing.minTouchTarget)`, etc.
- Remaining raw `.dp` values are intentional: border widths (1.dp), shadows (2.dp), RoundedCornerShape radii, and component-specific dimensions with no token equivalent.
- Zero raw hex `Color(0x...)` found (already cleaned in Batch 1). Zero hardcoded `fontSize` found (already using `MaterialTheme.typography`).

**Why:**
- iOS forces all spacing/typography/colors through tokens for visual consistency. Android previously had ~535 raw `.dp` values. This sweep brings Android to near-zero token violations for spacing/padding, matching iOS's token discipline.

## [2026-06-16] - Android Arch Batch A3: mock repository parity + RepositoryProvider
**What changed:**
- Created `data/repository/mock/` directory with lightweight mock/fake implementations for all 6 repository interfaces: `MockUserRepository`, `MockPostRepository`, `MockAcceptanceRepository`, `MockMessageThreadRepository`, `MockAuthRepository`, `MockReportRepository`.
- Mock repos use in-memory data structures with seeded realistic data (profiles, drifts, threads, messages) for offline/preview behavior when `google-services.json` is absent.
- Created `data/repository/RepositoryProvider.kt` — a singleton factory that returns the correct Firebase or mock implementation based on `FirebaseInitializer.currentState()`.
- All mock implementations mirror the Firebase impl method signatures exactly, making the Firebase/mock pairing obvious and discoverable.

**Why:**
- iOS pairs each service protocol with Firebase + mock/preview impls and a documented offline path. Android previously had no mock implementations, so the app crashed or showed empty screens when Firebase config was absent. This closes that gap.

## [2026-06-16] - Android Arch Batch A2: shared NavigationManager
**What changed:**
- Created `core/navigation/NavigationManager.kt` as a singleton shared state holder with `isTabBarHidden: StateFlow<Boolean>` and `activeInterestFilter: StateFlow<String?>`.
- In `CoffeeCallApp`, the floating bottom nav now auto-hides on detail/chat/profile-edit routes via `NavigationManager.isTabBarHidden`.
- Discovery interest taps now write to `NavigationManager.activeInterestFilter` instead of using ad-hoc local state, and Drifts reads from the shared manager.
- Removed the `activeInterestFilter` parameter from `DriftsScreen` — it now reads from `NavigationManager` directly.

**Why:**
- iOS centralizes tab-bar visibility (hidden on detail/chat) and passes the Discovery interest filter into Drifts through a shared `NavigationManager`. Android previously used scattered local state, which could drift. This closes that architecture gap.

## [2026-06-16] - Android Arch Batch A1: shared GlobalDriftStore
**What changed:**
- Created `core/state/GlobalDriftStore.kt` as an app-scoped singleton providing a single source of truth for drifts via `StateFlow<List<DriftPost>>`.
- GlobalDriftStore owns all repository calls: `fetch()`, `refresh()`, `createPost()`, `requestToJoin()`, `cancelJoinRequest()`, `acceptJoinRequest()`, `rejectJoinRequest()`, `leavePost()`, `updatePostStatus()`, `upsertPost()`.
- Store maintains a derived `notifications: StateFlow<List<DiscoveryNotification>>` from hosted/joined drift join requests and status changes.
- Refactored `DriftsViewModel` to observe `store.drifts` instead of calling `PostRepository` directly.
- Refactored `DriftDetailViewModel` to observe `store.drifts` and use `store.fetchPost()` / store mutation methods instead of calling `PostRepository` directly.
- Refactored `DiscoveryViewModel` to observe `store.notifications` instead of calling `PostRepository` directly for notification data.
- Removed duplicate per-screen repository calls — all drift state mutations now flow through the shared store.

**Why:**
- iOS has one app-scoped `GlobalDriftStore` source of truth; cross-screen updates (join/leave/new drift) propagate everywhere. Android previously had each ViewModel fetch independently, so state could diverge between Discovery/Drifts/Detail. This closes that architecture gap.

## [2026-06-16] - Android Parity Batch P8: Auth + Onboarding
**What changed:**
- Refreshed PhoneEntryView and OtpVerificationView with the premium design system (CoffeeBackground, CoffeeSurface, CoffeeIcons).
- Added country code picker and character-box styling for OTP entry.
- Updated ProfileSetupScreen with the immersive style, including photo picker integration and CoffeeAvatar.
- Applied sticky bottom button patterns using CoffeeButton.

**Why:**
- To bring the authentication and profile setup flows into visual parity with the iOS app's refreshed design.

## [2026-06-16] - Android Parity Batch P7: Chats parity
**What changed:**
- Added status filter chips (Active, Upcoming, Past) to the Chats list screen.
- Added context chips (Title, Category, Location) to the top of chat threads.
- Implemented an attachment menu in the chat composer with options for Camera, Photo Library, and Location sharing.
- Added a thread detail sheet with actions for Mute, View Drift, Report, Block, and Leave.
- Integrated system message rows for centered notices within the chat stream.

**Why:**
- To match the iOS chat features and management options listed in the widget mapper.

## [2026-06-16] - Android Parity Batch P6: Drift Detail privacy guardrails
**What changed:**
- Kept exact meeting point rendering locked to joined users and hosts.
- Changed calendar export text so non-joined users do not receive exact meeting point details.
- Replaced the always-visible participant strip with a guarded participants section: pre-join shows count/limited initials only, while joined users see full participant rows when available.
- Left precise map opening available only from the joined location section.

**Why:**
- To match iOS privacy behavior for exact meeting points and participant details before a user joins a drift.

## [2026-06-16] - Android Parity Batch P5: Host management parity
**What changed:**
- Kept host management folded into `DriftDetailScreen` instead of adding a separate route, matching the current Android detail architecture.
- Added a host-only management panel with overview counts, share, edit, close, delete, chat entry, participant chips, and a safety reminder.
- Added host edit, close, and delete actions in `DriftDetailViewModel`; close uses the existing status update path and delete removes the post/chat documents without changing schemas.
- Preserved the existing pending join request panel with accept/reject actions.

**Why:**
- To give Android hosts the iOS ManageDriftScreen controls while keeping the change scoped to Drift Detail presentation and view-model action wiring.

## [2026-06-16] - Android Parity Batch P4: Profile parity
**What changed:**
- Rebuilt the Profile screen around the iOS mapper sections: identity card with large `CoffeeAvatar`, verified-phone pill, approximate location, interest chips, and edit action.
- Added four tappable stat tiles for hosted, joined, no-shows, and score, each opening a detail bottom sheet.
- Added saved/recent drift and activity-log sections that route drift cards/rows to drift detail using existing drift history data.
- Added preference rows and sheets for Interests, Availability, Notifications, and Privacy/Safety; interests and availability persist through the existing profile update path, while notification/privacy toggles persist locally.
- Added account rows for Location, Help, and Sign out; Location can update via the existing GPS/geocode helper and Sign out uses the existing auth sign-out flow.

**Why:**
- To bring Android Profile behavior and widget coverage in line with the current iOS Profile mapper without changing schemas or iOS code.

## [2026-06-16] - Android Parity Batch P3: Notifications sheet
**What changed:**
- Added a Discovery notifications bottom sheet with non-empty and empty states.
- Replaced the Discovery bell Toast with sheet presentation and kept the unread dot tied to available notification items.
- Derived notification rows from existing hosted drift join requests and joined drift updates without adding new data models or schemas.
- Wired notification row taps to dismiss the sheet and navigate to the matching drift detail by ID.

**Why:**
- To match iOS behavior, where the Discovery bell opens a notifications sheet and notifications route into their drift context.

## [2026-06-16] - Android Parity Batch P2: Discovery radar-only
**What changed:**
- Removed the Discovery meetup card feed, search field, and category filter chips so Around is radar-first instead of a hybrid feed.
- Removed Discovery's nearby-post fetch/state from the embedded view model, leaving radar people and interest categories as the screen model.
- Kept the presence toggle, timed refresh scan, radar parallax, draggable bottom sheet, drifts-forming pill, and interest grid.
- Wired the drifts-forming pill to open Drifts and wired interest cards to open Drifts with a visible, clearable category filter.

**Why:**
- To match iOS, where Discovery is an anonymous radar/interest surface and meetup cards live on the Drifts tab.

## [2026-06-16] - Android Parity Batch P1: Create as modal + 4-tab nav
**What changed:**
- Removed Create from the Android bottom navigation destinations so the tab bar now exposes Discovery, Drifts, Chats, and Profile only.
- Added a raised center plus action inside the Android bottom nav that opens `CreateScreen` in a Material3 `ModalBottomSheet` without selecting a tab.
- Routed successful create completion to dismiss the sheet and navigate to the Drifts tab.
- Removed the standalone Create NavHost destination and unused create route constant after verifying there are no create deep links.

**Why:**
- To match the iOS app shell, where Create is a modal center action instead of a persistent tab.

## [2026-06-16] - Android UI Refresh Audit & Status Reconciliation
**What changed:**
- Audited Android UI Refresh batches against the Kotlin implementation and Figma Make `.tsx` references instead of trusting prior logs.
- Updated `docs/ANDROID_UI_REFRESH_HANDOFF.md` to mark Batches 1–3 and 5–7 Done, and Batches 4, 8, 9, and 10 Partial.
- Corrected the next-action handoff to finish Discovery parity first.

**Why:**
- The previous handoff status said only Batches 1–4 were complete and Batches 5–10 remained, while the code already contains substantial migrated work in later screens and still has partial gaps in Discovery/Profile/Auth/Shell.

## [2026-06-16] - Android UI Refresh Batch 7: Chat Screens (logged retroactively after code audit)
**What changed:**
- Verified `feature/chat/ChatScreen.kt` renders refreshed thread cards with `CoffeeAvatar`, rounded surfaces, category badges, timestamps, last-message snippets, and unread indicators.
- Verified `feature/chat/ChatThreadScreen.kt` renders mint self bubbles, surface-toned other bubbles, rounded composer/input bar, `CoffeeIcons.send`, attachment/location actions, and refreshed safety dialogs using `CoffeeButton`.

**Why:**
- The UI refresh work is present in code but was not logged as an Android UI Refresh batch entry.

## [2026-06-16] - Android UI Refresh Batch 6: Create Screen (logged retroactively after code audit)
**What changed:**
- Verified `feature/create/CreateScreen.kt` renders the refreshed activity chip grid, vibe/date/time/capacity/join-mode selectors, rounded section cards and inputs, location picker dialog, status card, and primary `CoffeeButton` CTA.

**Why:**
- The UI refresh work is present in code but was not logged as an Android UI Refresh batch entry.

## [2026-06-16] - iOS Screen And Widget Mapper
**What changed:**
- Added `docs/IOS_SCREEN_WIDGET_MAPPER.md`, a point-to-point SwiftUI responsibility map from the authenticated Home/Around screen through Drifts, Create, Detail/Manage, Chat, and Profile.
- Linked the mapper from `CURRENT_STATE.md` so future agents can find the iOS screen ownership notes before relying on Android-heavy changelog entries.

**Why:**
- To reflect the newer iOS screen/widget responsibilities in durable project notes and reduce confusion when the changelog is focused on Android migration work.

## [2026-06-15] - Android UI Refresh Batch 5: Drifts & Drift Detail Screen
**What changed:**
- Redesigned the `DriftsScreen.kt` to use `CoffeeDriftCard`, the new immersive, photo-forward card from the refreshed design components, replacing the legacy custom-built `DriftCard`.
- Updated `DriftsScreen` error state button to use `CoffeeButton`.
- Upgraded the `DriftDetailScreen.kt` hero image overlay to feature the host's `CoffeeAvatar` and a dynamically colored `CoffeeGlassBadge` for the category.
- Converted inline avatar loops for participants to use the new `CoffeeAvatar` component.
- Updated all CTA actions in the floating bottom bar (Join, Chat Room, Leave) to use `CoffeeButton` variants.
- Replaced buttons and avatars inside `HostContextCard` and `HostRequestsPanel` with `CoffeeAvatar` and `CoffeeButton`.

**Why:**
- To migrate the Drifts tab list view and the detailed view screen to the modern premium design system components, improving visual consistency and aligning with the "Social Refresh" spec.

## [2026-06-15] - Android Discovery Screen Polish & Parity
**What changed:**
- Adjusted bottom sheet collapsed height from 290dp offset to half screen (`screenHeight / 2`) and restricted drag gestures strictly between expanded and half-screen targets.
- Added a floating translucent circular refresh button on the bottom right of the screen (fades out as sheet expands).
- Added `isScanning` state to `DiscoveryUiState` and `refreshNearby()` to `DiscoveryViewModel` (runs 3s scanning timer).
- Bound background radar layer's scale, opacity, and blur attributes to the sheet drag progress to create a smooth parallax effect.
- Updated `AroundRadar` to only show and animate the sweep rotation line while scanning.
- Mapped `Icons.Rounded.Refresh` in `CoffeeIcons.kt`.
- Styled interest grid items inside the bottom sheet as premium visual cards.

**Why:**
- To bring the native Android Discovery screen to exact visual and behavioral parity with the premium iOS screen's bottom sheet offsets, radar sweep animation rules, and interest grid layouts.

## [2026-06-15] - Android UI Refresh Batch 4: Discovery Screen
**What changed:**
- Redesigned the Discovery Screen (`feature/discovery/DiscoveryScreen.kt`) to match the Figma "Social Refresh" layout:
  - Custom top header displaying "Hey {name}" and a count of active nearby meetups.
  - Interactive header actions: presence toggle, notifications bell with dot indicator, and profile photo avatar (`CoffeeAvatar`). Code audit note: the Figma map view toggle is still missing.
  - Implemented search input bar with live client-side filtering on drift titles, hooks, locations, and host names.
  - Added horizontal scrollable LazyRow of category filter chips (All, Coffee, Walks, Study, Food, Gaming, Creative) with matching real vector icons.
  - Replaced legacy list cards with the new immersive, photo-forward `CoffeeDriftCard`.
  - Added bottom-right floating slate-dark Plus FAB.
  - Implemented Join/Accept modal popup (`showAcceptModal`) and Match Confirmed overlay (`showMatchModal`) in Jetpack Compose.
  - Code audit note: the notifications bell currently shows a Toast rather than the Figma notifications view/sheet.
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
