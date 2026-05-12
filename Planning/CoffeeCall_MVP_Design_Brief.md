# CoffeeCall MVP — Design Brief for Figma/Pencil

## Product Summary

**CoffeeCall** is a lightweight activity coordination app based on real-time availability.

**Core Loop:** Post activity → Get notified → Accept → Confirm → Message → Meetup

**NOT in MVP:** Dating app, swiping, reputation system, reviews, badges, penalty system
**IS in MVP:** Activity-first, real meetups, simple discovery, quick coordination

---

## Design System

### Colors (Intentional Meaning)
- **Primary Blue #3B82F6** — Trust, safety, primary actions
- **Cyan #22D3EE** — Active status, highlights
- **Teal #0F766E** — Confirmed, success states
- **Coral #FF7A59** — Action buttons, requests
- **Light Blue #E0F2FE** — Soft backgrounds
- **Ice White #F8FAFC** — App background
- **Light Gray #F3F4F6** — Cards, dividers
- **Dark Gray #475569** — Secondary text
- **Black #0F172A** — Primary text

### Typography
- **Font:** SF Pro Display (iOS) / Roboto (Android)
- **Heading 1:** 28px, bold
- **Heading 2:** 22px, semibold
- **Body 1:** 16px, regular
- **Body 2:** 14px, regular
- **Caption:** 12px, regular

### Spacing & Layout
- **Grid:** 8px base unit (8, 16, 24, 32, 40px)
- **Border radius:** 8px (inputs), 12px (cards), 20px (modals)
- **Shadows:** Soft only (0 2px 8px rgba(0,0,0,0.1))
- **Button height:** 44px minimum
- **Touch targets:** 44x44px minimum

### Accessibility
- **Contrast:** 4.5:1 minimum (WCAG AA)
- **Text:** Always readable, clear hierarchy
- **Buttons:** Touch-friendly (44px+)

---

## Screens (7 Total — MVP)

### SCREEN 1: Authentication Flow (Multi-step)

**Step 1.1: Welcome**
- Hero: "Find activities nearby"
- CTA: "Continue with Phone"
- Design: Clean, minimal, inviting

**Step 1.2: Phone Entry**
- Phone number input with country code
- "Send Code" button
- Security note: "We'll send you a verification code"

**Step 1.3: OTP Verification**
- 6-digit input boxes (auto-focus between boxes)
- "Resend code in XX:XX"
- Numeric keyboard

**Step 1.4: Create Profile**
- Photo upload (camera + gallery)
- Name input
- Design: Large circular photo preview

**Step 1.5: Enable Location & Notifications**
- Two permission cards
- "Allow While Using App" (blue, primary)
- "Allow Once" (light blue)
- "Not Now" (ghost)

**Step 1.6: Done**
- Checkmark icon
- "You're all set!"
- CTA: "Start Exploring"

---

### SCREEN 2: Discovery/Notifications List

**Main View — Nearby Activities**
- **Header:** "Nearby activities" + filter/radius selector
- **Counter:** "12 activities within 5km" (auto-updates)
- **List of cards:** Each activity shows:
  - Poster avatar (small circle, left)
  - Name + Activity type + Distance (top right)
    - "Alex • Coffee • 0.8 km away"
  - Time: "In 30 minutes"
  - Location: "Downtown Brew House"
  - "Accept" button (blue, right) | "Skip" button (light gray)
- **Dividers:** Light gray between cards
- **Empty state:** "No activities nearby. Create one or check back soon!"

**Design Notes:**
- Cards are scannable, not cluttered
- Accept/Skip buttons always visible
- No swiping (tap to act)

---

### SCREEN 3: Post Activity Modal

**Trigger:** FAB (+) button on Discovery screen

**Form Fields:**
1. **Activity Type:** Dropdown or selector (Coffee, Movie, Walk, Study, Work, Food, Bike, Jog)
   - Single selection
2. **When:** Time picker
   - Default: "Now"
   - Options: Specific time or duration
3. **Where:** Location input
   - Auto-filled from current location
   - Editable (tap to change)
   - Shows address text
4. **Duration:** Dropdown (30 mins, 1 hr, 2 hrs, custom)

**CTA:** "Go Live" (blue, large, takes full width)

**Design:**
- Modal overlay, rounded corners, soft shadow
- Clear section dividers
- Minimal text labels
- Takes ~30 seconds to complete

---

### SCREEN 4: Acceptance Confirmation Dialog

**Trigger:** User taps "Accept" on an activity card

**Content:**
- **Poster info (top):**
  - Avatar (large, centered)
  - Name + age (if available)
- **Activity details:**
  - Type: "☕ Coffee"
  - Location: "Downtown Brew House"
  - Time: "In 30 minutes"
  - Distance: "0.8 km away"
- **Your commitment:**
  - "You'll be notified when you match"
  - "Then you can message to coordinate"
- **Buttons:**
  - "Confirm" (blue, large)
  - "Cancel" (ghost)

**Design:**
- Clear, straightforward, no distractions
- Emphasize the activity, not the person
- Warm, welcoming tone

---

### SCREEN 5: Match Confirmed

**Trigger:** Both users accept (or after accepting, show success state)

**Content:**
- **Success state:** Green checkmark or teal background
- "You matched with Alex!"
- **Activity summary:**
  - "☕ Coffee at Downtown Brew House"
  - "In 30 minutes (1 hour duration)"
- **Next step:**
  - Both avatars (centered, small)
  - "Message Alex to coordinate"
- **CTA:** "Open Messages" (blue, large)

**Design:** Celebratory but calm (no excessive animations)

---

### SCREEN 6: Messages Thread

**Trigger:** After match confirmed, or from tab navigation

**Layout:**
- **Header:** User name + status (Online/Offline)
- **Messages:**
  - Sent (right-aligned, blue bubble)
  - Received (left-aligned, gray bubble)
  - Timestamp below each message
  - Rounded corners on all bubbles
- **Activity summary (optional, top):**
  - ☕ Coffee • Downtown Brew House • In 25 minutes
- **Input area (bottom):**
  - Text field + Send button (Coral icon)

**Design:**
- Simple, utility-first (not Instagram-like)
- Chronological order
- No typing indicators or read receipts (v1.1+)

---

### SCREEN 7: My Activities Dashboard

**Tab view — Shows user's own posts**

**Header:** "Your Activities" + "New Activity" button (+)

**Section 1: Active Posts**
- List of posts created by user (newest first)
- Each card shows:
  - Activity type + location + time
  - "3 people accepted" (counter)
  - Tap to expand → see list of acceptors:
    - Acceptor avatar + name + accept time
    - Acceptance status: "Waiting" | "Accepted" | "In progress"

**Section 2: Completed**
- Posts that have passed their time
- Shows final count of acceptances

**Empty state:** "No activities posted yet. Create one to get started!"

**Design:**
- Clear separation of active vs. completed
- Notifications badge for new acceptances (count)
- Easy to see who accepted and when

---

### SCREEN 8: Profile View

**Trigger:** Tab navigation or settings

**Content:**
- **Header:**
  - Large profile photo
  - Name + "Edit Profile" link
- **Activity preferences:**
  - Chips: Coffee, Movie, Walk, etc. (shows interests)
- **Stats (simple):**
  - Posts created: 5
  - Activities attended: 3
- **Edit section:**
  - "Edit Profile" (change photo, name)
  - "Settings" → notifications, location privacy, logout

**Design:**
- Clean, uncluttered
- Focus on utility, not vanity
- No ratings, reviews, or trust scores (v1.1+)

---

## Bottom Navigation (Always Visible)

4 tabs:
1. **Discover** (default) — List of nearby activities
2. **Post** (or FAB) — Create new activity
3. **My Activities** — Activities you've posted
4. **Messages** — Chat threads
5. **Profile** — Your profile + settings

Active tab = Teal highlight
Inactive tabs = Gray

---

## Key UX Rules

✓ Activity FIRST (☕ Coffee nearby), person SECOND
✓ Accept/Skip visible on every card (no hidden actions)
✓ Time-based discovery (what's happening now/soon)
✓ No swiping, NO infinite feed, NO gamification
✓ Light, calm, trustworthy aesthetic
✓ Icons instead of emojis (except activity types)
✓ Async messaging (2-5s latency OK)
✓ In-app messaging only (no phone sharing)

---

## What's NOT Included (Deferred to v1.1+)

❌ Reputation/trust scores
❌ Flake badges or penalties
❌ Post-meetup reviews or ratings
❌ Face verification
❌ Verified badges
❌ Advanced reputation scoring
❌ Real-time chat (async only)
❌ Maps view
❌ Dark mode
❌ Payment system
❌ Scanner/radar visualization
❌ Settings (v1.2+)

---

## Copy Tone

- Honest and direct
- Professional but friendly (no cutesy language)
- Action-focused ("Accept", "Post", "Message")
- No trust language or badges (reserved for v1.1+)

---

## Design Success Checklist

✓ Users understand: "Not dating, just activities"
✓ Accept/Skip always visible (no hidden flows)
✓ Activity discovery takes <1 minute
✓ Accepting + messaging takes <2 minutes
✓ All buttons 44px+ and tappable
✓ 4.5:1 contrast ratio throughout
✓ Light, calm, minimal aesthetic
✓ Post creation takes <30 seconds
✓ No swiping or infinite scrolling
✓ Clear visual hierarchy

---

## Figma File Structure

- **Page 1:** Design System (colors, typography, components)
- **Page 2:** Auth Flow (screens 1.1–1.6)
- **Page 3:** Discovery + Post (screens 2, 3)
- **Page 4:** Acceptance Flow (screens 4, 5)
- **Page 5:** Messages (screen 6)
- **Page 6:** Dashboard (screen 7)
- **Page 7:** Profile (screen 8)
- **Page 8:** Components Library (reusable elements)
- **Page 9:** Prototype (interactive flows)

---

## Next Steps

1. Design 8 screens in Figma/Pencil
2. Build component library
3. Create interactive prototype (auth + discovery + messaging)
4. Review for alignment with architecture
5. Handoff to Ambiglytics for code generation

---

**Document Status:** Finalized for MVP  
**Alignment:** ✅ Matches 7-screen architecture  
**Scope:** ✅ 3-week timeline  
**Last Updated:** 2026-05-12
