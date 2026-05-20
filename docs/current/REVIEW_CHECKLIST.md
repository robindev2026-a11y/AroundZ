# CoffeeCall Screen Review Checklist

Status: ACTIVE
Last updated: 2026-05-19

This document is the live issue ledger for our screen-by-screen review. We log issues exactly as reported, then convert them into clean parallel fix batches once a screen review is complete.

Active spec followed for UI review:
- `docs/current/CONTEXT.md`
- `docs/current/STATUS.md`
- `docs/current/DESIGN.md`
- `docs/current/PLAN.md`
- `docs/current/ARCHITECTURE.md`

## Review Workflow

1. Review one screen at a time.
2. Log each issue in the relevant screen section.
3. Mark each issue with:
   - `Priority`: `P0`, `P1`, `P2`, or `P3`
   - `Type`: `UX`, `UI`, `Copy`, `Navigation`, `State`, `Accessibility`, `Performance`, or `Spec mismatch`
   - `Status`: `Open`, `Ready for fix`, `In progress`, `Blocked`, or `Done`
   - `Owner`: unassigned until we split work
4. After a screen review is complete, move the ready items into agent batches.

## Priority Guide

- `P0`: broken flow, blocker, or direct violation of core product rules
- `P1`: major UX mismatch or important visual/interaction issue
- `P2`: moderate polish or consistency issue
- `P3`: minor refinement or cleanup

## Parallel Fix Board

| Batch | Scope | Files | Items | Owner | Status |
|---|---|---|---|---|---|
| Batch A | Around / Discovery | RadarView.swift, DiscoveryScreen.swift | 5 | Agent | Done |
| Batch B | Drifts / Listing | DriftsScreen.swift, DriftsViewModel.swift | 4 | Agent | Done |
| Batch C | Chat / Thread | DriftChatScreen.swift, DriftChatViewModel.swift | 4 | Agent | Done |

## Screen Ledger

### 1. Around / Discovery

Spec anchors:
- `Around` is the first post-login screen
- Must stay activity-first, not people-browsing
- Must use approved radar, context card, interests grid, and floating bottom nav

Primary files:
- `apps/frontend/Coffee_Call/Coffee_Call/Screens/Main/DiscoveryScreen.swift`
- `apps/frontend/Coffee_Call/Coffee_Call/Components/RadarView.swift`
- `apps/frontend/Coffee_Call/Coffee_Call/ViewModels/DiscoveryViewModel.swift`
- `apps/frontend/Coffee_Call/Coffee_Call/Components/Navigation/CoffeeHeader.swift`

- [x] ISSUE-001
  - Screen: Around / Discovery
  - Priority: P1
  - Type: UI, Spec mismatch
  - Summary: Radar person tooltip is hard-positioned and can overflow off-screen when the selected person is near an edge.
  - Expected: Tooltip should clamp or re-anchor dynamically so it stays fully visible within the radar bounds and feels native to the radar UI.
  - Status: Done
  - Owner: Agent

- [x] ISSUE-002
  - Screen: Around / Discovery
  - Priority: P1
  - Type: UX, Spec mismatch
  - Summary: Radar tooltip currently includes a `Start Drift` CTA, but the review direction is to show only the anonymous interests signal.
  - Expected: Tooltip should focus on the person's active interests only, without direct action clutter.
  - Status: Done
  - Owner: Agent

- [x] ISSUE-003
  - Screen: Around / Discovery
  - Priority: P1
  - Type: State, Architecture
  - Summary: Nearby interests grid data is hardcoded in `DiscoveryViewModel` and the screen creates its own view model instead of receiving injected dependencies.
  - Expected: Discover data should come from an injected source or protocol-backed service.
  - Status: Done
  - Owner: Agent

- [x] ISSUE-004
  - Screen: Around / Discovery
  - Priority: P1
  - Type: Navigation, Spec mismatch
  - Summary: Tapping an interest card does nothing today.
  - Expected: Interest tap should route to Drifts with `Nearby` selected and that interest applied as a filter.
  - Status: Done
  - Owner: Agent

- [x] ISSUE-005
  - Screen: Around / Discovery
  - Priority: P3
  - Type: UX direction
  - Summary: Keep light identity hints like name and image support in the Around radar data model.
  - Status: Done
  - Owner: Agent

### 2. Drifts / Listing

Spec anchors:
- `Nearby` and `My Drifts` access must be clear
- Must answer what the user can join and what they are already part of
- Must not become a people browser

Primary files:
- `apps/frontend/Coffee_Call/Coffee_Call/Screens/Main/DriftsScreen.swift`
- `apps/frontend/Coffee_Call/Coffee_Call/Components/DriftCard.swift`
- `apps/frontend/Coffee_Call/Coffee_Call/ViewModels/DriftsViewModel.swift`
- `apps/frontend/Coffee_Call/Coffee_Call/Components/Navigation/CoffeeHeader.swift`

Issues:
- [x] ISSUE-006
  - Screen: Drifts / Listing
  - Priority: P1
  - Type: UX, Spec mismatch
  - Summary: Drifts header shows a search button and a filter button, but neither action presents working UI.
  - Status: Done
  - Owner: Agent

- [x] ISSUE-007
  - Screen: Drifts / Listing
  - Priority: P1
  - Type: State, Performance
  - Summary: Search state exists in the view model but is unused.
  - Status: Done
  - Owner: Agent

- [x] ISSUE-008
  - Screen: Drifts / Listing
  - Priority: P1
  - Type: Navigation, Spec mismatch
  - Summary: There is no current category filter handoff from Around to Drifts.
  - Status: Done
  - Owner: Agent

- [x] ISSUE-009
  - Screen: Drifts / Listing
  - Priority: P2
  - Type: Architecture
  - Summary: Drifts screen owns its own view model and mock data instead of taking injected data sources.
  - Status: Done
  - Owner: Agent

### 3. Create

Active spec:
- `docs/current/DESIGN.md`

Primary files:
- `apps/frontend/Coffee_Call/Coffee_Call/Components/CreateDriftButton.swift`
- `apps/frontend/Coffee_Call/Coffee_Call/Screens/Main/MainTabView.swift`
- `apps/frontend/Coffee_Call/Coffee_Call/ViewModels/CreateDriftViewModel.swift`
- `apps/frontend/Coffee_Call/Coffee_Call/Screens/Main/CreateDriftScreen.swift`

- [x] ISSUE-010
  - Screen: Create
  - Priority: P1
  - Type: UX, Spec mismatch
  - Summary: Replace the old generic Create UI with a premium Create Drift bottom sheet launched from the center tab bar action.
  - Expected: Create should feel warm, fast, and activity-first with a sheet layout matching the approved reference and CoffeeCall design tokens.
  - Status: Done
  - Owner: Agent

- [x] ISSUE-028
  - Screen: Create
  - Priority: P1
  - Type: UI, Layout
  - Summary: The close button should stay fixed in the sheet header so it does not scroll away with the body.
  - Expected: Keep the close icon visually anchored in the header with a consistent touch target.
  - Status: Done
  - Owner: Agent

- [x] ISSUE-029
  - Screen: Create
  - Priority: P1
  - Type: UX, State
  - Summary: Tapping `Custom` in the activity grid should reveal an inline custom activity input.
  - Expected: `Custom` becomes an explicit activity choice with a required text field appearing in-place when selected.
  - Status: Done
  - Owner: Unassigned

- [x] ISSUE-030
  - Screen: Create
  - Priority: P1
  - Type: UI, Layout
  - Summary: Activity choices should use a `LazyVGrid` that shows up to six items first, then folds remaining items behind a `View more` control.
  - Expected: The grid should breathe evenly across screen sizes, show the first row or six items by default, and expand gracefully when the user taps `View more`.
  - Status: Done
  - Owner: Agent

- [x] ISSUE-031
  - Screen: Create
  - Priority: P1
  - Type: UX, State
  - Summary: The current time chips should be replaced with a real picker for date and time.
  - Expected: Use separate date and time pickers so the user can choose a proper schedule instead of tapping preset chips.
  - Status: Done
  - Owner: Unassigned

- [x] ISSUE-032
  - Screen: Create
  - Priority: P2
  - Type: UI, Interaction
  - Summary: Capacity should be presented as a horizontal scroll wheel of numbers.
  - Expected: Use a scrollable number picker so the control stays compact and tactile on small screens.
  - Status: Done
  - Owner: Unassigned

- [x] ISSUE-033
  - Screen: Create
  - Priority: P1
  - Type: UI, Layout
  - Summary: `Who can join` should render as a grid so it fits on smaller screens cleanly.
  - Expected: The join-mode choices should be arranged in a grid/card pattern rather than a wide two-column row that can crowd narrow devices.
  - Status: Done
  - Owner: Unassigned

- [x] ISSUE-034
  - Screen: Create
  - Priority: P2
  - Type: UX, State
  - Summary: `Vibe` needs a lightweight chooser with a small set of options, without stacking another sheet on top of the Create sheet.
  - Expected: Use a `Menu`-style interaction with roughly 4 to 6 vibe choices so the user can pick one inline.
  - Status: Done
  - Owner: Unassigned

- [x] ISSUE-035
  - Screen: Create
  - Priority: P0
  - Type: State, Spec mismatch
  - Summary: All required fields need mandatory indicators and the `Post Drift` CTA must stay disabled until validation passes.
  - Expected: Mark required inputs clearly, keep optional fields visually separate, and only enable posting after all required data is present.
  - Status: Done
  - Owner: Unassigned

- [x] ISSUE-036
  - Screen: Create
  - Priority: P0
  - Type: Navigation, State
  - Summary: A posted Drift is not yet reflected in Discover or My Drifts.
  - Expected: After posting succeeds, the new Drift should appear in the relevant lists immediately or via a clear refresh path so the user sees the new state.
  - Status: Done
  - Owner: Unassigned

### 4. Chats Home

Spec anchors:
- Drift-tied conversations only
- No cold direct messaging

Primary files:
- `apps/frontend/Coffee_Call/Coffee_Call/Screens/Main/ChatsListScreen.swift`
- `apps/frontend/Coffee_Call/Coffee_Call/ViewModels/ChatsViewModel.swift`
- `apps/frontend/Coffee_Call/Coffee_Call/Components/Navigation/CoffeeHeader.swift`

Issues:
- [x] ISSUE-026
  - Screen: Chats Home
  - Priority: P1
  - Type: UI, Spec mismatch
  - Summary: Remove Bubble field UI for MVP scope reduction.
  - Status: Done
  - Owner: Agent

### 5. Drift Chat / Thread

Spec anchors:
- Async Drift-tied coordination only
- Chat unlocks after joining or hosting

Primary files:
- `apps/frontend/Coffee_Call/Coffee_Call/Screens/Main/DriftChatScreen.swift`
- `apps/frontend/Coffee_Call/Coffee_Call/ViewModels/DriftChatViewModel.swift`

Issues:
- [x] ISSUE-018
  - Screen: Drift Chat / Thread
  - Priority: P1
  - Type: Navigation, Layout
  - Summary: Chat thread should never show the floating bottom nav.
  - Status: Done
  - Owner: Agent

- [x] ISSUE-019
  - Screen: Drift Chat / Thread
  - Priority: P1
  - Type: UX, State
  - Summary: Composer input behavior is incomplete and attachment action is a dead button.
  - Status: Done
  - Owner: Agent

- [x] ISSUE-020
  - Screen: Drift Chat / Thread
  - Priority: P1
  - Type: Policy, Spec mismatch
  - Summary: Chat screen reachable from Drift Detail after instant join.
  - Status: Done
  - Owner: Agent

- [x] ISSUE-021
  - Screen: Drift Chat / Thread
  - Priority: P2
  - Type: Architecture, Test coverage
  - Summary: Chat thread uses local mock history with no injected chat source.
  - Status: Done
  - Owner: Agent

### 6. Drift Detail

Spec anchors:
- Must support post-join coordination context
- Exact coordination details stay inside joined Drift context

Primary files:
- `apps/frontend/Coffee_Call/Coffee_Call/Screens/Main/DriftDetailScreen.swift`
- `apps/frontend/Coffee_Call/Coffee_Call/ViewModels/DriftDetailViewModel.swift`

Issues:
- [x] ISSUE-010
  - Screen: Drift Detail
  - Priority: P1
  - Type: Layout, UI
  - Summary: Sub-header layout leaves too much leading and trailing space.
  - Status: Done
  - Owner: Agent

- [x] ISSUE-011
  - Screen: Drift Detail
  - Priority: P1
  - Type: Layout
  - Summary: There is too much vertical space between the top hero text and the summary sub-banner/grid.
  - Status: Done
  - Owner: Agent

- [ ] ISSUE-012
  - Screen: Drift Detail
  - Priority: P1
  - Type: State, Feature completeness
  - Summary: Share and reminder actions are visible but only stubbed.
  - Expected: Each action should have a real destination or sheet, or be hidden until available.
  - Notes: `shareDrift()` and `setReminder()` only print to console. `saveDrift()` is implemented via BookmarkManager.
  - Files: `DriftDetailViewModel.swift`, `DriftDetailScreen.swift`
  - Status: Open
  - Owner: Unassigned

- [x] ISSUE-013
  - Screen: Drift Detail
  - Priority: P1
  - Type: Navigation, UX
  - Summary: Hosted-by row is tappable but had no defined action.
  - Status: Done
  - Owner: Agent

- [x] ISSUE-014
  - Screen: Drift Detail
  - Priority: P1
  - Type: UX, Feature completeness
  - Summary: “See all” in Who’s Coming should open a participant sheet.
  - Status: Done
  - Owner: Agent

- [x] ISSUE-015
  - Screen: Drift Detail
  - Priority: P0
  - Type: Policy, Spec mismatch
  - Summary: Join flow was instant-joining instead of sending a request.
  - Status: Done
  - Owner: Agent

- [x] ISSUE-016
  - Screen: Drift Detail
  - Priority: P1
  - Type: UX, Feedback
  - Summary: There is no visible request-sent confirmation flow when the user joins or requests access.
  - Status: Done
  - Owner: Agent

- [x] ISSUE-017
  - Screen: Drift Detail
  - Priority: P1
  - Type: Feature completeness
  - Summary: Map/location feature is implemented with pre-join (approx) and post-join (precise) states.
  - Status: Done
  - Owner: Agent

- [x] ISSUE-027
  - Screen: Drift Detail / You
  - Priority: P1
  - Type: Feature completeness
  - Summary: Saved List watch-list gallery destination and persistence.
  - Status: Done
  - Owner: Agent

### 7. Profile / You

Spec anchors:
- Privacy-first and lightweight
- Should support user identity, participation, and settings without social gamification

Primary files:
- `apps/frontend/Coffee_Call/Coffee_Call/Screens/Main/ProfileScreen.swift`
- `apps/frontend/Coffee_Call/Coffee_Call/Screens/Main/EditProfileScreen.swift`
- `apps/frontend/Coffee_Call/Coffee_Call/ViewModels/ProfileViewModel.swift`
- `apps/frontend/Coffee_Call/Coffee_Call/Components/Navigation/CoffeeHeader.swift`

Issues:
- [ ] ISSUE-022
  - Screen: Profile / You
  - Priority: P1
  - Type: Feature completeness, State
  - Summary: Edit Profile exposes change-photo affordances but has no working image capture/upload flow or supporting profile image model.
  - Expected: User should be able to pick or capture a profile image, and profile data should store that image reference cleanly.
  - Notes: Camera buttons are present in `EditProfileScreen`, but actions are empty and `ProfileViewModel` has no profile image property.
  - Files: `EditProfileScreen.swift`, `ProfileViewModel.swift`, related model/storage files
  - Status: Open
  - Owner: Unassigned

- [x] ISSUE-023
  - Screen: Profile / You
  - Priority: P2
  - Type: Architecture, Test coverage
  - Summary: Profile data is persisted directly with `UserDefaults` inside the view model and lacks targeted tests.
  - Status: Done
  - Owner: Agent

### 8. Auth / Onboarding

Spec anchors:
- Supports phone signup and profile setup
- Should feel native, warm, and low-friction

Primary files:
- `apps/frontend/Coffee_Call/Coffee_Call/Screens/OnboardingScreen.swift`
- `apps/frontend/Coffee_Call/Coffee_Call/Screens/Auth/PhoneAuthScreen.swift`
- `apps/frontend/Coffee_Call/Coffee_Call/Screens/Auth/OTPVerificationScreen.swift`
- `apps/frontend/Coffee_Call/Coffee_Call/Screens/Auth/PermissionsScreen.swift`
- `apps/frontend/Coffee_Call/Coffee_Call/Screens/Auth/LocationPermissionScreen.swift`
- `apps/frontend/Coffee_Call/Coffee_Call/Screens/Auth/ProfileSetupScreen.swift`
- `apps/frontend/Coffee_Call/Coffee_Call/Screens/Auth/ReadyScreen.swift`
- `apps/frontend/Coffee_Call/Coffee_Call/ViewModels/AuthViewModel.swift`

Issues:
- None logged yet.

## Cross-Screen / Test Gaps

- [x] ISSUE-024
  - Screen: Cross-screen
  - Priority: P1
  - Type: Test coverage
  - Summary: The project has only scaffold test targets and no meaningful unit or UI coverage for the reviewed flows.
  - Status: Done
  - Owner: Agent
