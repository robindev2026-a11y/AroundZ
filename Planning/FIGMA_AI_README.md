# CoffeeCall MVP — Figma AI Handoff Package

**Purpose:** Complete, AI-ready specification for generating a clickable prototype in Figma  
**Audience:** Figma AI, designers, Pencil, or Antigravity IDE  
**Status:** ✅ Ready to use

---

## What You're Getting

Three documents, in this order:

### 1. **CoffeeCall_MVP_Design_Brief.md** (START HERE)
- 8-screen overview of the MVP
- Design system (colors, typography, spacing)
- UX rules and what's NOT included
- Perfect for understanding the product holistically

### 2. **CoffeeCall_MVP_Component_Specs.md** (BUILD WITH THIS)
- 12 reusable components (buttons, cards, inputs, avatars, etc.)
- All component states (default, hover, pressed, disabled, error)
- Exact sizing, padding, colors, typography
- Layout grid system (8px base unit)
- Icon requirements
- Typography application guide

### 3. **CoffeeCall_MVP_Screen_Content.md** (GENERATE FROM THIS)
- All 8 screens with exact content
- Every button label, placeholder text, color, size
- Interactions and what happens on tap/swipe
- Layout rules for each screen
- Empty states and error states
- Validation rules

---

## Quick Start for Figma AI

### Step 1: Design System Setup
1. Open Figma file "CoffeeCall MVP"
2. Create a "Design System" page with:
   - **Colors panel:** All 9 colors from brief (Primary Blue, Coral, Teal, etc.)
   - **Typography panel:** All 5 text styles (Heading 1, Body 1, Caption, etc.)
   - **Spacing guide:** 8px grid visualization

### Step 2: Build Components
1. Create component pages for each component type:
   - Buttons (primary, secondary, action, sizes)
   - Form inputs (text, dropdown, OTP code boxes)
   - Cards (activity, message, profile)
   - Navigation (tab bar, icons)
   - Avatar (small, medium, large)
   - Badges & status indicators

2. Each component should have variants for all states:
   - Default, Hover, Pressed, Disabled
   - Error, Focused, Filled
   - Selected, Unselected

### Step 3: Build Screens
1. Create 8 pages (one per screen)
2. Use components, not static elements
3. Reference exact content from `CoffeeCall_MVP_Screen_Content.md`
4. Apply design tokens (colors, typography) from system

### Step 4: Create Prototype
1. Add interactions to buttons/links
2. Map navigation flows:
   - Welcome → OTP → Profile → Permissions → Discovery
   - Discovery "Accept" → Confirmation → Match Confirmed → Messages
   - All screens connect to bottom navigation tabs

2. Test all user journeys:
   - Complete signup flow
   - Post an activity
   - Accept an activity
   - Send a message

---

## Document Structure

```
Planning/
├── CoffeeCall_MVP_Design_Brief.md
│   └── Use this to understand product + design system
│
├── CoffeeCall_MVP_Component_Specs.md
│   └── Use this to build components with correct specs
│
├── CoffeeCall_MVP_Screen_Content.md
│   └── Use this for exact copy + layout rules for each screen
│
└── FIGMA_AI_README.md (this file)
    └── Quick reference to tie everything together
```

---

## What to Feed Figma AI

**Input:** All three documents above  
**Output:** Clickable prototype with 8 screens + components

### Recommended Prompt for Figma AI

```
Create a clickable prototype for CoffeeCall MVP with 8 screens.

Design System Reference: See CoffeeCall_MVP_Design_Brief.md
- Colors: Primary Blue #3B82F6, Coral #FF7A59, Teal #0F766E, etc.
- Typography: SF Pro Display, Heading 1: 28px bold, Body 1: 16px regular, etc.
- Spacing: 8px base unit (8, 16, 24, 32, 40px)

Component Specifications: See CoffeeCall_MVP_Component_Specs.md
- 12 reusable components with all states
- Exact sizing, padding, colors
- Layout grid and spacing rules

Screen Details & Content: See CoffeeCall_MVP_Screen_Content.md
- All 8 screens with exact copy, colors, interactions
- Component usage on each screen
- Navigation flows and button targets

Screens to create:
1. Auth Flow (6 steps: Welcome, Phone, OTP, Profile, Permissions, Done)
2. Discovery List (Nearby activities)
3. Post Activity Modal
4. Acceptance Confirmation Dialog
5. Match Confirmed
6. Messages Thread
7. My Activities Dashboard
8. Profile View

Plus:
- Bottom navigation (5 tabs: Discover, Post, My Activities, Messages, Profile)
- Component library page
- Design system page (colors, typography)

Use components, not static elements. Apply design tokens to all elements.
Create interactive prototype with all navigation flows.
```

---

## File Outputs (Figma)

After generation, you should have:

```
CoffeeCall MVP.fig (Figma File)
├── Page: Design System
│   ├── Colors
│   ├── Typography
│   ├── Spacing Grid
│   └── Assets/Icons
│
├── Page: Components
│   ├── Buttons
│   ├── Form Elements
│   ├── Cards
│   ├── Navigation
│   ├── Avatars
│   └── Badges
│
├── Page: Auth Flow
│   ├── Welcome
│   ├── Phone Entry
│   ├── OTP Verification
│   ├── Create Profile
│   ├── Permissions
│   └── All Set
│
├── Page: Discovery
│   ├── Activity List
│   └── Empty State
│
├── Page: Post Activity
│   └── Modal
│
├── Page: Acceptance
│   ├── Confirmation Dialog
│   └── Match Confirmed
│
├── Page: Messages
│   └── Chat Thread
│
├── Page: Dashboard
│   ├── My Activities
│   └── Active/Completed Posts
│
├── Page: Profile
│   └── User Profile
│
└── Page: Prototype
    └── Interactive flows (links between screens)
```

---

## Validation Checklist

After Figma AI generates the prototype:

- [ ] All 9 colors correctly applied from design system
- [ ] All 5 typography styles correctly used
- [ ] 8px spacing grid maintained throughout
- [ ] All 12 components built and reusable
- [ ] All 8 screens created
- [ ] Bottom navigation on all screens
- [ ] All buttons have interactions
- [ ] Auth flow connects end-to-end
- [ ] Discovery → Post → Accept → Messages flow works
- [ ] All text matches content spec
- [ ] All component states visible (default, hover, error, disabled)
- [ ] Prototype interactive and clickable
- [ ] No hardcoded values (all use design tokens)

---

## Next Steps

1. **Provide all three documents to Figma AI** (or paste into Figma Make)
2. **Figma AI generates prototype** (expect 10-30 min for full build)
3. **Review against validation checklist**
4. **Iterate** if needed (adjustments are fast with AI)
5. **Hand to dev team** for code generation in Ambiglytics

---

## Troubleshooting

### "Figma AI doesn't know the colors"
→ Make sure component specs document is included. Color values are defined there with hex codes.

### "Components look different sizes"
→ Check CoffeeCall_MVP_Component_Specs.md for exact sizing. May need to manually adjust.

### "Missing interactions"
→ Review CoffeeCall_MVP_Screen_Content.md "Interactions" sections. May need to manually wire up flows.

### "Text doesn't match"
→ Copy from CoffeeCall_MVP_Screen_Content.md tables (column "Content"). Word-for-word.

---

## File Sizes & Complexity

- **Design System page:** ~30 elements (colors, typography, grid)
- **Components page:** ~150-200 elements (12 components × 8-10 states each)
- **8 Screen pages:** ~50-100 elements each
- **Total Figma file:** ~800-1000 elements
- **Estimated generation time:** 15-30 minutes for full AI build

---

## Support

If anything is unclear:
- **Design system questions?** → See `CoffeeCall_MVP_Design_Brief.md`
- **Component specs?** → See `CoffeeCall_MVP_Component_Specs.md`
- **Screen content?** → See `CoffeeCall_MVP_Screen_Content.md`
- **Architecture questions?** → See `/Planning/architecture.md`

---

**Package created:** 2026-05-12  
**Status:** ✅ Ready for Figma AI  
**Next handoff:** Ambiglytics (code generation from prototype)
