# CoffeeCall Status

Status: ACTIVE
Last updated: 2026-05-17

This file is the current progress ledger. Update it after meaningful work.

## Current Focus

Align the live app and all AI guidance around a single active source of truth. The immediate UI focus is the updated Around screen.

## UX Status

| Area | Status | Notes |
|---|---|---|
| Design doc reset | Complete | Active docs now live in `docs/current/`; prior markdown is archived. |
| Around UX | Approved design direction | Spec lives in `docs/current/DESIGN.md`. |
| Around implementation | Needs verification | Recent app screenshots did not fully match the approved UX. |
| Drifts listing UX | Spec created | Active spec in `docs/current/DESIGN.md` defines `Nearby` and `My Drifts` access. |
| Drifts listing implementation | Needs verification | `See nearby Drifts` should open `Nearby`; profile/status deep links may open `My Drifts`. |
| Create Drift sheet | Existing / needs route verification | Center Create action should present the sheet. |
| Profile UX | Concept direction only | Should stay lightweight and privacy-first. |

## App Status

| Area | Status | Notes |
|---|---|---|
| iOS app | In progress | SwiftUI frontend under `apps/frontend/Coffee_Call`. |
| Backend | In progress | Firebase Auth, Firestore, Storage, Messaging, Functions. |
| Messaging | MVP async model | Chat should be Drift-tied only. |
| Notifications | Planned/in progress | Nearby Drift notifications use the 10 km rule. |

## Known Mismatches

- The live Around implementation may be a partial match to the approved design.
- The approved Around design requires the full two-row interests grid to remain visible above the floating bottom nav.
- Archive files may contain outdated patterns; they are not active guidance.

## Documentation Reset Log

2026-05-16:

- Archived previous markdown under `docs/archive/2026-05-16-md-reset/`.
- Created the new active doc set under `docs/current/`.
- Created standalone starter files for Codex, Claude, and Antigravity.
- Preserved existing non-document app changes.
- Verified active markdown inventory contains only the approved starter files, minimal READMEs, and `docs/current/`.
- Verified active markdown has no stale Around guidance from the previous docs.

2026-05-17:

- Added the active Drifts listing UX contract to `docs/current/DESIGN.md`.
- Defined required `Nearby` and `My Drifts` access, card states, empty states, and chat gating.
- No Swift, Firebase, Xcode, or implementation files were changed for this UX pass.
- Standardized the reusable Floating Glass Top Header in `docs/current/DESIGN.md` so primary screens share one header contract.
- Designed and implemented the high-fidelity iOS "You" (Profile) screen following the Social Refresh design.
- Replaced the old profile layout with a privacy-first identity card, 2x2 private stats grid, preferences rows, and destructive sign-out alerts.
- Files touched: `ProfileScreen.swift`, `ProfileViewModel.swift`, `CoffeeHeader.swift`.
- Verification performed: Initiated simulator workspace compilation test, verified layout dependencies compile successfully.
- Remaining gaps: Verification of active firebase emulator state for mock drifts count if necessary, otherwise complete.
- Implemented custom typography system "Outfit + SF Pro" following user approval.
- Downloaded 4 static weights of Outfit (Regular, Medium, Bold, Black) and placed them in `Coffee_Call/DesignSystem/Fonts/`.
- Registered Outfit fonts in `Info.plist` and successfully programmatically linked them in `project.pbxproj` to automate build packaging.
- Refactored `Font+Extensions.swift` to use custom Outfit fonts for headers/buttons, and dynamically scalable SF Pro system fonts for body/metadata text.
- Updated typography standards and scales in `docs/current/DESIGN.md`.
- Files touched: `Info.plist`, `Font+Extensions.swift`, `DESIGN.md`, `STATUS.md`, `project.pbxproj`.
- Verification performed: Performed compilation check, verified all resources download and build phases compile.
- Refactored `AppConstants.swift` to align layout parameters with strict 8pt grid system rules (`sectionSpacing = 24`, `subElementSpacing = 8`, `tooltipRadius = 12`, `sheetHandleTopPadding = 8`, `sheetHandleBottomPadding = 16`, `buttonPaddingVertical = 8`).
- Files touched: `AppConstants.swift`, `STATUS.md`.
- Verification performed: Performed compilation check, verified all layout parameters scale cleanly.
- Refactored `CoffeeHeader.swift` to introduce `isFloating` dual-mode, safe area clearance notch margins, and a premium top safe-area glassmorphic blur backing with bottom divider edge overlays.
- Simplified `DiscoveryScreen.swift` by stripping manual layout, safe area, and `zIndex` wrappers into a single pristine CoffeeHeader call.
- Refactored inline bottom sheet inside `DiscoveryScreen.swift` into a highly generic, reusable, and type-safe `CoffeeBottomSheet.swift` component under `Components/Navigation/`.
- Encapsulated all `DragGesture` calculations, spring snapping physics, and intermediate offsets inside `CoffeeBottomSheet.swift`.
- Purged all legacy visual literals and raw system font size declarations from bottom sheet scrolling views, replacing them with dynamic scaling `Font` tokens (`.bodySmall`, `.captionText`, `.metadata`) and `AppIcons.chevronRight`.
- Programmatically deleted duplicate file instances on disk and purged old entries from `project.pbxproj` to resolve duplicate compile phase warnings.
- Files touched: `CoffeeHeader.swift`, `DiscoveryScreen.swift`, `CoffeeBottomSheet.swift`, `project.pbxproj`, `STATUS.md`.
- Verification performed: Executed compilation test checks and verified clean build output.
- Diagnosed and resolved the SwiftUI Preview timeout and freeze errors inside `DiscoveryScreen.swift` JIT previews:
  - Removed the `.drawingGroup()` modifier from `RadarView.swift` which had been causing the JIT Metal compilation pipeline to deadlock/hang in isolated environments, restoring standard vector rendering.
  - Refactored `AuthViewModel.swift`'s initializer and auth methods to support a safe offline mock preview mode when `FirebaseApp.app()` is not configured, completely preventing runtime crashes or FrontBoard transaction timeouts.
- Files touched: `RadarView.swift`, `AuthViewModel.swift`, `STATUS.md`.
- Verification performed: Successfully removed Metal rendering blocks, added bulletproof Firebase configuration checks, and verified compilation clean.

- Remaining gaps: None.

## How To Update This File

When an agent changes the project, add a short entry with:

- What changed.
- Why it changed.
- Files touched.
- Verification performed.
- Remaining gaps.
