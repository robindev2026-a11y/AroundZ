# CoffeeCall AI Context Management

This system is the living knowledge base for all AI agents working on CoffeeCall. It ensures continuity, prevents instruction decay, and maintains a single source of truth across sessions.

## Mandatory Pre-Task Protocol
Before starting **ANY** task, you must read these files in order:
1. **[CURRENT_STATE.md](./CURRENT_STATE.md)**: Architecture, non-negotiables, active goals, and conventions.
2. **[CHANGELOG.md](./CHANGELOG.md)**: Review recent shifts and decisions (last 5-10 entries).

## Post-Task Protocol
After completing a task that modifies architecture, conventions, or project scope:
1. Append an entry to **[CHANGELOG.md](./CHANGELOG.md)**.
2. Update **[CURRENT_STATE.md](./CURRENT_STATE.md)** to reflect the new state.

## Legacy Documentation
The following files are being phased out in favor of this system:
- `AGENTS.md` (Refer to this file instead)
- `docs/STATUS.md` (Historical milestones moved to `CHANGELOG.md`)
- `docs/CONTEXT.md` (Content merged into `CURRENT_STATE.md`)

## Local Context Cache & Semantic Memory
This project uses a hybrid caching system to speed up processing and provide "Semantic Memory":
- **Metadata Cache:** `.ai_cache/project_context.db` (SQLite) for fast change detection.
- **Semantic Memory:** `.ai_cache/vector_db` (ChromaDB) for conceptual searches across the codebase.
- **Sync Script:** `.ai_cache/update_cache.py`
Run `python3 .ai_cache/update_cache.py` after significant file changes. The script automatically updates both the SQLite index and the ChromaDB vector store if changes are detected.

---
*Status: ACTIVE | System: Living Knowledge Base*
