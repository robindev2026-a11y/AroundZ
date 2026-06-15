# CoffeeCall Design System
**iOS Mobile App MVP — Design Guidelines**  
Last Updated: 2026-05-12

---

## Product Summary

**CoffeeCall** is a lightweight activity coordination app based on real-time availability.

**Core Loop:** Post activity → Get notified → Accept → Confirm → Message → Meetup

**Design Philosophy:**
- Activity FIRST, person SECOND
- Light, calm, trustworthy aesthetic
- No gamification or swiping
- iOS-native feel
- Accessibility-first

---

## Color System

### Primary Colors
| Color Name | Hex Code | Usage |
|------------|----------|-------|
| Primary Blue | `#3B82F6` | Trust, safety, primary actions |
| Cyan | `#22D3EE` | Active status, highlights |
| Teal | `#0F766E` | Confirmed, success states |
| Coral | `#FF7A59` | Action buttons, requests |

### Neutral Colors
| Color Name | Hex Code | Usage |
|------------|----------|-------|
| Light Blue | `#E0F2FE` | Soft backgrounds |
| Ice White | `#F8FAFC` | App background |
| Light Gray | `#F3F4F6` | Cards, dividers |
| Dark Gray | `#475569` | Secondary text |
| Black | `#0F172A` | Primary text |

### Color Tokens (CSS Variables)
```css
--color-primary: #3B82F6;
--color-cyan: #22D3EE;
--color-teal: #0F766E;
--color-coral: #FF7A59;
--color-light-blue: #E0F2FE;
--color-ice-white: #F8FAFC;
--color-light-gray: #F3F4F6;
--color-dark-gray: #475569;
--color-black: #0F172A;
```

### Color Usage Map

| Color | Primary Use | Components |
|-------|-------------|-----------|
| **Primary Blue #3B82F6** | Primary actions, headers | Buttons, links, active tab |
| **Coral #FF7A59** | User actions, pings | Action buttons, badges |
| **Teal #0F766E** | Success, confirmation | Active chips, checkmarks |
| **Cyan #22D3EE** | Highlights (reserved for v1.1) | N/A in MVP |
| **Light Blue #E0F2FE** | Soft backgrounds, spacers | Screen background, card hover |
| **Ice White #F8FAFC** | App background | Main screen background |
| **Light Gray #F3F4F6** | Cards, dividers, inputs | Card backgrounds, borders |
| **Dark Gray #475569** | Secondary text, hints | Body 2, captions, icons |
| **Black #0F172A** | Primary text | Headings, body 1 |

---

## Typography

### Font Family
- **iOS:** SF Pro Display
- **Web fallback:** -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif

### Type Scale
| Style | Size | Weight | Line Height | Usage |
|-------|------|--------|-------------|-------|
| Heading 1 | 28px | Bold (700) | 36px | Screen titles |
| Heading 2 | 22px | Semibold (600) | 28px | Section headers |
| Body 1 | 16px | Regular (400) | 24px | Primary content |
| Body 2 | 14px | Regular (400) | 20px | Secondary content |
| Caption | 12px | Regular (400) | 16px | Timestamps, metadata |

### Typography Tokens
```css
--font-family-primary: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;

--font-size-h1: 28px;
--font-size-h2: 22px;
--font-size-body1: 16px;
--font-size-body2: 14px;
--font-size-caption: 12px;

--font-weight-bold: 700;
--font-weight-semibold: 600;
--font-weight-regular: 400;

--line-height-h1: 36px;
--line-height-h2: 28px;
--line-height-body1: 24px;
--line-height-body2: 20px;
--line-height-caption: 16px;
```

### Typography Application

**Heading 1 (28px, bold)**  
Usage: Screen titles, major sections  
Color: Black #0F172A  
Example: "Nearby activities", "Your Activities"

**Heading 2 (22px, semibold)**  
Usage: Subsection titles, card headers  
Color: Black #0F172A  
Example: "Activity Details", "Message Alex"

**Body 1 (16px, regular)**  
Usage: Main content, button text  
Color: Black #0F172A or Dark Gray #475569  
Example: Button text, card content

**Body 2 (14px, regular)**  
Usage: Secondary content, descriptions  
Color: Dark Gray #475569  
Example: Distance, time, metadata

**Caption (12px, regular)**  
Usage: Timestamps, hints, small labels  
Color: Dark Gray #475569  
Example: "In 30 minutes", "Sent at 3:45 PM"

---

## Spacing & Layout

### Grid System
Based on 8px units:
- **xs:** 8px — Padding inside tight components
- **sm:** 16px — Standard padding (cards, modals)
- **md:** 24px — Section spacing
- **lg:** 32px — Large spacing (between major sections)
- **xl:** 40px — XL spacing (top/bottom of screens)

### Spacing Tokens
```css
--spacing-xs: 8px;
--spacing-sm: 16px;
--spacing-md: 24px;
--spacing-lg: 32px;
--spacing-xl: 40px;
```

### Common Layouts
| Container | Padding | Gap Between Items |
|-----------|---------|-------------------|
| **Screen** | 16px horizontal | 16px |
| **Card** | 16px | 12px (internal) |
| **Modal** | 24px | 16px |
| **Form field** | 16px between inputs | N/A |

### Border Radius
- **Inputs:** 8px
- **Cards:** 12px
- **Modals:** 20px
- **Avatars:** 50% (circular)

### Border Radius Tokens
```css
--radius-input: 8px;
--radius-card: 12px;
--radius-modal: 20px;
--radius-circle: 50%;
```

### Shadows
Soft shadows only:
```css
--shadow-soft: 0 2px 8px rgba(0, 0, 0, 0.1);
--shadow-card: 0 1px 3px rgba(0, 0, 0, 0.1);
--shadow-modal: 0 4px 16px rgba(0, 0, 0, 0.15);
```

---

## Component Specifications

### 1. Primary Button
**States:** Default, Hover, Pressed, Disabled  
**Usage:** "Accept", "Go Live", "Send", "Confirm"

| Property | Value |
|----------|-------|
| **Color** | Primary Blue #3B82F6 |
| **Height** | 44px minimum |
| **Padding** | 16px horizontal, 12px vertical |
| **Text** | Body 1, semibold, white |
| **Border radius** | 8px |
| **Shadow** | Soft (0 2px 8px rgba(0,0,0,0.1)) |
| **Disabled state** | Light Gray #F3F4F6, text: Dark Gray #475569 |

---

### 2. Secondary Button (Ghost)
**States:** Default, Hover, Pressed, Disabled  
**Usage:** "Cancel", "Skip", "Not Now"

| Property | Value |
|----------|-------|
| **Background** | Transparent |
| **Border** | 1px Light Gray #F3F4F6 |
| **Height** | 44px minimum |
| **Text** | Body 1, semibold, Dark Gray #475569 |
| **Border radius** | 8px |

---

### 3. Action Button (Coral)
**States:** Default, Hover, Pressed  
**Usage:** "Ping", "Accept Activity", "Send Message"

| Property | Value |
|----------|-------|
| **Color** | Coral #FF7A59 |
| **Height** | 44px minimum |
| **Padding** | 16px horizontal, 12px vertical |
| **Text** | Body 1, semibold, white |
| **Border radius** | 8px |

---

### 4. Chip/Tag
**States:** Unselected, Selected, Disabled  
**Usage:** Activity types (Coffee, Movie, Walk, etc.), vibe tags

| Property | Unselected | Selected |
|----------|-----------|----------|
| **Background** | Light Gray #F3F4F6 | Teal #0F766E |
| **Text color** | Dark Gray #475569 | White |
| **Padding** | 8px horizontal, 6px vertical | Same |
| **Border radius** | 20px | Same |
| **Font size** | 14px | Same |

---

### 5. Input Field
**States:** Empty, Focused, Filled, Error  
**Usage:** Phone number, name, message text, location

| Property | Value |
|----------|-------|
| **Height** | 44px minimum |
| **Padding** | 12px horizontal, 12px vertical |
| **Border** | 1px Light Gray #F3F4F6 |
| **Border radius** | 8px |
| **Text** | Body 2, Dark Gray #475569 |
| **Placeholder** | Body 2, Light Gray #F3F4F6 |
| **Focused border** | Primary Blue #3B82F6 |
| **Focused shadow** | 0 0 0 3px rgba(59, 130, 246, 0.1) |
| **Error border** | Coral #FF7A59 |

---

### 6. Avatar Circle
**Sizes:** Small (32px), Medium (48px), Large (64px)  
**Usage:** User photos in cards, profiles, messages

| Property | Value |
|----------|-------|
| **Border radius** | 50% (perfect circle) |
| **Border** | None (or 2px Light Blue #E0F2FE for active) |
| **Fallback** | Light Gray #F3F4F6 + initials in black |

---

### 7. Card (Activity/Post Card)
**Usage:** Discovery list, dashboard acceptances

| Property | Value |
|----------|-------|
| **Padding** | 16px |
| **Border radius** | 12px |
| **Background** | White (or Ice White #F8FAFC) |
| **Border** | 1px Light Gray #F3F4F6 |
| **Shadow** | Soft (0 2px 8px rgba(0,0,0,0.1)) |
| **Divider** | 1px Light Gray #F3F4F6 between cards |

**Structure:**
```
┌─────────────────────────────────┐
│ [Avatar] Name • Type • Distance │
│          Time                    │
│          Location                │
│          [Accept] [Skip]         │
└─────────────────────────────────┘
```

---

### 8. Message Bubble
**States:** Sent (blue), Received (gray)

| Property | Sent | Received |
|----------|------|----------|
| **Background** | Primary Blue #3B82F6 | Light Gray #F3F4F6 |
| **Text color** | White | Black #0F172A |
| **Padding** | 12px horizontal, 8px vertical | Same |
| **Border radius** | 16px (rounded) | Same |
| **Alignment** | Right | Left |

---

### 9. Badge/Counter
**Usage:** Notification count, acceptance count, distance

| Property | Value |
|----------|-------|
| **Background** | Coral #FF7A59 (or Teal for success) |
| **Text color** | White |
| **Padding** | 4px horizontal, 2px vertical |
| **Border radius** | 4px |
| **Font size** | Caption (12px), bold |

---

### 10. Status Indicator
**States:** Online (Teal), Offline (Gray), Pending (Yellow)

| Property | Value |
|----------|-------|
| **Size** | 8px (small dot) |
| **Border radius** | 50% |
| **Online** | Teal #0F766E |
| **Offline** | Light Gray #F3F4F6 |

---

### 11. Tab Navigation
**States:** Active, Inactive

| Property | Active | Inactive |
|----------|--------|----------|
| **Bottom border** | 3px Teal #0F766E | None |
| **Text color** | Black #0F172A | Dark Gray #475569 |
| **Text style** | Body 1, semibold | Body 1, regular |

---

### 12. Modal/Dialog Overlay
**Usage:** Post creation, acceptance confirmation

| Property | Value |
|----------|-------|
| **Background** | Black with 50% opacity |
| **Modal padding** | 24px (from screen edges) |
| **Modal border radius** | 20px |
| **Modal background** | White or Ice White #F8FAFC |
| **Modal shadow** | Deep shadow (0 10px 40px rgba(0,0,0,0.15)) |

---

### Bottom Navigation
- **Height:** 56px + safe area
- **Background:** White
- **Border top:** 1px Light Gray
- **Icons:** 24px × 24px
- **Active color:** Teal (#0F766E)
- **Inactive color:** Dark Gray (#475569)

---

## Component States

### Button States
- **Default:** Full color, 100% opacity
- **Hover:** Darker shade (-10% brightness)
- **Pressed:** Darker shade (-20% brightness)
- **Disabled:** Light Gray #F3F4F6, text Dark Gray #475569

### Input States
- **Empty/Placeholder:** Border Light Gray, placeholder text
- **Focused:** Border Primary Blue #3B82F6, shadow (0 0 0 3px rgba(59, 130, 246, 0.1))
- **Filled:** Border Light Gray, text Black
- **Error:** Border Coral #FF7A59, error text below

### Card States
- **Default:** Light Gray background, soft shadow
- **Hover:** Slight scale (1.02x) or shadow increase (optional, for web)
- **Active/Selected:** Teal border or background tint

---

## Icons

### Activity Icons (8 types)
- Coffee ☕
- Movie 🎬
- Walk 🚶
- Study 📚
- Work 💼
- Food 🍽️
- Bike 🚴
- Jog 🏃

**Format:** Outlined style, consistent stroke weight  
**Size in UI:** 24px (in cards), 32px (in selections)  
**Recommendation:** Use SF Symbols (iOS native) or lucide-react for web

### UI Icons
- Checkmark ✓
- X (close)
- Arrow (back, forward)
- Settings ⚙️
- Send (paper plane)
- Plus (+)
- Edit (pencil)
- Location (pin)
- Clock (time)
- User (profile)

**Format:** Outlined, consistent 2px stroke  
**Size in UI:** 16px (inline), 24px (buttons)

---

## Interaction Specifications

### Navigation
- **Tab switching:** Instant, no fade
- **Screen transitions:** Slide left/right (iOS native)
- **Modal appearance:** Slide up from bottom
- **Modal dismissal:** Slide down or tap overlay

### Button Feedback
- **Tap:** Instant state change (pressed color)
- **Hold:** Maintained pressed state
- **Release:** Return to default or navigate

### Input Feedback
- **Type:** Instant character appearance
- **Focus:** Instant border color change to blue
- **Error:** Instant error message + border change to coral
- **Submit:** Button disabled until form valid

### List Interactions
- **Scroll:** Smooth, momentum scrolling
- **Pull to refresh:** Standard iOS pattern (v1.1+)
- **Swipe actions:** Not in MVP (reserved for v1.1)

---

## Accessibility

### Contrast Requirements
- **Minimum:** 4.5:1 (WCAG AA)
- **Primary text on white:** Black (#0F172A) = 17.9:1 ✓
- **Secondary text on white:** Dark Gray (#475569) = 5.8:1 ✓
- **White text on Primary Blue:** 4.6:1 ✓

### Touch Targets
- **Minimum size:** 44px × 44px
- **Button height:** 44px minimum
- **Icon tap area:** 44px × 44px minimum
- **Spacing between targets:** 8px minimum

### Text Readability
- **Line height:** 1.5× minimum
- **Max line length:** 65-75 characters
- **Clear hierarchy:** H1 → H2 → Body

---

## Screen Patterns

### 1. Authentication Flow
- **Steps:** 6 total (Welcome → Phone → OTP → Profile → Permissions → Done)
- **Progress:** Optional step indicator
- **Primary CTA:** Always at bottom
- **Design:** Clean, minimal, single-column

### 2. Discovery List
- **Header:** Title + filter/radius selector
- **Counter:** "X activities within Y km"
- **List:** Scrollable activity cards
- **Empty state:** Friendly message
- **FAB:** Bottom-right (+) button

### 3. Post Activity Modal
- **Overlay:** Semi-transparent background
- **Modal:** Rounded corners (20px), centered
- **Fields:** Activity type, When, Where, Duration
- **CTA:** Full-width "Go Live" button
- **Completion time:** ~30 seconds

### 4. Messages Thread
- **Header:** User name + status
- **Messages:** Right-aligned (sent), left-aligned (received)
- **Input:** Fixed bottom bar
- **Design:** Simple, chronological, no typing indicators

### 5. Profile View
- **Header:** Large avatar + name
- **Content:** Preferences, stats, settings
- **Design:** Clean, uncluttered, utility-focused

---

## Navigation Structure

### Bottom Tabs (4-5 tabs)
1. **Discover** (Home) — Nearby activities list
2. **Post** (FAB or tab) — Create activity
3. **My Activities** — User's posted activities
4. **Messages** — Chat threads
5. **Profile** — Settings and preferences

### Active Tab Styling
- **Color:** Teal (#0F766E)
- **Icon:** Filled version
- **Label:** Optional (icon-only for space)

---

## UX Principles

✓ **Activity FIRST, person SECOND** — Lead with activity type, location, time  
✓ **No swiping** — Tap-based actions only  
✓ **Accept/Skip always visible** — No hidden actions  
✓ **Time-based discovery** — What's happening now/soon  
✓ **No gamification** — No badges, streaks, or scores (v1.1+)  
✓ **Light and calm** — Trustworthy, not playful  
✓ **Async messaging** — 2-5s latency acceptable  
✓ **In-app only** — No phone number sharing  

---

## Copy Tone

- **Voice:** Honest, direct, professional but friendly
- **Style:** Action-focused ("Accept", "Post", "Message")
- **Avoid:** Cutesy language, trust badges (v1.1+), gamification language
- **Examples:**
  - ✓ "Accept" (not "I'm in!" or "Let's go!")
  - ✓ "Post activity" (not "Create adventure!")
  - ✓ "Message Alex to coordinate" (not "Chat with your match!")

---

## Activity Types

**Icons (24px):**
- ☕ Coffee
- 🎬 Movie
- 🚶 Walk
- 📚 Study
- 💼 Work
- 🍽️ Food
- 🚴 Bike
- 🏃 Jog

---

## States & Feedback

### Loading States
- **Spinner:** Primary Blue
- **Skeleton:** Light Gray shimmer
- **Text:** "Loading activities..."

### Empty States
- **Icon:** Light gray, 48px
- **Message:** Body 1, Dark Gray
- **CTA:** Optional secondary button

### Success States
- **Color:** Teal (#0F766E)
- **Icon:** Checkmark
- **Duration:** 2-3 seconds

### Error States
- **Color:** Coral (repurposed for attention)
- **Message:** Body 2, clear explanation
- **Action:** Retry button or dismissal

---

## Not Included in MVP

❌ Reputation/trust scores  
❌ Flake badges or penalties  
❌ Post-meetup reviews  
❌ Face verification  
❌ Real-time chat (async only)  
❌ Maps view  
❌ Dark mode  
❌ Payment system  

---

## Design Success Checklist

✓ Users understand: "Not dating, just activities"  
✓ Accept/Skip always visible  
✓ Activity discovery takes <1 minute  
✓ Accepting + messaging takes <2 minutes  
✓ All buttons 44px+ and tappable  
✓ 4.5:1 contrast ratio throughout  
✓ Light, calm, minimal aesthetic  
✓ Post creation takes <30 seconds  
✓ Clear visual hierarchy  

---

## Implementation Notes

### For Web Implementation
- Use mobile-first responsive design
- Viewport: 375px-428px width (iPhone SE to iPhone Pro Max)
- Safe area insets for iOS
- Touch-optimized interactions
- No hover states (mobile-first)

### Component Library Structure
```
/components
  /buttons
    - PrimaryButton.tsx
    - SecondaryButton.tsx
    - GhostButton.tsx
  /cards
    - ActivityCard.tsx
  /inputs
    - TextInput.tsx
    - Dropdown.tsx
  /avatars
    - Avatar.tsx
  /navigation
    - BottomNav.tsx
```

---

## Figma File Organization

```
CoffeeCall MVP Design System
├── Page: Components
│   ├── Frame: Buttons
│   │   ├── Primary Button (all states)
│   │   ├── Secondary Button (all states)
│   │   └── Action Button (all states)
│   ├── Frame: Form
│   │   ├── Input Field (all states)
│   │   ├── Chip (selected/unselected)
│   │   └── Dropdown
│   ├── Frame: Cards
│   │   ├── Activity Card
│   │   ├── Message Bubble
│   │   └── Acceptance Card
│   ├── Frame: Navigation
│   │   └── Tab Bar (all states)
│   ├── Frame: Avatar
│   │   ├── Avatar Small
│   │   ├── Avatar Medium
│   │   └── Avatar Large
│   └── Frame: Icons
│       ├── Activity Icons (8)
│       └── UI Icons (10)
├── Page: Colors & Typography
│   ├── Frame: Color Palette (all 9 colors with hex)
│   ├── Frame: Typography (all 5 styles applied)
│   └── Frame: Spacing Grid (8px system visualized)
├── Page: Auth Flow (Screens 1-6)
├── Page: Discovery (Screens 2-3)
├── Page: Acceptance (Screens 4-5)
├── Page: Messages (Screen 6)
├── Page: Dashboard (Screen 7)
├── Page: Profile (Screen 8)
└── Page: Prototype (interactive flows)
```

---

## Resources & References

- **Component specifications:** `/src/imports/pasted_text/component-specs.md`
- **Design philosophy:** Activity-first coordination, no gamification
- **Target platform:** iOS (MVP), Android (future)
- **Tech stack (web):** React + Tailwind CSS

---

**Document Status:** Design System Reference  
**Version:** 1.0 MVP  
**Last Updated:** 2026-05-12  
**Companion Document:** Component Specifications (component-specs.md)
