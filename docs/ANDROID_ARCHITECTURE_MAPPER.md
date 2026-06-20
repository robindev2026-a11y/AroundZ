# Android Architecture & iOS Parity Mapper

This document maps the native Android architecture and screen components directly against the `IOS_SCREEN_WIDGET_MAPPER.md` to prove that the Android client follows the exact same design patterns, state management, and visual hierarchy as the canonical iOS app.

## Entry And App Shell

| iOS Concept | Android Implementation | Status |
| --- | --- | --- |
| `App/ContentView.swift` | `CoffeeCallApp.kt` | ✅ Matches. Uses `AuthRoute` state to switch between Loading, Onboarding, Auth, ProfileSetup, and App Shell. |
| `MainTabView.swift` | `CoffeeCallAppShell` in `CoffeeCallApp.kt` | ✅ Matches. Owns the authenticated tab experience using `NavHost` and bottom navigation. |
| `FloatingTabBar.swift` | `CoffeeBottomNav` in `CoffeeCallApp.kt` | ✅ Matches. Floating navigation bar with Discovery, Drifts, Chats, and Profile. Uses an unindexed center button for Create. |
| `CoffeeHeader.swift` | `CoffeeTopAppBar` in `Components.kt` | ✅ Matches. Reusable header providing title, subtitle, and an action button (e.g., settings gear). |
| `GlobalDriftStore.swift` | `GlobalDriftStore.kt` | ✅ Matches. App-scoped singleton (`StateFlow`) acting as the single source of truth for drifts and notifications. |
| `NavigationManager.swift` | `NavigationManager.kt` | ✅ Matches. Shared state for hiding the tab bar (`isTabBarHidden`) on detail screens and managing interest filters. |

## Home / Around: Discovery

| iOS Concept | Android Implementation | Status |
| --- | --- | --- |
| `DiscoveryScreen.swift` | `DiscoveryScreen.kt` | ✅ Matches. Home screen combining radar, refresh, and bottom sheet. |
| Radar world | `CoffeeRadarView` | ✅ Matches. Anonymous presence visualization with rings, sweep animation, and initials. |
| Refresh button | `DiscoveryScreen.kt` (CTA) | ✅ Matches. Triggers radar scan animation and view model refresh. |
| Bottom sheet | `ModalBottomSheet` | ✅ Matches. Draggable sheet containing interest cards. |
| Interest grid | `InterestCard` | ✅ Matches. Category cards that apply filters to `NavigationManager` and route to Drifts. |
| Notifications | `DiscoveryNotificationsSheet` | ✅ Matches. Opens from the bell icon, showing join requests and updates. |
| `DiscoveryViewModel` | `DiscoveryViewModel.kt` | ✅ Matches. Injected via `RepositoryProvider`, managing radar state. |

## Drifts List

| iOS Concept | Android Implementation | Status |
| --- | --- | --- |
| `DriftsScreen.swift` | `DriftsScreen.kt` | ✅ Matches. Filterable list routing owned to Manage and others to Detail. |
| Mode switch | `CoffeeSegmentedControl` | ✅ Matches. Toggles between Discover (non-hosted) and Mine (hosted). |
| Filter button/sheet | `ModalBottomSheet` | ✅ Matches. Contains Distance slider, Time chips, and Activity Type grid. |
| Standard cards | `CoffeeDriftCard` | ✅ Matches. Unified photo-forward card component used across the app. |
| `DriftsViewModel` | `DriftsViewModel.kt` | ✅ Matches. Observes `GlobalDriftStore` and manages local filter state. |

## Drift Detail And Host Management

| iOS Concept | Android Implementation | Status |
| --- | --- | --- |
| `DriftDetailScreen.swift` | `DriftDetailScreen.kt` | ✅ Matches. Hides tab bar, syncs with store, owns join/request routing. |
| Summary grid | `DriftDetailScreen.kt` | ✅ Matches. 2x2 grid for Date/Location/Distance/Participants. |
| Host / Participants | `DriftDetailScreen.kt` | ✅ Matches. Locked privacy before join; expands initials/rows after join. |
| Sticky CTA | `CoffeeButton` (Bottom sticky) | ✅ Matches. Context-aware label (Manage, Open Chat, Join, Request). |
| `ManageDriftScreen.swift` | `DriftDetailScreen.kt` (Host View) | ✅ Matches. Host management is folded into the detail screen with Edit/Close/Delete and request management. |
| `DriftDetailViewModel` | `DriftDetailViewModel.kt` | ✅ Matches. Handles request/cancel/leave and participant fetching. |

## Chats

| iOS Concept | Android Implementation | Status |
| --- | --- | --- |
| `ChatsListScreen.swift` | `ChatScreen.kt` | ✅ Matches. Lists accessible chat rooms with status chips (Active/Joined/Hosted/Expired). |
| `CompactChatRow` | `ChatThreadCard` | ✅ Matches. Shows category icon, title, last message, timestamp. |
| `DriftChatScreen.swift` | `ChatThreadScreen.kt` | ✅ Matches. Hides tab bar, shows context chips, thread messages, and composer. |
| `ChatComposer` | `ChatComposer` | ✅ Matches. Input with attachment dialog for Camera/Library/Location. |
| `DriftChatDetailSheet` | `ChatThreadScreen.kt` | ✅ Matches. Thread info sheet with Mute/Report/Leave actions. |
| `DriftChatViewModel` | `ChatThreadViewModel.kt` | ✅ Matches. Sends messages and manages thread lifecycle via Firebase/Mock. |

## Profile

| iOS Concept | Android Implementation | Status |
| --- | --- | --- |
| `ProfileScreen.swift` | `ProfileScreen.kt` | ✅ Matches. Shows identity card, private stats, saved drifts, and preference sections. |
| Identity card | `IdentityCard` | ✅ Matches. Large `CoffeeAvatar`, verified pill, approximate location, interests, and edit button. |
| Stats section | `ProfileStatTile` | ✅ Matches. Four tiles (Hosted, Joined, No-Shows, Score). |
| Settings rows | `ProfileSettingsRow` | ✅ Matches. Color-coded icon rows for Interests, Availability, Notifications, Privacy, Location, Help, Sign Out. |
| `ProfileViewModel` | `ProfileViewModel.kt` | ✅ Matches. Syncs with Firebase users collection and local `ProfilePreferencesRepository`. |

## Dependency Injection

| iOS Concept | Android Implementation | Status |
| --- | --- | --- |
| `@EnvironmentObject` | `RepositoryProvider.kt` | ✅ Matches. A singleton factory ensuring all ViewModels receive the same Firebase or Mock repository implementation consistently, avoiding detached states. |
