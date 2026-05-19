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
| Batch A | Unassigned | TBD | 0 | Unassigned | Idle |
| Batch B | Unassigned | TBD | 0 | Unassigned | Idle |
| Batch C | Unassigned | TBD | 0 | Unassigned | Idle |

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
  - Notes: `ActivityTooltipView` is always offset upward by a fixed value from the bubble in `RadarView.swift`, with no edge detection or adaptive placement.
  - Files: `RadarView.swift`
  - Status: Done
  - Owner: Unassigned

- [x] ISSUE-002
  - Screen: Around / Discovery
  - Priority: P1
  - Type: UX, Spec mismatch
  - Summary: Radar tooltip currently includes a `Start Drift` CTA, but the review direction is to show only the anonymous interests signal.
  - Expected: Tooltip should focus on the person's active interests only, without direct action clutter.
  - Notes: This is a core UX change relative to the current `DESIGN.md`, so implementation should also update the design doc after confirmation.
  - Files: `RadarView.swift`, `DESIGN.md`
  - Status: Done
  - Owner: Unassigned

- [ ] ISSUE-003
  - Screen: Around / Discovery
  - Priority: P1
  - Type: State, Architecture
  - Summary: Nearby interests grid data is hardcoded in `DiscoveryViewModel` and the screen creates its own view model instead of receiving injected dependencies.
  - Expected: Discover data should come from an injected source or protocol-backed service, with mock data provided through dependency injection for now.
  - Notes: `@StateObject private var viewModel = DiscoveryViewModel()` in the screen and inline mock arrays in `loadData()` make backend integration harder.
  - Files: `DiscoveryScreen.swift`, `DiscoveryViewModel.swift`
  - Status: Open
  - Owner: Unassigned

- [x] ISSUE-004
  - Screen: Around / Discovery
  - Priority: P1
  - Type: Navigation, Spec mismatch
  - Summary: Tapping an interest card does nothing today.
  - Expected: Interest tap should route to Drifts with `Nearby` selected and that interest applied as a filter.
  - Notes: `InterestCard` is rendered without a button wrapper or navigation action. User requested to keep the Drifts-side filter implementation for later, but the missing flow should still be tracked now.
  - Files: `DiscoveryScreen.swift`, `InterestCard.swift`, `DriftsScreen.swift`, `DriftsViewModel.swift`
  - Status: Done
  - Owner: Unassigned

- [ ] ISSUE-005
  - Screen: Around / Discovery
  - Priority: P3
  - Type: UX direction
  - Summary: Keep light identity hints like name and image support in the Around radar data model as motivation to create a Drift, but avoid turning the surface into profile browsing.
  - Expected: Name and image fields may remain in the model for future motivational/contextual use, while the live UI stays activity-first and does not expose profile-navigation behavior.
  - Notes: User explicitly wants name and image retained in the data model. Do not remove these fields as part of the Around cleanup batch.
  - Files: `DiscoveryViewModel.swift`, `RadarPerson.swift`
  - Status: Done
  - Owner: Unassigned

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
- [ ] ISSUE-006
  - Screen: Drifts / Listing
  - Priority: P1
  - Type: UX, Spec mismatch
  - Summary: Drifts header shows a search button and a filter button, but neither action presents working UI.
  - Expected: Filter action should open the compact refinement sheet defined in `DESIGN.md`; search should either open a real search experience or be removed until implemented.
  - Notes: Both header button closures are empty in `DriftsScreen.swift`.
  - Files: `DriftsScreen.swift`
  - Status: Open
  - Owner: Unassigned

- [ ] ISSUE-007
  - Screen: Drifts / Listing
  - Priority: P1
  - Type: State, Performance
  - Summary: Search state exists in the view model but is unused, with no search field UI, debounce behavior, or lazy loading/pagination path.
  - Expected: Search should have an input surface, debounced query handling, and data loading strategy appropriate for backend-driven lists.
  - Notes: `searchText` is published in `DriftsViewModel` but never used in filtering or fetching.
  - Files: `DriftsViewModel.swift`, `DriftsScreen.swift`
  - Status: Open
  - Owner: Unassigned

- [x] ISSUE-008
  - Screen: Drifts / Listing
  - Priority: P1
  - Type: Navigation, Spec mismatch
  - Summary: There is no current category filter handoff from Around to Drifts.
  - Expected: Drifts should support opening with an interest filter applied from Around.
  - Notes: This blocks the intended Discover → Drifts flow even after interest taps are wired.
  - Files: `DiscoveryScreen.swift`, `DriftsScreen.swift`, `DriftsViewModel.swift`
  - Status: Done
  - Owner: Unassigned

- [ ] ISSUE-009
  - Screen: Drifts / Listing
  - Priority: P2
  - Type: Architecture
  - Summary: Drifts screen owns its own view model and mock data instead of taking injected data sources.
  - Expected: Use dependency injection so list behavior, filtering, and future backend integration are testable.
  - Notes: `@StateObject private var viewModel = DriftsViewModel()` and `loadMockDrifts()` are screen-owned.
  - Files: `DriftsScreen.swift`, `DriftsViewModel.swift`
  - Status: Open
  - Owner: Unassigned

### 3. Create Drift

Spec anchors:
- Center create action opens a sheet
- Must support purpose, approximate location, time, and optional hook

Primary files:
- `apps/frontend/Coffee_Call/Coffee_Call/Screens/Main/CreateDriftScreen.swift`
- `apps/frontend/Coffee_Call/Coffee_Call/ViewModels/CreateDriftViewModel.swift`

Issues:
- None logged yet.

### 4. Chats Home

Spec anchors:
- Drift-tied conversations only
- No cold direct messaging

Primary files:
- `apps/frontend/Coffee_Call/Coffee_Call/Screens/Main/ChatsListScreen.swift`
- `apps/frontend/Coffee_Call/Coffee_Call/ViewModels/ChatsViewModel.swift`
- `apps/frontend/Coffee_Call/Coffee_Call/Components/Navigation/CoffeeHeader.swift`

Issues:
- None logged yet.

### 5. Drift Chat / Thread

Spec anchors:
- Async Drift-tied coordination only
- Chat unlocks after joining or hosting

Primary files:
- `apps/frontend/Coffee_Call/Coffee_Call/Screens/Main/DriftChatScreen.swift`
- `apps/frontend/Coffee_Call/Coffee_Call/ViewModels/DriftChatViewModel.swift`

Issues:
- [ ] ISSUE-018
  - Screen: Drift Chat / Thread
  - Priority: P1
  - Type: Navigation, Layout
  - Summary: Chat thread should never show the floating bottom nav, but this needs verification because the user observed it when opening chat from Drift Detail.
  - Expected: Thread view must always hide the main floating tab bar.
  - Notes: Code attempts to set `navManager.isTabBarHidden = true` in `onAppear`, so the bug may be timing- or navigation-stack-related rather than a missing call.
  - Files: `DriftChatScreen.swift`, `MainTabView.swift`, `NavigationManager.swift`
  - Status: Open
  - Owner: Unassigned

- [ ] ISSUE-019
  - Screen: Drift Chat / Thread
  - Priority: P1
  - Type: UX, State
  - Summary: Composer input behavior is incomplete and attachment action is a dead button.
  - Expected: Text input should remain visible and usable, and the attachment affordance should either open a supported picker or be omitted per MVP rules.
  - Notes: `ChatComposer` renders a paperclip button with an empty action. User also reported the input not showing during actual use, which needs runtime verification.
  - Files: `DriftChatScreen.swift`
  - Status: Open
  - Owner: Unassigned

- [ ] ISSUE-020
  - Screen: Drift Chat / Thread
  - Priority: P1
  - Type: Policy, Spec mismatch
  - Summary: Chat screen is reachable from Drift Detail after an instant join path, but product rules require accepted or joined state only.
  - Expected: Pending/requested users must not reach or use chat until accepted.
  - Notes: `DriftDetailViewModel.joinDrift()` immediately changes state to `.joined`, which bypasses the request/accept flow defined in active docs.
  - Files: `DriftDetailViewModel.swift`, `DriftDetailScreen.swift`, `DESIGN.md`, `PLAN.md`, `ARCHITECTURE.md`
  - Status: Open
  - Owner: Unassigned

- [ ] ISSUE-021
  - Screen: Drift Chat / Thread
  - Priority: P2
  - Type: Architecture, Test coverage
  - Summary: Chat thread uses local mock history with no injected chat source and no focused tests.
  - Expected: Messages and thread state should come from an injected service or repository with unit/UI test coverage.
  - Notes: `DriftChatViewModel` loads mock history directly from `AppConstants.MockData`.
  - Files: `DriftChatViewModel.swift`, `Coffee_CallTests.swift`, `Coffee_CallUITests.swift`
  - Status: Open
  - Owner: Unassigned

### 6. Drift Detail

Spec anchors:
- Must support post-join coordination context
- Exact coordination details stay inside joined Drift context

Primary files:
- `apps/frontend/Coffee_Call/Coffee_Call/Screens/Main/DriftDetailScreen.swift`
- `apps/frontend/Coffee_Call/Coffee_Call/ViewModels/DriftDetailViewModel.swift`

Issues:
- [ ] ISSUE-010
  - Screen: Drift Detail
  - Priority: P1
  - Type: Layout, UI
  - Summary: Sub-header layout leaves too much leading and trailing space around the title capsule and actions.
  - Expected: Header should feel tighter and more balanced, with reduced wasted side spacing.
  - Notes: Likely rooted in the shared `CoffeeSubHeader` layout, not just this screen.
  - Files: `CoffeeHeader.swift`, `DriftDetailScreen.swift`
  - Status: Open
  - Owner: Unassigned

- [ ] ISSUE-011
  - Screen: Drift Detail
  - Priority: P1
  - Type: Layout
  - Summary: There is too much vertical space between the top hero text and the summary sub-banner/grid.
  - Expected: Hero content and summary information should read as one compact opening block.
  - Notes: Current screen stacks `heroSection`, then a full section top padding before `summaryInfoGrid`, inside a non-scroll page wrapper.
  - Files: `DriftDetailScreen.swift`, `CoffeeHeader.swift`
  - Status: Open
  - Owner: Unassigned

- [ ] ISSUE-012
  - Screen: Drift Detail
  - Priority: P1
  - Type: State, Feature completeness
  - Summary: Share, save, and reminder actions are visible but only stubbed.
  - Expected: Each action should have a real destination or sheet, or be hidden until available.
  - Notes: `saveDrift()`, `shareDrift()`, and `setReminder()` only print to console. There is also no surfaced “saved list” destination right now.
  - Files: `DriftDetailViewModel.swift`, `DriftDetailScreen.swift`
  - Status: Open
  - Owner: Unassigned

- [ ] ISSUE-013
  - Screen: Drift Detail
  - Priority: P1
  - Type: Navigation, UX
  - Summary: Hosted-by row is tappable but has no defined action yet.
  - Expected: Either route to an approved host profile experience once designed, or remove the affordance for now.
  - Notes: User marked host-profile UX as their task. Current button closure is empty.
  - Files: `DriftDetailScreen.swift`
  - Status: Blocked
  - Owner: Unassigned

- [ ] ISSUE-014
  - Screen: Drift Detail
  - Priority: P1
  - Type: UX, Feature completeness
  - Summary: “See all” in Who’s Coming should open a participant sheet, but no action exists.
  - Expected: Show a sheet with all participants and their interests, without profile deep links or extra navigation.
  - Notes: Current button is rendered only in unlocked state and has an empty action.
  - Files: `DriftDetailScreen.swift`
  - Status: Open
  - Owner: Unassigned

- [ ] ISSUE-015
  - Screen: Drift Detail
  - Priority: P0
  - Type: Policy, Spec mismatch
  - Summary: Join flow currently instant-joins instead of sending a request and waiting for host approval.
  - Expected: Drift join should respect the request/accept flow defined in the active product docs wherever approval is required.
  - Notes: `joinDrift()` sets `.joined` immediately even though active docs describe create → join/accept → confirm → message and requested state without chat access.
  - Files: `DriftDetailViewModel.swift`, `DriftDetailScreen.swift`, `PLAN.md`, `ARCHITECTURE.md`, `DESIGN.md`
  - Status: Open
  - Owner: Unassigned

- [ ] ISSUE-016
  - Screen: Drift Detail
  - Priority: P1
  - Type: UX, Feedback
  - Summary: There is no visible request-sent confirmation flow when the user joins or requests access.
  - Expected: User should get a clear success/pending confirmation after sending a join request.
  - Notes: Strings for requested state exist, but there is no toast, sheet, alert, or inline confirmation transition beyond the CTA changing state.
  - Files: `DriftDetailScreen.swift`, `DriftDetailViewModel.swift`, `AppStrings.swift`
  - Status: Open
  - Owner: Unassigned

- [ ] ISSUE-017
  - Screen: Drift Detail
  - Priority: P2
  - Type: Feature completeness
  - Summary: Map/location feature is not implemented beyond static text rows.
  - Expected: Exact or approximate location interactions should have a defined MVP behavior consistent with the no-map-first rule.
  - Notes: Current detail rows show location text and locked/unlocked copy, but no implemented map sheet or map handoff.
  - Files: `DriftDetailScreen.swift`
  - Status: Open
  - Owner: Unassigned

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

- [ ] ISSUE-023
  - Screen: Profile / You
  - Priority: P2
  - Type: Architecture, Test coverage
  - Summary: Profile data is persisted directly with `UserDefaults` inside the view model and lacks targeted tests.
  - Expected: Profile state should be abstracted behind an injected persistence layer and covered by unit tests.
  - Notes: This will matter once profile image handling and backend sync are added.
  - Files: `ProfileViewModel.swift`, `Coffee_CallTests.swift`
  - Status: Open
  - Owner: Unassigned

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

- [ ] ISSUE-024
  - Screen: Cross-screen
  - Priority: P1
  - Type: Test coverage
  - Summary: The project has only scaffold test targets and no meaningful unit or UI coverage for the reviewed flows.
  - Expected: Add focused tests for Discover data injection, Drifts filtering/navigation state, Drift join gating, chat visibility, and profile editing.
  - Notes: `Coffee_CallTests.swift` and `Coffee_CallUITests.swift` still contain template examples only.
  - Files: `Coffee_CallTests.swift`, `Coffee_CallUITests.swift`
  - Status: Open
  - Owner: Unassigned

## Issue Entry Template

Copy this format when logging a new issue:

```md
- [ ] ISSUE-001
  - Screen: Around / Discovery
  - Priority: P1
  - Type: UI, Spec mismatch
  - Summary: Interest grid is partially hidden behind the floating bottom nav.
  - Expected: Full two-row grid remains visible above the bottom nav per `DESIGN.md`.
  - Notes: Reproduced on iPhone planning size 393 x 852pt.
  - Files: `DiscoveryScreen.swift`
  - Status: Open
  - Owner: Unassigned
```
