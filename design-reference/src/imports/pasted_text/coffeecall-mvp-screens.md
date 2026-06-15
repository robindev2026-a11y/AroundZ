# CoffeeCall MVP — Screen Content & Interactions

**For:** Figma AI / Pencil / Antigravity IDE  
**Purpose:** Exact copy, layouts, and interactions for each screen  
**Usage:** Feed this + component specs to Figma AI to generate prototype

---

## SCREEN 1: Auth Flow (6 Steps)

### Step 1.1: Welcome Screen

**Layout:** Full screen, centered content

| Element | Content | Style | Color |
|---------|---------|-------|-------|
| **Logo/Icon** | CoffeeCall (or coffee icon) | Heading 1, bold | Black #0F172A |
| **Headline** | "Find activities nearby" | Heading 2 | Black #0F172A |
| **Subheading** | "Meet people. Do things. Together." | Body 2 | Dark Gray #475569 |
| **Hero Image** | Illustration: Coffee + people | — | — |
| **CTA Button** | "Continue with Phone" | Primary Button | Blue #3B82F6 |
| **Footer** | "By continuing, you agree to our Terms" | Caption | Dark Gray #475569 |

**Layout Rules:**
- Logo/heading: Centered, 40px from top
- Hero image: 200x200px, centered
- Button: 100% width - 32px padding, 44px height, 24px from bottom

---

### Step 1.2: Phone Entry

**Layout:** Form focused, numeric keyboard

| Element | Content | Style | Placeholder |
|---------|---------|-------|-------------|
| **Header** | "What's your number?" | Heading 2 | — |
| **Subtext** | "We'll send you a verification code" | Body 2 | Dark Gray #475569 |
| **Country Code** | "+1" (dropdown) | Body 1 | — |
| **Phone Input** | [text field] | Input Field | "(555) 123-4567" |
| **Hint** | "Standard SMS rates apply" | Caption | Dark Gray #475569 |
| **CTA Button** | "Send Code" | Primary Button | Blue #3B82F6 |
| **Back Link** | "← Back" | Body 2 link | Dark Gray #475569 |

**Layout Rules:**
- Header: 40px from top
- Inputs: 100% width, 16px padding horizontal
- Gap between inputs: 16px
- Button: 100% width, 24px from bottom

**Interactions:**
- Tap country code dropdown → show country selector
- Type in phone field → auto-format (e.g., "(555) 123-4567")
- Phone invalid → disable "Send Code" button
- Tap "Send Code" → Show OTP screen

---

### Step 1.3: OTP Verification

**Layout:** 6-digit code entry

| Element | Content | Style | Notes |
|---------|---------|-------|-------|
| **Header** | "Enter verification code" | Heading 2 | — |
| **Subtext** | "We sent a code to +1 (555) 123-4567" | Body 2 | Dark Gray #475569 |
| **Change Number Link** | "Wrong number?" | Body 2 link | Clickable |
| **Code Input** | [6 boxes] | — | Auto-focus, numeric only |
| **Resend Timer** | "Resend code in 00:45" | Caption | Dark Gray #475569 |
| **Resend Link** | "Send code again" | Body 2 link | Disabled initially, enabled after timer |
| **CTA Button** | "Verify" | Primary Button (disabled until 6 digits) | Blue #3B82F6 |

**Layout Rules:**
- Header: 40px from top
- Code boxes: 6 boxes, each 44x56px, 8px gap
- Centered horizontally
- Resend link: 16px below code boxes
- Button: 100% width, 24px from bottom

**Interactions:**
- Type digit → auto-move focus to next box
- Backspace on empty box → move focus to previous box
- All 6 digits entered → enable "Verify" button
- Tap "Verify" → Validate OTP, on success go to Screen 1.4

---

### Step 1.4: Create Profile

**Layout:** Photo upload + name input

| Element | Content | Style | Default |
|---------|---------|-------|---------|
| **Header** | "Create your profile" | Heading 2 | — |
| **Photo Upload** | [Circular frame, 120x120px] | Avatar Large | Placeholder: camera icon |
| **Upload Options** | "Take Photo" / "Choose from Library" | Caption links | Clickable |
| **Name Input** | [text field] | Input Field | "Enter your name" |
| **Name Hint** | "This is how others will see you" | Caption | Dark Gray #475569 |
| **CTA Button** | "Next" | Primary Button | Blue #3B82F6 |
| **Back Button** | "← Back" | Secondary Button | Ghost |

**Layout Rules:**
- Header: 32px from top
- Photo circle: Centered, 120x120px
- Upload links: Below photo, 16px gap
- Name input: Full width, 24px from photo
- Gap between elements: 16px
- Button: 100% width, 24px from bottom

**Interactions:**
- Tap photo circle → Show camera/library picker
- Upload photo → Crop/preview circle
- Type name → Enable "Next" when name length > 1
- Tap "Next" → Screen 1.5

---

### Step 1.5: Enable Location & Notifications

**Layout:** Two stacked permission cards

| Element | Content | Style | Color |
|---------|---------|-------|-------|
| **Header** | "We need a couple of permissions" | Heading 2 | Black #0F172A |
| **Card 1 Icon** | 📍 Location | — | — |
| **Card 1 Title** | "Allow Location Access" | Heading 3 (22px semibold) | Black #0F172A |
| **Card 1 Text** | "So we can find activities near you" | Body 2 | Dark Gray #475569 |
| **Card 1 Button** | "Allow While Using App" | Primary Button | Blue #3B82F6 |
| **Card 1 Secondary** | "Allow Once" | Secondary Button (small) | Ghost |
| **Card 2 Icon** | 🔔 Notifications | — | — |
| **Card 2 Title** | "Enable Notifications" | Heading 3 (22px semibold) | Black #0F172A |
| **Card 2 Text** | "Get notified when activities match" | Body 2 | Dark Gray #475569 |
| **Card 2 Button** | "Allow" | Primary Button | Blue #3B82F6 |
| **Card 2 Secondary** | "Not Now" | Secondary Button (small) | Ghost |

**Layout Rules:**
- Header: 32px from top
- Cards: 100% width - 16px padding, 20px gap between
- Card padding: 20px internal
- Card border radius: 12px
- Card background: Light Gray #F3F4F6

**Interactions:**
- Tap "Allow While Using App" → Request location permission (native OS)
- Tap "Allow" (notifications) → Request notification permission (native OS)
- Both allowed → Proceed to Screen 1.6 automatically
- Either denied → Show "Not Now" option, allow skip

---

### Step 1.6: All Set

**Layout:** Success celebration

| Element | Content | Style | Color |
|---------|---------|-------|-------|
| **Icon** | ✓ (large checkmark) | — | Teal #0F766E |
| **Heading** | "You're all set!" | Heading 1 (28px bold) | Black #0F172A |
| **Subtext** | "Ready to find activities?" | Body 1 | Dark Gray #475569 |
| **CTA Button** | "Start Exploring" | Primary Button | Blue #3B82F6 |

**Layout Rules:**
- Checkmark: 80x80px, centered, 60px from top
- Heading: Centered below icon
- Subtext: Centered below heading, 16px gap
- Button: 100% width, 24px from bottom

**Interactions:**
- Tap "Start Exploring" → Navigate to Screen 2 (Discovery)

---

## SCREEN 2: Discovery/Notifications List

**Navigation:** Default tab (Tab 1)  
**Scroll:** Vertical, infinite scroll (loads more as user scrolls)

### Top Bar

| Element | Content | Style | Notes |
|---------|---------|-------|-------|
| **Title** | "Nearby activities" | Heading 1 | Black #0F172A |
| **Filter Icon** | 🔽 (dropdown) | — | Tap to change radius |
| **Radius Selector** | "5 km" / "2 km" / "1 km" | Body 2 dropdown | Shows selected |

### Counter Bar

| Element | Content | Style | Updates |
|---------|---------|-------|---------|
| **Count Text** | "12 activities within 5 km" | Body 2 | Real-time |
| **Last Update** | "updated just now" | Caption | Timestamp |

### Activity Card (Repeating)

**Layout:** Horizontal card layout

| Element | Content | Example | Style |
|---------|---------|---------|-------|
| **Avatar** | User photo circle | [32x32px] | Avatar Small |
| **Name** | User's name | "Alex" | Body 1, semibold |
| **Activity Type** | Activity emoji + name | "☕ Coffee" | Body 2 |
| **Distance** | Distance away | "0.8 km away" | Caption, Dark Gray |
| **Location** | Street address | "Downtown Brew House" | Body 2 |
| **Time** | When activity is | "In 30 minutes" | Caption, Dark Gray |
| **Accept Button** | "Accept" | — | Primary Button (smaller variant) |
| **Skip Button** | "Skip" | — | Secondary Button (smaller variant) |
| **Divider** | Separator line | — | Light Gray #F3F4F6 |

**Card Layout Rules:**
- Padding: 16px
- Avatar: Left, 32x32px
- Name + info: Right of avatar (flex column)
- Accept/Skip: Below info, 8px gap
- Buttons: 48px height (or smaller variant)
- Divider: 1px Light Gray between cards

**Interactions:**
- Swipe card left (iOS) → "Skip" (optional for v1.1)
- Tap "Accept" → Show Screen 4 (Acceptance Confirmation)
- Tap "Skip" → Hide card, load next
- Scroll to bottom → Load more activities
- Tap name/avatar → Show Screen 5 (Full Profile, v1.1)

### Empty State

| Element | Content | Style |
|---------|---------|-------|
| **Icon** | 😴 (sleeping face) | 64x64px |
| **Headline** | "No activities nearby" | Heading 2 |
| **Subtext** | "Come back soon or create one yourself!" | Body 2 |
| **CTA** | "Create Activity" | Primary Button |

---

## SCREEN 3: Post Activity Modal

**Trigger:** FAB (+) button on Discovery screen  
**Overlay:** Black 50% opacity background

### Modal Container

| Element | Content | Style | Width |
|---------|---------|-------|-------|
| **Header** | "Create Activity" | Heading 2 | — |
| **Close Button** | ✕ | — | Top right |

### Form Fields (Stacked)

#### Field 1: Activity Type

| Element | Content | Style | Notes |
|---------|---------|-------|-------|
| **Label** | "What activity?" | Body 2, semibold | Dark Gray #475569 |
| **Selector** | [Grid: Coffee, Movie, Walk, Study, Work, Food, Bike, Jog] | Chips | 2 columns |

**Chip States:**
- Unselected: Light Gray #F3F4F6 background
- Selected: Teal #0F766E background, white text

#### Field 2: Time

| Element | Content | Style | Notes |
|---------|---------|-------|-------|
| **Label** | "When?" | Body 2, semibold | Dark Gray #475569 |
| **Default** | "Now" (or time picker) | Body 1 | Tappable dropdown |
| **Options** | "In 15 mins", "In 30 mins", "In 1 hour", "Specific time" | Body 2 | Dropdown menu |

#### Field 3: Location

| Element | Content | Style | Notes |
|---------|---------|-------|-------|
| **Label** | "Where?" | Body 2, semibold | Dark Gray #475569 |
| **Location Text** | "Downtown Brew House, Boston, MA" | Body 1 | Pre-filled from GPS |
| **Change Button** | "Change location" | Body 2 link, Blue | Tap to open map picker |

#### Field 4: Duration

| Element | Content | Style | Notes |
|---------|---------|-------|-------|
| **Label** | "How long?" | Body 2, semibold | Dark Gray #475569 |
| **Default** | "1 hour" | Body 1 | Dropdown |
| **Options** | "30 mins", "1 hour", "2 hours", "3 hours", "Custom" | Body 2 | Dropdown menu |

### Actions

| Element | Content | Style | Width |
|---------|---------|-------|-------|
| **CTA Button** | "Go Live" | Primary Button | 100% width |
| **Back/Cancel** | Cancel or back arrow | Ghost Button | Optional |

**Layout Rules:**
- Modal padding: 24px
- Label to field gap: 8px
- Field to field gap: 20px
- Button gap: 24px from last field
- All inputs: 100% width - padding

**Interactions:**
- Tap activity chip → Select (highlight Teal)
- Tap time field → Show time picker dropdown
- Tap location → Open map picker modal
- Tap duration → Show dropdown
- All fields valid → Enable "Go Live" button
- Tap "Go Live" → POST to Firebase, close modal, return to Discovery

---

## SCREEN 4: Acceptance Confirmation Dialog

**Trigger:** User taps "Accept" on activity card  
**Overlay:** Black 50% opacity background

### Modal Content (Centered)

| Element | Content | Example | Style |
|---------|---------|---------|-------|
| **Avatar** | Poster's photo | [64x64px circle] | Avatar Large, centered |
| **Name** | Poster's name | "Alex" | Heading 2, centered |
| **Age** | Age if provided | "28" | Body 2, centered, optional |
| **Spacer** | — | — | 20px |
| **Activity Section** | — | — | — |
| **Activity Icon** | ☕ | — | 32x32px, centered |
| **Activity Type** | Coffee | — | Body 1, centered |
| **Location** | Downtown Brew House | — | Body 2, centered |
| **Time** | In 30 minutes | — | Body 2, centered |
| **Distance** | 0.8 km away | — | Caption, centered |
| **Spacer** | — | — | 20px |
| **Commitment Text** | "You'll be notified when you match. Then you can message to coordinate." | — | Body 2, centered, teal/info color |
| **Spacer** | — | — | 24px |
| **Confirm Button** | "Confirm" | — | Primary Button, full width |
| **Cancel Button** | "Cancel" | — | Secondary Button, full width |

**Layout Rules:**
- Modal width: 90% of screen, max 400px
- Modal padding: 24px
- All content centered
- Avatar: 64x64px
- Button gap: 12px
- Both buttons: 44px height

**Interactions:**
- Tap "Confirm" → Create acceptance record in Firebase, show Screen 5 (Match Confirmed)
- Tap "Cancel" or tap outside → Close modal, return to Discovery

---

## SCREEN 5: Match Confirmed

**Trigger:** Both users accept OR immediate success state after user accepts  
**Display:** Full screen modal or transition screen

| Element | Content | Example | Style |
|---------|---------|---------|-------|
| **Background** | Teal success background | — | Teal #0F766E or Light Blue #E0F2FE |
| **Icon** | ✓ Checkmark or confetti | — | Large, animated (optional) |
| **Headline** | "You matched with Alex!" | — | Heading 1, white or black |
| **Activity Summary** | "☕ Coffee at Downtown Brew House" | — | Body 1 |
| **Time** | "In 30 minutes (1 hour duration)" | — | Body 2 |
| **Spacer** | — | — | 20px |
| **Avatars** | Both user photos side-by-side | [32x32px each] | Avatar Small, centered |
| **Map Preview** | Optional small location map | — | Small card (v1.1+) |
| **CTA Text** | "Message Alex to coordinate" | — | Body 2 |
| **CTA Button** | "Open Messages" | — | Primary Button |
| **Secondary Button** | "Keep Exploring" | — | Secondary Button |

**Layout Rules:**
- Full screen or 90% width modal
- Centered content
- Spacing: 20-24px between sections
- Buttons: 100% width or side-by-side

**Interactions:**
- Tap "Open Messages" → Navigate to Screen 6 (Messages with that user)
- Tap "Keep Exploring" → Return to Discovery (Screen 2)
- Auto-dismiss after 3 seconds (optional) and navigate to Messages

---

## SCREEN 6: Messages Thread

**Navigation:** Messages tab OR opened from Screen 5

### Top Bar

| Element | Content | Style | Notes |
|---------|---------|-------|-------|
| **Back Button** | ← | Secondary Button | iOS only |
| **User Name** | "Alex" | Heading 2 | Center |
| **Status** | "Online 🟢" or "Offline" | Caption, Teal or Gray | Right |
| **Info Button** | ℹ️ | — | Optional (v1.1+) |

### Activity Summary Card (Optional, Top)

| Element | Content | Style |
|---------|---------|-------|
| **Activity** | "☕ Coffee at Downtown Brew House" | Body 2 |
| **Time** | "In 20 minutes" | Caption |

### Message List (Scrollable)

#### Received Message

| Element | Content | Style | Alignment |
|---------|---------|-------|-----------|
| **Bubble** | Gray background | Message Bubble | Left |
| **Text** | "Hey, see you soon?" | Body 2, black | Left-aligned text |
| **Timestamp** | "3:45 PM" | Caption | Below bubble |

#### Sent Message

| Element | Content | Style | Alignment |
|---------|---------|-------|-----------|
| **Bubble** | Blue background | Message Bubble | Right |
| **Text** | "Yep! I'll be there in 10" | Body 2, white | Right-aligned text |
| **Timestamp** | "3:46 PM" | Caption | Below bubble |

**Layout Rules:**
- Padding: 16px sides, 12px between message groups
- Bubble max-width: 80% of screen
- Bubble padding: 12px horizontal, 8px vertical
- Border radius: 16px
- Timestamp: 8px below bubble, centered under bubble

**Interactions:**
- Scroll up → Load earlier messages (if available)
- Scroll down → Auto-scroll to latest message when new message arrives

### Input Area (Bottom)

| Element | Content | Style | Layout |
|---------|---------|-------|--------|
| **Text Input** | [text field] | Input Field | Flex grow |
| **Send Button** | ✈️ (paper plane icon) | Coral Button | Right |

**Layout Rules:**
- Fixed at bottom
- Padding: 16px
- Input height: 40px
- Input flex: 1
- Send button: 40x40px, Coral #FF7A59
- Gap: 8px between input and button

**Interactions:**
- Type in input → Enable send button
- Tap send button → POST message to Firebase, clear input, display message in thread
- Messages load in real-time or when opening thread (async, 2-5 second latency OK)

---

## SCREEN 7: My Activities Dashboard

**Navigation:** "My Activities" tab

### Top Bar & Header

| Element | Content | Style |
|---------|---------|-------|
| **Title** | "Your Activities" | Heading 1 |
| **New Activity Button** | "+ New Activity" | Primary Button or FAB |

### Section 1: Active Posts

| Element | Content | Example | Style |
|---------|---------|---------|-------|
| **Section Title** | "Active Posts" | — | Heading 2 |
| **Post Card** | — | — | — |
| **Activity Type** | Coffee | — | Body 1, semibold |
| **Location** | Downtown Brew House | — | Body 2 |
| **Time** | In 30 minutes | — | Caption |
| **Acceptance Count** | "3 people accepted" | — | Teal badge or bold text |
| **Expand Icon** | > | — | Disclosure arrow |

**Expand Action (on tap):**
- Show list of acceptors below card:

| Element | Content | Example | Style |
|---------|---------|---------|-------|
| **Acceptor Row** | [Avatar] Name • Accepted 10 mins ago | [32px avatar] Alex • Accepted 10 mins ago | Body 2 |
| **Status** | "Waiting" / "Confirmed" | — | Caption, Teal |

### Section 2: Completed

| Element | Content | Example | Style |
|---------|---------|---------|-------|
| **Section Title** | "Completed" | — | Heading 2 |
| **Post Card** | — | — | — |
| **Activity Type** | Movie | — | Body 1, semibold |
| **Final Count** | "2 people joined" | — | Body 2 |
| **Date** | "May 11" | — | Caption |

### Empty State

| Element | Content | Style |
|---------|---------|-------|
| **Icon** | 📝 | 64x64px |
| **Headline** | "No activities posted yet" | Heading 2 |
| **Subtext** | "Create one to get started!" | Body 2 |
| **CTA** | "+ Create Activity" | Primary Button |

**Layout Rules:**
- Padding: 16px
- Section spacing: 24px
- Card padding: 16px, border radius 12px
- Gap between cards: 12px

**Interactions:**
- Tap "New Activity" → Show Screen 3 (Post Activity Modal)
- Tap post card → Expand to show acceptors
- Tap acceptor name → Show their profile (v1.1+)

---

## SCREEN 8: Profile View

**Navigation:** Profile tab

### Header

| Element | Content | Style | Size |
|---------|---------|-------|------|
| **Photo** | User's profile photo | Avatar Large | 80x80px |
| **Name** | "Your Name" | Heading 1 | — |
| **Edit Profile Button** | "Edit Profile" | Body 2 link, Blue | — |

### Activity Interests

| Element | Content | Style |
|---------|---------|-------|
| **Label** | "Interested in" | Body 2, semibold |
| **Chips** | Coffee, Movie, Walk, etc. | Chips, selected state |

### Stats

| Element | Content | Example | Style |
|---------|---------|---------|-------|
| **Posts Created** | Posts created | "5" (with label) | Body 1 |
| **Activities Attended** | Activities attended | "3" (with label) | Body 1 |

**Layout Rules:**
- Stat cards: Flex row, equal width, 16px padding each
- Dividers: Light gray between stats

### Edit & Settings Section

| Element | Content | Style | Icon |
|---------|---------|-------|------|
| **Edit Profile** | Change photo, name | Body 1 link, Blue | ✏️ |
| **Notifications** | Push notification settings | Body 1 link | 🔔 |
| **Privacy** | Location privacy, visibility radius | Body 1 link | 🔒 |
| **Logout** | Sign out of app | Body 1 link, Coral | 🚪 |

**Layout Rules:**
- Padding: 16px
- Dividers: Light gray between options
- Icons: Left-aligned, 24x24px
- Text: Right side

**Interactions:**
- Tap "Edit Profile" → Modal to edit name, photo (v1.1+)
- Tap "Notifications" → Toggle notification types
- Tap "Privacy" → Show visibility radius selector
- Tap "Logout" → Confirm dialog, then sign out

### Empty State (No Profile Data)

| Element | Content | Style |
|---------|---------|-------|
| **Icon** | 👤 | 64x64px |
| **Headline** | "Complete your profile" | Heading 2 |
| **Subtext** | "Add a photo and name so others know who you are" | Body 2 |
| **CTA** | "Edit Profile" | Primary Button |

---

## BOTTOM NAVIGATION (All Screens)

**Fixed at bottom, always visible**

| Tab | Icon | Label | Active Color | Inactive Color |
|-----|------|-------|--------------|----------------|
| **Discover** | 🔍 | Discover | Teal #0F766E | Dark Gray #475569 |
| **Post** | ➕ | Post | Teal #0F766E | Dark Gray #475569 |
| **My Activities** | 📋 | My Activities | Teal #0F766E | Dark Gray #475569 |
| **Messages** | 💬 | Messages | Teal #0F766E | Dark Gray #475569 |
| **Profile** | 👤 | Profile | Teal #0F766E | Dark Gray #475569 |

**Layout Rules:**
- Height: 60px (iOS safe area included)
- Icons: 24x24px
- Labels: Caption (12px)
- Active: Teal bottom border (3px) + text Teal
- Inactive: Gray text

**Interactions:**
- Tap tab → Navigate to that screen
- Show notification badge on Messages tab (if new messages)

---

## Global Interactions & Rules

### Navigation Transitions
- Tab switching: Instant (no animation)
- Modal open: Slide up from bottom (300ms)
- Modal close: Slide down (200ms)
- Screen transitions: Slide left/right (iOS native, 300ms)

### States & Feedback
- Button tap → State change immediately (visual feedback)
- Form field focus → Border Blue #3B82F6, glow shadow
- Disabled button → Light Gray #F3F4F6, text unreadable
- Error state → Coral #FF7A59 border/text

### Validation Rules
- Phone number: Must be valid E.164 format
- OTP: Must be 6 digits
- Name: Must be > 1 character
- Activity type: Must select 1
- Location: Auto-filled, user can edit
- Duration: Must select 1
- Accept/Skip buttons: Always available

---

**Last Updated:** 2026-05-12  
**Status:** Ready for Figma AI generation  
**Companion Documents:**
- `CoffeeCall_MVP_Design_Brief.md`
- `CoffeeCall_MVP_Component_Specs.md`
