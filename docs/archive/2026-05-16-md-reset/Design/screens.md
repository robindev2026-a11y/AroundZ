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

## Around (Discovery)

Current direction:
- Primary dashboard is a **Radar visualization** with concentric distance rings (0.3mi, 0.6mi, 0.8mi).
- "You" avatar at center; surrounding avatars/initials show ambient presence only.
- **Rule**: No people-browsing. Radar is for ambient presence, not for unsolicited contact.
- **Interests Section**: Horizontal list of vertical cards showing icon, title, and nearby count.
- **Primary CTA**: Large capsule-shaped create button.
- Navigation: Around | Drifts | Chats | You.

---

## Drifts

Current direction:
- Two main views: **Discover** (nearby active meetups) and **Mine** (your hosted/joined drifts).
- **Mine** is nested within the Drifts screen.
- Pre-join: Only approximate location/distance shown.
- Post-acceptance: Exact coordination and meeting points unlocked.

---

## Drift Detail

Current direction:
- Sticky multi-state CTA footer (Join, Requested, Joined, Full, Ended).
- Rich summary info grid (Date, Time, Distance, Participants).
- **Safety Banner**: Mandatory for user trust and coordination guidance.

---

## Messages (Chats)

Current direction:
- **Rule**: No cold DMs. Messaging is only enabled for active Drifts where the user is a participant or host.
- Async coordination focus, not real-time social complexity.

---

## Profile (You)

Current direction:
- Focus on active involvement and basic trust metadata.
- **Rule**: No full social profiles or dating-style bios.
- No reputation, scoring, or phone number exchange in MVP.

---

## Do Not Use

- Old 7-screen-only prompt as a visual source of truth.
- Old blue/coral MVP wireframe palette.
- Placeholder "awaiting Figma" status.
- Generic white/blue startup layouts.
