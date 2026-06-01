# CHANGELOG - CoffeeCall

## [2026-06-01] - Context Management Migration & Resilient Leave Flow
**What changed:** 
- Initialized `AI.md` as the primary entry point for all agents.
- Created `CURRENT_STATE.md` to house architectural and product truth.
- Created `CHANGELOG.md` to track decision history chronologically.
- **Implemented "Bottom-Up" Leave Drift:** Refactored the leave flow to clean up `acceptances` documents before updating threads and posts.
- **Transaction-less Resiliency:** Switched from a single Firestore transaction to sequential writes to pinpoint failures and handle missing documents gracefully.
- **Fixed Permission Logic:** Broadened rules temporarily and then refined them to support decentralized cleanup.
- Deprecated `AGENTS.md`, `docs/STATUS.md`, and `docs/CONTEXT.md`.

**Why:** 
- To resolve persistent "Permission Denied" errors caused by complex multi-document dependencies.
- To ensure that leaving a drift properly cleans up all related data (acceptances, threads, posts).

**Affected areas:** 
- Project root documentation.

---

## [2026-05-30] - UX & Deep-linking Polish
**What changed:** 
- Resolved Batch 1 & 2 Issues (Dashboard, Feed, Participant State).
- Unified notifications bell with live unread counts.
- Fixed UI gaps in `DriftDetailScreen`.
- Programmatic navigation migration (removed eager NavigationLinks).
- Implemented Leave/Report/Block flows.

---

## [2026-05-26] - Join Request & Persistence
**What changed:** 
- Fixed stale Drifts listing updates using UUID-based navigation.
- Implemented `JoinRequestDebugTracer` for flow auditing.
- Derived `.requested` state from `Drift.pendingRequests` for persistence.
- Added `cancelJoinRequest` support.

---

## [2026-05-23] - State Management Refactor
**What changed:** 
- Migrated to `GlobalDriftStore` (@EnvironmentObject).
- Removed `CreatedDriftStore` and notification-based syncing.
- UI now updates instantly via shared store.

---

## [2026-05-22] - Location & Profile Services
**What changed:** 
- Implemented dynamic GPS coordinates lookup and reverse geocoding.
- Added profile image picker with Firebase Storage persistence.
- Rebuilt Edit Drift UI to match Create Drift.
- Fixed `Drift.notes` persistence.

---

## [2026-05-18] - UI Foundation & Page Structures
**What changed:** 
- Overhauled Chats list and detail info sheets.
- Implemented generic `CoffeeBasePage` and `CoffeeHeader`.
- Added dynamic stats and Activity Log to Profile.
- Added CPU/Energy optimizations for unread dots.

---

## [2026-05-16] - Documentation Reset
**What changed:** 
- Established active markdown files in `docs/` and archived legacy documentation.
