# CoffeeCall: Design Tokens

Source of truth for CoffeeCall visual implementation.

Current design source: `/Users/development/Downloads/figmaCoffe/src/styles/theme.css`

Status: active. Use these values for SwiftUI and documentation. Do not use older blue/coral MVP palette docs.

---

## Color Tokens

### Brand

| Token | Hex | SwiftUI semantic token | Usage |
|---|---:|---|---|
| brand-mint | `#53B8A6` | `.brandPrimary` | Primary CTAs, active controls, key accents |
| brand-mint-pressed | `#3D8D7A` | `.brandPrimaryDark` | Pressed CTA state, strong mint accents |
| brand-lavender | `#8E7DBE` | `.brandPurple` | Highlights, secondary accent, progress/illustration accents |
| brand-peach | `#E88C6B` | `.brandSecondary` | Optional warm CTA/accent, alerts where appropriate |

### Surfaces

| Token | Hex | SwiftUI semantic token | Usage |
|---|---:|---|---|
| bg-primary | `#F6F1EB` | `.backgroundMain` | Main warm app background |
| surface-card | `#FFFDF9` | `.surfaceMain` | Cards, elevated panels, form containers |
| surface-secondary | `#F4F4F8` | Use semantic surface token when added | Secondary panels, subtle input fill |
| border-subtle | `#E7DED4` | `.appBorder` | Card borders, separators, input outlines |

### Text

| Token | Hex | SwiftUI semantic token | Usage |
|---|---:|---|---|
| text-primary | `#243447` | `.textPrimary` | Headings, primary body text |
| text-secondary | `#5F6368` | `.textSecondary` | Captions, metadata, helper text |
| text-on-brand | `#FFFFFF` | `.textOnBrand` | Text on mint/lavender/peach backgrounds |

### Status

| Token | Hex | SwiftUI semantic token | Usage |
|---|---:|---|---|
| success | `#10B981` | `.statusSuccess` | Success confirmation only |
| error | `#DE4545` | `.statusError` | Error/destructive states only |

---

## Typography

The Figma prototype uses Inter on web. The iOS implementation should use native SF Pro through SwiftUI system fonts with `design: .default`.

Do not use `.rounded` typography unless a future Figma update explicitly requires it.

| Token | Size | Weight | SwiftUI token | Usage |
|---|---:|---|---|---|
| h1 | 32 | black/bold | `.heading1` | Onboarding titles, major screen titles |
| h2 | 24 | bold/semibold | Direct system token if needed | Section headers |
| h3 | 20 | bold/semibold | Direct system token if needed | Card titles |
| body | 16 | regular | `.bodyStandard` | Primary body copy |
| body-sm | 14 | regular | `.bodySmall` | Secondary body copy |
| caption | 12 | bold/regular by context | `.captionText` | Labels, metadata, uppercase badges |
| button | 16 | black/bold | `.buttonText` | CTA labels |

Implementation rule: use shared typography helpers from `apps/frontend/Coffee_Call/Coffee_Call/DesignSystem/Font+Extensions.swift` where possible.

---

## Spacing

Use the Figma Social Refresh spacing scale.

| Token | Points | Usage |
|---|---:|---|
| spacing-xs | 8 | Tight internal gaps |
| spacing-sm | 16 | Default card/form padding |
| spacing-md | 24 | Section spacing |
| spacing-lg | 32 | Large screen spacing |
| spacing-xl | 48 | Hero spacing, large vertical separation |

---

## Radius

| Token | Points | Usage |
|---|---:|---|
| radius-sm | 8 | Inputs, chips |
| radius-md | 16 | Cards, compact panels |
| radius-lg | 24 | Large cards, sheets |
| radius-xl | 32 | Hero CTAs, large containers |
| radius-circle | 50% | Avatars, circular icon wells |

---

## Shadows

| Token | Definition | Usage |
|---|---|---|
| shadow-soft | `0 4px 12px rgba(36, 52, 71, 0.04)` | Subtle layer separation |
| shadow-card | `0 8px 24px rgba(36, 52, 71, 0.06)` | Activity cards, profile cards |
| shadow-modal | `0 20px 48px rgba(36, 52, 71, 0.12)` | Sheets, overlays |

SwiftUI equivalent: use `Color.textPrimary.opacity(...)` for shadow color rather than pure black where practical.

---

## Usage Rules

- Use semantic SwiftUI tokens from `Color+Extensions.swift`.
- Do not hardcode raw hex values inside screens.
- Do not use the old blue/coral MVP design palette.
- Do not use placeholder design docs as implementation source.
- Keep full-screen image backgrounds behind page `TabView`; apply `.ignoresSafeArea()` only to background layers.
- Update this file whenever Figma visual tokens change.

---

## Current Swift Asset Mapping

| Asset | Hex |
|---|---:|
| `coffeePrimary` | `#53B8A6` |
| `coffeePrimaryDark` | `#3D8D7A` |
| `coffeePrimaryLight` | `#8E7DBE` |
| `coffeePurple` | `#8E7DBE` |
| `coffeePeach` | `#E88C6B` |
| `coffeeBackground` | `#F6F1EB` |
| `coffeeSurface` | `#FFFDF9` |
| `coffeeSurfaceSecondary` | `#F4F4F8` |
| `coffeeBorder` | `#E7DED4` |
| `coffeeTextPrimary` | `#243447` |
| `coffeeTextSecondary` | `#5F6368` |
| `coffeeSuccess` | `#10B981` |
