# CoffeeCall MVP — Component Specifications

**For:** Figma AI / Pencil / Antigravity IDE  
**Purpose:** Explicit component definitions for design generation  
**Status:** Governs all 8 screens in MVP brief

---

## Reusable Components

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

## Layout Grid & Spacing

### 8px Base Unit System
```
8px   — Padding inside tight components
16px  — Standard padding (cards, modals)
24px  — Section spacing
32px  — Large spacing (between major sections)
40px  — XL spacing (top/bottom of screens)
```

### Common Layouts
| Container | Padding | Gap Between Items |
|-----------|---------|-------------------|
| **Screen** | 16px horizontal | 16px |
| **Card** | 16px | 12px (internal) |
| **Modal** | 24px | 16px |
| **Form field** | 16px between inputs | N/A |

---

## Typography Application

### Heading 1 (28px, bold)
**Usage:** Screen titles, major sections  
**Color:** Black #0F172A  
**Example:** "Nearby activities", "Your Activities"

### Heading 2 (22px, semibold)
**Usage:** Subsection titles, card headers  
**Color:** Black #0F172A  
**Example:** "Activity Details", "Message Alex"

### Body 1 (16px, regular)
**Usage:** Main content, button text  
**Color:** Black #0F172A or Dark Gray #475569  
**Example:** Button text, card content

### Body 2 (14px, regular)
**Usage:** Secondary content, descriptions  
**Color:** Dark Gray #475569  
**Example:** Distance, time, metadata

### Caption (12px, regular)
**Usage:** Timestamps, hints, small labels  
**Color:** Dark Gray #475569  
**Example:** "In 30 minutes", "Sent at 3:45 PM"

---

## Color Usage Map

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

## Component States

### Button States
- **Default:** Full color, 100% opacity
- **Hover:** Darker shade (-10% brightness)
- **Pressed:** Darker shade (-20% brightness)
- **Disabled:** Light Gray #F3F4F6, text unreadable

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

## Icon Requirements

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
**Recommendation:** Use SF Symbols (iOS native) or Material Icons

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

## Responsive/Platform Notes

### iOS (MVP)
- Safe area insets (notch, home indicator)
- Native bottom tab bar
- Gesture-friendly (44px min touch targets)

### Android (Future)
- System status bar + nav bar
- Material Design 3 aesthetics
- Android system navigation

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

**Last Updated:** 2026-05-12  
**Status:** Ready for Figma AI / Pencil / Antigravity IDE  
**Companion Document:** `CoffeeCall_MVP_Design_Brief.md`
