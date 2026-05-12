# CoffeeCall MVP — Final Assembly Plan

**Date:** May 12, 2026  
**Status:** Ready for Agent Handoff  
**Owner:** Claude (Final Assembly Coordinator)  
**Agents in Progress:** 5 parallel designer agents

---

## Overview

This document outlines the final assembly strategy for completing the CoffeeCall MVP design after the 5 parallel designer agents complete their work.

### Work Completed So Far (Claude - Pre-Assembly Phase)
1. ✅ Design system established (colors, typography, spacing, radius)
2. ✅ 18 reusable components created (buttons, inputs, cards, modals, tabs)
3. ✅ Spawned 5 parallel agents to design 7 screens
4. ✅ Created comprehensive design specification (DESIGN_SPECIFICATION.md)
5. ✅ Created detailed verification checklist (FINAL_ASSEMBLY_CHECKLIST.md)
6. ✅ Prepared final assembly plan (this document)

### Agents Currently Working (Parallel)
- **Agent 1:** Signup/Onboarding flow (8-step registration)
- **Agent 2:** Home/Discover screen (activity feed)
- **Agent 3:** Post Creation + Acceptance Confirmation Dialog
- **Agent 4:** Messages/Chat screen (messaging thread)
- **Agent 5:** My Posts/Dashboard + Profile screens

---

## Final Assembly Workflow (Post-Agent)

### Step 1: Canvas Organization & Screen Cleanup
**Time Estimate:** 30-45 minutes  
**Objective:** Ensure all screens are properly positioned and organized

#### Actions:
1. [ ] Verify all 7 screens are present in `lP1Xr` (Screens frame)
2. [ ] Remove any duplicate or obsolete screens
3. [ ] Organize screens in logical order:
   - Signup flow screens (top)
   - Main app screens (middle): Home, Post Creation, Chat, My Posts, Profile
   - Dialog/modals (organized by usage)
4. [ ] Ensure consistent spacing between screens (64px gap already defined)
5. [ ] Verify all screens maintain 390-414px width (iPhone size)
6. [ ] Check that all screens have proper 844-896px height

#### Screen Ordering on Canvas:
```
1. Auth 1 - Welcome Screen
2. Auth 2 - Phone Entry
3. Auth 3 - OTP Verification
4. Auth 4 - Profile Setup
5. Auth 5 - Interests Selection
6. Auth 6 - Location Permission
7. Auth 7 - Selfie Verification
8. Auth 8 - Success
---
9. Home/Discover Screen (Tab Bar: Home active)
10. Post Creation Screen (Form)
11. Acceptance Confirmation Dialog (Modal overlay)
12. Messages/Chat Screen (Tab Bar: Messages active)
13. My Posts/Dashboard Screen (Tab Bar: My Posts active)
14. Profile Screen (Tab Bar: Profile active)
```

---

### Step 2: Design System Compliance Verification
**Time Estimate:** 60-90 minutes  
**Objective:** Ensure all screens adhere to design system variables and tokens

#### Color Verification:
- [ ] Run search for hardcoded colors (grep for #[0-9A-Fa-f])
- [ ] Replace any hardcoded colors with variables:
  - Primary actions → `$color-primary`
  - Reject/secondary → `$color-coral`
  - Text → `$color-text`
  - Secondary text → `$color-text-muted`
  - Backgrounds → `$color-bg`
  - Borders → `$color-border`
- [ ] Verify all fills use variable references ($ prefix)

#### Typography Verification:
- [ ] Check all titles are **28px, weight 700** (consistent)
- [ ] Check all section headers are **16px, weight 600**
- [ ] Check all body text is **14px, weight 400**
- [ ] Check all secondary text is **12px, weight 400**
- [ ] Check all button text is **14px, weight 600, uppercase**
- [ ] Verify font family is **Inter** throughout

#### Spacing Verification:
- [ ] All padding uses spacing variables:
  - `$spacing-xs` (4px) - minimal gaps
  - `$spacing-sm` (8px) - small spacing
  - `$spacing-md` (16px) - standard padding (cards, inputs)
  - `$spacing-lg` (24px) - section gaps
  - `$spacing-xl` (32px) - major gaps
- [ ] No hardcoded pixel values for spacing
- [ ] Consistent left/right padding on all screens (16-24px)
- [ ] Gap between sections consistent (24-32px)

#### Border Radius Verification:
- [ ] Buttons use `$radius-md` (12px)
- [ ] Input fields use `$radius-sm` (8px) or `$radius-md` (12px)
- [ ] Cards use `$radius-md` (12px)
- [ ] Modals use `$radius-md` or `$radius-lg` (20px)
- [ ] Tab bar pill uses `$radius-lg` (20px)
- [ ] No hardcoded radius values

---

### Step 3: Component Instance Verification
**Time Estimate:** 45-60 minutes  
**Objective:** Ensure all components are properly instantiated and customized

#### Component Usage Check:
- [ ] **sp1E6 (Bottom Tab Bar):** Present on all screens except Signup
  - Home: Home tab active
  - Post Creation: Home tab active (if present on this screen)
  - Chat: Messages tab active
  - My Posts: My Posts tab active
  - Profile: Profile tab active
  
- [ ] **HHcVb (Button/Primary):** Used for all primary CTAs
  - Submit buttons on forms
  - Confirm buttons on dialogs
  - "Continue" buttons on signup steps
  - Accept buttons on activity cards
  - Check: 44px height, correct padding, radius-md

- [ ] **Sof5H (Input/Text):** Used for all text inputs
  - Phone number, OTP, name, purpose, etc.
  - Check: 48px height, proper stroke, focus state

- [ ] **spFru (Input/DateTime):** Used for time selection
  - Post creation time picker
  - Check: proper formatting, calendar picker

- [ ] **ooEjY (Activity Card):** Used on Home/Discover
  - Multiple instances for activity listings
  - Check: avatar, name, purpose, location, time, buttons
  - Check: shadow and elevation

- [ ] **vvlGt (Compact Activity Card):** Used on My Posts
  - Smaller horizontal layout
  - Check: image, title, location, acceptance count

- [ ] **Alim1 (Chat Bubble Outgoing):** Used for sent messages
  - Right-aligned, primary color background
  - Timestamp included

- [ ] **jbQXb (Chat Bubble Incoming):** Used for received messages
  - Left-aligned, gray background
  - Timestamp included

- [ ] **BiTzO (Join Confirmation Modal):** Used for acceptance dialog
  - Activity details + poster profile
  - Confirm/Cancel buttons
  - Check: centered, proper sizing, backdrop

- [ ] **kBXRH (User Card):** Used for user profiles
  - Acceptor lists, profile display
  - Check: avatar, name, rating, interests

---

### Step 4: Accessibility Audit
**Time Estimate:** 45-60 minutes  
**Objective:** Verify WCAG AA compliance and touch ergonomics

#### Contrast Verification:
- [ ] All text meets 4.5:1 contrast minimum
- [ ] Primary text on light background: #1E293B on #F8FAFC ✓
- [ ] Primary color button text: contrast with #3B82F6 ✓
- [ ] Coral button text: contrast with #FF7A59 ✓
- [ ] Muted text visibility: check specific combos
- [ ] No text too light on light background

#### Touch Target Check:
- [ ] All buttons: minimum 44x44px ✓
- [ ] All input fields: minimum 48px height ✓
- [ ] All card tap areas: comfortable (16px+ gaps)
- [ ] Tab bar items: min 44x44px each ✓
- [ ] No cramped or hard-to-tap elements
- [ ] Modal dismiss area (outside modal) adequate

#### Navigation Clarity:
- [ ] Active tab clearly distinguished from inactive
- [ ] Back buttons present in nested flows
- [ ] Signup step progression obvious
- [ ] Empty states have clear messaging
- [ ] Error messages visible and helpful

---

### Step 5: Layout & Alignment Verification
**Time Estimate:** 30-45 minutes  
**Objective:** Ensure proper screen structure and alignment

#### Screen Structure:
- [ ] Status bar: 62px height (OS-controlled, don't modify)
- [ ] App content: Starts below status bar
- [ ] Content wrapper: Single vertical frame with consistent padding
- [ ] Padding: 16-24px left/right on all screens
- [ ] Tab bar: Positioned at bottom, sticky during scroll

#### Vertical Alignment:
- [ ] Content properly distributed within screen
- [ ] No excessive white space at bottom
- [ ] Scroll areas: proper bottom padding (gap value)
- [ ] Modals: centered vertically on screen

#### Horizontal Alignment:
- [ ] Consistent left/right margin on all screens
- [ ] Text alignment matches component definitions
- [ ] Buttons properly aligned
- [ ] Cards aligned with screen edges

---

### Step 6: Screen-Specific Verification
**Time Estimate:** 60-90 minutes  
**Objective:** Verify each screen meets all requirements

#### Use Checklist Section 6 from FINAL_ASSEMBLY_CHECKLIST.md:
- [ ] Signup Flow: 8 steps, proper progression, no tab bar
- [ ] Home/Discover: Cards, filters, search, empty state, tab bar
- [ ] Post Creation: Form fields, submission, success
- [ ] Acceptance Dialog: Modal content, buttons, overlay
- [ ] Messages/Chat: Thread, bubbles, input, tab bar
- [ ] My Posts: Posted activities, acceptor list, tab bar
- [ ] Profile: Avatar, stats, action buttons, tab bar

---

### Step 7: Visual Quality Verification
**Time Estimate:** 30-45 minutes  
**Objective:** Ensure polish and consistency

#### Visual Checks:
- [ ] No misaligned elements
- [ ] Shadows consistent and subtle
- [ ] Color usage consistent throughout
- [ ] Typography hierarchy clear
- [ ] Component styling matches definitions
- [ ] No broken component references
- [ ] Smooth visual flow between screens

---

### Step 8: Screenshot Capture & Export
**Time Estimate:** 30-45 minutes  
**Objective:** Prepare final deliverables

#### Screenshots to Capture:
1. [ ] Signup - Onboarding flow (representative steps)
2. [ ] Home/Discover - Feed with activity cards
3. [ ] Post Creation - Form layout
4. [ ] Acceptance Dialog - Modal overlay
5. [ ] Messages - Chat thread
6. [ ] My Posts - Dashboard with acceptor list
7. [ ] Profile - User profile + stats

#### Export Settings:
- Scale: 2x (for clarity on modern displays)
- Format: PNG
- Include context: Each screen labeled with name

#### Asset Exports:
- [ ] Color palette (CSS/Swift format)
- [ ] Typography styles
- [ ] Spacing tokens
- [ ] Component reference guide

---

### Step 9: Final Documentation & Handoff
**Time Estimate:** 45-60 minutes  
**Objective:** Create handoff materials for code generation

#### Documents to Create/Update:
1. [ ] **Component Library Guide**
   - Each component's purpose, usage, states
   - Props and customization options
   - Visual examples

2. [ ] **Design Tokens Export**
   ```swift
   // Colors
   let colorPrimary = UIColor(hex: "#3B82F6")
   let colorCoral = UIColor(hex: "#FF7A59")
   let colorText = UIColor(hex: "#1E293B")
   
   // Spacing
   let spacingSM = 8.0
   let spacingMD = 16.0
   let spacingLG = 24.0
   
   // Radius
   let radiusMD = 12.0
   let radiusLG = 20.0
   ```

3. [ ] **Screen Specifications**
   - Each screen's layout structure
   - Component instances used
   - Content requirements
   - Interaction patterns

4. [ ] **Accessibility Report**
   - Contrast verification
   - Touch target verification
   - Navigation audit

5. [ ] **Handoff Summary**
   - What's included
   - How to use design files
   - Next steps for code generation

---

### Step 10: Final Review & Approval
**Time Estimate:** 30 minutes  
**Objective:** Final sign-off before code generation

#### Final Checks:
- [ ] All screens present and correct
- [ ] Design system fully applied
- [ ] Components properly used
- [ ] Accessibility verified
- [ ] Screenshots captured
- [ ] Documentation complete
- [ ] No blocking issues

#### Approval Sign-Off:
- [ ] Design is production-ready
- [ ] Ready for Codex prompt generation
- [ ] Ready for Ambiglytics code generation

---

## Timeline & Dependencies

### Parallel Work (Agents Working Now)
- **Duration:** ~1-2 hours
- **Deliverable:** 5 screen design groups (7 total screens)
- **Blocking:** All steps below

### Sequential Assembly Work (Claude - Post-Agent)
| Step | Duration | Dependencies |
|------|----------|--------------|
| 1. Canvas Organization | 30-45m | Agent work complete |
| 2. Design System Compliance | 60-90m | Step 1 complete |
| 3. Component Verification | 45-60m | Step 2 complete |
| 4. Accessibility Audit | 45-60m | Step 3 complete (parallel possible) |
| 5. Layout Verification | 30-45m | Step 4 complete (parallel possible) |
| 6. Screen-Specific Check | 60-90m | Step 5 complete |
| 7. Visual Quality | 30-45m | Step 6 complete (parallel possible) |
| 8. Screenshot Capture | 30-45m | Step 7 complete |
| 9. Documentation | 45-60m | Step 8 complete |
| 10. Final Review | 30m | Step 9 complete |
| **Total** | **5-7 hours** | Sequential |

### Grand Total
- Agent parallel work: ~1-2 hours
- Claude assembly: ~5-7 hours
- **Total project time: 6-9 hours**

---

## Success Criteria

### Design Completeness
- ✓ All 7 screens designed and visible
- ✓ All screens follow the design specification
- ✓ All user flows are complete

### Quality Standards
- ✓ Design system fully applied (no hardcoded values)
- ✓ All components properly instantiated
- ✓ WCAG AA accessibility compliance
- ✓ Consistent visual style across all screens
- ✓ Production-ready for code generation

### Documentation
- ✓ Comprehensive design specification
- ✓ Component library reference
- ✓ Design tokens exported
- ✓ Final screenshots captured
- ✓ Handoff materials prepared

---

## Handoff to Code Generation

### Deliverables to Codex/Ambiglytics:
1. **Design File:** `untitled.pen` (finalized and organized)
2. **Design Specification:** Complete screen-by-screen specs
3. **Component Guide:** Usage, states, customization
4. **Design Tokens:** Colors, typography, spacing (Swift/CSS)
5. **Screenshots:** All 7 screens at 2x resolution
6. **Assets:** Icons, images, color palette

### Code Generation Process:
1. **Codex** generates detailed SwiftUI implementation prompts
2. **Ambiglytics** transforms prompts to working code
3. **SwiftUI** views created matching design fidelity
4. **Testing** verifies visual fidelity against design

---

## Risk Mitigation

### Potential Issues & Solutions:

| Risk | Probability | Mitigation |
|------|-------------|-----------|
| Agent screen misalignment | Low | Canvas org cleanup |
| Color inconsistency | Medium | Automated variable replacement |
| Component misuse | Medium | Component verification checklist |
| Accessibility gaps | Low | Contrast & touch target audit |
| Missing screens | Low | Inventory check against spec |
| Spacing inconsistency | Medium | Spacing token verification |

---

## Notes

- All work documented in `DESIGN_SPECIFICATION.md` and `FINAL_ASSEMBLY_CHECKLIST.md`
- Design system is solid foundation (18 components + tokens ready)
- Agents are instructed to use components, not hardcode layouts
- Final assembly is meticulous verification, not redesign

---

**Document Version:** 1.0  
**Created:** May 12, 2026  
**Status:** Ready for Agent Handoff  
**Next Update:** After agent work completion
