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
- Right action: circular notification button, 56 x 56pt, with badge `3`.

### Radar

- Height target: 330pt.
- No heavy enclosing card.
- Three soft rings labeled `0.8 mi`, `0.6 mi`, and `0.3 mi`.
- Center bubble: 72 x 72pt, icon and label `You`.
- Nearby anonymous bubbles: 46 x 46pt with initials such as `LM`, `DK`, `MR`, `NP`, `AL`.
- Bubbles are interactive activity signals.
- Tapping a radar element must not open a profile or direct message. Instead, it presents an anonymous "Activity Signal Tooltip" showing active interests (e.g., "Coffee & Walks") and routing the user to Create Drift.

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
- Create presents Create Drift as a sheet, not as a normal tab page.
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
- Primary action: `Create Drift`, presented as the Create Drift sheet.
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
- Create presents Create Drift as a sheet.
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

## Other Screen Direction

- Drifts: follow the active Drifts screen spec above. Pre-join shows approximate location; post-join unlocks exact coordination.
- Create Drift: sheet presentation with purpose, location, time, optional hook, permission and dirty-form states.
- Drift Detail: summary, host context, participant privacy, safety banner, and sticky join/request/joined state.
- Chats: async Drift-tied coordination only.
- You: lightweight profile, active involvement, privacy/settings. No social profile depth.

## Design QA

- Screen reads as activity-first within 3 seconds.
- No cold outreach affordance exists.
- Text fits on 393pt width.
- Floating nav does not obscure required content.
- Mint is the primary action color.
- Lavender and peach remain accents.
- Archive files are ignored for design decisions.
