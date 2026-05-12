# AGENTS.md: AI Assistant Configuration

**Project:** CoffeeCall MVP  
**Purpose:** Standardized context for all AI tools (Claude, Cursor, Aider, etc.)

---

## Project Summary

CoffeeCall is an activity-based meetup platform. Users post activities (coffee, movies, jogging) → nearby people get notified → they accept → coordinate via in-app messages → meet up.

**Not a dating app.** Focus: lightweight, activity-focused, local (10km radius).

**MVP Timeline:** 3 weeks  
**Architecture:** SwiftUI iOS app + Firebase (backend)

---

## Critical Context

### Tech Stack
- **Frontend:** SwiftUI for iOS
- **Backend:** Firebase (Auth, Firestore, Cloud Messaging, Storage)
- **Geolocation:** Native iOS (CoreLocation)
- **Notifications:** Firebase Cloud Messaging (10km radius broadcast)

### Key Constraints
- **Async messaging only** (not real-time)
- **Posts stay active** (group meetups, not one-on-one)
- **No phone exchange in MVP** (in-app messages only)
- **10km radius fixed** (no customization)
- **3-week deadline** (aggressive, limited polish time)

### Key Decisions
- Use Firebase for zero ops overhead
- Use SwiftUI for the iOS MVP; keep Android for a future phase
- Keep messages async (simplify, not needed for coordination)
- Allow group meetups (posts never close after first accept)
- Document everything with ADRs (decisions.md)

---

## Files to Read First

| File | Purpose | Read This First |
|------|---------|---|
| `/Planning/spec.md` | Comprehensive specification | ✅ YES |
| `/Planning/architecture.md` | System design + tech decisions | ✅ YES |
| `/Planning/decisions.md` | Architecture Decision Records | ✅ YES |
| `/Design/design-tokens.md` | Reusable design values | When generating UI code |
| `/Design/screens.md` | Screen specifications | When building screens |
| `/Planning/context.md` | Shared rolling session log for all AI tools | At start of each session |

---

## How You Can Help

### If You're Planning/Architecture
- Review `/Planning/spec.md` for completeness
- Identify gaps or inconsistencies
- Update `/Planning/decisions.md` with new ADRs
- Suggest improvements to data models

### If You're Generating Code (Codex/Ambiglytics)
- Use prompts in `/Prompts/production/`
- Reference design tokens from `/Design/design-tokens.md`
- Follow architecture in `/Planning/architecture.md`
- Run tests after code generation

### If You're Designing
- Use design tokens from `/Design/design-tokens.md`
- Document components in `/Design/component-specs.md`
- Add accessibility notes to `/Design/accessibility.md`
- Link to Figma/Pencil in `/Design/figma-link.md`

### If You're Testing
- Verify against acceptance criteria in `/Planning/spec.md`
- Check `/Planning/timeline.md` for current phase
- Update `/Planning/context.md` with blockers
- Document failures in session summary

---

## Folder Structure (Monorepo)

```
CoffeeCall/
├── README.md                 # For humans (quick start)
├── CLAUDE.md                 # For Claude Code
├── AGENTS.md                 # This file
├── .claude/
│   └── settings.json         # Permissions config
├── .cursorrules              # For Cursor IDE
├── .claudeignore             # Files to ignore
├── docs/                     # All planning, design, prompts
│   ├── Planning/
│   │   ├── spec.md          # ⭐ Read first
│   │   ├── architecture.md   # ⭐ Read first
│   │   ├── decisions.md      # ⭐ Read first
│   │   ├── features.md
│   │   ├── requirements.md
│   │   ├── timeline.md
│   │   └── context.md
│   ├── Design/
│   │   ├── design-tokens.md  # ⭐ For code generation
│   │   ├── design-system.md
│   │   ├── screens.md
│   │   ├── component-specs.md
│   │   └── accessibility.md
│   └── Prompts/
│       ├── README.md
│       ├── VERSIONING.md
│       ├── templates/
│       └── production/
└── apps/
    ├── frontend/             # SwiftUI iOS app
    │   ├── src/
    │   ├── README.md
    │   └── package.json
    └── backend/              # Firebase Cloud Functions
        ├── functions/
        ├── README.md
        └── package.json
```

---

## Workflow for AI Tools

### Phase 1: Planning (Current)
1. Claude reads spec + architecture
2. Claude reviews decisions + context
3. Claude identifies gaps/issues
4. Claude updates documentation

**Output:** Refined spec, architecture, decision logs

### Phase 2: Design
1. Designer creates mockups (Figma/Pencil)
2. Designer documents design tokens
3. Designer specs components
4. Claude reviews for consistency with spec

**Output:** Design system, component specs, Figma file

### Phase 3: Prompt Generation
1. Codex reads spec + architecture + design
2. Codex generates backend prompt
3. Codex generates frontend prompt
4. Codex generates integration prompt
5. Prompts uploaded to `/Prompts/production/` with versioning

**Output:** Versioned prompts (v1.0.0)

### Phase 4: Code Generation
1. Ambiglytics reads backend-prompt.v1.0.0.md
2. Ambiglytics generates backend code (Cloud Functions, Firestore rules)
3. Ambiglytics reads frontend-prompt.v1.0.0.md
4. Ambiglytics generates frontend code (SwiftUI iOS)
5. Code tested against spec

**Output:** Working code, deployment-ready

### Phase 5: Verification
1. Claude verifies code against acceptance criteria
2. Claude checks for spec compliance
3. Claude identifies issues
4. If issues found: loop back to Codex for prompt refinement
5. If pass: merge to main

**Output:** Verified, merge-ready code

---

## What NOT to Do

- ❌ Write code directly (use Ambiglytics)
- ❌ Change architecture without ADR (update decisions.md)
- ❌ Edit design tokens without updating design-tokens.md
- ❌ Commit without tests passing
- ❌ Update context.md manually between sessions unless you are appending the current session log
- ❌ Ignore .claudeignore files

## Shared Session Log

All AI tools should use `/Planning/context.md` as the single rolling session log.

- Append a short note after finishing work.
- Put the newest session at the top.
- Include what changed, why, files updated, and verification.
- Keep the log compact.
- When it grows too large, delete the oldest session entries and keep only the latest 5 sessions or about 300 lines.

---

## Build & Test Commands

**Build:**
```bash
npm run build
```

**Test:**
```bash
npm test
```

**Lint:**
```bash
npm run lint
```

**Firebase Emulator:**
```bash
firebase emulators:start
```

**Deploy (Firebase Functions):**
```bash
firebase deploy --only functions
```

---

## Code Conventions

- **TypeScript:** Strict mode enabled
- **Naming:** camelCase (variables), PascalCase (classes/components)
- **Imports:** Sorted alphabetically
- **Max line length:** 100 characters
- **Comments:** Only WHY, not WHAT
- **Tests:** Required for all functions

---

## Critical Gotchas

1. **Firestore rate limits** — 500 writes/second per collection
2. **Location permissions** — Must request on app launch (iOS)
3. **Geohashing** — Firestore best practice (not naive lat/lng queries)
4. **Messages are async** — 2-5 second latency expected, no real-time
5. **Posts stay active** — After first accept, post remains visible (design choice)
6. **Phone exchange in MVP** — NOT supported, users message in-app only

---

## Success Criteria (MVP)

- Signup completion: >80%
- Post creation: >95% success
- Notification delivery: >99%
- Message persistence: 100%
- App crashes: <0.1%
- Acceptance rate: >30% of notified users

---

## Next Steps

1. ✅ Spec finalized
2. ✅ Architecture finalized
3. ⏳ Design finalization (Figma/Pencil mockups)
4. ⏳ Codex prompt generation
5. ⏳ Ambiglytics code generation
6. ⏳ Testing + verification

---

## Questions?

Refer to:
- **"What should we build?"** → `/Planning/spec.md`
- **"How should we build it?"** → `/Planning/architecture.md`
- **"Why did we decide X?"** → `/Planning/decisions.md`
- **"What does this screen look like?"** → `/Design/screens.md`
- **"What colors/fonts should I use?"** → `/Design/design-tokens.md`

---

**Last Updated:** 2026-05-10  
**Status:** Active  
**Owner:** Claude (Planner), User (Ambiglytics/Codex direction)
