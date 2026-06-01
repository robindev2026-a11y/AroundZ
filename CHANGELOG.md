# CHANGELOG - CoffeeCall

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
