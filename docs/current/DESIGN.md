# CoffeeCall Design Contract

Status: ACTIVE
Last updated: 2026-05-17

This is the single active design contract for CoffeeCall. If another file disagrees with this file, follow this file and report the conflict.

## Design Personality

CoffeeCall should feel warm, social, safe, premium, and native iOS. The experience is activity-first: users notice nearby energy, choose a Drift, and coordinate with context.

Do not design CoffeeCall like a dating app, coffee ordering app, enterprise dashboard, task manager, or generic blue-and-white startup interface.

## Social Refresh Tokens

- **Core Rule: Never write raw HEX string literals or RGB/HSL/HSB parameters inside SwiftUI screen views.** All colors must be mapped physically as named color assets in `Assets.xcassets` and referenced in code via static properties under `Color` (bridged through `AppColors.swift` and `Color+Extensions.swift`). This preserves 100% native Dark Mode and Light Mode asset handling!

| Role | Asset Name | Hex | Usage |
|---|---|---:|---|
| Primary mint | `coffeePrimary` | `#53B8A6` | Primary actions, active controls, key accents |
| Pressed mint | `coffeePrimaryDark` | `#3D8D7A` | Pressed primary state |
| Lavender | `coffeePurple` | `#8E7DBE` | Secondary accent |
| Peach | `coffeePeach` | `#E88C6B` | Warm accent |
| Warm background | `coffeeBackground` | `#F6F1EB` | Main app background |
| Card surface | `coffeeSurface` | `#FFFDF9` | Cards, sheets, elevated panels |
| Secondary surface | `coffeeSurfaceSecondary` | `#F4F4F8` | Inputs and subtle panels |
| Primary text | `coffeeTextPrimary` | `#243447` | Titles and main body text |
| Secondary text | `coffeeTextSecondary` | `#5F6368` | Captions, metadata, helper text |
| Border | `coffeeBorder` | `#E7DED4` | Separators and subtle outlines |
| Success | `coffeeSuccess` | `#10B981` | Success confirmations only |
| Error | `coffeeError` | `#DE4545` | Destructive/error states only |

## Typography

- CoffeeCall uses a hybrid typography system: **Outfit** for headlines/display elements, and **SF Pro** (system) for body/micro copy.
- **Outfit** (geometric sans-serif) is used for headers, active buttons, and badges to give the app a premium, warm, social community feel.
- **SF Pro** (iOS system default) is used for all core UI lists, body paragraphs, and small metadata labels to guarantee native screen legibility and platform alignment.
- All fonts must support **Dynamic Type auto-scaling** relative to iOS semantic styles.
- Suggested scale (Dynamic Type base sizes):
  - H1 (heading1): 28pt, Black (Outfit), relative to `.title`.
  - H2 (heading2): 20pt, Black (Outfit), relative to `.title2`.
  - Body (bodyStandard): 15pt, Medium (SF Pro System), relative to `.body`.
  - Body Bold (bodyBold): 15pt, Black (SF Pro System), relative to `.body`.
  - Body Small (bodySmall): 12pt, Bold (SF Pro System), relative to `.subheadline`.
  - Caption (captionText): 12pt, Bold (SF Pro System), relative to `.caption1`.
  - Metadata (metadata): 10pt, Bold (SF Pro System), relative to `.caption2`.
  - Micro (micro): 9pt, Black (SF Pro System), relative to `.caption2`.
  - Button (buttonText): 17pt, Black (Outfit), relative to `.headline`.

### Engineering Rules for Dynamic Type Scaling

To support Dynamic Type scaling without breaking layouts, all screens must adhere to these engineering rules:

1. **Never Rigidly Set Frame Heights on Text Containers**:
   Avoid setting absolute `.frame(height: 50)` on buttons, text rows, or input fields. Use vertical padding so the container naturally expands as font size scales:
   ```swift
   // ❌ WRONG (crops text when system text scales):
   Text("Join Drift").frame(height: 50)
   
   // ✅ CORRECT (expands naturally):
   Text("Join Drift").padding(.vertical, 16)
   ```

2. **Scale Spacing Dynamically Using @ScaledMetric**:
   If layout spacing or custom paddings are hardcoded, larger text sizes will cause overlapping. Wrap layout spacing in a `@ScaledMetric` so it grows with the text:
   ```swift
   @ScaledMetric(relativeTo: .body) var cardPadding: CGFloat = 16
   ```

3. **Wrap Long Text in Responsive Layouts**:
   Ensure text views are allowed to wrap by avoiding unnecessary `.lineLimit(1)` on body copy, and use flexible stacks (`VStack` instead of rigid `HStack`) for metadata tags.

## Spacing, Radius, And Effects

- **Core Rule: Never write raw/hardcoded visual padding, margins, heights, or spacing values inside screen views.** Every size must be referenced semantically through the centralized `AppConstants.Layout` or `AppConstants.UI` tokens, maintaining a strict Hybrid Scale System under the hood.
- Base spacing grid: 8, 16, 24, 32, 48pt (configured privately under `AppConstants.Grid` and mapped to specific surface layout tokens).
- Screen horizontal padding: 20pt for primary mobile screens (`AppConstants.Layout.standardPadding`).
- Radius:
  - Small controls: 8pt / 12pt (`UI.cornerRadiusSmall`).
  - Cards: 16-24pt (`UI.cornerRadiusMedium`).
  - Large soft cards and sheets: 24-32pt (`UI.cornerRadiusLarge`).
  - Avatars and icon wells: circular.
- Shadows are soft and slate-tinted, never heavy black.
- Glass surfaces use iOS material-style blur with subtle border highlights.

## Shared Screen Components

These components are reused across primary app screens. Screen specs may define content, active state, and actions, but should not reinvent the base visual treatment.

### Floating Glass Top Header

- Use on primary tab screens such as Around, Drifts, Chats, and You.
- Floating glass card, not a solid navbar.
- Horizontal margin: 20pt.
- Top placement: below safe area/status bar with comfortable breathing room.
- Height: 82pt by default.
- Corner radius: 30pt.
- Subtle 1pt light border or highlight stroke.
- Soft slate-tinted shadow.
- Title: screen-specific title, 32pt heavy/bold, primary text.
- Subtitle: screen-specific subtitle, 16pt regular/medium, secondary text.
- Right action: circular button specific to the screen.
- Right action size: 52-56pt.
- Badge, when needed, anchors to the right action's upper-right edge.
- Do not make this a tall hero block, split media header, or standard solid iOS navigation bar.

Screen-specific content:

| Screen | Title | Subtitle | Right action |
|---|---|---|---|
| Around | `Around` | `Plans forming nearby` | Notification button with badge |
| Drifts - Nearby | `Drifts` | `Plans you can join` | Filter button |
| Drifts - My Drifts | `Drifts` | `Your active plans` | Filter button |
| Chats | `Chats` | `Drift conversations` | Optional search/filter button |
| You | `You` | `Your profile and plans` | Settings button |

## Core UX Rules

- Activity first, person second.
- Drifts are the action object.
- No direct person pings.
- No cold message button.
- No public people list from Around.
- No phone number display in MVP.
- Chat appears only after joining or hosting a Drift.
- Exact meeting details stay inside Drift detail/chat after joining.

## Around Screen: Active First Screen

Around is the first screen after login.

### Intent

Around is a soft discovery surface. It should communicate that plans are forming nearby, then guide users to:

- open concrete nearby Drifts, or
- create a Drift through the center Create action.

### Screen Structure

Target iPhone planning size: 393 x 852pt.

1. Floating glass top header.
2. Ambient radar field.
3. Circular refresh control.
4. Drift context card.
5. Two-row interests grid.
6. Floating glass bottom navigation.

### Top Header

- Use the shared Floating Glass Top Header.
- Title: `Around`.
- Subtitle: `Plans forming nearby`.
- Right actions: circular Online/Offline presence toggle plus circular notification button.
- Presence toggle: icon-only button; Online uses mint active treatment, Offline uses muted/private treatment. It must not expose extra public profile details.

### Radar

- Height target: 330pt.
- No heavy enclosing card.
- Three soft rings labeled `0.8 mi`, `0.6 mi`, and `0.3 mi`.
- Center bubble: 72 x 72pt, icon and label `You`.
- Nearby anonymous bubbles: 46 x 46pt with initials such as `LM`, `DK`, `MR`, `NP`, `AL`.
- Bubbles may be backed by nearby user presence, but they are presented as ambient activity signals rather than profile cards.
- Users who set presence Offline must not appear in other users' radar snapshots.
- Tapping a radar element must not open a profile or direct message. Instead, it presents a small floating interest card anchored near the bottom of the radar showing only the anonymous active interests (e.g., "Coffee & Walks").

### Refresh Control

- Circular glass button.
- Size: 58 x 58pt.
- Lower-right of radar area.
- Mint refresh icon.

### Drift Context Card

- Horizontal margin: 20pt.
- Height: 88pt.
- Corner radius: 26pt.
- Surface: card surface or glass card.
- Leading mint icon well: 52 x 52pt.
- Title: `Nearby Drifts are forming`.
- Body: `Join one or create your own.`
- CTA: `See nearby Drifts`.
- CTA routes to the Drifts listing.

### Interests Grid

- Section title: `Your interests nearby`.
- Layout: 4 columns x 2 rows.
- Card size target: 79 x 112pt on 393pt width.
- Column gap: 12pt.
- Row gap: 14pt.
- Corner radius: 22pt.
- Cards:
  - Coffee, `3 nearby`, mint cup icon.
  - Walks, `4 nearby`, mint walking icon.
  - Movies, `2 nearby`, lavender film icon.
  - Food, `5 nearby`, peach food icon.
  - Music, `3 nearby`, warm music icon.
  - Gaming, `2 nearby`, amber game icon.
  - Books, `2 nearby`, soft blue book icon used sparingly.
  - Workout, `4 nearby`, lavender fitness icon.
- Tapping an interest filters or routes to Drifts for that category.
- It must not open a people list.

### Bottom Navigation

- Floating glass pill.
- Horizontal margin: 20pt.
- Height: 78pt.
- Corner radius: 34pt.
- Tabs: Around, Drifts, Create, Chats, You.
- Around is active in mint on this screen.
- Center Create is a mint circular plus action.
- Create remains reserved for a future sheet design and should not be treated as implemented.
- Content must have enough bottom inset so the grid does not hide behind the bar.

## Drifts Screen: Active Listing Screen

Drifts is the concrete meetup surface. It is where users move from ambient interest into specific nearby plans, and where they can quickly return to Drifts they host or have joined.

### Intent

The Drifts screen must answer two questions immediately:

- What nearby Drifts can I join?
- What Drifts am I already hosting, joining, or waiting on?

This screen is not a people browser. Cards may show host context and participant counts, but they must not expose cold direct messaging or profile browsing as the primary action.

### Entry Points

- Bottom nav `Drifts` opens this screen with `Nearby` selected by default.
- Around card CTA `See nearby Drifts` opens this screen with `Nearby` selected.
- Interest cards on Around open this screen with `Nearby` selected and a category filter applied.
- Profile or status surfaces may deep link to this screen with `My Drifts` selected.

### Screen Structure

Target iPhone planning size: 393 x 852pt.

1. Floating glass top header.
2. Two-option access switch: `Nearby` and `My Drifts`.
3. Optional search/filter row.
4. Active list content.
5. Floating glass bottom navigation.

### Top Header

- Use the shared Floating Glass Top Header.
- Title: `Drifts`.
- Subtitle for `Nearby`: `Plans you can join`.
- Subtitle for `My Drifts`: `Your active plans`.
- Right action: circular filter button, 52 x 52pt.
- Filter button opens a compact sheet for category, time, and distance refinement.

### Access Switch

- Position: 16pt below the header.
- Horizontal margin: 20pt.
- Height: 48pt.
- Shape: glass or card-surface pill.
- Radius: 24pt.
- Options:
  - `Nearby`
  - `My Drifts`
- Active segment uses primary mint fill or mint text on a soft mint surface.
- Inactive segment uses secondary text.
- The switch is mandatory. Do not hide `My Drifts` behind a profile screen or overflow menu.

### Nearby Drifts List

Nearby is the default tab. It shows active, joinable Drifts within the 10 km discovery radius.

#### Filter Row

- Horizontal margin: 20pt.
- Top spacing from access switch: 14pt.
- Height: 36-40pt.
- Horizontal chip row.
- Default chips:
  - `All`
  - `Coffee`
  - `Walks`
  - `Food`
  - `Movies`
  - `Today`
- Active chip uses mint-tinted fill and primary mint text.
- Chips filter Drifts, not people.

#### Drift Card

- Horizontal margin: 20pt.
- Width: fill.
- Minimum height: 132pt.
- Corner radius: 24pt.
- Surface: card surface or subtle glass.
- Border: `#E7DED4` at 1pt or equivalent subtle divider.
- Vertical gap between cards: 14pt.
- Card content:
  - Leading icon well: 48 x 48pt, circular, category color.
  - Title/purpose: 18pt semibold/bold, primary text.
  - Time chip: 12-14pt semibold, e.g. `Today 6:30 PM`.
  - Approximate location: secondary text, e.g. `0.8 mi away` or `Near Indiranagar`.
  - Participant signal: `2 joined`, `4 spots open`, or `Group forming`.
  - Optional hook preview: one line, secondary text.
  - Primary action: `View Drift`.
- Pre-join cards must not show exact meeting coordinates, phone number, or chat button.
- `View Drift` opens Drift Detail. Join/request happens in Drift Detail unless a future approved spec allows inline join.

### My Drifts List

My Drifts gives direct access to Drifts the user hosts, has joined, or has requested to join.

#### My Drifts States

- `Hosting`: user created the Drift.
- `Joined`: user is accepted or already participating.
- `Requested`: user asked to join and is waiting.
- `Past`: optional future section, not required for MVP.

#### My Drift Card

- Horizontal margin: 20pt.
- Width: fill.
- Minimum height: 124pt.
- Corner radius: 24pt.
- Surface: card surface.
- Status chip at top right:
  - `Hosting` uses mint.
  - `Joined` uses lavender.
  - `Requested` uses peach.
- Card content:
  - Title/purpose.
  - Time.
  - Approximate or unlocked location depending on state.
  - Participant count.
  - Next action.
- Next actions:
  - Hosting: `Manage`.
  - Joined: `Open Chat`.
  - Requested: `View Request`.
- Chat is visible only for hosted or joined Drifts.
- Requested Drifts must not expose chat until accepted.

### Empty States

Nearby empty state:

- Title: `No Drifts nearby yet`.
- Body: `Start one and nearby people can join.`
- Primary action: `Create` is reserved for future sheet UX.
- Keep this compact and inside the Drifts screen. The center bottom nav Create action remains the main global create affordance.

My Drifts empty state:

- Title: `No active Drifts`.
- Body: `Joined and hosted Drifts will appear here.`
- Secondary action: `Browse Nearby`, switching back to `Nearby`.

### Bottom Navigation

- Same floating glass pill as Around.
- Tabs: Around, Drifts, Create, Chats, You.
- Drifts is active in mint on this screen.
- Center Create remains a mint circular plus action.
- Create is a pending sheet UX design item.
- List content must include enough bottom inset so the last card can scroll above the nav.

### Interaction Rules

- Tapping a card opens Drift Detail.
- Tapping `Manage` opens Drift Detail in host mode.
- Tapping `Open Chat` opens the Drift-tied chat only when the user is hosting or joined.
- Tapping `Requested` or `View Request` opens Drift Detail with pending status.
- No card should offer a cold message, phone call, user profile jump, follower action, or public people list.
- Pull to refresh is allowed and should use subtle native motion.

### Visual Notes

- The screen should feel like a companion to Around, not a separate dashboard.
- Use warm background, glass header, mint primary actions, and lavender/peach as status accents.
- Avoid map-first browsing in MVP.
- Avoid dense enterprise table layouts.
- Avoid oversized marketing-style hero blocks.

## Create Drift Sheet: Active Compose Sheet

Create Drift is a modal bottom sheet launched from the center `Create` tab bar action.

### Intent

The sheet should feel fast, peaceful, warm, social, safe, and activity-first. It must help a user post a spontaneous nearby plan in under 20 seconds without exposing exact location, people browsing, chat, or direct-message behavior.

### Entry Point

- Bottom nav center `Create` opens this sheet.
- The sheet is dismissed only after explicit confirmation if there are unsaved changes.

### Screen Structure

Target iPhone planning size: 393 x 852pt.

1. Bottom sheet handle.
2. Header with title, subtitle, and close action.
3. Activity type grid.
4. Plan title input.
5. Time chip row.
6. Two-column row with approximate location and capacity.
7. Join mode selector.
8. Optional details collapsible section.
9. Privacy helper text.
10. Sticky CTA footer.

### Design Rules

- Use warm background and ivory sheet surface.
- Use rounded tactile cards and chips with soft border treatment.
- Use mint as the selected state for primary choices.
- Use lavender and peach only as restrained accents.
- Use Outfit for section titles, selected chips, and CTA text.
- Use SF Pro/system for helper text, placeholders, metadata, and input text.
- Use app colors from the CoffeeCall token system only.
- Show approximate location only.
- Never show exact coordinates or a public people list.

### Content Contract

- Default activity: `Coffee`.
- Activity grid includes:
  - Coffee, Walk, Food, Movie, Study
  - Fitness, Games, Music, Sports, Drinks
  - Custom
- Time chips:
  - Now, In 30 mins, Tonight, Tomorrow, Custom
- Capacity chips:
  - 1, 3, 5, 8+
- Join mode:
  - Anyone can join
  - Approve requests
- Vibe (Required, always visible below Join Mode)
- Optional details:
  - Hook
  - Notes
- Primary CTA:
  - `Post Drift`

### Interaction Rules

- Activity, time, capacity, and join mode are single-selection controls.
- Optional details are collapsed by default and expand smoothly.
- CTA remains disabled until required fields are valid.
- CTA shows a loading state while creating.
- On success, show a brief confirmation state and dismiss or route to the new Drift.
- If the user tries to dismiss with unsaved changes, ask for discard confirmation first.

## Chats: Active Chat Screens

Chats are Drift-tied conversations for coordination only. There is no direct person-to-person cold messaging in MVP. Every chat thread must be associated with a Drift the user is hosting or has joined.

### Intent

Chats should make it effortless to:

- continue coordination for a Drift the user is part of,
- find the right Drift thread quickly,
- view key Drift context without leaving the thread,
- keep the experience safe and activity-first.

### Screen Set

Chats has three primary screens:

1. Chats Home (Compact Rooms List)
2. Chat Thread (Conversation) (Drift Room)
3. Chat Detail (Info Sheet)

Optional (MVP-safe) supporting sheets:

- Attachment picker (system)

### Entry Points

- Bottom nav `Chats` opens Chats Home.
- A Drift Detail screen may deep link directly into the Chat Thread only after the user is hosting or joined.
- Notifications for new messages open the Chat Thread.

### Shared Components

- Use the shared Floating Glass Top Header on Chats Home.
- Use the shared floating bottom nav on Chats Home.
- Chat Thread uses a standard navigation header (or a compact glass header) but must preserve the same typography/tokens and avoid a new visual style.

### Chats Home

Purpose: provide a clean, scan-friendly list of all your active Drift conversations.

#### Top Header

- Use the shared Floating Glass Top Header.
- Title: `Chats`.
- Subtitle: `Drift rooms`.


#### Layout

Target iPhone planning size: 393 x 852pt.

1. Floating glass top header.
2. Drift status filter row.
3. Compact Rooms List.
5. Floating glass bottom navigation.

#### Drift Status Filter Row

This row separates Drift-based chats by the user's relationship/state. It is not a social filter and must not introduce people browsing.

- Horizontal chips row (preferred) under the header.
- Horizontal margin: 20pt.
- Height: 36-40pt.
- Chip radius: 18-20pt.
- Chips:
  - `Active` (default)
  - `Joined`
  - `Hosted`
  - `Expired`
- Active chip uses mint-tinted fill + mint text.
- Inactive chips use card surface with border `#E7DED4` and secondary text.

Definitions:

- `Active`: Drifts the user is Hosting or Joined and that are currently active/upcoming.
- `Joined`: Drifts where the user is Joined (not Hosting).
- `Hosted`: Drifts where the user is Hosting.
- `Expired`: Drifts that have ended or been archived. This replaces the older `Archived` concept for Chats.

#### Compact Rooms List

List mode is the scan-friendly view that matches an Instagram-style message list, but each row is still a Drift room.

Row rules:

- Threads represent Drift rooms only (no global DMs, no people directory).
- Only Drifts where the user is `Hosting` or `Joined` appear, filtered by the Drift status chips.

Row sizing (compact):

- Row height: 56-64pt (target 60pt).
- Horizontal margin: 20pt.
- Row radius: 18-20pt.
- Leading icon well: 36-40pt circle.
- Title: 16-17pt semibold, 1 line.
- Preview: 13-14pt secondary, 1 line.
- Trailing time: 12pt secondary.
- Unread indicator: mint dot preferred; tiny count pill allowed for >1 unread.

Tap row opens Chat Thread.

Empty state (when filter has no rooms):

- Title: `No Drift chats yet`.
- Body: `Chats appear after you join or host a Drift.`
- Secondary action: `Browse Drifts` routes to Drifts (Nearby).

### Chat Thread (Conversation)

This is the Drift room conversation screen.

#### Thread Header (Compact)

Purpose: provide Drift context without encouraging person browsing.

- Title: Drift purpose, e.g. `Coffee after work`.
- Subtitle: `Today 6:30 PM • Location unlocked` (since this screen only exists for joined/hosting).
- Right action: `Info` button opens Chat Detail (Info Sheet).

#### Context Strip (Optional but Recommended)

A compact "Drift Context" strip at the top of the message list:

- Shows: time, approximate/unlocked location, participant count, and status (Hosting/Joined).
- Height: 44-52pt.
- Uses card surface with subtle border.
- Tapping opens Drift Detail (read-only summary) or Chat Detail sheet.

#### Message List

- Standard bubble list with comfortable spacing.
- Use neutral bubbles with subtle tints:
  - Incoming: card surface / light neutral.
  - Outgoing: mint-tinted subtle fill (not fully saturated mint).
- Timestamp separators are subtle secondary text.
- Sender identity:
  - For group rooms, show first name or initial as a small label above the bubble when needed.
  - Avoid avatar stacks that turn the screen into a people UI.

#### Composer

- Fixed input at bottom, above safe area.
- Components:
  - Text field (card surface, 16-20pt radius).
  - Send button (mint circular or rounded, pressed mint on press).
  - Optional attachment icon (paperclip) if attachments exist; otherwise omit.
- No call button, no share phone number, no "DM user" affordance.

#### Safety / Guardrails

- A small inline system note can appear once per thread: `Keep details in-app. No phone numbers.` (optional, MVP-safe).
- Report/Block is available only via Chat Detail, not as a visible main action.

### Chat Detail (Info Sheet)

Purpose: show Drift context, participants, and safety controls without exposing a social directory.

Presentation:

- Bottom sheet presentation from the Chat Thread.
- Height: ~70-80% of screen.
- Corner radius: 28-32pt.

Header:

- Title: `About this Drift`.
- Subtitle: drift purpose (small).
- Close button: `X`.

Section: Drift Details (card)

- Purpose, time, location state (`Location unlocked`).
- Optional host note / rules (1-3 lines).
- Actions:
  - Primary: `View Drift` (opens Drift detail).
  - Secondary: `Mute room`.

Section: Participants (card)

- Title: `Participants (N)`.
- List: first names or initials (no full social profile).
- Host label: `(Host)` for the host.
- Optional “Message in context” action:
  - If enabled, allow 1:1 only inside the same Drift context.
  - This must not create a global DM directory or cold messaging surface.
  - Keep it low emphasis (icon-only) and never the primary call to action.

Section: Safety & Controls (card)

- `Report Drift` (destructive).
- `Block user` (destructive; opens picker).
- `Leave Drift` (destructive) if supported.

No profile deep links, no follower actions.

### Interaction Rules

- Users can only see threads for Drifts they are hosting or joined.
- Users can only send messages in those threads.
- Requested/pending join state must not show Chat; it can show "Awaiting acceptance" on Drift Detail.

## Other Screen Direction

- Drifts: follow the active Drifts screen spec above. Pre-join shows approximate location; post-join unlocks exact coordination.
- Create: pending design work only; no implementation contract yet.
- Drift Detail: summary, host context, participant privacy, safety banner, and sticky join/request/joined state.
- Chats: async Drift-tied coordination only.
- You: lightweight profile, active involvement, privacy/settings. No social profile depth.

## Detailed MVP Screen UX Specifications

### 1. Host Context Card Bottom Sheet (ISSUE-013)
- **Presentation**: Tapping the host name or avatar inside the Drift Detail screen triggers a compact slide-up sheet, not a full page transition.
- **Content Gating**: First name, display initials, and a Verified Checkmark badge only. No phone numbers, no social links.
- **Trust & History Stats Grid**: Renders a 2x2 miniature, Outfit-style stats card grid showing:
  - **Hosted**: Total Drifts created by the user (e.g., `4 Hosted`).
  - **Joined**: Total Drifts they participated in (e.g., `12 Joined`).
  - **Verified Check**: A soft badge and checkmark confirming identity.
  - **Reliability Metric**: Total completed physical check-ins (e.g., `16 Completed`).
- **Synergy Signal**: Shows Outfit-styled tags of the host's selected interest capsules.
- **Activity History & Active Drifts**:
  - **Active Drifts**: A mini vertical card list of upcoming drifts scheduled by this host. Tapping any item routes to its Drift Detail screen.
  - **Past Drifts Log**: A subtle horizontal scroll gallery of past completed meetups they hosted or joined (e.g., `"Walk in Indiranagar"`, `"Coffee chat"` with a grayed-out `"Completed"` state) to visually confirm physical real-world consistency.
- **Safety Guardrail**: Structurally omits cold messaging, phone calls, and follower options to preserve activity-first boundaries.

### 2. "Who’s Coming" Sheet (ISSUE-014)
- **Presentation**: Triggered via the participants avatar strip on the Drift Detail screen.
- **Icebreakers Row**: Next to each participant's first name, renders a horizontal row of their active interest icons.
- **Strict Read-Only Gating**: Participants rows are completely static. Tapping on a participant has zero interaction, preventing social browsing or direct side-channel pings.

### 3. Drift List Refinement (Tactile Filter Panel)
- **Radius Bounds**: Renders a mint HSL-styled horizontal slider representing `1 km` to `10 km` (the MVP absolute discovery limit).
- **Activity Tags Grid**: Renders a 2x4 tag grid displaying standard categories (Coffee, Walks, Movie, Dinner) to instantly refine the list.
- **Demographic Exclusions**: STRUCTURALLY FORBIDDEN to filter by age, gender, occupation, or status.

### 4. Saved Drifts Gallery & Watch-list
- **Home Surface**: Located in the "You" tab as a horizontal row.
- **Dynamic State Checking**: Renders bookmarked cards with live status badges. Expired/cancelled bookmarked items automatically fade and delete.

### 5. Attendance Warnings & Vibe Confirmations
- **Looming Alert**: 2 hours before a joined/hosted Drift starts, triggers a local notification and in-app banner.
- **Confirmation State**: Tapping the alert displays a compact banner asking: *"Are you still good to go?"* with CTAs `"Yes, on my way!"` and `"Need to cancel"`.

### 6. Activity-Centric Map/Location Bounds
- **Pre-Join state**: Drift detail renders a circular, static vector map showcasing *only* a generic **500-meter radius colored highlight ring** centered on the drift neighborhood (e.g. Indiranagar, Kochi) with NO specific pin or street address.
- **Post-Join state**: Renders a precise pin drop and an inline action `"Open in Maps"` to deep link into native Apple Maps.

## Design QA

- Screen reads as activity-first within 3 seconds.
- No cold outreach affordance exists.
- Text fits on 393pt width.
- Floating nav does not obscure required content.
- Mint is the primary action color.
- Lavender and peach remain accents.
- Archive files are ignored for design decisions.
