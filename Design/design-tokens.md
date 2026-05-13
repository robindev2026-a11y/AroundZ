# CoffeeCall: Design Tokens

Reusable design values for consistent implementation across iOS.

## Colors

### Primary Palette
| Token | Value | Hex | Usage |
|-------|-------|-----|-------|
| color-primary | Teal Green | #49B89D | CTAs, highlights, primary buttons |
| color-primary-light | Light Teal | #74D1B9 | Hover states, disabled backgrounds |
| color-primary-dark | Dark Teal | #2B826C | Active states, borders |

### Secondary Palette
| Token | Value | Hex | Usage |
|-------|-------|-----|-------|
| color-success | Green | #10B981 | Accept, positive actions, success states |
| color-warning | Amber | #F59E0B | Pending, caution states |
| color-error | Red | #EF4444 | Errors, reject, danger states |
| color-info | Blue | #3B82F6 | Information, notifications |

### Neutral Palette
| Token | Value | Hex | Usage |
|-------|-------|-----|-------|
| color-background | White | #FFFFFF | Main app background |
| color-surface | Light Gray | #F9FAFB | Card, container backgrounds |
| color-surface-alt | Lighter Gray | #F3F4F6 | Alternative surface |
| color-border | Gray | #E5E7EB | Dividers, borders |
| color-border-dark | Dark Gray | #D1D5DB | Emphasis borders |

### Text Colors
| Token | Value | Hex | Usage |
|-------|-------|-----|-------|
| color-text-primary | Dark Gray | #1F2937 | Body text, headings |
| color-text-secondary | Medium Gray | #6B7280 | Secondary text, captions |
| color-text-tertiary | Light Gray | #9CA3AF | Disabled text |
| color-text-inverse | White | #FFFFFF | Text on dark backgrounds |

---

## Typography

### Font Family
- **Primary:** Inter (sans-serif)
- **Fallback:** System font stack (SF Pro Display on iOS)

### Heading Styles
| Token | Font Size | Font Weight | Line Height | Letter Spacing | Usage |
|-------|-----------|-------------|-------------|---|---|
| heading-1 | 32px | 700 (Bold) | 1.2 | -0.5px | Page titles, major headings |
| heading-2 | 24px | 700 (Bold) | 1.3 | 0px | Section titles |
| heading-3 | 20px | 600 (SemiBold) | 1.4 | 0px | Subsection titles |

### Body Styles
| Token | Font Size | Font Weight | Line Height | Letter Spacing | Usage |
|-------|-----------|-------------|-------------|---|---|
| body-lg | 18px | 400 (Regular) | 1.6 | 0px | Large body text |
| body | 16px | 400 (Regular) | 1.5 | 0px | Standard body text |
| body-sm | 14px | 400 (Regular) | 1.5 | 0px | Smaller body text |

### Other Styles
| Token | Font Size | Font Weight | Line Height | Usage |
|-------|-----------|-------------|-------------|---|
| caption | 12px | 400 (Regular) | 1.4 | Small text, labels |
| overline | 11px | 600 (SemiBold) | 1.5 | Uppercase labels |
| button | 16px | 600 (SemiBold) | 1.5 | Button text |

---

## Spacing System

All spacing follows an 8px base unit for consistency.

| Token | Pixels | Usage |
|-------|--------|-------|
| spacing-xs | 4px | Tight spacing (rarely used) |
| spacing-sm | 8px | Small gaps (inside inputs, between icons) |
| spacing-md | 16px | Default spacing (padding in cards, gaps between elements) |
| spacing-lg | 24px | Large gaps (between sections) |
| spacing-xl | 32px | Extra large gaps (between major sections) |
| spacing-2xl | 48px | Huge gaps (screen-level spacing) |

**Examples:**
- Button padding: `spacing-sm` (vertical), `spacing-md` (horizontal)
- Card padding: `spacing-md`
- Section gap: `spacing-lg`
- Page padding: `spacing-md`

---

## Border Radius

| Token | Pixels | Usage |
|-------|--------|-------|
| radius-none | 0px | Sharp corners (rare) |
| radius-sm | 4px | Small elements (badges, small inputs) |
| radius-md | 8px | Standard (cards, input fields) |
| radius-lg | 12px | Large elements (modals, large containers) |
| radius-full | 50% | Circles (avatars, profile photos), Pill Buttons |

---

## Shadows

| Token | Definition | Usage |
|-------|-----------|-------|
| shadow-none | None | Flat design, no depth |
| shadow-sm | 0 1px 2px rgba(0, 0, 0, 0.05) | Subtle elevation |
| shadow-md | 0 4px 6px rgba(0, 0, 0, 0.1) | Cards, default elevation |
| shadow-lg | 0 10px 15px rgba(0, 0, 0, 0.1) | Modals, popovers |
| shadow-xl | 0 20px 25px rgba(0, 0, 0, 0.15) | Overlays, dropdowns |

---

## Effects

| Token | Definition | Usage |
|-------|-----------|-------|
| effect-glass | bg: rgba(255, 255, 255, 0.15), blur: 10px | Glassmorphic floating cards, badges |
| effect-glass-dark | bg: rgba(0, 0, 0, 0.25), blur: 10px | Dark glass elements, dark mode overlays |

---

## Component-Level Tokens

### Button
| Token | Value | Usage |
|-------|-------|-------|
| button-height-sm | 36px | Small buttons |
| button-height-md | 44px | Standard buttons |
| button-height-lg | 52px | Large buttons |
| button-padding-h | spacing-md | Horizontal padding |
| button-padding-v-sm | 8px | Small button vertical |
| button-padding-v-md | 12px | Standard vertical |

### Input
| Token | Value | Usage |
|-------|-------|-------|
| input-height | 44px | Text inputs, select |
| input-padding-h | spacing-md | Horizontal padding |
| input-padding-v | 10px | Vertical padding |
| input-border-width | 1px | Border thickness |
| input-border-color | color-border | Default state |

### Card
| Token | Value | Usage |
|-------|-------|-------|
| card-padding | spacing-md | Internal padding |
| card-border-radius | radius-md | Corner radius |
| card-background | color-surface | Background color |
| card-shadow | shadow-md | Depth |

---

## States & Interactions

### Button States
```
Default:    background: color-primary, text: color-text-inverse
Hover:      background: color-primary-dark, shadow: shadow-md
Active:     background: color-primary-dark, transform: scale(0.98)
Disabled:   background: color-border, text: color-text-tertiary
Loading:    opacity: 0.7, spinner overlay
```

### Input States
```
Default:    border: 1px color-border, background: color-background
Focused:    border: 2px color-primary, shadow: shadow-sm
Error:      border: 2px color-error, text: color-error
Disabled:   background: color-surface-alt, text: color-text-tertiary
```

---

## Animations

| Token | Duration | Easing | Usage |
|-------|----------|--------|-------|
| animation-fast | 150ms | ease-in-out | Quick feedback (button press) |
| animation-normal | 300ms | ease-in-out | Standard transitions |
| animation-slow | 500ms | ease-in-out | Complex animations |

---

## Accessibility Notes

- **Contrast:** All text meets WCAG AA (4.5:1 minimum)
- **Touch targets:** All interactive elements ≥44x44 points
- **Color:** Never rely on color alone (use icons + text)
- **Focus indicators:** Visible keyboard focus (2px primary border)

---

## Implementation Standard

To ensure consistency and type-safety, we use a centralized naming system for all design assets.

### 1. Asset Catalog
All binary assets (Colors, Images, Icons) MUST be stored in the `Assets.xcassets` catalog and accessed via our standardized extensions.

### 2. Static Strings (Text)
Strings are managed in `DesignSystem/AppStrings.swift` using a nested enum structure.
- **Usage:** `AppText.Onboarding.title`
- **Why:** Centralizes all copy, making updates and localization simple.

### 3. Colors
Colors are managed via an extension on `Color` in `DesignSystem/Color+Extensions.swift`.
- **Usage:** `Color.coffeePrimary`
- **Why:** Enables auto-complete and ensures only approved palette colors are used.

### 4. Images & Backgrounds
Images are managed in `DesignSystem/AppImages.swift`.
- **Usage:** `AppImages.Onboarding.hero`
- **Why:** Decouples the logic of fetching (local vs remote) from the View.

### 5. Icons
Icons (SF Symbols) are managed in `DesignSystem/AppIcons.swift`.
- **Usage:** `AppIcons.navHome`
- **Why:** Ensures consistent weight and style across the app.

---

## Code Example

```swift
struct ExampleView: View {
    var body: some View {
        VStack {
            AppImages.logo
                .resizable()
                .frame(width: 100, height: 100)
            
            Text(AppStrings.welcome)
                .font(.heading1)
                .foregroundColor(.coffeePrimary)
            
            Button(action: {}) {
                Label(AppStrings.continueBtn, systemImage: AppIcons.arrowRight)
            }
            .buttonStyle(PrimaryButtonStyle())
        }
    }
}
```

---

**Status:** Finalized  
**Last Updated:** 2026-05-13
