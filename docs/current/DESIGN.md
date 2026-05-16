# CoffeeCall Design Contract

Status: ACTIVE
Last updated: 2026-05-16

This is the single active design contract for CoffeeCall. If another file disagrees with this file, follow this file and report the conflict.

## Design Personality

CoffeeCall should feel warm, social, safe, premium, and native iOS. The experience is activity-first: users notice nearby energy, choose a Drift, and coordinate with context.

Do not design CoffeeCall like a dating app, coffee ordering app, enterprise dashboard, task manager, or generic blue-and-white startup interface.

## Social Refresh Tokens

| Role | Hex | Usage |
|---|---:|---|
| Primary mint | `#53B8A6` | Primary actions, active controls, key accents |
| Pressed mint | `#3D8D7A` | Pressed primary state |
| Lavender | `#8E7DBE` | Secondary accent |
| Peach | `#E88C6B` | Warm accent |
| Warm background | `#F6F1EB` | Main app background |
| Card surface | `#FFFDF9` | Cards, sheets, elevated panels |
| Secondary surface | `#F4F4F8` | Inputs and subtle panels |
| Primary text | `#243447` | Titles and main body text |
| Secondary text | `#5F6368` | Captions, metadata, helper text |
| Border | `#E7DED4` | Separators and subtle outlines |
| Success | `#10B981` | Success confirmations only |
| Error | `#DE4545` | Destructive/error states only |

## Typography

- Use native iOS default system typography.
- Do not use rounded font design unless a future approved design contract says so.
- Suggested scale:
  - H1: 32pt, heavy/bold.
  - H2: 24pt, bold/semibold.
  - H3: 20pt, bold/semibold.
  - Body: 16pt, regular.
  - Body small: 14pt, regular.
  - Caption: 12pt, semibold/bold by context.
  - Button: 16pt, bold/heavy.

## Spacing, Radius, And Effects

- Base spacing: 8, 16, 24, 32, 48pt.
- Screen horizontal padding: 20pt for primary mobile screens.
- Radius:
  - Small controls: 8pt.
  - Cards: 16-24pt.
  - Large soft cards and sheets: 24-32pt.
  - Avatars and icon wells: circular.
- Shadows are soft and slate-tinted, never heavy black.
- Glass surfaces use iOS material-style blur with subtle border highlights.

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

- Floating glass card.
- Horizontal margin: 20pt.
- Height: 82pt.
- Corner radius: 30pt.
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

## Other Screen Direction

- Drifts: concrete nearby Drifts plus hosted/joined state. Pre-join shows approximate location; post-join unlocks exact coordination.
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
