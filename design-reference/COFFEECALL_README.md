# CoffeeCall MVP — Design & Development Reference

**Project Type:** Activity coordination mobile app (iOS-first)  
**Status:** Design system finalized, ready for implementation  
**Last Updated:** 2026-05-12

---

## Quick Links

### Design Documentation
1. **[Design System](/workspaces/default/code/COFFEECALL_DESIGN_SYSTEM.md)** — Complete design guidelines with colors, typography, spacing, and patterns
2. **[Component Specifications](/workspaces/default/code/src/imports/pasted_text/component-specs.md)** — Detailed component definitions for all 12 reusable components

---

## What is CoffeeCall?

CoffeeCall is a lightweight activity coordination app based on real-time availability.

**Core Loop:**  
Post activity → Get notified → Accept → Confirm → Message → Meetup

**NOT in MVP:** Dating app, swiping, reputation system, reviews, badges, penalty system  
**IS in MVP:** Activity-first, real meetups, simple discovery, quick coordination

---

## Design Principles

✓ **Activity FIRST, person SECOND** — Lead with ☕ Coffee nearby, not profiles  
✓ **No swiping** — Tap-based Accept/Skip on every card  
✓ **Time-based discovery** — What's happening now or soon  
✓ **No gamification** — No badges, streaks, or scores (reserved for v1.1)  
✓ **Light & calm aesthetic** — Trustworthy, professional, not playful  
✓ **iOS-native feel** — SF Pro Display, 44px touch targets, safe area insets  
✓ **Accessibility-first** — 4.5:1 contrast minimum, clear hierarchy  

---

## Tech Stack (Web Implementation)

- **Framework:** React + TypeScript
- **Styling:** Tailwind CSS v4
- **Icons:** lucide-react (outlined style)
- **Target:** Mobile-responsive web app (375px-428px viewport)
- **Font:** -apple-system (SF Pro Display fallback)

---

## Screens (7 Total)

1. **Authentication Flow** (6 steps: Welcome → Phone → OTP → Profile → Permissions → Done)
2. **Discovery/Notifications List** — Nearby activities with Accept/Skip
3. **Post Activity Modal** — Create new activity (30 seconds to complete)
4. **Acceptance Confirmation Dialog** — Confirm interest in activity
5. **Match Confirmed** — Success state after mutual acceptance
6. **Messages Thread** — Async messaging to coordinate
7. **My Activities Dashboard** — User's posted activities + acceptances
8. **Profile View** — Settings and preferences

---

## Core Components (12 Total)

1. Primary Button (Blue)
2. Secondary Button (Ghost)
3. Action Button (Coral)
4. Chip/Tag (Activity types)
5. Input Field (Text, phone, etc.)
6. Avatar Circle (Small/Medium/Large)
7. Card (Activity/Post card)
8. Message Bubble (Sent/Received)
9. Badge/Counter (Notifications)
10. Status Indicator (Online/Offline)
11. Tab Navigation (Bottom bar)
12. Modal/Dialog Overlay

---

## Color Palette

| Color | Hex | Usage |
|-------|-----|-------|
| Primary Blue | #3B82F6 | Primary actions, trust |
| Coral | #FF7A59 | Action buttons, requests |
| Teal | #0F766E | Success, confirmed states |
| Cyan | #22D3EE | Active status (v1.1) |
| Light Blue | #E0F2FE | Soft backgrounds |
| Ice White | #F8FAFC | App background |
| Light Gray | #F3F4F6 | Cards, dividers |
| Dark Gray | #475569 | Secondary text |
| Black | #0F172A | Primary text |

---

## Typography Scale

| Style | Size | Weight | Usage |
|-------|------|--------|-------|
| Heading 1 | 28px | Bold (700) | Screen titles |
| Heading 2 | 22px | Semibold (600) | Section headers |
| Body 1 | 16px | Regular (400) | Primary content |
| Body 2 | 14px | Regular (400) | Secondary content |
| Caption | 12px | Regular (400) | Timestamps, metadata |

---

## Spacing System (8px grid)

- **8px** — Tight component padding
- **16px** — Standard padding (cards, screens)
- **24px** — Section spacing
- **32px** — Large spacing between sections
- **40px** — XL spacing (screen top/bottom)

---

## Activity Types (8)

☕ Coffee | 🎬 Movie | 🚶 Walk | 📚 Study  
💼 Work | 🍽️ Food | 🚴 Bike | 🏃 Jog

---

## Navigation Structure

**Bottom Tabs (4-5):**
1. **Discover** — Nearby activities
2. **Post** — Create activity
3. **My Activities** — User's posts
4. **Messages** — Chat threads
5. **Profile** — Settings

---

## Not Included in MVP

❌ Reputation/trust scores  
❌ Post-meetup reviews or ratings  
❌ Flake badges or penalties  
❌ Face verification  
❌ Real-time chat (async only)  
❌ Maps view  
❌ Dark mode  
❌ Payment system  

**Deferred to:** v1.1+

---

## Implementation Checklist

When building the web app:

✓ Mobile-first responsive design (375px-428px width)  
✓ All buttons 44px minimum height (touch-friendly)  
✓ 4.5:1 contrast ratio throughout  
✓ No hover states (mobile-first)  
✓ Safe area insets for iOS  
✓ Activity discovery takes <1 minute  
✓ Post creation takes <30 seconds  
✓ Accept/Skip always visible (no hidden flows)  
✓ Light, calm, minimal aesthetic  
✓ Clear visual hierarchy  

---

## Next Steps

1. ✅ Design system finalized
2. ✅ Component specifications documented
3. ⏳ Build web application prototype
4. ⏳ Test on mobile devices (iOS Safari)
5. ⏳ Gather user feedback
6. ⏳ Iterate based on testing

---

## Support & Questions

For questions about:
- **Design decisions:** See COFFEECALL_DESIGN_SYSTEM.md
- **Component specs:** See component-specs.md
- **Implementation:** Contact development team

---

**Version:** 1.0 MVP  
**Timeline:** 3-week sprint  
**Target:** iOS mobile web app
