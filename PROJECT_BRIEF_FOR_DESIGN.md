# CoffeeCall MVP — Project Brief for Design Phase

---

## What is CoffeeCall?

**CoffeeCall** is a local activity-based meetup platform. Users post activities (coffee, movies, jogging, etc.) → nearby people get notified → they accept → coordinate via in-app messages → meet up in real life.

**NOT a dating app.** Focus: lightweight, activity-based, local community (10km radius).

---

## Core Problem

Existing meetup apps are complex. Existing social apps are dating-focused. CoffeeCall solves this: quick, simple, activity-first.

**User Need:** "I want to grab coffee with someone nearby in the next hour."  
**Solution:** Post activity → see who's interested → meet up.

---

## MVP Scope (7 Screens)

### User Flows:

**Flow 1: New User Signup**
```
App Open → Phone Signup → OTP Verification → Profile Photo → Name → 
Home Screen (see nearby activities)
```

**Flow 2: Discover & Accept Activity**
```
Home (see nearby posts) → Tap post → See activity details + poster → 
Accept → Message thread opens → Coordinate → Meet up
```

**Flow 3: Post Activity & Manage**
```
"My Posts" tab → Create post (3 fields) → Submit → 
See acceptances → Message with people → Activity happens
```

---

## 7 Key Screens

### 1. Signup
- Phone number input
- OTP verification
- Profile photo upload
- Name input
- Allow location + notifications
- **Feel:** Simple, fast, welcoming

### 2. Home / Discover
- Tab bar: Home | My Posts | Messages | Profile
- List of nearby posts (10km radius)
- Each post: poster avatar, name, activity purpose, location, time
- Accept / Reject buttons per post
- **Feel:** Clean, scannable, easy to browse

### 3. Post Creation
- 3-field form: Purpose (text) | Location (map) | Time (picker)
- Submit button
- Confirmation
- **Feel:** Quick, straightforward, no friction

### 4. Acceptance Confirmation
- Modal dialog
- Activity details (purpose, location, time)
- Poster profile (avatar, name, rating)
- Confirm / Cancel buttons
- Auto-opens message thread on confirm
- **Feel:** Confident, clear decision-making

### 5. Messages
- Message thread header (who you're chatting with)
- Chronological message list
- Sent messages (right-aligned, branded color)
- Received messages (left-aligned, gray)
- Message input at bottom + Send button
- **Feel:** Simple, focused, minimal distraction

### 6. My Posts / Dashboard
- Tab showing user's active posts
- Each post shows acceptance count
- Click to see list of acceptors
- Each acceptor: avatar, name, when they accepted
- **Feel:** Clear ownership, easy management

### 7. Profile
- User avatar + name
- Stats: posts created, acceptances, rating
- Edit profile option
- Settings
- Logout
- **Feel:** Personal, clear identity

---

## Design Priorities

### Visual Style
- **Modern & Minimal** — Not cluttered
- **Approachable & Friendly** — Not sterile
- **Trust-Building** — Reputation/safety visible
- **Activity-Focused** — Not social media heavy

### User Experience
- **Fast** — Post in <30 seconds
- **Clear** — Know what's happening at each step
- **Local** — 10km radius is central
- **Community** — Feel of meeting neighbors

### Accessibility
- **WCAG AA Compliant** — 4.5:1 contrast minimum
- **Touch-Friendly** — 44x44px minimum buttons
- **Readable** — Clear typography hierarchy
- **Inclusive** — Supports dark mode

---

## Key Features (MVP Only)

✅ Phone signup + OTP  
✅ Location capture (10km radius notifications)  
✅ Post activity (3 fields: Purpose, Location, Time)  
✅ Discover nearby posts  
✅ Accept/reject posts  
✅ Async messaging (2-5 sec latency OK)  
✅ Poster dashboard (see acceptances)  
✅ User profile

❌ Scoring/reputation system (v1.1)  
❌ Real-time chat (async only)  
❌ Maps view (text location only)  
❌ Post reviews (v1.1)  

---

## Design Constraints

1. **Posts never close** — After first acceptance, post stays visible (group meetups OK)
2. **10km radius fixed** — Not user-configurable
3. **No phone numbers shown** — All contact via in-app messages
4. **Async messages** — 2-5 second latency is acceptable (not real-time)
5. **Simple components** — No complex animations
6. **Consistent colors** — Use system throughout

---

## Admin vs User (Future Consideration)

**MVP:** User-only interface

**V1.1 (Optional):** Admin dashboard for moderation (separate visual design):
- User management
- Activity moderation
- Stats/analytics
- Should look visually different from user interface

---

## Design System Needs

### Color Palette
- Primary color (main CTA, highlights)
- Secondary color (accents)
- Success color (green, for accept)
- Error color (red, for reject)
- Neutral colors (whites, grays, blacks)

### Typography
- Headings (page titles, section headers)
- Body (main text)
- Labels (buttons, captions)

### Components
- Buttons (primary, secondary, danger)
- Input fields (text, phone, location)
- Cards (post cards, profile cards)
- Dialog/modal (confirmation)
- Avatar (profile images)
- Message bubbles (sent/received)
- Navigation (tab bar)

### Spacing & Layout
- Grid/spacing system (4px, 8px, 16px, 24px, 32px)
- Border radius (rounded, sharp, very rounded)
- Shadows (subtle elevation)

---

## User Personas

### Primary User: Alex
- Age: 25-35
- Wants quick social activities
- Values: Simplicity, safety, local community
- Pain point: Existing apps are too complex or dating-focused

### Secondary: Sam
- Age: 35-50
- Wants regular meetups (coffee, hiking)
- Values: Reliability, clear communication
- Pain point: Hard to find people to do activities with

---

## Success Metrics (Design-Related)

- ✅ Post creation takes <30 seconds
- ✅ Finding + accepting activity takes <1 minute
- ✅ All screens load instantly
- ✅ Clear what to do on each screen (no confusion)
- ✅ Feel safe posting activity + accepting others
- ✅ Feel connected to local community

---

## Tech Stack (For Reference)

- **Frontend:** SwiftUI iOS
- **Backend:** Firebase
- **Notifications:** Firebase Cloud Messaging (10km radius)
- **Messaging:** Async Firestore (not real-time)
- **Location:** Native device geolocation

*Design doesn't change based on tech, but useful context.*

---

## Timeline

- **Days 1-3:** Design (color palette, components, all screens)
- **Days 4+:** Code generation + testing

---

## Design Handoff Process

1. **You research** design references (use ChatGPT prompt)
2. **Share findings** (apps, colors, styles you like)
3. **I analyze** and propose final color palette
4. **We iterate** on colors until approved
5. **I define** complete design system
6. **I design** all 7 screens
7. **Finalize** Figma/Pencil file
8. **Hand off to Codex** for prompt updates
9. **Antigravity IDE** generates code with real design

---

## Questions to Guide Design Decisions

As you design, answer these:

1. **Color Mood:** Warm + approachable? Cool + modern? Vibrant + energetic?
2. **Button Style:** Rounded and soft? Sharp and modern? Custom shape?
3. **Card Style:** Shadowed depth? Flat + bordered? Filled backgrounds?
4. **Typography:** Serif or sans-serif? Geometric or friendly?
5. **Icons:** Outlined, filled, or duotone?
6. **Photography:** Real people? Illustrations? Icons only?
7. **Empty States:** How to show "no activities nearby"?
8. **Loading:** Spinner, skeleton, progress bar?
9. **Errors:** How to show "invalid phone number"?
10. **Micro-interactions:** Button tap animation? Swipe gestures?

---

## Next Steps

1. **Research:** Use ChatGPT prompt to find design references
2. **Gather:** Screenshots, links, descriptions of styles you like
3. **Share:** Send findings to me
4. **Analyze:** I propose color palette + design system
5. **Iterate:** We refine until design is approved
6. **Design:** I create all 7 screens
7. **Handoff:** Design ready for code generation

---

**Ready to start design! 🎨**

Share research findings → I analyze → We build design system → Create app → Code generation

---

**Project Status:**  
✅ Planning complete  
✅ Architecture finalized  
🎨 **Design phase — STARTING NOW**  
⏳ Code generation (after design)
