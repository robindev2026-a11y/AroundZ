# CoffeeCall Build & Design Guidelines

This document tracks recurring issues, build gotchas, and design patterns to ensure they are not repeated.

## 1. Xcode Project Structure
- **Groups vs. Folder References**: Source files (`.swift`) MUST be added to Xcode as **Groups** (yellow folders), not Folder References (blue folders). 
    - *Why:* Folder references are treated as bundles and their contents are not automatically compiled.
    - *Fix:* Use a Ruby script or manually remove the folder reference and "Add Files" as a group. Ensure files appear in the target's **Compile Sources** list.

## 2. SwiftUI Materials (Glassmorphism)
- **UltraThinMaterial**: `UltraThinMaterial` is a `ShapeStyle`, not a `View`. 
    - *Incorrect:* `UltraThinMaterial()`
    - *Correct:* `Rectangle().fill(.ultraThinMaterial)` or `.background(.ultraThinMaterial)`.
- **Opacity**: Use `Color.white.opacity(0.15)` for a frosted look on dark backgrounds.

## 3. Navigation (iOS 16+)
- **NavigationLink Deprecation**: Avoid `NavigationLink(destination:isActive:label:)`.
    - *Fix:* Use `.navigationDestination(isPresented:destination:)` combined with a `@State` boolean.
    - *Pattern:*
      ```swift
      .navigationDestination(isPresented: $navigateToNext) {
          NextScreen()
      }
      ```

## 4. Design System Components
- **Flexibility**: Shared components (e.g., `PrimaryButton`) should use optional parameters with default values to accommodate unique screen requirements without breaking existing implementations.
- **Tokens**: Always use semantic tokens (e.g., `.brandPrimary`, `.surfaceMain`) rather than hardcoded `Color("name")` strings.

## 5. Animation Tokens
- **Standardized Delays**: Entrance animations should follow these staggered delays:
    - Headlines/Progress: `0.2s`
    - Content/Cards: `0.4s - 0.6s`
    - CTA Buttons: `0.6s`

## 6. Build Environment
- **Concurrent Builds**: NEVER run `xcodebuild` in the terminal while Xcode is open and building. 
    - *Why:* This locks the build database and causes "Internal Inconsistency" errors (incomplete targets).
    - *Fix:* Close Xcode or terminate terminal builds. If the database gets corrupted, delete the project's **Derived Data** folder.

