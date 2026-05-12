# Prompt Versioning Strategy

## Semantic Versioning for Prompts

Prompts follow semantic versioning: **MAJOR.MINOR.PATCH**

### Version Increment Rules

**MAJOR (X.0.0 → Y.0.0):**
- Breaking changes to prompt logic or output format
- Task scope significantly changes
- Architecture decisions fundamentally shift
- Output incompatible with previous version

Example: `backend-prompt.v1.0.0.md` → `backend-prompt.v2.0.0.md`

**MINOR (X.Y.0 → X.Y+1.0):**
- Backward-compatible improvements
- Refined wording or examples
- Additional clarity or edge cases
- Better performance guidance
- New optional features added

Example: `backend-prompt.v1.0.0.md` → `backend-prompt.v1.1.0.md`

**PATCH (X.Y.Z → X.Y.Z+1):**
- Bug fixes in prompt wording
- Typo corrections
- Clarification of existing requirements
- Minor adjustments that don't affect scope

Example: `backend-prompt.v1.0.0.md` → `backend-prompt.v1.0.1.md`

---

## Prompt Metadata (Required)

Every production prompt must include:

```markdown
---
version: 1.0.0
author: Codex
date: 2026-05-10
status: production | staging | dev
model: claude-opus-4.7
parameters:
  temperature: 0.5
  max_tokens: 4000
description: [One-line description of what this prompt generates]
tested_with: [Tools/frameworks tested with, e.g., "Firebase Emulator, Jest"]
evaluation_score: 0.92 (scale: 1-100)
changes: [What changed from previous version, if applicable]
---
```

---

## File Naming Convention

```
{type}-prompt.v{MAJOR}.{MINOR}.{PATCH}.md

Examples:
- backend-prompt.v1.0.0.md
- frontend-prompt.v1.0.0.md
- integration-prompt.v1.0.0.md
- backend-prompt.v1.1.0.md (if improvements made)
- backend-prompt.v2.0.0.md (if breaking changes)
```

---

## Deployment Workflow

### 1. Development Phase
- Write prompt in `prompts/dev/` or `prompts/staging/`
- Version as v0.1.0, v0.2.0, etc.
- Test with actual tool (Antigravity IDE)
- Iterate based on generated code quality

### 2. Staging Phase
- Move to `prompts/staging/` when ready for testing
- Label as v0.X.0 → v1.0.0-rc1 (release candidate)
- Full testing with Antigravity IDE
- Track performance metrics

### 3. Production Phase
- Move to `prompts/production/` when verified
- Label as v1.0.0 (release)
- Never edit — only create new versions
- Document all changes in metadata

### 4. Updates & Rollback
If a prompt generates poor code:
```
Current:  backend-prompt.v1.0.0.md (working)
Issue:    New requirement discovered
Fix:      backend-prompt.v1.1.0.md (updated)
Rollback: If v1.1.0 breaks, switch back to v1.0.0
```

---

## Quality Evaluation Scoring

Rate prompts 1-100:

- **90-100:** Excellent — Code generation is high quality, all requirements met
- **80-89:** Good — Minor fixes needed, most requirements met
- **70-79:** Acceptable — Several issues, needs refinement
- **60-69:** Poor — Significant issues, major refinement needed
- **<60:** Unusable — Fundamental problems, rewrite needed

Track in metadata: `evaluation_score: 0.92`

---

## Change Log Example

```markdown
## Version History

### v1.0.0 (2026-05-10) - Production Release
- Initial production release
- Covers all 5 backend endpoints
- Includes Firestore schema, FCM, geohashing
- Author: Codex

### v1.1.0 (2026-05-15) - Bug Fixes
- Fixed geohashing grid precision
- Clarified error handling for FCM failures
- Added endpoint rate limiting
- Author: Codex

### v2.0.0 (2026-06-01) - Reputation System
- Added scoring system (breaking change)
- New Firestore collections for ratings
- Updated notification logic
- Author: Codex
```

---

## Current Prompts

| Prompt | Version | Status | Score | Author | Date |
|--------|---------|--------|-------|--------|------|
| backend-prompt | v1.0.0 | production | 0.92 | Codex | 2026-05-10 |
| frontend-prompt | v1.0.0 | production | 0.91 | Codex | 2026-05-10 |
| integration-prompt | (pending) | — | — | — | — |

---

## Best Practices

1. **Never edit production prompts** — Always create new versions
2. **Use semantic versioning** — Clear communication of changes
3. **Document everything** — Metadata is required
4. **Test before deploying** — Verify with actual tool
5. **Track metrics** — Evaluation scores show quality trends
6. **Archive old versions** — Keep for reference/rollback

---

**Status:** Versioning strategy active  
**Last Updated:** 2026-05-10
