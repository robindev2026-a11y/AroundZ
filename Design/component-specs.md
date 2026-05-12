# CoffeeCall: Component Specifications

Detailed specifications for each reusable UI component in the MVP.

---

## Button Component

**Variants:**
- Primary (CTA, default style)
- Secondary (alternative action)
- Danger (destructive actions)
- Disabled (non-interactive)

**States:**
- Default
- Hover
- Pressed/Active
- Disabled
- Loading (spinner)

**Properties:**
- Size: small (36px), medium (44px), large (52px)
- Full width option: true/false
- Icon support: left, right, or icon-only
- Text truncation: ellipsis

**Styles (from design-tokens.md):**
- Height: 44px (standard)
- Padding: 12px vertical, 16px horizontal
- Border radius: fully rounded (pill/capsule)
- Font: 16px, 600 weight (SemiBold)
- Color: primary (#49B89D), text: white (#FFFFFF)
- Hover: darker background (#2B826C)
- Disabled: gray background, gray text

**Code Template (SwiftUI):**
```swift
Button(
  action: { /* action */ },
  label: {
    Text("Accept")
      .font(.system(size: 16, weight: .semibold))
  }
)
.frame(height: 44)
.frame(maxWidth: .infinity)
.background(Color(hex: "#49B89D"))
.foregroundColor(.white)
.clipShape(Capsule())
.disabled(isDisabled)
```

**Accessibility:**
- Touch target: minimum 44x44 points
- Contrast: 4.5:1 (WCAG AA)
- Keyboard navigable
- Screen reader: announces button text + state

---

## Text Input Component

**States:**
- Default (empty, unfocused)
- Focused (border highlight)
- Filled (with content)
- Error (invalid input)
- Disabled

**Properties:**
- Placeholder text
- Label (above input)
- Helper text (below)
- Error message
- Keyboard type: default, phone, email, number
- Max length
- Clearable: true/false
- Secure (password): true/false

**Styles:**
- Height: 44px
- Padding: 10px vertical, 12px horizontal
- Border: 1px, color-border (#E5E7EB)
- Border radius: 8px
- Font: 16px, regular
- Focused: 2px primary border
- Error: 2px error border + red text

**Code Template (SwiftUI):**
```swift
TextField("Location", text: $location)
  .frame(height: 44)
  .padding(12)
  .border(Color(hex: "#E5E7EB"), width: 1)
  .cornerRadius(8)
  .focused($isFocused)
  .onChange(of: isFocused) { focused in
    // Update border color
  }
```

**Validation:**
- Real-time feedback
- Error message displays below input
- Submit button disables if invalid

---

## Card Component

**Variants:**
- Post card (shows activity details)
- Profile card (shows user info)
- Message card (shows message bubble)
- Acceptance card (shows acceptance info)
- Glassmorphic card (floating overlays over images)

**States:**
- Default
- Hover
- Pressed
- Loading

**Properties:**
- Background color: surface (#F9FAFB)
- Border: none (shadow only)
- Shadow: md (standard elevation)
- Padding: 16px
- Corner radius: 8px

**Glassmorphic Card Properties:**
- Background: semi-transparent white/black
- Blur: 10px backdrop blur
- Border: 1px subtle white/transparent border
- Shadow: subtle elevation
- Corner radius: 12px or 16px

**Post Card Anatomy:**
```
┌─────────────────────────┐
│ [Avatar] [Name] [Time]  │ <- Header
│─────────────────────────│
│ Activity purpose text   │ <- Title
│─────────────────────────│
│ 📍 Location address     │ <- Location
│ ⏰ Time (formatted)     │ <- Time
│─────────────────────────│
│ [Accept] [Reject]       │ <- Actions
└─────────────────────────┘
```

**Code Template:**
```swift
VStack(alignment: .leading) {
  // Header: Avatar + Name + Time
  HStack {
    Circle().frame(width: 40, height: 40) // Avatar
    VStack(alignment: .leading) {
      Text(userName).font(.system(size: 14, weight: .semibold))
      Text(timeAgo).font(.system(size: 12, weight: .regular)).foregroundColor(.gray)
    }
    Spacer()
  }
  
  // Activity purpose
  Text(purpose).font(.system(size: 16, weight: .semibold))
  
  // Location + Time
  HStack {
    Label(location, systemImage: "mappin.circle")
    Label(formattedTime, systemImage: "clock")
  }
  
  // Action buttons
  HStack {
    Button("Accept") { /* ... */ }
    Button("Reject") { /* ... */ }
  }
}
.padding(16)
.background(Color(hex: "#F9FAFB"))
.cornerRadius(8)
.shadow(color: Color.black.opacity(0.1), radius: 4)

---

## Pill Badge Component

**Variants:**
- Solid (primary, secondary)
- Glassmorphic (semi-transparent over images)

**Code Template (Glassmorphic):**
```swift
HStack {
  Image(systemName: "sparkles")
  Text("COFFEECALL BETA")
}
.padding(.horizontal, 12)
.padding(.vertical, 6)
.background(.thinMaterial)
.clipShape(Capsule())
```
```

---

## Dialog/Modal Component

**Variants:**
- Confirmation dialog (Accept/Cancel)
- Alert dialog (OK only)
- Input dialog (with form)

**Anatomy:**
```
┌────────────────────────┐
│        Title           │ <- 24px, bold
├────────────────────────┤
│                        │
│    Content area        │ <- Message, form, details
│                        │
├────────────────────────┤
│ [Primary]  [Secondary] │ <- Actions
└────────────────────────┘
```

**Styles:**
- Background: white (#FFFFFF)
- Shadow: lg (elevation + depth)
- Border radius: 12px
- Padding: 24px
- Overlay: semi-transparent (backdrop)

**Behavior:**
- Modal (blocks background interaction)
- Keyboard: Escape to close, Tab to navigate buttons
- Focus management: First interactive element focused on open

---

## Message Bubble Component

**Anatomy:**
```
Sent (Right-aligned):
┌─────────────────────────────┐
│ Hello there!               │ <- Blue background
│ 3:45 PM                    │
└─────────────────────────────┘

Received (Left-aligned):
┌─────────────────────────────┐
│ Hi! How are you?            │ <- Gray background
│ 3:46 PM                     │
└─────────────────────────────┘
```

**Styles:**
- Sent: primary color (#49B89D) background, white text
- Received: surface (#F9FAFB) background, dark text
- Border radius: 12px
- Padding: 12px horizontal, 8px vertical
- Font: 16px, regular
- Timestamp: 12px, secondary gray, below message

**Code Template:**
```swift
HStack(alignment: .bottom) {
  if isSent {
    Spacer()
    VStack(alignment: .trailing) {
      Text(message)
        .padding(12)
        .background(Color(hex: "#49B89D"))
        .foregroundColor(.white)
        .cornerRadius(12)
      Text(timestamp)
        .font(.system(size: 12))
        .foregroundColor(.gray)
    }
  } else {
    VStack(alignment: .leading) {
      Text(message)
        .padding(12)
        .background(Color(hex: "#F9FAFB"))
        .foregroundColor(.black)
        .cornerRadius(12)
      Text(timestamp)
        .font(.system(size: 12))
        .foregroundColor(.gray)
    }
    Spacer()
  }
}
.padding(.horizontal, 16)
.padding(.vertical, 8)
```

---

## Avatar Component

**Variants:**
- Small (32x32px)
- Medium (40x40px)
- Large (56x56px)

**States:**
- With image (circular)
- Placeholder (initials or icon)
- Loading (skeleton)
- Offline (badge indicator)

**Styles:**
- Shape: Circle
- Border: none
- Fallback: light gray background + user initials

**Code Template:**
```swift
AsyncImage(url: URL(string: photoUrl)) { image in
  image.resizable()
    .scaledToFill()
    .frame(width: 40, height: 40)
    .clipShape(Circle())
} placeholder: {
  Circle()
    .fill(Color.gray.opacity(0.3))
    .frame(width: 40, height: 40)
    .overlay(
      Text(initials)
        .font(.system(size: 14, weight: .semibold))
    )
}
```

---

## List Item Component

**Anatomy:**
```
┌─────────────────────────────────────┐
│ [Icon] Title      [Badge/Value] →   │
│        Subtitle                     │
└─────────────────────────────────────┘
```

**States:**
- Default
- Hover
- Selected
- Disabled

**Properties:**
- Icon (left)
- Title + Subtitle
- Value/Badge (right)
- Divider: show/hide
- Selectable: true/false

**Styles:**
- Padding: 16px
- Height: 56px (min)
- Border-bottom: 1px divider
- Tap target: full cell

---

## Accessibility Requirements

All components must support:

- **Color Contrast**
  - Text: 4.5:1 minimum (WCAG AA)
  - UI Components: 3:1 minimum

- **Touch Targets**
  - Minimum: 44x44 points
  - Spacing: 8px between targets

- **Keyboard Navigation**
  - Tab to navigate all interactive elements
  - Enter/Space to activate buttons
  - Escape to close modals

- **Screen Readers**
  - Semantic HTML/accessibility labels
  - Button text visible or announced
  - Form labels associated with inputs
  - Error messages announced

- **Focus Indicators**
  - Visible focus ring (2px primary color)
  - Never remove focus outline

---

## Design Token References

All components use tokens from `/Design/design-tokens.md`:

```
Colors:
- Primary: color-primary (#49B89D)
- Secondary: color-success (#10B981)
- Background: color-background (#FFFFFF)
- Surface: color-surface (#F9FAFB)
- Border: color-border (#E5E7EB)
- Text: color-text-primary (#1F2937)

Spacing:
- Padding/Gap: spacing-md (16px)
- Button padding: spacing-sm (8px) / spacing-md (16px)

Typography:
- Body: 16px, regular
- Heading: 24px, bold
- Button: 16px, semibold

Radius:
- Standard: radius-md (8px)
- Modal: radius-lg (12px)

Shadows:
- Cards: shadow-md
- Modals: shadow-lg
```

---

## Implementation Notes

1. **Use design tokens** — Never hardcode values
2. **Test accessibility** — Run WCAG AA compliance checks
3. **Responsive design** — Components scale to all screen sizes
4. **Consistent spacing** — Use spacing token values
5. **State management** — Handle all states (default, hover, disabled, etc.)
6. **Performance** — Images lazy-load, modals don't block rendering

---

**Status:** Complete  
**Last Updated:** 2026-05-10
