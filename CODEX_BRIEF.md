# CODEX BRIEF: CoffeeCall MVP Project Review

**To:** Codex (Code Synthesis AI)  
**From:** Claude (Project Planner)  
**Project:** CoffeeCall MVP  
**Purpose:** Your role is to generate production-ready prompts for Antigravity IDE to generate code

---

## Your Mission

You will **NOT code directly**. Instead, you will:
1. **Review** the complete project specification and architecture
2. **Understand** all requirements, constraints, and design decisions
3. **Generate** detailed, production-ready prompts for Antigravity IDE
4. **Verify** prompts are comprehensive and reference-correct

Antigravity IDE will then use your prompts to generate the actual code into `/apps/frontend/` and `/apps/backend/`.

---

## What You Need to Know

### Project Overview
**CoffeeCall** is an activity-based meetup platform (not dating). Users post activities → nearby people notified → accept → coordinate via in-app messages → meetup happens.

**Core Flow:**
```
User posts (Purpose + Location + Time)
        ↓
Firebase notifies people within 10km radius
        ↓
Users see nearby posts + poster profile
        ↓
Users accept activity
        ↓
Message thread opens automatically
        ↓
Users coordinate and meet
```

### Tech Stack
- **Frontend:** SwiftUI for iOS 15.0+
- **Backend:** Firebase (Auth, Firestore, Cloud Messaging, Storage)
- **Geolocation:** Native iOS (CoreLocation)
- **Messaging:** Async only (2-5 second latency acceptable, NOT real-time)

### Key Constraints (CRITICAL)
1. **Posts stay active** — Don't close after first acceptance (group meetups allowed)
2. **Async messaging only** — No real-time WebSockets, Firestore polling is fine
3. **No phone exchange in MVP** — All contact happens in-app messages only
4. **10km radius fixed** — Not configurable by users
5. **3-week deadline** — Aggressive, but architecture is solid
6. **No scoring system in MVP** — Reputation system is v1.1
7. **No real-time features in MVP** — All async patterns

---

## Project Structure Review Checklist

### ✅ Documentation You Should Read First

**CRITICAL (Read These First):**
- [ ] `/Planning/spec.md` — Comprehensive specification (all features, acceptance criteria, data models)
- [ ] `/Planning/architecture.md` — System design, data models, API structure
- [ ] `/Design/design-tokens.md` — Colors, typography, spacing, component values

**Important (Read These Second):**
- [ ] `/Planning/decisions.md` — Architecture Decision Records (why we chose Firebase, async, etc.)
- [ ] `/Design/screens.md` — Screen specifications (7 screens total)
- [ ] `/Prompts/README.md` — How prompts are organized

**Reference (Use as Needed):**
- [ ] `AGENTS.md` — Workflow and how Codex fits in
- [ ] `MONOREPO_STRUCTURE.md` — Folder organization
- [ ] `AI_PROJECT_SETUP.md` — Best practices we're following

### ✅ Key Specification Details You Need

**Features (All in MVP):**
1. Phone signup + OTP
2. Profile creation + photo
3. Post activity (3 fields: Purpose, Location, Time)
4. Discover nearby posts (10km radius notifications)
5. Accept/reject activity
6. Automatic message thread opening
7. Async message coordination
8. Poster dashboard (see all acceptances)

**Firestore Collections You'll Need to Reference:**
```
/users/{userId}
  - uid, phoneNumber, name, profilePhotoUrl, lastLocation, lastLocationGeoHash, createdAt

/posts/{postId}
  - creatorId, purpose, location, locationGeoHash, time, createdAt, expiresAt, isActive, acceptanceCount

/acceptances/{acceptanceId}
  - postId, acceptorId, acceptedAt, status

/messageThreads/{threadId}
  - postId, participants, createdAt

/messageThreads/{threadId}/messages/{messageId}
  - senderId, text, timestamp
```

**API Endpoints You'll Prompt For:**
```
POST /createPost — Post creation + geohashing + notification
POST /acceptPost — Acceptance + thread creation + notification  
POST /sendMessage — Message persistence
GET /getNearbyPosts — Geohashing query
GET /getPosterDashboard — Acceptances list
```

**Design Tokens Reference:**
- See `/Design/design-tokens.md` for exact values
- Colors: Primary (#8B6F47), Success (#10B981), Error (#EF4444)
- Spacing: 4px, 8px, 16px, 24px, 32px
- Typography: Inter font, 32px headings, 16px body
- Border radius: 4px, 8px, 12px, 50%

---

## Your Tasks (In Order)

### Task 1: Project Review ✅ (Do This First)
Complete this checklist before generating any prompts:

- [ ] Read `/Planning/spec.md` completely
- [ ] Read `/Planning/architecture.md` completely
- [ ] Read `/Design/design-tokens.md` completely
- [ ] Skim `/Planning/decisions.md` (understand the why)
- [ ] Skim `MONOREPO_STRUCTURE.md` (understand folder organization)
- [ ] **Verify you understand:**
  - [ ] All 7 screens and what they do
  - [ ] All data models (Firestore collections)
  - [ ] All API endpoints
  - [ ] Design tokens (colors, spacing, fonts)
  - [ ] Why we chose async (not real-time)
  - [ ] Why posts stay active (not one-on-one)
  - [ ] Why no phone exchange in MVP

**Output:** You should be able to summarize the project in 3-5 sentences.

### Task 2: Identify Gaps or Questions
After reviewing, flag any:
- [ ] Unclear requirements
- [ ] Missing specifications
- [ ] Ambiguous design decisions
- [ ] Architectural concerns

**Output:** List of questions for Claude (optional, but helpful)

### Task 3: Generate Backend Prompt
Create a comprehensive prompt for Antigravity IDE to generate Firebase Cloud Functions:

**Output File:** `/Prompts/production/backend-prompt.v1.0.0.md`

**Should Include:**
- Detailed requirements for each Cloud Function
- Firestore data model specifications
- Security rules
- Cloud Messaging integration
- Error handling
- Reference to `/Planning/architecture.md` and `/Planning/spec.md`

**Metadata:**
```markdown
---
version: 1.0.0
author: Codex
date: [Today]
status: production
model: [Your model]
parameters:
  temperature: 0.5
  max_tokens: 4000
description: Backend code generation for Firebase Cloud Functions
tested_with: Firebase Emulator, Jest
---
```

### Task 4: Generate Frontend Prompt
Create a comprehensive prompt for Antigravity IDE to generate SwiftUI iOS code:

**Output File:** `/Prompts/production/frontend-prompt.v1.0.0.md`

**Should Include:**
- Detailed requirements for each screen
- Component specifications (reference `/Design/component-specs.md`)
- Design tokens usage (reference `/Design/design-tokens.md`)
- Navigation structure
- State management
- Firebase integration (auth, notifications, messages)
- Error handling

**Metadata:**
```markdown
---
version: 1.0.0
author: Codex
date: [Today]
status: production
model: [Your model]
parameters:
  temperature: 0.5
  max_tokens: 4000
description: Frontend code generation for SwiftUI iOS
tested_with: Xcode previews, Firebase
---
```

### Task 5: Generate Integration Prompt (Optional)
Create a prompt for API integration and data flow:

**Output File:** `/Prompts/production/integration-prompt.v1.0.0.md`

**Should Include:**
- Firebase integration (auth, Firestore, messaging, storage)
- Data sync patterns
- Error handling
- Real-time listeners (where applicable)

---

## Critical Constraints to Enforce in Prompts

When writing prompts, **emphasize these**:

1. **No Real-Time Chat**
   - Use Firestore polling, not listeners
   - 2-5 second latency is acceptable
   - Simpler = better for MVP

2. **Posts Stay Active**
   - After first acceptance, post remains visible
   - Multiple people can accept same activity
   - This is a design choice, not a bug

3. **No Phone Numbers in MVP**
   - Phone numbers never displayed in UI
   - All contact happens in-app messages
   - Phone exchange deferred to v1.1

4. **Geohashing Required**
   - All location queries MUST use geohashing
   - Not naive lat/lng filtering
   - Firebase best practice for scalability

5. **Async Messaging**
   - Messages stored in Firestore
   - Fetched on demand (polling), not real-time listeners
   - No typing indicators, presence, or read receipts in MVP

6. **10km Radius Fixed**
   - Not a user setting
   - Cloud Functions hardcode this
   - All notifications filtered to 10km radius

---

## Reference Files (Quick Links)

| File | Purpose | When to Use |
|------|---------|------------|
| `/Planning/spec.md` | What to build | Reference detailed acceptance criteria |
| `/Planning/architecture.md` | How to build it | Reference data models, APIs, tech decisions |
| `/Design/design-tokens.md` | UI values | Reference colors, spacing, fonts |
| `/Design/screens.md` | Screen specs | Reference UI layout and user flows |
| `/Planning/decisions.md` | Why we decided X | Understand architectural rationale |
| `/Prompts/VERSIONING.md` | Versioning strategy | When updating prompts |

---

## Verification Checklist (Before Submitting Prompts)

Before uploading prompts, verify:

- [ ] Backend prompt includes all 5 API endpoints
- [ ] Backend prompt specifies all Firestore collections
- [ ] Backend prompt includes Cloud Messaging setup
- [ ] Backend prompt includes geohashing logic
- [ ] Backend prompt includes error handling
- [ ] Frontend prompt includes all 7 screens
- [ ] Frontend prompt references design tokens (not hardcoded colors)
- [ ] Frontend prompt specifies async messaging (not real-time)
- [ ] Frontend prompt includes Firebase integration
- [ ] Frontend prompt specifies navigation structure
- [ ] Both prompts reference `/Planning/spec.md` for acceptance criteria
- [ ] Both prompts reference `/Design/design-tokens.md` for UI values
- [ ] Metadata includes version, author, date, status
- [ ] Prompts are saved to `/Prompts/production/` with .v1.0.0 naming

---

## Quality Standards

Your prompts must be:
- **Comprehensive** — Cover all features, not just happy path
- **Reference-Correct** — Point to actual files and documents
- **Actionable** — Clear enough for Antigravity IDE to generate working code
- **Specific** — Not vague; include concrete examples and requirements
- **Testable** — Include acceptance criteria and verification steps

---

## Questions or Clarifications?

If you find gaps or ambiguities while reviewing:
1. Check `/Planning/spec.md` first
2. Check `/Planning/decisions.md` for rationale
3. Check `/Planning/architecture.md` for design details
4. If still unclear, flag it for Claude in your report

---

## Success Criteria

You're done when:
- ✅ You've read and understood the entire project
- ✅ You've generated 2-3 comprehensive prompts
- ✅ Prompts are saved to `/Prompts/production/` with proper versioning
- ✅ Each prompt includes metadata
- ✅ You've verified all checklist items above

Then Antigravity IDE will take your prompts and generate production-ready code into:
- `/apps/frontend/` — SwiftUI iOS code
- `/apps/backend/` — Firebase Cloud Functions code

---

## Timeline

- **Now:** Complete project review (1-2 hours)
- **Today/Tomorrow:** Generate backend prompt v1.0.0
- **Today/Tomorrow:** Generate frontend prompt v1.0.0
- **Next:** Antigravity IDE uses prompts to generate code (1-2 weeks)
- **Final:** Testing + verification (1 week)

---

## Final Notes

1. **Read the spec first.** Everything else flows from `/Planning/spec.md`
2. **Ask for clarification.** It's better to ask than to assume
3. **Keep prompts focused.** One prompt per component (backend, frontend)
4. **Version properly.** Use semantic versioning (v1.0.0 → v1.1.0, v2.0.0)
5. **Reference documents.** Don't repeat specs; link to them

---

**You're now ready to review the CoffeeCall project and generate prompts.**

Start with `/Planning/spec.md` and work your way through the checklist above.

Good luck! 🚀

---

**Document Status:** Ready for Codex Review  
**Last Updated:** 2026-05-10  
**Next Owner:** Codex (Prompt Generation) → Antigravity IDE (Code Generation) → Claude (Verification)
