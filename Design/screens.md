# CoffeeCall Screen Specifications

Status: active but evolving. Screens are still being built in SwiftUI.

Visual source: `/Users/development/Downloads/figmaCoffe`

Design token source: `Design/design-tokens.md`

---

## Screen Priorities

1. Onboarding
2. Discovery
3. Activity Details
4. Messages
5. Profile/Auth completion
6. Create Meetup
7. Notifications
8. Map View
9. Empty States
10. Create Meetup Success
11. Verification and Trust

---

## Onboarding

Current direction:
- Multi-page carousel.
- Full-screen photographic background where Figma uses a background image.
- Warm dark overlay on image screens for readable white text.
- "COFFEECALL BETA" glass badge.
- Hero copy: bold, large, direct.
- Floating social/activity cards.
- Large mint pill CTA.

Implementation rule:
- Keep full-bleed image/gradient background behind the page `TabView`.
- Do not apply `.ignoresSafeArea()` to the whole `TabView`.

---

## Discovery

Current direction:
- Nearby activities and people should feel alive and social.
- Use warm background, layered cards, mint actions, lavender/peach accents.
- Avoid dense admin/dashboard layouts.

---

## Auth And Profile Setup

Current direction:
- Simple, friendly setup flow.
- Use native iOS typography with default system design.
- Use mint for primary progress/action.
- Use warm cards and clear helper text.

---

## Create Meetup

Current direction:
- Simple form.
- Activity, place, time, and optional social context.
- Primary mint submit action.

---

## Messages

Current direction:
- Async coordination, not real-time social chat complexity.
- Clear sender distinction.
- Warm surfaces and readable message bubbles.

---

## Profile

Current direction:
- Human, trust-building, not gamified.
- No reputation/scoring system in MVP.

---

## Do Not Use

- Old 7-screen-only prompt as a visual source of truth.
- Old blue/coral MVP wireframe palette.
- Placeholder "awaiting Figma" status.
- Generic white/blue startup layouts.
