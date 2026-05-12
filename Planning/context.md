# CoffeeCall Project Context

## Session: Design Scope Validation (2026-05-12)

### What Happened
Validated initial Figma design brief (`CoffeeCall_Final_Figma_Brief.md`) against MVP architecture.

**Finding:** The initial brief was comprehensive but over-scoped—it described a v1.1+ product (15 screens with full reputation system) rather than the 3-week MVP (7-8 screens, no reputation).

### Decision
**Option A: MVP-First Approach** — Align design brief with 3-week timeline and existing architecture decisions.

**Key changes:**
- ✅ Reduced from 15 screens → 8 screens
- ✅ Removed reputation system (trust scores, badges, flakes)
- ✅ Removed post-meetup reviews & ratings
- ✅ Removed penalty system
- ✅ Removed scanner/radar visualization
- ✅ Removed settings screen (v1.2+)
- ✅ Kept design system (colors, typography, spacing)

### Deliverables
1. **New Brief:** `CoffeeCall_MVP_Design_Brief.md` (finalized, governance doc)
2. **Archived:** `CoffeeCall_Final_Figma_Brief.md` (reference for v1.1+ planning)
3. **Updated:** `decisions.md` (added design scope decision)

### MVP Screens (8 Total)
1. Auth Flow (6 steps)
2. Discovery/Notifications List
3. Post Activity Modal
4. Acceptance Confirmation Dialog
5. Match Confirmed
6. Messages Thread
7. My Activities Dashboard
8. Profile View

### Next Steps
1. Design all 8 screens in Figma/Pencil
2. Build component library
3. Create interactive prototype
4. Handoff to Ambiglytics for code generation
5. Ship in 3 weeks

### Timeline Lock
- **Design phase:** Week 1 (May 12-18)
- **Dev phase:** Weeks 2-3 (May 19-25)
- **Launch:** By 2026-05-25

---

**Owner:** Claude (Planner)  
**Status:** Approved  
**Next Review:** 2026-05-18 (design review)
