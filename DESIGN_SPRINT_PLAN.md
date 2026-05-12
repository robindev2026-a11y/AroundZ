# CoffeeCall Design Sprint Plan

**Duration:** 2-3 days (focused design work only)  
**Goal:** Complete, finalized design before code generation  
**Owner:** Design team + UX/visual decisions  
**Deliverable:** Figma/Pencil file + design documentation

---

## Sprint Overview

We are designing the complete CoffeeCall MVP user experience including:
- Admin login flow (separate from user)
- User login flow
- 7 core screens + all user interactions
- Color palette + visual consistency
- Admin vs User UI separation
- Complete user journey mapping

---

## Daily Breakdown

### Day 1: Strategy & Wireframes (Low-Fidelity)

**Morning (2 hours):**
- [ ] Define user personas (admin vs regular user)
- [ ] Map user journeys (signup → post → accept → message)
- [ ] Sketch 7 screens (pen & paper or digital)
- [ ] Define screen hierarchy
- [ ] Create basic flow diagrams

**Afternoon (3 hours):**
- [ ] Create wireframes for all 7 screens (low-fidelity)
- [ ] Admin-specific screens (admin dashboard, user management, etc.)
- [ ] User screens (signup, post, discover, messages, etc.)
- [ ] Identify key interactions on each screen
- [ ] Note state changes (loading, error, success, disabled)

**Deliverable:** Sketches + wireframe outlines + user flow diagrams

---

### Day 2: Visual Design & Color System (High-Fidelity)

**Morning (2 hours):**
- [ ] Define color palette (primary, secondary, neutrals)
- [ ] Create color inspiration board
- [ ] Define typography (headings, body, labels)
- [ ] Create component library (button states, inputs, cards)
- [ ] Design spacing/grid system

**Afternoon (3 hours):**
- [ ] Design all 7 screens in high-fidelity (colors, typography, spacing)
- [ ] Admin screens with clear separation from user screens
- [ ] Define component variations (primary button, secondary button, etc.)
- [ ] Create state variations (default, hover, active, disabled, loading)
- [ ] Ensure color consistency across all screens

**Deliverable:** Figma/Pencil file with all designs + color system

---

### Day 3: Refinement & Documentation

**Morning (2 hours):**
- [ ] Review designs for consistency
- [ ] Refine spacing and alignment
- [ ] Verify accessibility (contrast ratios, touch targets)
- [ ] Create interaction specifications (tap, swipe, scroll)
- [ ] Document all design decisions

**Afternoon (2 hours):**
- [ ] Create design handoff documentation
- [ ] Update `/Design/` folder with final specs
- [ ] Export design assets (icons, images, etc.)
- [ ] Create design system document
- [ ] Verify Codex prompts align with finalized design

**Deliverable:** Final design file + complete documentation

---

## Screens to Design (7 Total)

### 1. Signup Flow
**Screens:**
- [ ] Phone number entry
- [ ] OTP verification
- [ ] Profile photo upload
- [ ] Name input
- [ ] Location permission request
- [ ] Success/welcome screen

**Admin Variant:** (N/A - admin has separate admin login)

**Key States:**
- [ ] Loading (sending OTP, uploading photo)
- [ ] Error (invalid phone, wrong OTP)
- [ ] Success

---

### 2. Admin Login (Separate from User)
**Screens:**
- [ ] Admin login screen (different from user signup)
- [ ] Admin dashboard
- [ ] User management view
- [ ] Activity moderation view
- [ ] Analytics/stats view

**Separation:** Use different color scheme or distinct header to differentiate admin interface

**Key States:**
- [ ] Logged out
- [ ] Logged in (admin view)
- [ ] Loading states
- [ ] Error states

---

### 3. User Login
**Screens:**
- [ ] Phone + OTP (same as signup for returning users)
- [ ] Profile setup (if new user)
- [ ] Home screen (after login)

---

### 4. Home / Discover (Notifications View)
**Design:**
- [ ] Tab bar navigation (Home, My Posts, Messages, Profile)
- [ ] Notification list of nearby posts
- [ ] Each post shows: poster avatar, name, activity, location, time
- [ ] Accept/Reject buttons per post
- [ ] Refresh/load more functionality
- [ ] Empty state (no posts nearby)
- [ ] Loading state (fetching posts)

**Admin View:** (Different - see admin dashboard above)

---

### 5. Post Creation
**Design:**
- [ ] Purpose input field (text)
- [ ] Location picker (map or address input)
- [ ] Time picker (date + time)
- [ ] Submit button
- [ ] Success confirmation
- [ ] Error states

**States:**
- [ ] Default (empty form)
- [ ] Filled (ready to submit)
- [ ] Loading (submitting)
- [ ] Success (post created)
- [ ] Error (submission failed)

---

### 6. Acceptance Dialog
**Design:**
- [ ] Modal overlay
- [ ] Activity details (purpose, location, time)
- [ ] Poster profile (avatar, name, rating)
- [ ] Confirm/Cancel buttons
- [ ] Confirmation after acceptance
- [ ] Auto-opens message thread

**States:**
- [ ] Dialog open
- [ ] Confirming (loading)
- [ ] Confirmed (show message thread)
- [ ] Cancelled (return to posts)

---

### 7. Messages
**Design:**
- [ ] Message thread header (who you're chatting with)
- [ ] Message list (chronological)
- [ ] Sent messages (right-aligned, primary color)
- [ ] Received messages (left-aligned, gray)
- [ ] Message input field at bottom
- [ ] Send button
- [ ] Timestamp on each message
- [ ] Loading state for sending

**States:**
- [ ] Thread open
- [ ] Sending message (spinner)
- [ ] Message sent (timestamp)
- [ ] Error sending (retry option)
- [ ] Empty state (no messages yet)

---

### 8. Poster Dashboard (My Posts Tab)
**Design:**
- [ ] List of user's active posts
- [ ] For each post: purpose, location, time, acceptance count
- [ ] Tap post to see acceptances
- [ ] Acceptances list (acceptor avatar, name, time accepted)
- [ ] Empty state (no posts yet)

---

### 9. Profile
**Design:**
- [ ] Profile header (avatar, name)
- [ ] Stats (posts created, acceptances, rating)
- [ ] Edit profile option
- [ ] Logout button
- [ ] Settings (notifications, privacy)

---

## Color Palette Definition

### Primary Colors
- [ ] Primary brand color (main CTA button, highlights)
- [ ] Primary hover state (darker)
- [ ] Primary active state (even darker)

### Secondary Colors
- [ ] Success color (accept, confirmations)
- [ ] Error/Danger color (reject, errors)
- [ ] Warning color (pending, caution)
- [ ] Info color (notifications, hints)

### Neutral Colors
- [ ] Background (page background)
- [ ] Surface (cards, panels)
- [ ] Border (dividers, separators)
- [ ] Text primary (body text)
- [ ] Text secondary (labels, captions)
- [ ] Text disabled (disabled text)

### Accessibility Requirements
- [ ] Primary color: 4.5:1 contrast with white (WCAG AA)
- [ ] All text: 4.5:1 contrast minimum
- [ ] No color-only differentiation (use icons + color)

---

## Typography System

### Headings
- [ ] Heading 1 (page titles)
- [ ] Heading 2 (section titles)
- [ ] Heading 3 (subsection titles)

### Body
- [ ] Body large (emphasized text)
- [ ] Body (standard text)
- [ ] Body small (secondary text)

### Labels
- [ ] Button text
- [ ] Form labels
- [ ] Captions
- [ ] Timestamps

### Font Choices
- [ ] Primary font (e.g., Inter, Poppins, Roboto)
- [ ] Font sizes (px)
- [ ] Font weights (regular, medium, semibold, bold)
- [ ] Line heights

---

## Component Library (Design System)

Create reusable components with all states:

### Buttons
- [ ] Primary button (default, hover, active, disabled, loading)
- [ ] Secondary button (all states)
- [ ] Danger button (all states)
- [ ] Size variants (small, medium, large)

### Inputs
- [ ] Text input (default, focused, filled, error, disabled)
- [ ] Phone input (with country code)
- [ ] OTP input (6 digits)
- [ ] Location picker

### Cards
- [ ] Post card (poster info + activity details)
- [ ] Acceptance card (acceptor info)
- [ ] Message card (message bubble)
- [ ] Profile card

### Dialogs
- [ ] Confirmation dialog (confirmation pattern)
- [ ] Alert dialog (warning pattern)
- [ ] Loading dialog (loading spinner)

### Navigation
- [ ] Tab bar (5 tabs: Home, My Posts, Messages, Profile, [Admin if applicable])
- [ ] Header bar (title + back button)

### Other
- [ ] Avatar (profile images)
- [ ] Badges (acceptance count, ratings)
- [ ] Dividers (section separators)
- [ ] Empty states (no data screens)
- [ ] Loading states (spinners, skeletons)
- [ ] Error states (error messages)

---

## Admin vs User Separation

**Critical Design Decision:** Admin interface should be visually distinct from user interface.

### Separation Strategy

**Option A: Different Color Scheme**
- User: Primary color brown (#8B6F47)
- Admin: Different primary (e.g., blue, purple)
- Clear visual distinction

**Option B: Different Header/Branding**
- User: Standard header
- Admin: "Admin Panel" badge/indicator
- Different navigation options

**Option C: Separate App/URL**
- User app: CoffeeCall
- Admin: CoffeeCall Admin (separate experience)

### Recommendation
**Use Option A or B** to clearly separate user and admin experiences in a single app. Admin users should immediately know they're in a different interface.

### Admin-Specific Screens
- [ ] Admin login screen
- [ ] Admin dashboard (stats, activity overview)
- [ ] User management (list, approve, ban)
- [ ] Activity moderation (flag inappropriate)
- [ ] Analytics view (trends, usage)
- [ ] Settings (admin configuration)

---

## User Journey Flows

### User Journey 1: New User Signup → First Post
```
1. App opens
2. Phone signup screen
3. Enter phone number
4. OTP verification
5. Upload profile photo
6. Enter name
7. Allow location + notifications
8. Home screen (no posts nearby)
9. Create first post
10. Post created, see other posts
```

### User Journey 2: Discover & Accept Activity
```
1. Home tab (see nearby posts)
2. See post from another user
3. Tap post (opens confirmation dialog)
4. Confirm acceptance
5. Message thread auto-opens
6. Message the poster
7. Meet up at activity
```

### User Journey 3: Post Activity & Manage Acceptances
```
1. Post tab (create new post)
2. Enter purpose, location, time
3. Submit post
4. Post appears in nearby users' feeds
5. Users accept activity
6. See acceptances in "My Posts" tab
7. Message with acceptors
8. Activity happens
```

### Admin Journey: Moderate & Manage
```
1. Admin login (separate from user)
2. Admin dashboard (see stats)
3. View flagged activities
4. View user complaints
5. Approve/reject activities
6. Ban inappropriate users
```

---

## Design Deliverables Checklist

**End of 3-Day Sprint, you should have:**

### Design Files
- [ ] Figma file (or Pencil file) with all screens
- [ ] All 7 user screens designed (high-fidelity)
- [ ] All admin screens designed (if applicable)
- [ ] Component library (buttons, inputs, cards, etc.)
- [ ] All states documented (default, hover, active, disabled, loading, error)

### Documentation
- [ ] `/Design/design-tokens.md` — UPDATED with final colors, typography, spacing
- [ ] `/Design/design-system.md` — UPDATED with final system description
- [ ] `/Design/screens.md` — UPDATED with final screen descriptions
- [ ] `/Design/component-specs.md` — UPDATED with final component specs
- [ ] `/Design/figma-link.md` — Link to Figma/Pencil file
- [ ] `/Design/accessibility.md` — Accessibility verification
- [ ] `/Design/admin-design.md` — OPTIONAL: Admin interface design specs

### Color Export
- [ ] Final color palette (hex codes)
- [ ] Typography scale (sizes, weights)
- [ ] Spacing/grid system (values)

### Ready for Codex?
- [ ] Codex will read updated design files
- [ ] Prompts will be regenerated to match finalized design
- [ ] THEN Antigravity IDE generates code

---

## How to Execute (Tools)

**Choose one:**

1. **Figma** (Recommended)
   - Cloud-based, collaborative
   - Design system tools built-in
   - Export assets easily
   - Link: Create project, share with team
   - Cost: Free tier sufficient for MVP

2. **Pencil** (Alternative)
   - Self-hosted design tool
   - Similar to Figma
   - Works offline
   - Local file (.pen format)

3. **Paper & Scan** (Bootstrap)
   - Day 1: Hand-sketch wireframes
   - Day 2: High-fidelity digital mockups (Figma/Pencil)
   - Day 3: Finalize

**Recommendation:** Use **Figma** for speed + collaboration.

---

## Success Criteria (End of Sprint)

You're done when:
- ✅ All 7 screens designed (high-fidelity)
- ✅ Admin screens designed (separate interface)
- ✅ Color palette defined and tested (4.5:1 contrast)
- ✅ Typography system complete
- ✅ Component library with all states
- ✅ All user journeys documented
- ✅ Design tokens updated in `/Design/` folder
- ✅ Figma/Pencil link documented
- ✅ Ready for Codex to reference in prompt updates

---

## Next Steps (After Design Sprint)

1. ✅ Finalize design (this sprint)
2. Codex updates prompts to reference finalized design
3. Antigravity IDE generates code from updated prompts
4. Code includes actual design (colors, spacing, layouts)

---

## Questions to Answer During Design

As you design, document answers to:

1. **Admin Separation:** How will admin interface look different? (color, layout, navigation)
2. **Color Consistency:** How do colors carry across all screens?
3. **Empty States:** What does "no posts nearby" look like?
4. **Loading States:** How do spinners/skeletons appear?
5. **Error States:** How are validation errors shown?
6. **Accessibility:** Do all color combinations meet 4.5:1 contrast?
7. **Responsive:** How do screens adapt to different phone sizes?
8. **Micro-interactions:** How do buttons respond to taps? (scale, ripple?)
9. **Typography Hierarchy:** How is heading/body/label distinction clear?
10. **Navigation:** How do users move between screens?

---

## Timeline

- **Day 1 Morning:** Wireframes + user journeys
- **Day 1 Afternoon:** Low-fidelity screen mockups
- **Day 2 Morning:** Color palette + typography
- **Day 2 Afternoon:** High-fidelity designs
- **Day 3 Morning:** Refinement + consistency check
- **Day 3 Afternoon:** Documentation + handoff

**Result:** Complete design ready for code generation.

---

**Design Sprint Status:** Ready to start  
**Duration:** 2-3 days  
**Priority:** CRITICAL — Code generation cannot proceed without finalized design

---

**Next Question for You:**

1. Will you use Figma, Pencil, or paper wireframes?
2. Who is designing (you, a designer, or collaborative)?
3. Do you have admin users, or is it user-only for MVP?
4. Any color preferences or brand guidelines?
5. Should we schedule this sprint for specific days?

Once you answer these, we can create a focused design checklist for your team.
