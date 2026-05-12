# CoffeeCall MVP — Design Specification

## Document Purpose
This document serves as the comprehensive design specification for the CoffeeCall MVP. It defines the 7 core screens, component usage, design system application, and handoff guidelines for code generation.

**Created:** May 12, 2026  
**Status:** In Development (Agent-driven design in progress)  
**Design System File:** `untitled.pen`

---

## 1. Design System Overview

### Color Palette
All colors are defined as variables in the design system. Always reference variables, never hardcode colors.

| Token | Value | Usage |
|-------|-------|-------|
| `$color-primary` | #3B82F6 | Primary actions, accept buttons, active states |
| `$color-coral` | #FF7A59 | Reject/secondary actions, alerts |
| `$color-cyan` | #22D3EE | Accent highlights, new features |
| `$color-teal` | #0F766E | Success states, confirmations |
| `$color-text` | #1E293B | Primary text, headings |
| `$color-text-muted` | #64748B | Secondary text, timestamps |
| `$color-bg` | #F8FAFC | Page backgrounds |
| `$color-border` | #E2E8F0 | Borders, dividers |
| `$color-light-blue` | #E0F2FE | Light backgrounds, hover states |

### Typography
- **Font Family:** Inter (fallback: system sans-serif)
- **Hierarchy:**
  - **Page Title:** 28px, weight 700, color $color-text
  - **Section Title:** 16px, weight 600, color $color-text
  - **Body Text:** 14px, weight 400, color $color-text
  - **Secondary Text:** 12px, weight 400, color $color-text-muted
  - **Button Text:** 14px, weight 600, uppercase, color varies by button type

### Spacing System
All spacing uses 8px base unit. Common values:
- `$spacing-xs` = 4px
- `$spacing-sm` = 8px
- `$spacing-md` = 16px
- `$spacing-lg` = 24px
- `$spacing-xl` = 32px

### Component Border Radius
- `$radius-sm` = 8px (small elements, inputs)
- `$radius-md` = 12px (cards, modals, buttons)
- `$radius-lg` = 20px (large surfaces)

### Interactive Elements
- **Button Height:** 44px (minimum touch target for accessibility)
- **Input Height:** 48px
- **Card Shadows:** 0 2px 8px rgba(0,0,0,0.08)

---

## 2. Screen Inventory (7 Screens)

### Screen 1: Signup / Onboarding
**File Reference:** Auth flows (no bottom tab bar)  
**Purpose:** First-time user registration and verification  
**Flow Steps:**
1. Welcome screen (CTA to continue)
2. Phone number entry + OTP verification
3. Profile photo upload
4. Name input
5. Permissions request (location + notifications)
6. Interests/activities selection
7. Success screen ("You're verified!")

**Key Interactions:**
- Form validation on phone number
- OTP timer (resend after 60s)
- Photo upload from camera/gallery
- Permission permission dialogs (OS-native)
- Success celebration screen

**Components Used:**
- Primary button (CTA)
- Input/Text fields
- Input/DateTime (if time picker needed)

**Design Notes:**
- Fast, frictionless experience
- Clear step progression
- Success reinforcement
- No tab bar on this flow

---

### Screen 2: Home / Discover Activities
**File Reference:** Discover Home Screen  
**Purpose:** Core discovery feed showing nearby activities  
**Content Layout:**
- Header: "Hi [Name] 👋" with search bar
- Filter chips: "Today", "Coffee", "Movies", "Free Now", etc.
- Section 1: "Nearby Now" - Activities within 10km
- Section 2: "Tonight" - Activities happening today

**Key Interactions:**
- Scroll through activity cards
- Pull-to-refresh to load new posts
- Tap card to see acceptance dialog
- Filter by activity type (uses chip components)

**Components Used:**
- Activity Card (ooEjY) - repeated for each post
- Chip/Filter (a4aa5u) - for filtering by type/time
- Bottom Tab Bar (sp1E6) - with Home tab active
- Input/Search (M9oGeT) - search functionality

**Design Notes:**
- Clean, scannable card layout
- Activity card shows: avatar, name, purpose, location, time
- Accept/Reject buttons on each card
- Tab bar never obscures content
- Empty state: "No activities nearby"

---

### Screen 3: Post Creation
**File Reference:** Post creation flow  
**Purpose:** User creates a new activity post  
**Form Fields:**
1. Purpose - Text input ("What are you doing?")
2. Location - Current location auto-filled, editable
3. Time - Date + time picker

**Key Interactions:**
- Form validation
- Loading spinner during submission
- Success toast notification
- Auto-return to Home screen

**Components Used:**
- Input/Text (Sof5H) - purpose field
- Input/DateTime (spFru) - time picker
- Primary button (HHcVb) - submit button
- Loading indicator

**Design Notes:**
- Minimize steps (3 fields only)
- Pre-populate location (current location)
- Time picker defaults to "today"
- Clear error messages for validation

---

### Screen 4: Acceptance Confirmation Dialog
**File Reference:** Modal overlay on Home screen  
**Purpose:** Confirm activity acceptance before opening message thread  
**Dialog Content:**
- Header: "Confirm Activity"
- Activity details: Purpose, location, time
- Poster profile: Avatar, name, rating (optional)
- Buttons: "Confirm" (primary), "Cancel"
- Semi-transparent overlay behind modal

**Key Interactions:**
- Tap "Confirm" → message thread opens
- Tap "Cancel" or outside modal → closes
- Smooth fade animation

**Components Used:**
- Join Confirmation Modal (BiTzO) - base dialog
- User Card (kBXRH) - for poster profile

**Design Notes:**
- Centered on screen, max-width 340px
- High contrast buttons
- Clear decision point before commitment

---

### Screen 5: Messages / Chat
**File Reference:** Chat thread with activity acceptor  
**Purpose:** Coordinate details via in-app messaging  
**Content Layout:**
- Header: "Chatting with [Acceptor Name]" + back button
- Message thread (chronological)
- Sent messages: Right-aligned, primary color background
- Received messages: Left-aligned, light gray background
- Timestamps on each message
- Input area: Message text field + Send button

**Key Interactions:**
- Scroll to view conversation history
- Type message → tap Send
- Message appears with timestamp
- Auto-scroll to latest message
- Async delivery (2-5s latency acceptable)

**Components Used:**
- Chat Bubble Outgoing (Alim1) - sent messages
- Chat Bubble Incoming (jbQXb) - received messages
- Input/Text field - message composition
- Bottom Tab Bar (sp1E6) - with Messages tab active

**Design Notes:**
- Minimal distractions
- Clear message authorship
- No typing indicators (async messages only)
- No read receipts
- Timestamps every few messages

---

### Screen 6: My Posts / Dashboard
**File Reference:** User's posted activities  
**Purpose:** Manage and track user's own posts  
**Content Layout:**
- Header: "My Posts" with tab indicator
- List of active posts (scrollable)
- Each post shows: Purpose, location, time, acceptance count
- Tap post → see list of acceptors
- Acceptor list shows: Avatar, name, accepted time
- Can message acceptor from this view

**Key Interactions:**
- View all posted activities
- See acceptance count
- Tap post → expand acceptor list
- Message individual acceptor
- Delete post (if needed)

**Components Used:**
- Compact Activity Card (vvlGt) - for posted activities
- User Card (kBXRH) - for acceptor list
- Bottom Tab Bar (sp1E6) - with My Posts active

**Design Notes:**
- Clear post ownership
- Quick access to acceptor info
- Messaging path is clear
- Acceptance count visible at a glance

---

### Screen 7: Profile
**File Reference:** User profile and account settings  
**Purpose:** View profile, manage account, settings  
**Content Layout:**
- Header: Profile tab indicator
- Avatar: Large (120-160px), editable
- Name: Editable
- Stats section:
  - Posts created (count)
  - Acceptances (count)
  - Rating/reputation (if implemented)
- Action buttons:
  - Edit Profile
  - Settings
  - Logout

**Key Interactions:**
- Tap avatar → change photo (camera/gallery)
- Tap name → edit name
- Edit Profile → form to update info
- Settings → preferences (notifications, privacy)
- Logout → confirm, return to login

**Components Used:**
- Avatar component (custom ellipse)
- Primary button (HHcVb) - Edit Profile, Settings
- Secondary button (yH0Mo) - Logout (destructive)
- Bottom Tab Bar (sp1E6) - with Profile active

**Design Notes:**
- Personal feel
- Clear identity
- Stats give transparency
- Quick settings access
- Safe logout process

---

## 3. Navigation Structure

### Bottom Tab Bar (4 Tabs)
Present on all screens except signup/onboarding flow.

| Tab | Screen | Icon | Active Color |
|-----|--------|------|--------------|
| Home | Home / Discover | Home icon | $color-primary |
| My Posts | Dashboard | Layers icon | $color-primary |
| Messages | Chat list | Chat icon | $color-primary |
| Profile | User profile | User icon | $color-primary |

**Design Rules:**
- Tab bar is sticky (always visible during scroll)
- Active tab: solid fill with white text
- Inactive tabs: transparent, muted icon + label
- Height: 62px including safe area (iPhone home indicator)
- Corner radius: 36px (pill-shaped)

---

## 4. States & Variations

### Button States
- **Default:** Solid fill, no shadow
- **Hover:** Darker shade of fill color
- **Active/Pressed:** Slight inset shadow
- **Disabled:** Reduced opacity (50%)
- **Loading:** Spinner inside button

### Input States
- **Empty:** Light background, placeholder text visible
- **Focused:** Border color changes to $color-primary, light blue background
- **Filled:** Normal state with value
- **Error:** Red/coral border, error message below
- **Disabled:** Reduced opacity, no interaction

### Card States
- **Default:** White background, subtle shadow
- **Hover:** Light background tint
- **Active:** Border highlight or shadow increase
- **Empty state:** Centered message, icon, CTA

---

## 5. Accessibility Requirements

### Contrast
- All text must meet WCAG AA standard: 4.5:1 contrast ratio
- Verify color combinations:
  - $color-text (#1E293B) on $color-bg (#F8FAFC) ✓
  - $color-primary (#3B82F6) on white ✓
  - $color-coral (#FF7A59) on white ✓

### Touch Targets
- All interactive elements minimum 44x44px
- Buttons are 44px height (defined)
- Card tap areas are generous

### Typography
- Minimum font size: 12px (for secondary text)
- Maximum line length: ~60 characters for body text
- Adequate line height for readability (1.4-1.6x)

### Navigation
- Bottom tab bar is accessible and clear
- Back buttons present in nested flows
- Clear state indication (active tab)

---

## 6. Mobile Device Specifications

### Target Devices
- iPhone 12/13/14 (390px width)
- iPhone 12/13/14 Pro Max (414px width)
- Safe areas respected (notch, home indicator)

### Status Bar
- Height: 62px (includes safe area)
- Never place critical UI behind it
- App content begins below status bar

### Screen Height
- Typical: 844px (iPhone 12/13/14)
- Pro Max: 896px (iPhone 12 Pro Max)
- Designs should accommodate both

---

## 7. Component Usage Guide

### Activity Card (ooEjY)
Used on Home screen to show nearby activities.
- **States:** Default, hover
- **Content:** Avatar, name, purpose, location, time, buttons
- **Reusable:** Yes
- **Instances:** Multiple per screen

### Chat Bubbles (Alim1, jbQXb)
Used on Messages screen for conversation threads.
- **Outgoing:** Right-aligned, primary color
- **Incoming:** Left-aligned, gray background
- **Content:** Text message + timestamp

### Compact Activity Card (vvlGt)
Used on My Posts screen for posted activities.
- **Difference from Activity Card:** Smaller layout, horizontal
- **Content:** Image, title, location, acceptance count

### Join Confirmation Modal (BiTzO)
Overlay dialog for accepting activities.
- **Content:** Activity details + poster info + buttons
- **Animation:** Fade in/out
- **Overlay:** Semi-transparent dark background

### Bottom Tab Bar (sp1E6)
Navigation bar at bottom of screen.
- **4 Tabs:** Home, My Posts, Messages, Profile
- **States:** Active (filled) vs. inactive (outline)
- **Fixed:** Always visible during scroll

---

## 8. Design Handoff Process

### For Code Generation
1. All screens are finalized in Figma/Pencil
2. Design variables are exported as CSS tokens
3. Component library is exported as SwiftUI components
4. Colors, typography, spacing are consistently applied
5. Screens are organized in logical groups

### Color Export (CSS/SwiftUI)
```css
--color-primary: #3B82F6;
--color-coral: #FF7A59;
--color-text: #1E293B;
/* ... etc */
```

### Typography Export
```swift
// iOS: Use UIFont descriptors or custom typography scales
let titleFont = UIFont.systemFont(ofSize: 28, weight: .bold)
let bodyFont = UIFont.systemFont(ofSize: 14, weight: .regular)
```

### Spacing Export
```swift
let spacingXS = 4.0
let spacingSM = 8.0
let spacingMD = 16.0
let spacingLG = 24.0
let spacingXL = 32.0
```

---

## 9. Design Decisions & Rationale

### Why 7 Screens (Not More)
- MVP scope: Only essential flows
- Signup → discover → post → message → manage
- Deferred: Reviews, ratings, scoring (v1.1)
- Deferred: Maps, advanced filtering (v1.1)

### Why Bottom Tab Navigation
- Standard iOS pattern
- Accessible and discoverable
- 4 major destinations (home, posts, messages, profile)
- Persistent navigation across app

### Why No Real-Time Chat
- Simpler backend (Firebase polling)
- Lower latency requirements (2-5s acceptable for activity coordination)
- Reduced complexity for MVP
- Message for coordination, not socializing

### Why 10km Radius is Fixed
- Balances reach vs. locality
- Most users want neighbors, not city-wide
- Hardcoded to reduce complexity
- Can adjust in settings later (v1.1)

### Why Simple Components
- Easy to build and maintain
- Clear UX (no confusion)
- Fast load times
- Accessible to all users

---

## 10. Next Steps

### Current Phase
- Agent-driven design of 7 MVP screens (in progress)
- Design system verification
- Component consistency check

### Verification Phase (After Agent Completion)
- [ ] Verify all screens use correct components
- [ ] Check color consistency across all screens
- [ ] Verify typography hierarchy
- [ ] Validate spacing and alignment
- [ ] Check accessibility (contrast, touch targets)
- [ ] Take final screenshots for handoff
- [ ] Create component reference guide

### Code Generation Phase (After Design Approval)
- [ ] Codex generates detailed prompts from design
- [ ] Ambiglytics converts prompts to SwiftUI code
- [ ] Design tokens exported as Swift constants
- [ ] Components exported as reusable SwiftUI views

---

## 11. Design Files & Assets

### Primary Design File
- **File:** `untitled.pen`
- **Frames:**
  - Foundations (colors, typography, spacing)
  - Components (18 reusable components)
  - Screens (7 MVP screens)

### Exported Assets (TBD)
- [ ] Colors (CSS/Swift variables)
- [ ] Typography (font files, sizes)
- [ ] Icons (SF Symbols or custom)
- [ ] Imagery (placeholders or real photos)

---

## 12. Revision History

| Date | Version | Changes | Owner |
|------|---------|---------|-------|
| 2026-05-12 | 1.0 | Initial specification | Claude |

---

**Document Last Updated:** May 12, 2026  
**Design System Status:** In Development  
**Screen Design Status:** Agent-Driven (In Progress)
