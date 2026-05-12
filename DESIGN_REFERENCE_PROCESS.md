# CoffeeCall Design Process: Reference-Based

**Approach:** Extract design language from reference images → build design system → apply to CoffeeCall

---

## Phase 1: Reference Analysis & Color Selection

### Step 1A: You Provide Reference Images
- [ ] Share reference images (2-5 images recommended)
- [ ] Images should represent the visual style you want for CoffeeCall
- [ ] Examples: other apps, design inspiration, mood boards, wireframes

### Step 1B: I Analyze References
When you share images, I will:
- [ ] Extract primary colors
- [ ] Extract secondary/accent colors
- [ ] Identify neutral colors (grays, whites)
- [ ] Analyze typography (font styles, weights, sizes)
- [ ] Observe layout patterns (spacing, alignment, component styles)
- [ ] Note visual elements (shapes, icons, illustrations)
- [ ] Identify component states (buttons, cards, inputs)

### Step 1C: Color Palette Recommendation
I will propose:
- [ ] **Primary Color** — Main brand color (with hex code)
- [ ] **Secondary Color** — Accent color
- [ ] **Success Color** — Positive actions (green family)
- [ ] **Error Color** — Negative actions (red family)
- [ ] **Neutral Colors** — Whites, grays, blacks
- [ ] **Contrast Verification** — All colors meet 4.5:1 WCAG AA

### Step 1D: Color Iteration
- [ ] You provide feedback on proposed colors
- [ ] I adjust and propose alternatives
- [ ] Iterate until you approve final palette

---

## Phase 2: UX System Design Definition

Once colors are finalized, I will create:

### 2A: Component Library
For each component, define:
- [ ] **Button** — Primary, secondary, danger variants + all states
- [ ] **Input Fields** — Text, phone, location, with states
- [ ] **Cards** — Post cards, profile cards, with variations
- [ ] **Dialog/Modal** — Confirmation, alert patterns
- [ ] **Avatar** — Profile images (sizes)
- [ ] **Message Bubble** — Sent/received variants
- [ ] **Navigation** — Tab bar, header bar design

### 2B: Color Variations per Component
For each component:
- [ ] Default state (with exact hex color)
- [ ] Hover state (lighter/darker variant)
- [ ] Active/pressed state
- [ ] Disabled state (grayed out)
- [ ] Loading state (spinner style)
- [ ] Error state (red variant)

### 2C: Structure & Layout System
- [ ] Spacing system (4px, 8px, 16px, 24px, 32px grid)
- [ ] Border radius system (sharp, small, medium, large, full)
- [ ] Shadow/elevation system (subtle, medium, large)
- [ ] Typography scale (sizes + weights)
- [ ] Grid/alignment guidelines

### 2D: Basic Shapes & Patterns
- [ ] Primary shape style (rectangular, rounded, organic)
- [ ] Icon style (outlined, filled, duotone)
- [ ] Illustration style (if needed)
- [ ] Animation/motion patterns

### 2E: Icons & Images Decision
- [ ] Which icon library to use (SF Symbols, Material Design, custom)
- [ ] Image types (photography, illustration, geometric)
- [ ] Where to source assets (Unsplash, custom, etc.)

---

## Phase 3: Complete App Design

After system is defined:
- [ ] Design all 7 screens using the system
- [ ] Admin interface (separate visual treatment)
- [ ] All user journeys mapped
- [ ] All states + variations included
- [ ] Finalized Figma/Pencil file

---

## What I Need From You (Now)

**Share:**
1. Reference image(s) (2-5 is ideal)
2. Brief description of each image (why you like it, what aspect appeals to you)
3. Any color preferences (if you have them)
4. Any visual style preferences (minimalist? bold? colorful? etc.)

**Format:**
- Image files (PNG, JPG)
- Or links to design inspiration (Dribbble, Behance, etc.)
- Or describe the style if no images available

---

## My Deliverables (After Each Phase)

### After Phase 1: Color Palette
Document saved to `/Design/color-palette-analysis.md`:
- Reference images analyzed
- Proposed color palette (hex codes)
- Reasoning for each color choice
- WCAG AA contrast verification
- Color mood/tone explanation

### After Phase 2: Design System
Documents saved to `/Design/`:
- Updated `design-tokens.md` (final colors, typography, spacing)
- Updated `design-system.md` (complete system)
- New `component-specifications.md` (all components with states)
- New `icon-image-guide.md` (icon/image decisions)

### After Phase 3: Complete Design
Documents saved:
- Updated `screens.md` (all 7 screens finalized)
- Updated `design-tokens.md` (with component-specific values)
- Figma/Pencil file link in `figma-link.md`
- Design handoff ready for Codex

---

## Timeline (Proposed)

**Day 1:**
- [ ] You share reference images
- [ ] I analyze + propose color palette
- [ ] We iterate on colors
- [ ] Colors finalized (EOD)

**Day 2:**
- [ ] I define component library
- [ ] I define structure/layout system
- [ ] We iterate on components
- [ ] System finalized (EOD)

**Day 3:**
- [ ] I apply system to all 7 screens
- [ ] Design refinement + polish
- [ ] Finalize Figma/Pencil file
- [ ] Ready for Codex (EOD)

**Then:** Codex updates prompts → Antigravity IDE codes

---

## Color Analysis Framework (What I'll Do)

When you share images, I will analyze:

```
REFERENCE IMAGE #1: [Name/Description]
├── Primary Colors
│   ├── Color 1: Hex: #ABC123, RGB: (171, 193, 35)
│   ├── Color 2: Hex: #DEF456, RGB: (222, 244, 86)
│   └── Color 3: Hex: #789012, RGB: (120, 144, 18)
├── Secondary Colors
│   └── [similar analysis]
├── Typography
│   ├── Headings: [font, size, weight]
│   ├── Body: [font, size, weight]
│   └── Labels: [font, size, weight]
├── Layout Patterns
│   ├── Spacing: [observed gaps]
│   ├── Alignment: [grid type]
│   └── Components: [observed patterns]
└── Visual Feeling
    ├── Mood: [professional/fun/minimal/bold]
    ├── Complexity: [simple/complex]
    └── Target Audience: [inferred]
```

---

## Iteration Process

**Round 1:** I propose based on references  
**Round 2:** You feedback → I adjust  
**Round 3:** (If needed) Final refinement  
**Round 4:** (If needed) Edge cases/alt versions  

**Goal:** Finalized palette in 24 hours

---

## Questions for You (Before We Start)

1. **Reference Images:** Ready to share? (Or want to gather them first?)
2. **Format:** Will you use Figma, Pencil, or another tool?
3. **Timeline:** Can you start tomorrow? Or specific date?
4. **Preference:** Any colors/styles to avoid?
5. **Brand:** Any existing brand guidelines? (Logo, existing color palette?)

---

**Status:** Ready to receive reference images  
**Next Action:** You share images → I analyze → Color iteration begins

Share the reference images whenever you're ready, and we'll kick off Phase 1!
