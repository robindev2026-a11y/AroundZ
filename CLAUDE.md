# CoffeeCall: Planning & Execution Workflow

## Overview
This document defines the workflow, roles, and folder structure for CoffeeCall MVP development using Ambiglytics for code generation and Codex for prompt generation.

## Roles & Responsibilities

### Claude (Planner & Oversight)
- **Planning**: Define architecture, scope, features, and timelines
- **Oversight**: Track execution, ensure quality, maintain alignment with plan
- **Never code**: Do not write implementation code directly
- **Coordination**: Ensure Ambiglytics, Codex, and design systems are synchronized

### Ambiglytics (Code Generation & System Projects)
- **System projects**: Create project structure, build scorecards
- **Code generation**: Transform prompts into implementation code
- **Artifact delivery**: Produce working code based on Codex-generated prompts

### Codex (Prompt Generation)
- **Prompt engineering**: Generate detailed prompts from architecture/design specs
- **Code synthesis**: Transform planning documents into executable instructions for Ambiglytics

### Code (Generated Artifacts)
- **Implementation**: Deliverable code produced by Ambiglytics
- **Quality**: Must pass verification against planning specs

## Workflow

```
1. Planning Phase (Claude)
   ↓
2. Architecture Definition (/docs/Planning/)
   ↓
3. Design & Mockups (/docs/Design/)
   ↓
4. Codex Prompt Generation
   ↓
5. Antigravity IDE Code Generation (apps/frontend/ + apps/backend/)
   ↓
6. Verification Against Plan
```

## Folder Structure (Monorepo)

### `/docs/Planning`
Contains architecture, scope, features, timelines, and decision logs.

**Key files:**
- `spec.md` — Comprehensive specification (features, acceptance criteria, data models)
- `architecture.md` — System design, components, tech stack decisions
- `features.md` — Feature breakdown, requirements, acceptance criteria
- `timeline.md` — Week-by-week deliverables, milestones, dependencies
- `decisions.md` — Architecture Decision Records (ADRs) with rationale
- `context.md` — Session tracking (updated after each session)

**Purpose:** Claude reads to understand scope. Codex reads to generate prompts.

### `/docs/Design`
Contains design specs, mockups, and design system decisions.

**Key files:**
- `design-tokens.md` — Colors, typography, spacing, shadows, component values
- `design-system.md` — Overall design philosophy
- `screens.md` — Screen-by-screen specifications
- `component-specs.md` — Component details and states
- `accessibility.md` — WCAG compliance notes

**Purpose:** Reference for Codex/Antigravity IDE during code generation.

### `/docs/Prompts` (Generated)
Contains Codex-generated prompts for Antigravity IDE.

**Key files:**
- `backend-prompt.v1.0.0.md` — Firebase Cloud Functions generation
- `frontend-prompt.v1.0.0.md` — SwiftUI iOS code generation
- `integration-prompt.v1.0.0.md` — API + data flow generation

**Purpose:** Codex generates these. Antigravity IDE reads to generate code.

### `/apps/frontend`
SwiftUI iOS app for the MVP. Android is future work.

**Structure:**
- `src/screens/` — UI screens
- `src/components/` — Reusable components
- `src/services/` — Firebase, location, API calls
- `src/models/` — Data models

**Purpose:** Antigravity IDE generates code here.

### `/apps/backend`
Firebase Cloud Functions + Firestore for serverless backend.

**Structure:**
- `functions/src/triggers/` — Cloud Function entry points
- `functions/src/handlers/` — Business logic
- `functions/src/services/` — Firebase, geohashing
- `firestore.rules` — Security rules
- `firestore.indexes.json` — Query indexes

**Purpose:** Antigravity IDE generates code here.

## How Claude Starts Each Session

1. **Read CLAUDE.md** (this file)
2. **Read `/Planning/architecture.md`** — Understand current scope & decisions
3. **Check `/Design/screens.md`** — Understand design direction
4. **Review `/Prompts`** — See what's been handed to Ambiglytics
5. **Ask**: What's the next focus? (feature, component, prompt generation, verification?)

## How to Add Context Between Sessions

- Update `/Planning/decisions.md` after major decisions
- Update `/Design/design-decisions.md` after design finalization
- Update `/Planning/timeline.md` if scope or schedule changes
- Create new prompt files in `/Prompts` after Codex generation

## Quick Reference

### When starting a session:
1. Read this file (CLAUDE.md)
2. Check `/Planning/architecture.md` for current scope
3. Check `/Design/screens.md` for design direction
4. Review latest prompt in `/Prompts/`
5. Ask: What's the next focus?

### To track progress:
- Update `/Planning/decisions.md` after decisions
- Update `/Planning/timeline.md` for schedule changes
- Create new prompt files in `/Prompts/` after Codex generation

## Current Status

**Project:** CoffeeCall MVP  
**Phase:** Architecture + Planning Complete  
**Done:**
- ✅ MVP scope defined
- ✅ Architecture finalized (SwiftUI iOS + Firebase)
- ✅ Key decisions documented
- ✅ Features broken down
- ✅ Screen list defined

**Next Steps:**
1. Design finalization (Figma/Pencil mockups)
2. Codex prompt generation
3. Ambiglytics code generation
4. Verification + testing

**Current Blockers:** None  
**Owner:** User (Ambiglytics direction), Claude (Oversight)

---

**Last Updated:** 2026-05-11  
**Folder Structure:** ✅ Complete  
**Planning Files:** ✅ Complete  
**Design Files:** 🔄 In Progress  
**Prompts:** ⏳ Awaiting Codex  
**Figma Integration:** ✅ Plugin installed (v2.1.30)
