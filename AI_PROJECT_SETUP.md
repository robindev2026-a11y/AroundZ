# CoffeeCall: AI-Assisted Development Setup (Corrected Structure)

## Complete Folder Structure

```
CoffeeCall/
├── README.md                          # For humans (quick start, overview)
├── CLAUDE.md                          # For Claude Code (AI assistant context)
├── AGENTS.md                          # For all AI tools (standardized format)
├── .claudeignore                      # Files Claude should ignore
├── .claude/
│   ├── settings.json                  # Permissions and tool config
│   └── CLAUDE.md                      # Project-scoped Claude config (optional)
├── .cursorrules                       # For Cursor IDE users
│── Planning/
│   ├── README.md                      # Overview of planning docs
│   ├── spec.md                        # Comprehensive specification (NEW)
│   ├── architecture.md                # System design, tech stack, components
│   ├── features.md                    # Feature breakdown with acceptance criteria
│   ├── requirements.md                # User stories, requirements (NEW)
│   ├── api-spec.md                    # API endpoints and contracts (if applicable)
│   ├── decisions.md                   # Architecture Decision Records (ADRs)
│   ├── timeline.md                    # Project phases and milestones
│   └── context.md                     # Session context (updated after each session)
├── Design/
│   ├── README.md                      # Overview of design docs
│   ├── design-system.md               # Colors, typography, spacing, patterns
│   ├── design-tokens.md               # Reusable design values (NEW)
│   ├── screens.md                     # Screen specifications and wireframes
│   ├── component-specs.md             # Individual component details (NEW)
│   ├── design-decisions.md            # UX rationale and philosophy
│   ├── accessibility.md               # WCAG compliance and inclusive design
│   ├── figma-link.md                  # Links to living design system
│   └── assets/                        # Images, icons, design references
└── Prompts/
    ├── README.md                      # Prompt organization guide
    ├── VERSIONING.md                  # Prompt versioning strategy (NEW)
    ├── templates/                     # Reusable prompt structures
    │   ├── analysis-template.md
    │   ├── code-generation-template.md
    │   └── documentation-template.md
    ├── production/                    # Versioned prompts for code gen
    │   ├── backend-prompt.v1.0.0.md
    │   ├── frontend-prompt.v1.0.0.md
    │   └── integration-prompt.v1.0.0.md
    └── evaluation/                    # Testing and quality prompts
        ├── test-generation.md
        └── quality-evaluation.md
```

---

## Component Details & Corrections

### 1. Planning Folder (CORRECTED)

**New/Enhanced Files:**

#### **spec.md** (NEW - CRITICAL)
The single source of truth. Should contain:
- Project overview and problem statement
- Features and requirements
- Architecture and data models
- API contracts
- Testing strategy and acceptance criteria
- Constraints and limitations

**Why:** This becomes your "golden reference" that Codex uses to generate consistent prompts.

#### **requirements.md** (NEW)
User stories, acceptance criteria per feature, priority levels, dependencies.

Format:
```markdown
## Feature: [Name]

### User Story
As a [role], I want to [action], so that [benefit]

### Acceptance Criteria
- [ ] User can...
- [ ] System should...

### Priority: [High/Medium/Low]
### Dependencies: [List]
```

#### **api-spec.md** (NEW - if backend exists)
Document all API endpoints:
```markdown
## POST /posts
### Request
```json
{
  "purpose": "string",
  "location": {"lat": number, "lng": number},
  "time": "ISO8601"
}
```
### Response
```json
{
  "id": "string",
  "status": "success"
}
```
### Errors
- 400: Invalid location
- 401: Unauthorized
```

#### **decisions.md** (ENHANCED - Use ADR Format)
Format each decision as:
```markdown
## ADR-001: Use Firebase Instead of Custom Backend

### Status
Accepted

### Context
We need a backend for CoffeeCall MVP.

### Decision
Use Firebase (Auth, Firestore, Cloud Messaging, Storage).

### Rationale
- Serverless (no ops overhead)
- Built-in geolocation support
- Scales without infra work
- Lower cost for MVP stage

### Consequences
- Vendor lock-in (Firebase)
- Less customization for platform-specific features
- Rate limits for Firestore

### Alternatives Considered
- Custom Node.js + PostgreSQL (rejected: too much dev time)
- AWS Lambda + DynamoDB (rejected: higher ops complexity)

### Date
2026-05-10

### Author
Claude (Planner)
```

#### **context.md** (NEW - Session Tracking)
Created at the end of each working session:
```markdown
# Session Context - [Date]

## What We Accomplished
- Completed architecture planning
- Defined the MVP screens
- Decided on SwiftUI iOS + Firebase stack

## Critical Details
- SwiftUI / Xcode version: [X]
- Firebase regions: [US]
- Min iOS target: [15.0]
- Android: deferred to future phase

## Next Session Focus
1. Design finalization (Figma mockups)
2. Generate backend prompt with Codex
3. Begin Ambiglytics code generation

## Blockers
None

## Architecture Updates
- Added Poster Dashboard screen
- Confirmed posts stay active (group meetups)
```

---

### 2. Design Folder (CORRECTED)

**New/Enhanced Files:**

#### **design-tokens.md** (NEW - CRITICAL)
Reusable values for consistent code generation:
```markdown
# Design Tokens

## Colors
| Token | Value | Usage |
|-------|-------|-------|
| color-primary | #6C5CE7 | Buttons, highlights |
| color-secondary | #00B894 | Positive actions |
| color-background | #FFFFFF | Main backgrounds |
| color-surface | #F5F6FA | Card backgrounds |
| color-text-primary | #2D3436 | Body text |
| color-text-secondary | #636E72 | Secondary text |
| color-border | #DFE6E9 | Dividers |
| color-error | #D63031 | Error states |

## Spacing
| Token | Value | Usage |
|-------|-------|-------|
| spacing-xs | 4px | Tight spacing |
| spacing-sm | 8px | Small gaps |
| spacing-md | 16px | Default spacing |
| spacing-lg | 24px | Large gaps |
| spacing-xl | 32px | Extra large gaps |

## Typography
| Token | Font | Size | Weight | Usage |
|-------|------|------|--------|-------|
| heading-1 | Inter | 32px | Bold | Page titles |
| heading-2 | Inter | 24px | Bold | Section titles |
| body | Inter | 16px | Regular | Body text |
| caption | Inter | 12px | Regular | Small text |

## Shadows
| Token | Value |
|-------|-------|
| shadow-sm | 0 1px 3px rgba(0,0,0,0.1) |
| shadow-md | 0 4px 6px rgba(0,0,0,0.15) |
| shadow-lg | 0 8px 12px rgba(0,0,0,0.2) |

## Corner Radius
| Token | Value | Usage |
|-------|-------|-------|
| radius-sm | 4px | Small elements |
| radius-md | 8px | Cards, inputs |
| radius-lg | 12px | Modals, containers |
| radius-full | 50% | Avatars, circles |
```

**Why:** Codex/Ambiglytics can reference these tokens directly in generated code, ensuring consistency.

#### **component-specs.md** (NEW)
For each component, document:
```markdown
## Button Component

### Variants
- **Primary** (color-primary, default)
- **Secondary** (color-secondary, outline)
- **Danger** (color-error, filled)
- **Disabled** (grayed out, no interaction)

### States
- Default
- Hover
- Active
- Disabled
- Loading

### Properties
- Size: small | medium | large
- Full width option
- Icon + text support
- Loading spinner

### Code Example
```swift
Button(
  text: "Accept",
  variant: .primary,
  size: .medium,
  onTap: { /* ... */ }
)
```

### Accessibility
- WCAG AA contrast (4.5:1)
- Min 44px touch target
- Keyboard navigable
```

#### **accessibility.md** (NEW - WCAG Compliance)
```markdown
# Accessibility Guidelines

## Color Contrast
- All text: 4.5:1 contrast minimum (WCAG AA)
- Large text (18pt+): 3:1 contrast minimum
- Test with: https://webaim.org/resources/contrastchecker/

## Touch Targets
- All interactive elements: minimum 44x44 points
- Spacing between targets: minimum 8 points

## Screen Readers
- All images must have alt text
- Form labels associated with inputs
- Use semantic HTML/native components

## Keyboard Navigation
- All features accessible via keyboard
- Tab order logical and visible
- Skip links for repetitive content

## Testing
- Test with iOS VoiceOver
- Test with keyboard navigation only
- Test with high contrast mode
```

---

### 3. Prompts Folder (CORRECTED)

**New/Enhanced Structure:**

#### **VERSIONING.md** (NEW)
```markdown
# Prompt Versioning Strategy

## Semantic Versioning for Prompts
- **Major (1.0.0 → 2.0.0):** Breaking changes (output format, task scope)
- **Minor (1.0.0 → 1.1.0):** Backward-compatible improvements
- **Patch (1.0.0 → 1.0.1):** Bug fixes, typos, edge cases

## Metadata Per Prompt
Each prompt file should include:
```yaml
---
version: 1.0.0
author: [Name]
date: 2026-05-10
status: production | staging | dev
model: claude-opus-4.7
parameters:
  temperature: 0.7
  max_tokens: 4000
changes: "Initial release for backend code generation"
evaluation_score: 0.92 (1-100 scale)
---
```

## Deployment Strategy
1. Write prompt in `dev/` folder
2. Test and evaluate (track metrics)
3. Move to `staging/` with v0.1.0
4. Deploy to `production/` with v1.0.0
5. Never edit deployed versions—always create new versions
6. Use feature flags for rollback if needed

## Rollback Strategy
If a prompt generates poor code:
```
Current: backend-prompt.v1.1.0.md (broken)
Rollback: Switch to backend-prompt.v1.0.0.md immediately
Fix: Create backend-prompt.v1.1.1.md with fix
Deploy: Promote v1.1.1 to production
```
```

#### **templates/** Folder Structure
```markdown
# analysis-template.md
[Template for analyzing existing code, requirements, architecture]

# code-generation-template.md
[Template for instructing Ambiglytics to generate code]

# documentation-template.md
[Template for generating documentation from code]
```

#### **Prompt Metadata Example** (in production/ folder)
```markdown
---
version: 1.0.0
author: Codex
date: 2026-05-10
status: production
model: claude-opus-4.7
parameters:
  temperature: 0.5
  max_tokens: 4000
changes: "Initial backend prompt for Firebase + Cloud Functions"
evaluation_score: 0.91
tested_with: [Firebase Emulator, Jest]
---

# Backend Code Generation Prompt

[Actual prompt content...]
```

---

### 4. README Files (CORRECTED)

#### **README.md** (Root Level - For Humans)
```markdown
# CoffeeCall

Activity-based meetup platform for coffee, movies, jogging, etc.

## Quick Start
1. Clone repo
2. Install dependencies: `npm install`
3. Set up Firebase: `firebase init`
4. Run: `npm start`

## Features
- Phone signup + profile
- Post activities with location/time
- Discover nearby activities (10km radius)
- Accept/reject + message coordination
- Simple async messaging

## Tech Stack
- Frontend: SwiftUI iOS
- Backend: Firebase (Auth, Firestore, Cloud Messaging, Storage)
- Geolocation: Native iOS

## Project Structure
See [CLAUDE.md](./CLAUDE.md) for detailed documentation structure.

## Contributing
See [CONTRIBUTING.md](./CONTRIBUTING.md) (if applicable)

## License
[Your License]
```

#### **CLAUDE.md** (For Claude Code - Enhanced)
```markdown
# CoffeeCall: Claude Code Configuration

## Project Overview
[Brief description + business context]

## Folder Structure & Purpose
- `/Planning` — Architecture, requirements, specifications, decisions
- `/Design` — Design system, components, wireframes, accessibility
- `/Prompts` — Versioned prompts for code generation

## How to Start Each Session
1. Read this file (CLAUDE.md)
2. Check `/Planning/spec.md` — Comprehensive spec
3. Check `/Planning/context.md` — Last session summary
4. Review latest prompt version in `/Prompts/production/`

## Build & Test Commands
- Build: `npm run build`
- Test: `npm test`
- Lint: `npm run lint`

## Code Conventions
- TypeScript: strict mode enabled
- Naming: camelCase for variables, PascalCase for classes
- Imports: sorted alphabetically
- Max line length: 100 characters

## Architecture Overview
[Link to design documents]

## Critical Dependencies & Versions
- SwiftUI iOS: v1.4+
- Firebase SDK: v9.0+
- Node: v18+

## Common Workflows
- Creating a new screen: See `/Design/component-specs.md`
- Adding a new API: See `/Planning/api-spec.md`
- Changing architecture: Document in `/Planning/decisions.md`

## Key Gotchas
- Firestore has rate limits (500 writes/second)
- Location permissions must be requested on app launch
- Messages are async (2-5 sec latency expected)

## Next Session Focus
See `/Planning/context.md` for the latest session notes.
```

#### **AGENTS.md** (NEW - For All AI Tools)
Standardized format recognized by Claude, Cursor, Aider, etc.
```markdown
# AGENTS.md - AI Assistant Configuration

## Project: CoffeeCall
Activity-based meetup platform (coffee, jog, movie).

## Critical Context
- **Frontend:** SwiftUI iOS
- **Backend:** Firebase (Auth, Firestore, Cloud Messaging, Storage)
- **Timeline:** 3 weeks to MVP launch
- **Key constraint:** Posts stay active (group meetups allowed)

## Specifications
- Full spec: `/Planning/spec.md`
- Architecture: `/Planning/architecture.md`
- Design system: `/Design/design-tokens.md`
- API spec: `/Planning/api-spec.md`

## How You Can Help
1. **Planning:** Refine architecture, identify gaps
2. **Code Generation:** Use prompts in `/Prompts/production/`
3. **Verification:** Test against `/Planning/spec.md`
4. **Documentation:** Keep `/Planning/context.md` updated

## What NOT to Do
- Never code directly; use Codex + Ambiglytics
- Don't change architecture without documenting in `/Planning/decisions.md`
- Don't commit without running tests

## Files to Read First
1. `/Planning/spec.md`
2. `/Design/design-system.md`
3. `/Planning/decisions.md`

## Folder Structure
[Use the folder tree above]
```

---

### 5. Configuration Files (NEW)

#### **.claude/settings.json** (NEW)
Granular permissions and tool configuration.
```json
{
  "allowedTools": {
    "bash": {
      "description": "Run shell commands",
      "defaultAllow": false,
      "allowList": [
        "npm run build",
        "npm test",
        "npm run lint"
      ]
    },
    "editor": {
      "description": "Edit files",
      "defaultAllow": true,
      "excludePaths": [
        "node_modules/**",
        "*.lock",
        ".env.local"
      ]
    }
  },
  "autoCommit": false,
  "maxContextWindow": 150000,
  "modelPreference": "claude-opus-4.7"
}
```

#### **.cursorrules** (For Cursor IDE Users - NEW)
```markdown
# Cursor Rules for CoffeeCall

You are a planning and oversight AI for the CoffeeCall project.

## Key Responsibilities
- Maintain architecture consistency
- Oversee code quality
- Never code directly—use Ambiglytics
- Update documentation after each session

## Project Conventions
- TypeScript strict mode
- PascalCase for classes/components
- camelCase for variables
- 100 char max line length

## Files to Check First
- `/Planning/spec.md` (always)
- `/Design/design-system.md` (for UI)
- `/Planning/decisions.md` (for architecture)

## Architecture
- Frontend: SwiftUI iOS
- Backend: Firebase
- No real-time chat (async only)
- Posts stay active (group meetups)

## Never Do
- Commit without tests passing
- Edit design tokens without updating `/Design/design-tokens.md`
- Change architecture decisions without ADR

## Code Generation Workflow
1. Refine requirements in `/Planning/`
2. Update design in `/Design/`
3. Generate prompt with Codex
4. Upload prompt to `/Prompts/production/`
5. Ambiglytics generates code
6. Verify against spec
```

#### **.claudeignore** (NEW)
```
node_modules/
.git/
*.lock
.env.local
.env.*.local
dist/
build/
.next/
__pycache__/
*.pyc
.DS_Store
.idea/
*.swp
*.swo
```

---

## Comparison: Before vs After

| Component | Before | After | Benefit |
|-----------|--------|-------|---------|
| Spec Document | Missing | spec.md | Single source of truth |
| Requirements | In architecture.md | requirements.md | Clear acceptance criteria |
| API Documentation | Missing | api-spec.md | Clear contracts for code gen |
| Design Tokens | Colors only | design-tokens.md + values | Ambiglytics can reference directly |
| Prompt Versioning | Ad-hoc | Semantic versioning + metadata | Track quality, enable rollback |
| Session Tracking | None | context.md | Continuity between sessions |
| AI Tool Config | None | AGENTS.md + settings.json | Better tool interoperability |
| Accessibility | Placeholder | accessibility.md | Compliance + testing |
| Component Specs | Missing | component-specs.md | Clear implementation guides |

---

## Implementation Checklist

- [ ] Create `/Planning/spec.md` (comprehensive specification)
- [ ] Create `/Planning/requirements.md` (user stories + acceptance criteria)
- [ ] Create `/Planning/api-spec.md` (API contracts)
- [ ] Enhance `/Planning/decisions.md` (use ADR format)
- [ ] Create `/Planning/context.md` (session tracking template)
- [ ] Create `/Design/design-tokens.md` (colors, spacing, typography)
- [ ] Create `/Design/component-specs.md` (component details + states)
- [ ] Create `/Design/accessibility.md` (WCAG compliance)
- [ ] Create `/Prompts/VERSIONING.md` (prompt versioning strategy)
- [ ] Create `/Prompts/templates/` folder with templates
- [ ] Create `AGENTS.md` (standardized AI assistant config)
- [ ] Create `.claude/settings.json` (permissions config)
- [ ] Create `.cursorrules` (Cursor IDE rules)
- [ ] Create `.claudeignore` (ignore file)
- [ ] Update root `README.md` (for humans)
- [ ] Update `CLAUDE.md` (for Claude Code)

---

**Status:** Corrected structure ready for implementation  
**Last Updated:** 2026-05-10
