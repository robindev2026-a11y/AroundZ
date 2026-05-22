# CoffeeCall Screen Review Checklist

Status: ACTIVE
Last updated: 2026-05-22

This document tracks issues identified during screen-by-screen code reviews. 

## Active Specs
- `docs/CONTEXT.md`
- `docs/STATUS.md`
- `docs/DESIGN.md`
- `docs/PLAN.md`
- `docs/ARCHITECTURE.md`

---

## Screen Ledger

### 1. Around / Discovery
Spec anchors:
- `Around` is the first post-login screen.
- Must stay activity-first, not people-browsing.
- Must use approved radar, context card, interests grid, and floating bottom nav.

Primary files:
- [DiscoveryScreen.swift](file:///Users/developer/Documents/Projects/CoffeeCall/apps/frontend/Coffee_Call/Screens/Main/DiscoveryScreen.swift)
- [RadarView.swift](file:///Users/developer/Documents/Projects/CoffeeCall/apps/frontend/Coffee_Call/Components/RadarView.swift)
- [DiscoveryViewModel.swift](file:///Users/developer/Documents/Projects/CoffeeCall/apps/frontend/Coffee_Call/ViewModels/DiscoveryViewModel.swift)
- [CoffeeHeader.swift](file:///Users/developer/Documents/Projects/CoffeeCall/apps/frontend/Coffee_Call/Components/Navigation/CoffeeHeader.swift)

Completed Issues:
- [x] ISSUE-001 (P1 UI): Radar person tooltip overflows off-screen. Fixed with edge-clamped tooltip positioning.
- [x] ISSUE-002 (P1 UX): Tooltip showing "Start Drift" CTA. Changed to show anonymous active interests only.
- [x] ISSUE-003 (P1 State): Discovery grid hardcoded data. Moved to dynamic protocol-based dependency injection.
- [x] ISSUE-004 (P1 Navigation): Interest card click routing. Tapping an interest card now routes to Drifts screen with category filter active.
- [x] ISSUE-005 (P3 UX): Retain name/avatar support in radar data model. Supported in backend fields but kept anonymous in UI.
- [x] ISSUE-037 (P1 Perf): Firebase live presence listener and eager location checks. Changed to one-time snapshot caching and throttled location writes.
- [x] ISSUE-038 (P1 Privacy): User Online/Offline presence toggle in header. Offline hides user from radar snapshots.

---

### 2. Drifts / Listing
Spec anchors:
- `Nearby` and `My Drifts` segments must be clear and accessible.
- Must answer what the user can join and what they are already part of.
- Must not become a people browser.

Primary files:
- [DriftsScreen.swift](file:///Users/developer/Documents/Projects/CoffeeCall/apps/frontend/Coffee_Call/Screens/Main/DriftsScreen.swift)
- [DriftCard.swift](file:///Users/developer/Documents/Projects/CoffeeCall/apps/frontend/Coffee_Call/Components/DriftCard.swift)
- [DriftsViewModel.swift](file:///Users/developer/Documents/Projects/CoffeeCall/apps/frontend/Coffee_Call/ViewModels/DriftsViewModel.swift)

Completed Issues:
- [x] ISSUE-006 (P1 UX): Non-working search/filter buttons in header. Wired search toggle and radius filter sheet.
- [x] ISSUE-007 (P1 State): Unused search text query. Integrated dynamic search filter in view model.
- [x] ISSUE-008 (P1 Navigation): Handoff from Around to Drifts. Linked Around category click to Drifts screen filtering.
- [x] ISSUE-009 (P2 Architecture): Injected dependency data source. Created protocol-based service and mock data source.

---

### 3. Create
Spec anchors:
- Sheet must feel fast, peaceful, warm, and activity-first.
- Host details and coordinates must be approximate.

Primary files:
- [CreateDriftButton.swift](file:///Users/developer/Documents/Projects/CoffeeCall/apps/frontend/Coffee_Call/Components/CreateDriftButton.swift)
- [CreateDriftScreen.swift](file:///Users/developer/Documents/Projects/CoffeeCall/apps/frontend/Coffee_Call/Screens/Main/CreateDriftScreen.swift)
- [CreateDriftViewModel.swift](file:///Users/developer/Documents/Projects/CoffeeCall/apps/frontend/Coffee_Call/ViewModels/CreateDriftViewModel.swift)

Completed Issues:
- [x] ISSUE-010 (P1 UX): Outdated compose UI. Implemented premium sliding bottom sheet compose flow.
- [x] ISSUE-028 (P1 UI): Sheet close button scrolling away. Fixed in sticky header slot.
- [x] ISSUE-029 (P1 UX): Custom activity input. Custom grid option opens inline text input.
- [x] ISSUE-030 (P1 UI): Folded activity grid. Standard grid limited to 6 elements with dynamic "View more" toggle.
- [x] ISSUE-031 (P1 UX): Preset time chips. Swapped with inline date/time picker controls.
- [x] ISSUE-032 (P2 UI): Capacity buttons layout. Replaced with compact horizontal scrollwheel number picker.
- [x] ISSUE-033 (P1 UI): Wide join mode cards. Replaced with grid pattern fitting small devices.
- [x] ISSUE-034 (P2 UX): Nested vibe sheets. Replaced with inline context menu vibe selector.
- [x] ISSUE-035 (P0 State): Missing validation. Added dynamic validation gating the "Post Drift" CTA.
- [x] ISSUE-036 (P0 Navigation): Post creation list update. Registered `CreatedDriftStore` to propagate new drifts instantly.

---

### 4. Chats Home
Spec anchors:
- Drift-tied conversations only. No cold direct messaging.

Primary files:
- [ChatsListScreen.swift](file:///Users/developer/Documents/Projects/CoffeeCall/apps/frontend/Coffee_Call/Screens/Main/ChatsListScreen.swift)
- [ChatsViewModel.swift](file:///Users/developer/Documents/Projects/CoffeeCall/apps/frontend/Coffee_Call/ViewModels/ChatsViewModel.swift)

Completed Issues:
- [x] ISSUE-026 (P1 UI): Remove experimental Bubble Field UI for MVP scope. Stripped bubbles and animations, keeping compact Instagram-style rooms list.

---

### 5. Drift Chat / Thread
Spec anchors:
- Async coordination only. Chat unlocks after joining or hosting.

Primary files:
- [DriftChatScreen.swift](file:///Users/developer/Documents/Projects/CoffeeCall/apps/frontend/Coffee_Call/Screens/Main/DriftChatScreen.swift)
- [DriftChatViewModel.swift](file:///Users/developer/Documents/Projects/CoffeeCall/apps/frontend/Coffee_Call/ViewModels/DriftChatViewModel.swift)

Completed Issues:
- [x] ISSUE-018 (P1 Navigation): Chat thread showing bottom navigation. Hidden tab bar dynamically during navigation.
- [x] ISSUE-019 (P1 UX): Dead composer actions and attachments. Removed attachment button, polished text/color contrast.
- [x] ISSUE-020 (P1 Policy): Reachable chat prior to host acceptance. Added request/accept gating; chat is disabled for pending requests.
- [x] ISSUE-021 (P2 Architecture): Local mock chat history. Decoupled and protocol-oriented chat service thread loading.

---

### 6. Drift Detail
Spec anchors:
- Pre-join displays approximate location and join requests.
- Post-join unlocks exact coordination map pins and chat access.

Primary files:
- [DriftDetailScreen.swift](file:///Users/developer/Documents/Projects/CoffeeCall/apps/frontend/Coffee_Call/Screens/Main/DriftDetailScreen.swift)
- [DriftDetailViewModel.swift](file:///Users/developer/Documents/Projects/CoffeeCall/apps/frontend/Coffee_Call/ViewModels/DriftDetailViewModel.swift)

Open Issues:
- [ ] **ISSUE-012**
  - Priority: P1
  - Type: State, Feature completeness
  - Summary: Share and reminder actions are visible but only stubbed.
  - Expected: Each action should have a real destination or sheet, or be hidden until available.
  - Notes: `shareDrift()` and `setReminder()` only print to console. `saveDrift()` is implemented via BookmarkManager.
  - Files: [DriftDetailViewModel.swift](file:///Users/developer/Documents/Projects/CoffeeCall/apps/frontend/Coffee_Call/ViewModels/DriftDetailViewModel.swift), [DriftDetailScreen.swift](file:///Users/developer/Documents/Projects/CoffeeCall/apps/frontend/Coffee_Call/Screens/Main/DriftDetailScreen.swift)
  - Status: Open
  - Owner: Unassigned

Completed Issues:
- [x] ISSUE-010 (P1 Layout): Detail header margin layout spacing. Adjusted paddings.
- [x] ISSUE-011 (P1 Layout): Too much vertical space below hero text. Tightened layout stack.
- [x] ISSUE-013 (P1 Navigation): Hosted-by row action. Tapping now displays recursive Host Context Card sheet.
- [x] ISSUE-014 (P1 UX): Participant "See all" action. Opens "Who's Coming" interest-matching sheet.
- [x] ISSUE-015 (P0 Policy): Instant joining instead of requesting. Request sent to Firestore transaction pipeline.
- [x] ISSUE-016 (P1 UX): No request-sent confirmation. Added active status indicators.
- [x] ISSUE-017 (P1 Feature): Pre-join vs post-join location map states. Shows 500m area ring pre-join, pin/deep-link post-join.
- [x] ISSUE-027 (P1 Feature): Bookmarked watch-list. Integrated BookmarkManager local storage syncing.

---

### 7. Profile / You
Spec anchors:
- Privacy-first lightweight stats card, preferences, and activity list.

Primary files:
- [ProfileScreen.swift](file:///Users/developer/Documents/Projects/CoffeeCall/apps/frontend/Coffee_Call/Screens/Main/ProfileScreen.swift)
- [EditProfileScreen.swift](file:///Users/developer/Documents/Projects/CoffeeCall/apps/frontend/Coffee_Call/Screens/Main/EditProfileScreen.swift)
- [ProfileViewModel.swift](file:///Users/developer/Documents/Projects/CoffeeCall/apps/frontend/Coffee_Call/ViewModels/ProfileViewModel.swift)

Open Issues:
- [ ] **ISSUE-022**
  - Priority: P1
  - Type: Feature completeness, State
  - Summary: Edit Profile exposes change-photo affordances but has no working image capture/upload flow or supporting profile image model.
  - Expected: User should be able to pick or capture a profile image, and profile data should store that image reference cleanly.
  - Notes: Camera buttons are present in `EditProfileScreen`, but actions are empty and `ProfileViewModel` has no profile image property.
  - Files: [EditProfileScreen.swift](file:///Users/developer/Documents/Projects/CoffeeCall/apps/frontend/Coffee_Call/Screens/Main/EditProfileScreen.swift), [ProfileViewModel.swift](file:///Users/developer/Documents/Projects/CoffeeCall/apps/frontend/Coffee_Call/ViewModels/ProfileViewModel.swift)
  - Status: Open
  - Owner: Unassigned

Completed Issues:
- [x] ISSUE-023 (P2 Architecture): Profile data persistence. Swapped view-local stubs with UserDefaults caching and CRUD sync.

---

### 8. Auth / Onboarding
Spec anchors:
- Phone signup, OTP, location permission, and basic profile setup screens.

Primary files:
- [OnboardingScreen.swift](file:///Users/developer/Documents/Projects/CoffeeCall/apps/frontend/Coffee_Call/Screens/OnboardingScreen.swift)
- [PhoneAuthScreen.swift](file:///Users/developer/Documents/Projects/CoffeeCall/apps/frontend/Coffee_Call/Screens/Auth/PhoneAuthScreen.swift)
- [OTPVerificationScreen.swift](file:///Users/developer/Documents/Projects/CoffeeCall/apps/frontend/Coffee_Call/Screens/Auth/OTPVerificationScreen.swift)

Completed Issues:
- [x] Auth Loops: Resolved returning-user OTP and launch loops, routing directly to the main feed if profile is already configured.

---

### Cross-Screen / Test Gaps
Completed Issues:
- [x] ISSUE-024 (P1 Test): Scaffold test coverage. Added targeted unit tests for auth state, chat services, and bookmark toggling.
