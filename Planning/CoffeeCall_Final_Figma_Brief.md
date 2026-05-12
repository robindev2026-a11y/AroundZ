# CoffeeCall MVP — Final Design Brief for Figma/Pencil

## Product Summary

**CoffeeCall** is a local activity coordination app based on real-time availability and reputation.

**NOT:** Dating app, social media, swipe app
**IS:** Activity-first, real meetups, trust-based

---

## Core Mechanic

1. User goes "live" (posts availability: coffee, movie, walk, etc. + time + location)
2. Nearby users discover them via Scanner or Discover list
3. Interested users ping them ("Want to grab coffee?")
4. Both accept = commitment (reputation stake)
5. In-app messaging to coordinate details
6. Meet up in person
7. Post mandatory review (5-star + vibe tags)
8. Ratings visible on profile (trust building)
9. Flaking = public badge + penalties

---

## Design System

### Colors (Intentional Meaning)
- **Primary Blue #3B82F6** — Trust, safety, primary actions
- **Cyan #22D3EE** — Live/active status, scanning highlight
- **Teal #0F766E** — Online, available, confirmed
- **Coral #FF7A59** — Pings, user actions, requests
- **Light Blue #E0F2FE** — Soft backgrounds, spacious
- **Ice White #F8FAFC** — App background, clarity
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
- **Border radius:** 8px (inputs), 12px (cards), 20px (chips), 20px+ (modals)
- **Shadows:** Soft only (0 2px 8px rgba(0,0,0,0.1))
- **Button height:** 44px minimum
- **Touch targets:** 44x44px minimum

### Accessibility
- **Contrast:** 4.5:1 minimum (WCAG AA)
- **Text:** Always readable, clear hierarchy
- **Buttons:** Touch-friendly (44px+)

### Images & Icons
- **Activity illustrations:** Colorful, friendly (Coffee, Movie, Walk, Study, Work, Food, Bike, Jog)
- **Icon style:** Outlined, consistent set
- **Photography:** Optional, modern, diverse

---

## Screens to Design (11 Total)

### SCREEN 1: Authentication Flow (5 steps in sequence)

**1.1 Welcome**
- Hero: "See who's around you"
- CTA: "Continue with Phone"
- Design: Clean, welcoming, minimal

**1.2 Phone Entry**
- Phone number input with country code
- "Send Code" button
- Security note: "We'll send you a verification code"

**1.3 OTP Verification**
- 6-digit input boxes (auto-focus between boxes)
- "Resend code in 00:45"
- Numeric keyboard

**1.4 Create Profile**
- Photo upload (camera + gallery)
- Name input
- Design: Large circular photo preview

**1.5 Select Activities**
- Title: "What are you interested in?"
- Grid of activity cards (2 columns): Coffee, Movie, Walk, Study, Work, Food, Bike, Jog
- Multi-select (min 2, max 8)
- Selected = Teal background

**1.6 Enable Location & Notifications**
- "Allow While Using App" (blue, primary)
- "Allow Once" (light blue)
- "Not Now" (ghost)
- Two separate permission cards

**1.7 All Set**
- Green checkmark, "You're all set!"
- CTA: "Start Scanning"

---

### SCREEN 2: Scanner (Tab 1 - Default)

**Main Discovery View**
- **Hero:** Radar/scanner visualization with cyan pulse
- **Center:** Circular map with avatars floating in 5km radius
- **Top:** "Scanning within 5 km" (dropdown to change radius → 1km/2km/5km)
- **Counter:** "8 people available, updated just now"
- **Avatars:** Small circles with user photo + activity icon overlay
- **Interaction:** Tap avatar → Mini card opens (bottom sheet)

**Design Notes:**
- Radar pulse animation (2-3 second cycle, cyan color)
- Avatars drift into view smoothly
- Clean, minimal UI (not cluttered)
- No text labels on avatars (just icons + photos)

---

### SCREEN 3: Discover List (Tab 2)

**Alternative Discovery View (Vertical List)**
- **Layout:** Scrollable vertical list
- **Card per person:**
  - Avatar (small, left)
  - Name + Activity + Distance (top right)
  - "Mira • Coffee • 0.8 km away"
  - Trust score + status (below)
  - ⭐ 4.7/5 (8 meetups) | Online 🟢
  - "Ping" button (Coral, right)
- **Dividers:** Light gray between cards
- **Empty state:** "No one nearby. Come back soon!"

---

### SCREEN 4: Mini Profile Card (Bottom Sheet)

**Trigger:** Tap user avatar from Scanner or Discover

- **Header:** Large avatar, name, age, activity icon
- **Distance:** "0.8 km away"
- **Trust section (prominent):**
  - ⭐ 4.7/5 (8 meetups)
  - 0 flakes (green text)
  - Status: "Available now" (Teal)
- **Bio:** Short text (if any)
- **Buttons:**
  - "Ping" (Coral, large)
  - "View Full Profile" (ghost)

---

### SCREEN 5: Full Profile

**Trigger:** Tap "View Full Profile" from Mini Card

- **Header:** Large photo, name, age, activity preferences
- **Trust Meter (Visual):**
  - Circular meter showing 87/100
  - Color gradient: Green (85%+), Yellow (70-84%), Red (<70%)
  - Label: "Trustworthy" or "Reliable"
- **Stats Section:**
  - 8 meetups | 4.7 avg rating | 0 flakes | 100% show rate
  - Icons next to each stat
- **Badges:** Deferred to v1.1 (show as placeholder)
- **Reviews Section (Scrollable):**
  - Each review card:
    - Reviewer avatar + name (small)
    - ⭐⭐⭐⭐⭐ (star rating)
    - Quote: "Great vibes! Super friendly. Exactly on time."
    - Vibe tags: Friendly, Engaging, On-time (small chips)
    - Date: "Oct 20, 2024"
  - Design: Light cards, easy to scan
- **Bio:** Full profile description
- **CTA:** "Ping" button (Coral, large)

---

### SCREEN 6: Post Availability Modal

**Trigger:** Floating "+" button on Scanner

**Form Fields:**
- **Activity:** Grid selector (Coffee, Movie, Walk, Study, Work, Food, Bike, Jog)
  - Single select, visual feedback on selected
- **Duration:** Dropdown (30 mins, 1 hr, 2 hrs, 3 hrs, custom)
- **Location:** Auto-filled current location, can edit
  - Shows address text
  - "Tap to change location"
- **Visibility Radius:** Selector (1 km, 2 km, 5 km)
  - 5 km = free
  - 1 km / 2 km = paid (show lock icon)
- **CTA:** "Go Live" (blue, large)

**Design:**
- Modal overlay (not full screen)
- Rounded corners, soft shadow
- Clear section dividers

---

### SCREEN 7: Ping Request

**Trigger:** User taps "Ping" on someone's card

**Bottom Sheet:**
- Title: "What do you want to do?"
- Message templates:
  - "Coffee?" (default for coffee activity)
  - "Movie?" (default for movie)
  - Custom text input (optional)
- **When:** "Right now" (default)
- **CTA:** "Send Ping" (Coral)

**Design:** Simple, quick options (no overthinking)

---

### SCREEN 8: Incoming Ping Notification

**In-App Card (appears in Pings tab):**
- Avatar + name (left)
- Request: "Alex wants coffee at Brew House"
- Trust score: ⭐ 4.7/5 | Online 🟢
- **Warning text:** "If you accept, you're committing. Canceling = flake badge."
- Buttons: "Accept" (blue) | "Decline" (ghost)

**Design:**
- Prominent, can't dismiss without action
- Clear consequences visible
- Warm color (welcoming but serious)

---

### SCREEN 9: Flake Warning Modal

**Trigger:** User tries to cancel after accepting

- **Title:** "Cancel this meetup?"
- **Content:**
  - "You'll get a 'Flaked 1x' badge on your profile"
  - "3 flakes = account suspension"
- **Buttons:** "Still Cancel" (red) | "Go Through" (blue)

**Design:** Red background, serious but fair tone

---

### SCREEN 10: Match Confirmed

**Trigger:** Both users accept ping

- **Success state:** Green background or checkmark icon
- **Content:**
  - "You matched with Alex!"
  - Activity + time: "Coffee at Brew House, 3:00 PM (1 hour)"
  - Both user avatars (centered)
  - Location map (small preview)
  - **Timer:** Countdown to meetup time
- **CTA:** "Open Messages" (blue)

**Design:** Celebratory but calm (no flashy animations)

---

### SCREEN 11: Messages/Chat

**Trigger:** After match confirmed (or tap Messages tab)

- **Header:** User name + status (Online/Away)
- **Messages:**
  - Sent (right-aligned, blue bubble)
  - Received (left-aligned, gray bubble)
  - Timestamp below each message
  - Both use rounded corners
- **Input:** Text field + Send button (Coral icon)
- **No features:** Typing indicators, read receipts, presence

**Design:** Simple, utility-first (not Instagram-like)

---

### SCREEN 12: Post-Meetup Review

**Trigger:** 5 mins after meetup time ends → Notification

**Step 1: Star Rating**
- "How was your meetup with Alex?"
- 5-star selector (large, tap to select)
- Color feedback (gray → yellow → blue)

**Step 2: Vibe Tags (Multi-select)**
- "How was the vibe?"
- Chips: Friendly, Engaging, Fun, Awkward, Quiet, Creepy, Respectful, On-time
- Selected = Teal background

**Step 3: Comment (Optional)**
- "Tell others what it was like" (100 char max)
- Text input
- If stars ≤2, comment is required

**Step 4: Confirmation**
- "Review posted to Alex's profile!"
- Show what was posted:
  - ⭐⭐⭐⭐⭐
  - "Great vibes!"
  - Friendly, Engaging, On-time tags
- CTA: "Done" or "View Profile"

---

### SCREEN 13: Pings Tab

**Shows:**
- **Incoming Pings:** Users who pinged you (newest first)
  - Avatar, name, request, status
  - Actions: Accept / Decline
- **Outgoing Pings:** You pinged them (newest first)
  - Avatar, name, what you pinged for
  - Status: Waiting / Accepted / Declined
- **Empty state:** "No pings yet. Go discover people!"

**Design:** Clear separation between incoming/outgoing

---

### SCREEN 14: My Profile

**Shows:**
- **Header:** Large photo, name, age
- **Activity preferences:** Chips of selected activities
- **Trust Meter (Visual):**
  - Circular 87/100, green color
  - Label: "Trustworthy"
- **Stats:**
  - 8 meetups | 4.7 avg rating | 0 flakes | 100% show rate
- **Reviews Section (Scrollable):**
  - Recent 5-star reviews from others
  - Same design as full profile
- **Badges:** Placeholder for v1.1
- **Edit buttons:**
  - "Edit Profile" (change photo, name, bio, activities)
  - "Settings" (privacy, notifications, radius)

---

### SCREEN 15: Settings

**Sections:**
- **Privacy & Safety:**
  - Visibility radius (1 km / 2 km / 5 km)
  - Show exact distance (toggle)
  - Block users (list)
  - Report user (option)
- **Notifications:**
  - Pings (toggle)
  - Reviews (toggle)
  - Matchups (toggle)
  - Do Not Disturb times
- **Account:**
  - Edit profile
  - Change phone number
  - Delete account

---

## Bottom Navigation (Always Visible)

5 tabs:
1. **Scanner** (default) — Radar view
2. **Discover** — List view
3. **Pings** — Incoming/outgoing requests
4. **Messages** — Chat threads
5. **Profile** — My profile + settings

Active tab = Teal highlight
Inactive tabs = Gray

---

## Key UX Rules

✓ Activity FIRST (☕ Coffee nearby), person SECOND
✓ Trust scores VISIBLE on every card (rating + flakes + status)
✓ Review quality matters (show author + comment + tags)
✓ Commitment friction visible (flake warning before cancel)
✓ NO swiping, NO infinite feed, NO dopamine mechanics
✓ Light, calm, trustworthy aesthetic
✓ Icons instead of emojis
✓ Async messaging (2-5s latency OK)
✓ In-app messaging only (no phone sharing)

---

## Deferred to v1.1

❌ Face verification (selfie confirmation)
❌ Verified badges (checkmark)
❌ Advanced reputation scoring
❌ Real-time chat
❌ Payment system
❌ Dark mode
❌ Maps view

---

## Copy Tone

- Honest ("You'll get a flake badge if you cancel")
- Professional but friendly (no cutesy language)
- Trust-focused ("Trustworthy" not "Badge unlocked!")
- Practical (explain why, not just what)

---

## Design Success Checklist

✓ Users instantly understand: "Not a dating app"
✓ Trust scores visible on every interaction
✓ Flake mechanics clearly explained
✓ Review quality builds confidence
✓ Activity is visual hero (not profile)
✓ Commitment friction understood
✓ All buttons 44px+ and tappable
✓ 4.5:1 contrast ratio throughout
✓ Light, calm, minimal aesthetic
✓ Post creation takes <30 seconds
✓ Discovering + accepting takes <1 minute

---

## Next Steps

1. **Design all 15 screens** in Figma/Pencil
2. **Apply design system** (colors, typography, spacing)
3. **Create component library** (buttons, cards, inputs, badges)
4. **Interactive prototype** (auth + scanner + ping flow)
5. **Share for review**
6. **Iterate based on feedback**
7. **Handoff to Flutter dev** with design tokens

---

## Files to Create in Figma

- Page 1: Design System (colors, typography, components)
- Page 2: Auth Flow (screens 1.1-1.7)
- Page 3: Discovery (screens 2, 3, 4, 5)
- Page 4: Going Live (screen 6)
- Page 5: Ping Flow (screens 7, 8, 9, 10)
- Page 6: Messages (screen 11)
- Page 7: Review (screen 12)
- Page 8: Tabs (screens 13, 14, 15)
- Page 9: Components Library (reusable elements)
- Page 10: Prototype (interactive flows)

---

## Contact for Clarification

If any questions arise during design, refer back to this brief. Product is locked. Design should follow spec exactly.

Good luck! 🚀
