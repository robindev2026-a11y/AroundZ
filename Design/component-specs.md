# CoffeeCall Component Specifications

Status: active. Use with `Design/design-tokens.md`.

This file describes current component direction only. Older blue/coral component specs have been removed because they no longer match the Figma prototype.

---

## Primary Button

Use for main actions such as "Let's Go", "Next", "Create Drift", and "Send".

Visual:
- Height: 52-64pt depending on screen context.
- Shape: pill/capsule.
- Fill: `#53B8A6` / `.brandPrimary`.
- Pressed fill: `#3D8D7A` / `.brandPrimaryDark`.
- Text: white / `.textOnBrand`.
- Font: 16pt, heavy/bold default system.

**Create Drift Variant**:
- Large capsule button (height 72-80pt).
- Leading circular icon (white circle with mint plus).
- Stacked title ("Create Drift") and subtitle ("Share what you're up for").
- Trailing SF Symbol chevron.

Rules:
- Minimum touch target: 44x44pt.
- Use semantic color and font helpers.
- Do not hardcode raw hex inside screen views.

---

## Secondary Button

Use for alternate actions where the primary action should remain visually dominant.

Visual:
- Surface: `#FFFDF9` or transparent.
- Border: `#E7DED4`.
- Text: `#243447`.
- Optional lavender or peach accent only when it matches Figma intent.

---

## Cards

Use for activity cards, profile snippets, notification cards, and floating onboarding cards.

Visual:
- Surface: `#FFFDF9` / `.surfaceMain`.
- Secondary surface: `#F4F4F8` when needed.
- Text primary: `#243447`.
- Text secondary: `#5F6368`.
- Border: `#E7DED4` when a card needs definition.
- Radius: 16-24pt.
- Shadow: soft slate-tinted shadow, not heavy black shadow.

Floating cards over image backgrounds:
- Use translucent material or overlay style.
- Keep text high-contrast.
- Preserve full-bleed background imagery behind the card.

Drift cards:
- Show purpose, location, time, and an optional hook or offer.
- Keep hooks short and specific.
- Do not make the card read like a marketplace listing.

---

## Inputs

Use for phone, OTP, profile, and create-activity forms.

Visual:
- Height: 44-52pt.
- Surface: `#FFFDF9` or `#F4F4F8`.
- Border: `#E7DED4`.
- Focus ring/accent: `#53B8A6`.
- Error: `.statusError`.
- Text: `#243447`.
- Placeholder/helper: `#5F6368`.

---

## Badges And Chips

Use for beta badge, interest cards, and status labels.

**Vertical Interest Cards**:
- Vertical rectangle with large corner radius (24-32pt).
- Stacked layout: SF Symbol (top), Category title (middle), Count badge (bottom).
- Active state: Mint fill (`#53B8A6`) with white text.
- Inactive state: White surface (`#FFFDF9`) with mint/lavender/peach icon accents.
- Count badge: small capsule inside the card showing "X nearby".

Visual:
- Pill shape.
- Mint, lavender, peach, or neutral surface depending on meaning.
- Uppercase labels should use bold 12pt caption style.
- Icons should use SF Symbols unless Figma provides a specific asset.
- Chips can surface active interest states, such as `3 nearby`, `Open now`, or `Coffee on me`.

---

## Avatar And Icon Wells

Visual:
- Avatar: circle.
- Icon wells: rounded square or circle with mint/lavender/peach accent fill.
- Keep icon size readable at small mobile scale.

---

## Navigation And Layout

Rules:
- **Floating Navigation Bar**: Use a pill-style floating bar anchored at the bottom.
- Tabs: Around (Pin), Drifts (Calendar), Chats (Bubble), You (Person).
- Screens should feel mobile-first and spacious.
- Prefer layered cards and clear sections over dashboard density.
- Avoid generic blue startup UI.
- Onboarding image backgrounds must be full bleed where Figma shows a full-screen image.
- For page `TabView`, background imagery should sit behind the `TabView`; do not apply `.ignoresSafeArea()` to the entire `TabView`.
- Discovery should not expose a direct `Say hi` or cold-message affordance from the radar surface.
- The primary discovery action should route into a Drift context first.
