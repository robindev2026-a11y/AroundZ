# AI Context System Module

This system provides "Memory" and "Context Management" for AI agents (like Cursor, Gemini, Claude) working on any codebase.

## Portable Components:
- **`requirements.txt`**: The Python dependencies.
- **`setup.sh`**: One-click setup for new machines.
- **`update_cache.py`**: Syncs file metadata to SQLite.
- **`vector_sync.py`**: Syncs code chunks to ChromaDB (Semantic Search).
- **`search_cache.py`**: Utility for testing semantic memory.

## How to use on a new machine:
1. Push this folder (`.ai_cache/`) and the root Markdown files (`AI.md`, `CURRENT_STATE.md`, `CHANGELOG.md`) to GitHub.
2. Clone the repo on a new machine.
3. Run: `./.ai_cache/setup.sh`
4. The system will automatically rebuild the local databases specifically for that machine's file paths.

---
*Status: PORTABLE | Author: AI-System-Architect*
