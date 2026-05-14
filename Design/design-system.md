# CoffeeCall Design System

Status: active. This replaces the older placeholder and blue/coral MVP design notes.

Current design source: `/Users/development/Downloads/figmaCoffe`

Primary implementation reference: `Design/design-tokens.md`

---

## Product Feel

CoffeeCall should feel warm, social, safe, and premium. It is not a coffee ordering app, dating app, enterprise dashboard, task manager, or generic blue startup interface.

Design priorities:
- Activity first, person second.
- Warm neutral surfaces.
- Mint primary actions.
- Lavender and peach accents used sparingly.
- Large friendly typography.
- Layered cards and soft shadows.
- Full-bleed photographic onboarding where Figma uses image backgrounds.
- Generous spacing and clear mobile hierarchy.

---

## Active Palette

| Role | Hex |
|---|---:|
| Primary mint | `#53B8A6` |
| Pressed mint | `#3D8D7A` |
| Lavender highlight | `#8E7DBE` |
| Peach accent | `#E88C6B` |
| Warm background | `#F6F1EB` |
| Card surface | `#FFFDF9` |
| Secondary surface | `#F4F4F8` |
| Primary text | `#243447` |
| Secondary text | `#5F6368` |
| Subtle border | `#E7DED4` |

---

## Typography Direction

Use native iOS system typography with `design: .default`.

Do not use `.rounded` fonts unless the Figma source changes.

Titles and CTAs should feel bold and confident. Body copy should remain readable and calm.

---

## Component Direction

Buttons:
- Large pill CTAs.
- Mint default, darker mint pressed.
- White text.
- Strong, simple labels.

Cards:
- Warm off-white surfaces.
- Rounded corners.
- Soft shadows.
- Clear hierarchy between title, metadata, and actions.

Onboarding:
- Figma image-background screens must remain full bleed.
- Put image/gradient backgrounds behind `TabView`.
- Do not apply `.ignoresSafeArea()` to the entire page `TabView`; apply it only to background layers.

Discovery:
- Prioritize nearby social activity cards.
- Avoid dense dashboard layouts.
- Use mint/lavender accents for liveliness, not generic blue.

---

## Do Not Use

- Old primary-blue palette.
- Old cyan/teal/coral system from the archived Design UX files.
- Generic white/blue startup styling.
- Rounded SF font design.
- Hardcoded colors inside screens.
