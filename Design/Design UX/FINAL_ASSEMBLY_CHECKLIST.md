# CoffeeCall MVP — Final Assembly & Verification Checklist

**Status:** Ready for Agent Completion Handoff  
**Created:** May 12, 2026  
**Owner:** Claude (Final Assembly)

---

## Phase 1: Screen Completion Verification (Post-Agent)

### All 7 Screens Present & Properly Structured
- [ ] **Screen 1 - Signup:** 8-step onboarding flow (welcome → phone → OTP → photo → name → interests → location → success)
- [ ] **Screen 2 - Home/Discover:** Feed with activity cards, filter chips, search bar, bottom tab bar (Home active)
- [ ] **Screen 3 - Post Creation:** Form with purpose, location, time fields + submit button
- [ ] **Screen 4 - Acceptance Dialog:** Modal overlay with activity details, poster profile, confirm/cancel buttons
- [ ] **Screen 5 - Messages/Chat:** Message thread with outgoing/incoming bubbles, timestamps, input area, bottom tab bar (Messages active)
- [ ] **Screen 6 - My Posts:** User's posted activities list with acceptance counts, expandable acceptor list, bottom tab bar (My Posts active)
- [ ] **Screen 7 - Profile:** User profile with avatar, name, stats, edit/settings/logout buttons, bottom tab bar (Profile active)

### Screen Content & Components
- [ ] All screens use proper reusable components (not hardcoded layouts)
- [ ] Activity cards use ooEjY component (Home screen)
- [ ] Compact activity cards use vvlGt component (My Posts screen)
- [ ] Chat bubbles use Alim1 (outgoing) and jbQXb (incoming) components
- [ ] Modals use BiTzO component for confirmation dialogs
- [ ] All screens have sp1E6 (Bottom Tab Bar) except Signup
- [ ] Tab bars show correct active tab on their respective screens

---

## Phase 2: Design System Compliance Check

### Color Usage ✓ Variables Only
- [ ] All fills use `$color-primary` (#3B82F6) for primary CTAs
- [ ] Reject/secondary actions use `$color-coral` (#FF7A59)
- [ ] Success states use `$color-teal` (#0F766E)
- [ ] All text uses `$color-text` (#1E293B) for primary, `$color-text-muted` (#64748B) for secondary
- [ ] Backgrounds use `$color-bg` (#F8FAFC)
- [ ] Borders use `$color-border` (#E2E8F0)
- [ ] Light backgrounds/hovers use `$color-light-blue` (#E0F2FE)
- [ ] **No hardcoded colors** — all must be variable references

### Typography Consistency
- [ ] **Page titles** (Signup steps, screen headers): 28px, weight 700
- [ ] **Section titles** (Card headers, section labels): 16px, weight 600
- [ ] **Body text** (Card content, descriptions): 14px, weight 400
- [ ] **Secondary text** (Timestamps, helper text): 12px, weight 400
- [ ] **Button text:** 14px, weight 600, color appropriate for button type
- [ ] All text uses **Inter** font family
- [ ] **No mixed font sizes** within a category (all titles should match)
- [ ] Enough **line height** for readability (1.4-1.6x)

### Spacing Consistency
- [ ] **Padding inside components:** Use spacing tokens (`$spacing-sm` = 8, `$spacing-md` = 16)
- [ ] **Gap between sections:** Use `$spacing-lg` (24) or `$spacing-xl` (32)
- [ ] **Padding inside buttons:** `$spacing-sm` (8) horizontal, consistent vertical
- [ ] **Padding inside cards:** `$spacing-md` (16) all around
- [ ] **Padding inside dialogs/modals:** `$spacing-lg` (24)
- [ ] **No custom spacing values** — all must reference variables
- [ ] Consistent left/right padding on all screens (16-24px)

### Border Radius Consistency
- [ ] **Buttons:** `$radius-md` (12px)
- [ ] **Input fields:** `$radius-sm` (8px) or `$radius-md` (12px)
- [ ] **Cards:** `$radius-md` (12px)
- [ ] **Modals/dialogs:** `$radius-md` (12px) or `$radius-lg` (20px)
- [ ] **Tab bar pill:** `$radius-lg` (20px)
- [ ] **No hardcoded radius values**

---

## Phase 3: Component Instance Verification

### Button Component Usage (HHcVb - Primary)
- [ ] Used for all primary CTAs (Submit, Confirm, Accept)
- [ ] Correct height: 44px (defined in variable)
- [ ] Correct padding: spacing-sm horizontal
- [ ] Correct border radius: radius-md
- [ ] Correct text styling: 14px, weight 600
- [ ] Disabled state works properly (opacity reduced)

### Input Component Usage (Sof5H - Text, spFru - DateTime)
- [ ] Used for all form fields (phone, OTP, name, purpose, location, time)
- [ ] Correct height: 48px
- [ ] Correct padding: spacing-sm
- [ ] Border: 1px solid $color-border
- [ ] Focus state: changes to $color-primary with light-blue background
- [ ] Placeholder text visible and helpful
- [ ] Error state (if applicable): coral border with error message

### Card Component Usage (ooEjY - Activity Card)
- [ ] Used for activity listings on Home screen
- [ ] Contains: avatar, name, purpose, location, time, accept/reject buttons
- [ ] Shadow applied: subtle (2px offset, 8px blur)
- [ ] Border radius: radius-md (12px)
- [ ] Padding: spacing-md (16px)
- [ ] All instances properly filled with content

### Bottom Tab Bar Component (sp1E6)
- [ ] Present on all screens EXCEPT Signup
- [ ] 4 tabs visible: Home, My Posts, Messages, Profile
- [ ] Only one tab active per screen
- [ ] Active tab: solid fill with $color-primary
- [ ] Inactive tabs: transparent with muted text
- [ ] Height: 62px (includes safe area)
- [ ] Border radius: 36px (pill-shaped)
- [ ] Properly positioned at bottom of viewport

### Modal Component (BiTzO - Join Confirmation)
- [ ] Used for acceptance confirmation on Home screen
- [ ] Centered on screen
- [ ] Max-width: ~340px
- [ ] Contains: title, activity details, poster info, action buttons
- [ ] Semi-transparent dark overlay behind modal
- [ ] Proper shadow and elevation
- [ ] Border: 1px stroke $color-border
- [ ] Border radius: radius-md (12px)

---

## Phase 4: Accessibility Compliance Check

### Contrast Ratios (WCAG AA - 4.5:1 Minimum)
- [ ] Primary text (#1E293B) on light background (#F8FAFC): ✓ Sufficient
- [ ] Primary color (#3B82F6) on white: ✓ Sufficient
- [ ] Coral color (#FF7A59) on white: ✓ Sufficient
- [ ] Teal (#0F766E) on light-blue background: ✓ Sufficient
- [ ] Muted text (#64748B) on light background: Check specific combinations
- [ ] All text meets minimum 4.5:1 contrast

### Touch Target Sizes
- [ ] All buttons: minimum 44x44px ✓
- [ ] All input fields: minimum 48px height ✓
- [ ] All tappable cards: comfortable spacing (16px+ gap)
- [ ] Tab bar items: min 44x44px per item ✓
- [ ] No cramped or hard-to-tap areas

### Typography Readability
- [ ] Minimum font size: 12px (secondary text) ✓
- [ ] Maximum font size: 28px (titles) ✓
- [ ] Line height adequate for body text (1.4-1.6x)
- [ ] Line length not excessive (under 60 characters for body)
- [ ] Clear hierarchy: titles > body > secondary text

### Navigation Clarity
- [ ] Bottom tab bar clearly shows current location
- [ ] Active tab visually distinct from inactive
- [ ] Back buttons present in nested flows (chat, posts)
- [ ] Signup flow has clear step progression
- [ ] Empty states have clear messaging

---

## Phase 5: Layout & Alignment Check

### Screen Structure
- [ ] **Status bar:** 62px height (OS-controlled)
- [ ] **App content:** Begins below status bar
- [ ] **Content wrapper:** Single vertical stack with consistent padding (16-24px left/right)
- [ ] **Gap between sections:** Consistent (24-32px)
- [ ] **Bottom tab bar:** Sticky at bottom, never obscures content

### Vertical Alignment
- [ ] Content properly centered vertically within available space
- [ ] No excessive white space at bottom (use padding on wrapper, not spacers)
- [ ] Scroll areas properly padded for tab bar (bottom padding = content gap)
- [ ] Modals/dialogs centered on screen

### Horizontal Alignment
- [ ] Consistent left/right padding on all screens
- [ ] Text alignment matches component definitions
- [ ] Buttons full-width or centered appropriately
- [ ] Cards properly aligned with screen edges

---

## Phase 6: Screen-Specific Verification

### Signup Flow (Screen 1)
- [ ] 8 distinct steps visible in progression
- [ ] Each step has clear title + helper text
- [ ] Form fields properly validated
- [ ] CTA button prominent and clear
- [ ] Success screen celebrates completion
- [ ] No tab bar on this flow

### Home/Discover (Screen 2)
- [ ] Header: "Hi [Name] 👋" with greeting
- [ ] Search bar visible (Input/Search component)
- [ ] Filter chips visible: Today, Coffee, Movies, Free Now, etc.
- [ ] Activity cards display correctly with all info
- [ ] Accept/Reject buttons prominent on each card
- [ ] Empty state shown when no activities
- [ ] Pull-to-refresh indicator present
- [ ] Bottom tab bar with Home active
- [ ] Scrollable content doesn't hide tab bar

### Post Creation (Screen 3)
- [ ] 3 form fields: Purpose, Location, Time
- [ ] Purpose field is text input
- [ ] Location shows current location
- [ ] Time picker functional
- [ ] Submit button prominent
- [ ] Loading state visible during submission
- [ ] Success confirmation message
- [ ] Auto-return to Home after success

### Acceptance Dialog (Screen 4)
- [ ] Modal appears as overlay
- [ ] Activity details clearly shown
- [ ] Poster profile visible (avatar, name)
- [ ] "Confirm" button (primary color)
- [ ] "Cancel" button (secondary)
- [ ] Semi-transparent dark backdrop
- [ ] Modal is centered and sized appropriately
- [ ] Can dismiss by tapping outside or Cancel

### Messages/Chat (Screen 5)
- [ ] Header shows "Chatting with [Name]"
- [ ] Message thread displays chronologically
- [ ] Outgoing messages: right-aligned, primary color background
- [ ] Incoming messages: left-aligned, gray background
- [ ] Timestamps visible on messages
- [ ] Input field at bottom with Send button
- [ ] Scroll area for long conversations
- [ ] Bottom tab bar with Messages active
- [ ] Tab bar doesn't obscure input area

### My Posts/Dashboard (Screen 6)
- [ ] Shows list of user's posted activities
- [ ] Each post shows: purpose, location, time, acceptance count
- [ ] Tappable to expand acceptor list
- [ ] Acceptor list shows: avatar, name, accepted time
- [ ] Can message acceptor from this view
- [ ] Bottom tab bar with My Posts active
- [ ] Scrollable if many posts

### Profile (Screen 7)
- [ ] Large avatar (120-160px) editable
- [ ] Name editable with tap
- [ ] Stats section: Posts created, Acceptances count
- [ ] "Edit Profile" button (primary)
- [ ] "Settings" button (secondary)
- [ ] "Logout" button (destructive, coral color)
- [ ] Clear personal information
- [ ] Bottom tab bar with Profile active

---

## Phase 7: Visual Quality Check

### Shadows & Depth
- [ ] Cards have subtle shadows (0 2px 8px rgba(0,0,0,0.08))
- [ ] Modals have more pronounced shadows
- [ ] No double-shadows or conflicting effects
- [ ] Shadows consistent across similar components

### Visual Hierarchy
- [ ] Most important elements are largest
- [ ] Headings clearly distinguished from body text
- [ ] CTAs visually prominent
- [ ] Secondary actions de-emphasized
- [ ] Status information clear at a glance

### Consistent Styling
- [ ] All buttons of same type look identical
- [ ] All cards of same type look identical
- [ ] All inputs of same type look identical
- [ ] Color usage consistent throughout
- [ ] Icon styles consistent (if present)

### Polish & Details
- [ ] No misaligned elements
- [ ] No broken components or references
- [ ] Smooth transitions between states
- [ ] Hover/active states visually distinct
- [ ] Loading states clearly visible

---

## Phase 8: Final Screenshots & Documentation

### Screenshot Capture
- [ ] Signup flow: Capture all 8 steps (or representative steps)
- [ ] Home/Discover: Show feed with multiple activity cards
- [ ] Post Creation: Show form before and after submission
- [ ] Acceptance Dialog: Show modal overlay
- [ ] Messages/Chat: Show conversation thread
- [ ] My Posts: Show posted activities + acceptor list
- [ ] Profile: Show user profile + stats + actions
- [ ] Each at 2x scale for clarity

### Export Assets
- [ ] Color palette (CSS variables)
- [ ] Typography styles (font sizes, weights)
- [ ] Spacing tokens (for SwiftUI/CSS)
- [ ] Component reference guide
- [ ] Icon list (if using custom icons)

### Create Handoff Document
- [ ] Component library guide (usage, states, props)
- [ ] Design tokens guide (colors, typography, spacing)
- [ ] Screen-by-screen specifications
- [ ] Interaction guidelines (tap, scroll, transitions)
- [ ] Edge cases & error states

---

## Phase 9: Approval & Sign-Off

### Design System Review
- [ ] All variables properly used (no hardcoded values)
- [ ] All components properly instantiated
- [ ] All screens follow design patterns
- [ ] Design is production-ready

### Accessibility Audit
- [ ] WCAG AA compliance verified
- [ ] Touch target sizes adequate
- [ ] Color contrast sufficient
- [ ] Navigation clear
- [ ] No barriers to usability

### Final Approval
- [ ] [ ] All verification items complete
- [ ] [ ] No blocking issues found
- [ ] [ ] Design approved for code generation
- [ ] [ ] Ready for Codex prompt generation

---

## Phase 10: Code Generation Handoff

### Deliverables to Codex/Ambiglytics
1. **Design File:** untitled.pen with all screens finalized
2. **Design Specification:** DESIGN_SPECIFICATION.md
3. **Component Guide:** Detailed component usage and states
4. **Design Tokens:** Colors, typography, spacing variables
5. **Screenshots:** All 7 screens at 2x resolution
6. **Interaction Guide:** Tap targets, scroll behavior, transitions

### Code Generation Process
1. **Codex** reads design spec + screenshots
2. **Codex** generates detailed SwiftUI implementation prompts
3. **Ambiglytics** transforms prompts into working code
4. **Code** produces SwiftUI views matching design
5. **Testing** verifies visual fidelity against design

---

## Notes & Special Cases

### Signup Flow Complexity
The signup is 8 steps. If agents combine steps, ensure:
- Phone entry + OTP verification are separate
- Photo upload is dedicated screen
- Name input is separate
- Interests selection is separate
- Location + notification permissions shown
- Success screen celebrates

### Message Latency
Design should accommodate 2-5 second delay:
- No typing indicators
- No read receipts
- Simple message delivery
- Timestamp shows when sent

### 10km Radius
Design doesn't show maps, just text location.
Radius is implicit, not visual element.

### Post Persistence
Posts never close after first acceptance.
Multiple people can accept same activity.
This is design feature, not bug.

---

## Verification Sign-Off

- [ ] **Phase 1:** All 7 screens present ✓
- [ ] **Phase 2:** Design system compliant ✓
- [ ] **Phase 3:** Components properly used ✓
- [ ] **Phase 4:** Accessibility verified ✓
- [ ] **Phase 5:** Layout & alignment correct ✓
- [ ] **Phase 6:** Screen-specific requirements met ✓
- [ ] **Phase 7:** Visual quality approved ✓
- [ ] **Phase 8:** Screenshots & docs prepared ✓
- [ ] **Phase 9:** Final approval obtained ✓
- [ ] **Phase 10:** Handoff deliverables ready ✓

---

**Checklist Version:** 1.0  
**Last Updated:** May 12, 2026  
**Next Step:** Agent Design Completion → Verification Phase
