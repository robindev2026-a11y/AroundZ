# CoffeeCall Status

Status: ACTIVE
Last updated: 2026-05-30

This file is the current progress ledger.

## Current Focus

Align the live app and all AI guidance around a single active source of truth. The immediate focus is resolving any lingering bugs (such as sharing, reminders, and profile photo features) and validating full flows.

## Future Plan Notes

- Add a simple internal web admin panel after MVP for moderation, user review, and safety operations.
- Keep the admin panel separate from the consumer iOS app and gate it with admin-only auth claims.
- Around radar uses anonymous nearby user presence as ambient signal, while Drifts remains the concrete discovery/action surface.
- Around radar Firebase behavior uses one-time presence snapshots and one-hour-throttled current-user location writes instead of live user listeners.
- Future engineering cleanup: audit Swift files for correct access specifiers, add `final` where inheritance is not intended, and organize related behavior into focused extensions to improve code clarity and maintainability.

## UX Status

| Area | Status | Notes |
|---|---|---|
| Design doc reset | Complete | Active docs now live in `docs/`; prior markdown is archived. |
| Around UX | Approved design direction | Spec lives in `docs/DESIGN.md`. |
| Around implementation | Complete | Tooltips clamped, interests focus, cached snapshot refresh. |
| Drifts listing UX | Spec created | Active spec in `docs/DESIGN.md` defines `Nearby` and `My Drifts` access. |
| Drifts listing implementation | Complete | Search, category chips, radius filter panel, and Around navigation handoff. |
| Create sheet | Complete | Modal bottom sheet launched from center Create action. Validation, Custom input, Date/Time pickers. |
| Profile UX | Complete | Identity card, 2x2 private stats, Activity Log, local caching, and Firebase Storage persistence. |
| Chats UX | Complete | Compact Rooms List, chat detail info sheet, and message threads. |

## App Status

| Area | Status | Notes |
|---|---|---|
| iOS app | Staged restructuring | SwiftUI frontend under `apps/frontend`. Structure cleaned up and files staged in Git. |
| Backend | CRUD complete | Firebase Auth, Firestore Location/Geohash/CRUD, Storage, Messaging, Functions. |
| Messaging | MVP async model | Chat is Drift-tied only. Decoupled and protocol-oriented. |
| Notifications | Complete | Connected share and reminder stubs in DriftDetailViewModel and DriftDetailScreen. |

## Known Mismatches
- None confirmed. Drift join-request in-app notification fix is pending user validation in Xcode; no build or simulator validation run here per repo rules.

## Historical Milestones

- **2026-05-16**: Archived legacy documentation. Established active markdown files in `docs/`.
- **2026-05-17**: Defined active Drifts listing and Navigation specs in `docs/DESIGN.md`.
- **2026-05-18**: Overhauled Chats list (Compact List Mode) and detail info sheet (Report/Block/Leave). Implemented generic `CoffeeBasePage` and `CoffeeHeader` to support floating navigation blurs and swipe-back gestures. Refreshed "You" Profile screen with dynamic stats, Activity Log, local UserDefaults caching, and custom text cycler. Added CPU/Energy optimizations for Chat unread pulse dots.
- **2026-05-19**: Implemented Around Radar edge-clamped tooltip. Implemented Create Drift sheet with activity folding, custom inputs, horizontal capacity scroller, and required field validation. Added debounced title/description Search, Category chips, and Radius filter panel to Drifts listing. Integrated Around-to-Drifts interest navigation routing. Added Codable Drift models, UserDefaults-based Bookmarks manager, and recursive Host Context Card bottom sheets. Created "Who's Coming" participant list sheet.
- **2026-05-20**: Fixed Firestore API calls to match iOS SDK APIs. Resolved SwiftUI preview deadlocks by removing drawingGroup from Radar. Wired onboarding auth status directly into App entry routing.
- **2026-05-21**: Relocated Vibe compose field to main Create page. Added `LazyView` wrappers to prevent eager routing crashes. Integrated native `UIActivityViewController` sharing. Implemented live GPS location tracking and geohash uploads to Firestore `users/{uid}`. Added dynamic distance recalculations for nearby Drifts using CoreLocation updates. Fixed existing-user OTP login routing loops.
- **2026-05-22**: Flattened `apps/frontend/` layout, moved Xcode files up, moved active docs to root of `docs/`, deleted empty/obsolete folders, and staged restructuring in Git. Resolved ISSUE-012 (connected share and reminder stubs with local notifications) and ISSUE-022 (implemented profile image picker, camera capture, local caching, and Firebase Storage persistence). Resolved Profile/You section location hardcoding by implementing dynamic GPS coordinates lookup, reverse geocoding to city/locality names, and dynamic Location Sheet updates. Fixed missing Manage/Edit Drift strings that caused a SwiftUI `Form {}` compile error in `EditDriftScreen`. Fixed Manage Drift host actions (Edit navigation, Delete confirmation + pop-on-success) and made the native share sheet presentation more resilient. Rebuilt Edit Drift as the same UI as Create Drift (no `Form`, not presented as a sheet) with a real update call; fixed `Drift.notes` so hook/notes persist in the model.
- **2026-05-23**: Migrated Drifts data flow to a SwiftUI-native `@EnvironmentObject` store (`GlobalDriftStore`), removing `CreatedDriftStore` and Notification-based drift syncing. `DriftsViewModel` is now UI-only; create/edit/delete paths update the shared store so Drifts lists update instantly. Verification: not run here (per repo rules); validate in Xcode.
- **2026-05-24**: Fixed stale Drifts listing updates after editing a Drift by removing `Drift`'s id-only `Hashable/Equatable` behavior and switching value-based navigation (`NavigationLink(value:)` / `navigationDestination(for:)`) to use `UUID` drift IDs. Verification: not run here (per repo rules); validate in Xcode.
- **2026-05-24**: Documented the AI “Three Circle” file-scope rule in `docs/CONTEXT.md` and the Obsidian vault so future debugging stays intentional and permission-gated when exploring beyond directly related files.
- **2026-05-26**: Applied Drift join-request in-app notification fixes. `MainTabView` now starts `GlobalDriftStore` as soon as the authenticated main app appears, so the Firestore snapshot listener can run before the host manually opens Drifts. `GlobalDriftStore.mergeDrifts()` now prefers Firebase/base Drifts over duplicate locally cached Drifts when Firebase is active, preventing stale local hosted Drifts from hiding fresh `pendingRequests`. Added DEBUG-only `JoinRequestDebugTracer.trace(...)` calls through the join-request path (`DriftDetailScreen`, `DriftDetailViewModel`, `FirebaseDriftsService`/`MockDriftsService`, `GlobalDriftStore`, `DriftsScreen`, `NotificationsSheet`, and `ManageDriftViewModel`). Set one Xcode breakpoint inside `JoinRequestDebugTracer.trace` to pause on every traced step; console prints use the `[JoinRequestFlow]` prefix. Verification: not run here (per repo rules); validate in Xcode.
- **2026-05-26**: Updated Drift request-state persistence. `DriftDetailViewModel` now derives `.requested` from the current user's `Drift.pendingRequests`, so the pending state survives closing and reopening the Drift until the host accepts/rejects or the user cancels. Added `cancelJoinRequest` to `DriftsServiceProtocol`, `FirebaseDriftsService`, and `MockDriftsService`, wired the pending CTA to undo the request, and kept the success sheet title separate from the undo CTA label. Verification: not run here (per repo rules); validate in Xcode.
- **2026-05-30**: Resolved ISSUE-049 (fixed simulator freeze/crash when tapping "Open Chat" and "Manage Drift" by migrating from eager NavigationLinks to state-driven programmatic navigation destinations), ISSUE-050 (implemented "Leave Drift" action sheet dialog and service hook), ISSUE-051 (implemented "Report Drift" reason picker and backend reporting logging), ISSUE-052 (implemented member blocking selector sheet), and ISSUE-053 (fixed "View Drift" back navigation in chat info sheet to dismiss chat view and pop back to drift details). Verification: not run here (per repo rules); validate in Xcode.

- **2026-05-30**: Resolved Batch 1 Issues (Dashboard & Feed Discovery). Wrapped `DiscoveryScreen` in `NavigationStack` for navigation path binding, unified the notifications bell with `NotificationsSheet` to show live unread counts and enable deep-linking, forced location fetching on dashboard load (`onAppear`), and populated realistic coordinates in `MockDriftsService` to support dynamic distance calculation and verify radius filtering. Verification: not run here (per repo rules); validate in Xcode.
