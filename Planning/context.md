# CoffeeCall Project Context

This file is a shared rolling log for all AI tools working on CoffeeCall.

Rules:
- Append new entries at the top under the latest session.
- Keep entries short and factual.
- If this file grows too large, delete the oldest session entries and keep only the most recent ones.
- Retention target: keep the latest 5 session entries or roughly the latest 300 lines, whichever comes first.

## Session: Antigravity — Navigation Stability & UI Polish (2026-05-13)

### Changed by: Antigravity

**What changed:**
- **Refactored Navigation:** Migrated the onboarding and auth flow to a single `NavigationStack` root in `ContentView`. Removed redundant `NavigationStack` wrappers from child screens to prevent state synchronization issues and broken transitions.
- **Fixed Onboarding Navigation:** Resolved a compiler type-checking error in `TabView` by unifying the parameter signatures of all slides. Added a `navigateToAuth` state to `OnboardingScreen` and implemented it via `.navigationDestination` for a smooth transition from Slide 5 to `PhoneAuthScreen`.
- **Improved UI Interaction:** Enhanced `PrimaryButton` by adding `.contentShape(Rectangle())` to the label. This ensures the entire button surface (including the background) is hit-testable and responsive to touch, fixing intermittent interaction failures.
- **Code Cleanup:** Replaced the legacy `NavigationLink` in `OnboardingScreen` Slide 5 with a consistent `PrimaryButton`.

**Why:** Nested `NavigationStack`s were causing navigation triggers to fail. The `TabView` compiler error was a "gotcha" where heterogeneous child signatures in a page-style TabView caused type inference failures.

**Files updated:**
- `apps/frontend/Coffee_Call/Coffee_Call/App/ContentView.swift`
- `apps/frontend/Coffee_Call/Coffee_Call/Screens/OnboardingScreen.swift`
- `apps/frontend/Coffee_Call/Coffee_Call/Components/PrimaryButton.swift`
- `Planning/context.md`

---

## Session: Codex — Onboarding TabView Navigation Diagnosis (2026-05-13)

### Changed by: Codex

**What changed:**
- Diagnosed `OnboardingScreen` page navigation where tapping the first CTA did not visibly switch the `TabView`.
- Added temporary debug prints to confirm the button action fired and `currentPage` changed from `0` to `1`.
- Removed the temporary prints after confirmation.
- Fixed `ContentView` layout by removing `.ignoresSafeArea()` from the whole `OnboardingScreen` inside `NavigationStack`.
- Hid the navigation bar with `.toolbar(.hidden, for: .navigationBar)` instead.
- Follow-up: moved onboarding image backgrounds into a root `ZStack` behind the `TabView`, keyed by `currentPage`, so image backgrounds cover the status bar and home indicator without invalidating `TabView` paging layout.

**What was learned:**
- The `TabView(selection: $currentPage)` and `.tag(0...4)` wiring was correct.
- The button action was firing correctly; this was not a binding or state propagation bug.
- The real symptom came from SwiftUI page `TabView`'s underlying `UICollectionView` getting invalid sizing:
  - `item height must be less than the height of the UICollectionView minus the section/content insets`
  - logged with adjusted inset `{59, 0, 34, 0}`
- Root cause: forcing the entire onboarding `TabView` to ignore safe areas inside `NavigationStack` conflicted with UIKit's paging layout insets.
- Keep full-bleed imagery at the slide/background layer, not by applying `.ignoresSafeArea()` to the whole `TabView` from `ContentView`.
- Pattern to keep: if a screen uses a page `TabView` plus full-screen image background, render the background outside/behind the `TabView` and apply `.ignoresSafeArea()` only to that background layer.

**Separate warnings not responsible for the page switch bug:**
- Firebase Crashlytics/Messaging logs are unrelated to onboarding paging.
- `UIBackgroundModes` remote-notification warning is unrelated to onboarding paging.
- Missing `coffeePurple` asset warning is separate visual/config cleanup.

**Files updated:**
- `apps/frontend/Coffee_Call/Coffee_Call/App/ContentView.swift`
- `apps/frontend/Coffee_Call/Coffee_Call/Screens/OnboardingScreen.swift`

---

## Session: Antigravity — Navigation & Build System Fixes (2026-05-13)

### Changed by: Antigravity

**What changed:**
- **Fixed Navigation Deprecations:** Migrated `PhoneAuthScreen`, `OTPVerificationScreen`, `ProfileSetupScreen`, and `PermissionsScreen` from the deprecated `NavigationLink(destination:isActive:)` to the modern `.navigationDestination(isPresented:)` for iOS 16 compatibility.
- **Fixed Build Errors:** Resolved `Extra arguments` errors in `OnboardingScreen` by updating `PrimaryButton` to support optional `height`, `cornerRadius`, and `icon` parameters.
- **Fixed Scope Errors:** Corrected `UltraThinMaterial` usage in `BetaBadge` and `GlassmorphicCard` (applied as `ShapeStyle` via `.fill()` instead of as a `View`).
- **Standardized UI Tokens:** Replaced hardcoded color strings with semantic extensions (e.g., `.brandPrimary`) in `BetaBadge`.
- **Documentation:** Created `docs/Planning/build-guidelines.md` to track recurring build issues and design patterns.

## Session: Antigravity — Xcode Folder Reference Fix (2026-05-13)

### Changed by: Antigravity

**What changed:**
- **Fixed Build Errors:** Resolved `Cannot find type 'Activity' in scope` errors in `ActivityCardView` and `DiscoveryScreen`.
- **Xcode Project Maintenance:**
  - Removed the `Models/` folder reference (blue folder in Xcode) which was causing its contents to be treated as resources instead of source code.
  - Created a proper `Models` group (yellow folder in Xcode).
  - Added `Activity.swift` to the `Models` group and registered it in the `Sources` build phase for the `Coffee_Call` target.
- **Tools Used:** Created and executed a Ruby script `scratch/fix_project.rb` using the `xcodeproj` gem to safely modify the project structure.

**Why:** Xcode treats "Folder References" (blue folders) as bundles where files are NOT compiled. By converting it to a "Group" (yellow folder), the Swift files inside are correctly identified as source code to be compiled, making the `Activity` type available across the app scope.

**Files updated:**
- `apps/frontend/Coffee_Call/Coffee_Call.xcodeproj/project.pbxproj`
- `scratch/fix_project.rb` (new)

---

## Session: Antigravity — UltraThinMaterial Scope Fix (2026-05-13)

### Changed by: Antigravity

**What changed:**
- **Fixed Build Error:** Resolved `Cannot find 'UltraThinMaterial' in scope` by replacing invalid `UltraThinMaterial()` view instantiation with `Rectangle().fill(.ultraThinMaterial)`.
- **Components Updated:**
  - `Components/GlassmorphicCard.swift`: Updated background ZStack to use proper Material fill.
  - `Components/BetaBadge.swift`: Updated background ZStack to use proper Material fill.
- **Verification:** Verified that `ActivityCardView.swift` uses the correct `.background(.ultraThinMaterial)` modifier.

**Why:** `UltraThinMaterial` is a `ShapeStyle` in SwiftUI, not a `View`. It cannot be instantiated with `()` as a standalone view in a `ZStack`. Using `Rectangle().fill(.ultraThinMaterial)` is the correct way to use it as a layer.

**Files updated:**
- `Components/GlassmorphicCard.swift`
- `Components/BetaBadge.swift`

---

## Session: Kilo AI — Landing Screen Figma Compliance Fixes (2026-05-13)

### Changed by: Kilo AI

**What changed:**
- **Background & Overlay:** Fixed UnsplashBackground gradient to use `#243447` (RGB 36,52,71) with opacity 0.9→0.4; added brightness(0.8) filter to image.
- **Badge:** Created new `BetaBadge` component with glassmorphic styling (white/10 background, white/20 border, UltraThinMaterial blur, no shadow).
- **Typography:** Updated headline to 40px black font with lineSpacing(4); added letter spacing tracking(-0.5).
- **Glass Cards:** Modified `GlassmorphicCard` to use white/10 background, white/20 border, UltraThinMaterial blur; fixed emoji content (🌅, 📸) and proper text styling.
- **Card Colors:** Added `coffeePurple` color asset (#8E7DBE); updated card fills to `brandPrimary` (teal) and `brandPurple`.
- **Card Rotations:** Added -2° and +2° rotations to cards for visual balance.
- **CTA Button:** Created custom inline button with 64px height, 24px radius, brandPrimary color, proper shadow, and arrow icon.
- **Spacing:** Fixed all padding values to match 8px grid (top 96px, horizontal 32px, headline bottom 48px, CTA bottom 64px).
- **Animations:** Added entrance animations with staggered delays (headline 0.2s, cards 0.4-0.6s, CTA 0.6s).
- **Colors:** Added `darkOverlay` color token for background gradient.
- **Build Fix:** Removed duplicate Info.plist reference from Xcode project.

**Why:** Landing screen implementation did not match Figma design — wrong colors, fonts, spacing, and styling throughout.

**Files updated:**
- `Screens/OnboardingScreen.swift` — Complete Slide1View refactor
- `Components/GlassmorphicCard.swift` — Glass styling update
- `Components/BetaBadge.swift` — New glass badge component
- `Components/PrimaryButton.swift` — Reverted to original (custom button for Slide1)
- `DesignSystem/Color+Extensions.swift` — Added darkOverlay and brandPurple
- `Assets.xcassets/coffeePurple.colorset/Contents.json` — New color asset
- `DesignSystem/AppStrings.swift` — Removed arrow from slide1CTA
- `Coffee_Call.xcodeproj/project.pbxproj` — Fixed duplicate Info.plist

## Session: Xcode Folder Reorganization (2026-05-13)

### What Changed
- Moved the core app files into a physical `App/` folder:
  - `Coffee_CallApp.swift`
  - `ContentView.swift`
  - `Persistence.swift`
  - `Info.plist`
  - `GoogleService-Info.plist`
- Updated the Xcode project to point to the new `App/` paths.
- Replaced the absolute-path `DesignSystem` group entry with a relative folder-based group.

### Why
- Keep the source tree folder-based instead of leaving core app files loose at the project root.
- Make the Xcode navigator mirror the filesystem layout more closely.

### Files Updated
- `/apps/frontend/Coffee_Call/Coffee_Call/App/Coffee_CallApp.swift`
- `/apps/frontend/Coffee_Call/Coffee_Call/App/ContentView.swift`
- `/apps/frontend/Coffee_Call/Coffee_Call/App/Persistence.swift`
- `/apps/frontend/Coffee_Call/Coffee_Call/App/Info.plist`
- `/apps/frontend/Coffee_Call/Coffee_Call/App/GoogleService-Info.plist`
- `/apps/frontend/Coffee_Call/Coffee_Call.xcodeproj/project.pbxproj`

### Next Step
- If needed, continue cleaning the remaining Xcode groups so the navigator stays aligned with the folder structure.

## Session: Antigravity — Onboarding Screen Fixes & Refactoring (2026-05-13)

### Changed by: Antigravity

**What changed:**
- Refactored `Screens/OnboardingScreen.swift`:
  - Fixed critical syntax errors in `UnsplashBackground` (broken braces and undefined state).
  - Migrated all `AsyncImage` instances to `CoffeeImageView` (Standard Image Protocol).
  - Wrapped content in `NavigationView` to enable `NavigationLink` functionality on the final slide.
  - Standardized font sizes and weights to match design-tokens.
  - Fixed progress bar logic (total slides updated to 4).
  - Ensured all background colors use semantic tokens (`surfaceMain`, `backgroundMain`).

**Why:** Syntax errors were preventing compilation. Navigation was non-functional due to missing container. Image overflow was a risk without `CoffeeImageView`.

**Files updated:**
- `Screens/OnboardingScreen.swift`

**Verification:**
- Open `OnboardingScreen` in Simulator.
- Verify swiping through all 5 slides.
- Verify "Start Exploring" button navigates to `PhoneAuthScreen`.

---

## Session: Antigravity — Firebase SDK Fix & Package Resolution (2026-05-13)

### Changed by: Antigravity

**What changed:**
- Triggered `xcodebuild -resolvePackageDependencies` to re-fetch Firebase SDK files.
- Identified that `status_errno.cc` missing error is a byproduct of DerivedData cleanup requiring a full package re-resolution.
- Verified `Color+Extensions.swift` manual updates: added `brandPurple` and `darkOverlay`.

**Why:** Deleting DerivedData (to fix path issues) also clears the Swift Package Manager (SPM) checkouts. Xcode needs to re-fetch these dependencies from the web.

**Files updated:**
- `DesignSystem/Color+Extensions.swift` (manual update confirmed)

**Verification:**
- In Xcode UI: **File → Packages → Reset Package Cache** followed by **Product → Build**.

---

## Session: Antigravity — Build Error Fixes (2026-05-13)

### Changed by: Antigravity

**What changed:**
- Deleted Xcode derived data (`~/Library/Developer/Xcode/DerivedData/Coffee_Call-*`).
  - Fixed "Build input files cannot be found: `.../App/App/Coffee_CallApp.swift`" error.
  - Root cause: stale Xcode index cached a double `App/App/` path; files correctly exist at `Coffee_Call/App/`.
- `Cannot find type 'Activity' in scope` — cascading error from derived data; resolved by clean derived data + `Models/Activity.swift` already registered.

**Why:** Xcode's build index caches wrong resolved paths when project structure changes. Always clean derived data after significant xcodeproj changes.

**Files updated:** None (project structure already correct).

**Verification:** After derived data delete, do `Cmd+Shift+K` (Clean) then `Cmd+B` (Build) in Xcode.

---

## Session: Antigravity — Animation System & Model Extraction (2026-05-13)

### Changed by: Antigravity

**What changed:**
- Created `DesignSystem/AnimationSystem.swift`: centralized animation token system.
  - `CoffeeAnimation.spring` / `.springSnap` / `.springGentle` / `.easeOut` presets.
  - `PressScaleModifier` — all buttons scale down on press (Figma behavior).
  - `SlideUpEntranceModifier` — slide up + fade in on screen load.
  - `FadeInModifier` — opacity fade on appear.
  - View extensions: `.pressScale()`, `.slideUpEntrance(delay:)`, `.fadeIn(delay:)`.
- Applied animations across `DiscoveryScreen`, `ActivityCardView`, `FloatingTabBar`:
  - Staggered card entrances (each delayed by 0.08s).
  - Header/search/chips slide up on load.
  - Tab icon spring scale on switch.
  - Heart/join button spring state change.
- Extracted `Activity` + `ActivityStatus` into `Models/Activity.swift`.
  - Removed duplicate definitions from `ActivityCardView.swift`.
  - Fixes cascading `Cannot find type 'Activity' in scope` build error.
- Registered `AnimationSystem.swift` and `Models/Activity.swift` in Xcode project via xcodeproj Ruby script.

**Why:** Models must never live inside View files. Animation values must be centralized tokens, not inline magic numbers.

**Rules established:**
- All animations use `CoffeeAnimation.*` tokens — never inline values.
- All data models live in `Models/` directory.
- All images use `CoffeeImageView` — never raw `AsyncImage`.

**Files updated:**
- `DesignSystem/AnimationSystem.swift` (new)
- `Models/Activity.swift` (new)
- `Components/ActivityCardView.swift`
- `Components/FloatingTabBar.swift`
- `Screens/Main/DiscoveryScreen.swift`

**Verification:** Clean build (`Cmd+Shift+K`) required after xcodeproj changes.

---

## Session: Antigravity — Image Overflow Fix & Floating Tab Bar (2026-05-13)

### Changed by: Antigravity

**What changed:**
- Created `Components/CoffeeImageView.swift`: canonical image component using `GeometryReader` + `clipped()`. **All images in the app must use this.** Never use raw `AsyncImage` directly.
- Fixed `ActivityCardView.swift`: replaced raw `AsyncImage` with `CoffeeImageView`; applied `clipShape(RoundedRectangle)` at card level so nothing bleeds outside bounds.
- Created `Components/FloatingTabBar.swift`: custom floating pill tab bar with spring animations, semantic colors, and `AppStrings.Tabs` labels. Replaces native SwiftUI `TabView` chrome.
- Rebuilt `MainTabView.swift`: uses ZStack (content + FloatingTabBar overlay) instead of native TabView — no iOS tab bar chrome.
- Added `AppStrings.Tabs` namespace: `discover`, `myPosts`, `messages`, `profile`.

**Rule established:** Always use `CoffeeImageView` for all image display. Never use raw `AsyncImage`.

**Files updated:**
- `Components/CoffeeImageView.swift` (new)
- `Components/FloatingTabBar.swift` (new)
- `Components/ActivityCardView.swift`
- `Screens/Main/MainTabView.swift`
- `DesignSystem/AppStrings.swift`

---

## Session: Antigravity — Discovery Screen Rebuild to Match Figma (2026-05-13)

### Changed by: Antigravity

**What changed:**
- Rebuilt `ActivityCardView.swift` to match actual Figma design:
  - Full-bleed background image card (380pt height)
  - Gradient overlay for readability
  - `STARTING SOON` / `HAPPENING NOW` / `LATER TODAY` status badge
  - Vibe tag badge (e.g. RELAXED, CHILL, SOCIAL) in `brandPrimary`
  - Host avatar with stacked `+N` attendee bubble
  - `Join Moment` CTA button + heart save button
- Rebuilt `DiscoveryScreen.swift` to match actual Figma design:
  - `Hey [name]` greeting + `N meetups happening nearby` subtitle
  - Top-right icon row: bell + map + avatar initials circle
  - Search bar with filter icon
  - Horizontal scrolling category chips with spring animation
  - Dark navy circular FAB (replaces wide pill button)
- Added `AppStrings.Discovery.joinMomentBtn = "Join Moment"`
- Added `AppStrings.Auth.otpTitle`, `.verifying`, `.otpCTA`, `.sentTo` (build fixes)

**Why:** Previous Discovery implementation was generic and did not match the actual Figma design shared by user.

**Files updated:**
- `Components/ActivityCardView.swift`
- `Screens/Main/DiscoveryScreen.swift`
- `DesignSystem/AppStrings.swift`

---

## Session: Antigravity — Discover Page & Reusable Components (2026-05-13)

### What Changed
- **Created Discovery Screen:** Built `DiscoveryScreen.swift` with a functional activity feed, category filtering (Coffee, Walks, Gaming, etc.), and search functionality.
- **Reusable Component Library:** Extracted `ActivityCardView.swift` and `CategoryChip.swift` into a dedicated `Components/` directory for cross-screen reuse.
- **Navigation Integration:** Created `MainTabView.swift` as the primary app container and integrated it into `ContentView.swift` for authenticated users.
- **Design System Expansion:** Updated `AppStrings.swift` and `AppIcons.swift` with discovery-specific tokens (categories, search, map, post button).
- **Xcode Integration:** Updated Ruby scripts and modified the `.xcodeproj` to include the new `Main` and `Components` groups and files.
- **Repository Setup:** Created a private GitHub repository (`robindev2026-a11y/CoffeeCall`) and pushed all current progress.

### Why
- The Discovery/Home screen is the core of the CoffeeCall experience, allowing users to find and join nearby activities.
- Moving components to a shared library ensures UI consistency and reduces code duplication as the app grows (e.g., for "My Activities").
- Establishing a remote repository provides backup and enables collaboration.

### Files Updated
- `/apps/frontend/Coffee_Call/Coffee_Call/Screens/Main/DiscoveryScreen.swift` (NEW)
- `/apps/frontend/Coffee_Call/Coffee_Call/Screens/Main/MainTabView.swift` (NEW)
- `/apps/frontend/Coffee_Call/Coffee_Call/Components/ActivityCardView.swift` (NEW)
- `/apps/frontend/Coffee_Call/Coffee_Call/Components/CategoryChip.swift` (NEW)
- `/apps/frontend/Coffee_Call/Coffee_Call/DesignSystem/AppStrings.swift`
- `/apps/frontend/Coffee_Call/Coffee_Call/DesignSystem/AppIcons.swift`
- `/apps/frontend/Coffee_Call/Coffee_Call/ContentView.swift`
- `/apps/frontend/Coffee_Call/Coffee_Call/DesignSystem/Color+Extensions.swift` (Cleanup)

### Next Step
- Build the **"Post Activity"** modal UI and logic.
- Implement the **"Messages Thread"** screen for activity coordination.

## Session: Antigravity — Design System "Deep Clean" (2026-05-13)

### What Changed
- **Total Tokenization:** Removed 100% of hardcoded strings from all auth and onboarding screens, including error messages, tip content, and debug labels.
- **AppStrings Expansion:** Added comprehensive tokens for `Auth.tipTitle`, `Auth.locationRadiusDesc`, `Auth.skipProfileDebug`, and onboarding social proof.
- **Legacy Cleanup:** Deleted all legacy `coffee-` prefixed color aliases from `Color+Extensions.swift`.
- **Refactoring:** Updated `LocationPermissionScreen.swift`, `ProfileSetupScreen.swift`, and `OnboardingScreen.swift` to strictly use semantic tokens and `AppStrings`.
- **Commit:** Committed all standardization changes with message: `style: deep clean of design system, removed all hardcoded strings and legacy color aliases`.

### Why
- Parity with the `Design/design-tokens.md` standard.
- Centralizing UI text enables future localization and simplifies copy updates.
- Removing legacy aliases prevents technical debt and ensures developers use only the approved semantic palette.

### Files Updated
- `/apps/frontend/Coffee_Call/Coffee_Call/DesignSystem/AppStrings.swift`
- `/apps/frontend/Coffee_Call/Coffee_Call/DesignSystem/Color+Extensions.swift`
- `/apps/frontend/Coffee_Call/Coffee_Call/Screens/Auth/LocationPermissionScreen.swift`
- `/apps/frontend/Coffee_Call/Coffee_Call/Screens/Auth/ProfileSetupScreen.swift`
- `/apps/frontend/Coffee_Call/Coffee_Call/Screens/OnboardingScreen.swift`
- `/apps/frontend/Coffee_Call/Coffee_Call/Screens/Auth/ReadyScreen.swift`
- `/apps/frontend/Coffee_Call/Coffee_Call/Screens/Auth/PhoneAuthScreen.swift`
- `/apps/frontend/Coffee_Call/Coffee_Call/Screens/Auth/OTPVerificationScreen.swift`

## Session: Brand and Product Brainstorm Notes (2026-05-13)

### What Was Noted
- Brand the product as a social app focused on bringing people together.
- Keep the logo theme social and simple; no unique logo system required.
- Prioritize messaging as the core product behavior.
- Build the story on trust, privacy, and a strong foundation.
- Explore business tie-ups with cafes and restaurants.
- Consider gift cards, promotions, and app-organized events for growth.
- Consider future friend features and community/event promotion.
- Consider broad audience segments: Gen Z, millennials, boomers, sports, exercise/walking users.

### Product Ideas for Later Review
- Add user ratings / activity scoring.
- Penalize no-shows by lowering rating.
- Let event creators choose how many people can request and how many extra members can join.
- Let requesters indicate how many people they are bringing.
- Allow creators to add extra members from existing profiles.
- Add a location toggle button on the home page.
- Use rounded distance text instead of exact distance, for example "less than 4 km" instead of "3.7 km".
- Add a skip option on the permissions page so the app can continue without location access.

### Notes on Current MVP Alignment
- Some ideas overlap with the current MVP, but ratings, penalties, and richer group controls are future-facing and should stay out of the near-term build unless explicitly approved.

### Next Step
- Review these ideas against the current MVP scope before moving any of them into decisions or implementation.

## Session: Antigravity — Design System Standardization & Semantic Naming (2026-05-13)

### What Changed
- **Standardized Asset Management:** Created `AppStrings.swift`, `AppIcons.swift`, and `AppImages.swift` in `DesignSystem/` to centralize all text, icons, and image URLs.
- **Semantic Color Naming:** Refactored `Color+Extensions.swift` to use a semantic structure (`brandPrimary`, `backgroundMain`, `textPrimary`, `statusSuccess`, etc.) rather than descriptive names.
- **Documentation:** Updated `Design/design-tokens.md` with the new "Implementation Standard" for asset access.
- **Refactoring Components:** Updated `PrimaryButton.swift`, `PillBadge.swift`, and `GlassmorphicCard.swift` to use the new semantic tokens and strings.
- **Refactoring Screens:** Completed the refactor of ALL onboarding and authentication screens (`OnboardingScreen.swift`, `PhoneAuthScreen.swift`, `OTPVerificationScreen.swift`, `ProfileSetupScreen.swift`, `PermissionsScreen.swift`, `ReadyScreen.swift`, and `ContentView.swift`) to implement `AppStrings`, `AppIcons`, `AppImages`, and semantic colors.
- **Project Maintenance:** Updated `AppStrings.swift` and `AppIcons.swift` to include missing tokens for the new screens.
- **Commit:** Staged and committed the design system foundation and the complete refactor of the onboarding/auth flow.

### Why
- Eliminate magic strings and descriptive color names (like "red") which are brittle and hard to maintain.
- Ensure type-safety for SF Symbols and Unsplash URLs across the entire application.
- Prepare the codebase for dark mode support and future theming changes via centralized semantic tokens.
- Maintain consistency with the Figma design brief by standardizing UI elements across all 8 core screens.

### Next Step
- Begin building the `Discovery/Home` screen (the main activities list) using the established standardized tokens and components.
- Implement the "Post Activity" modal structure.

### What Changed
- Added `Slide5View` ("Start Exploring" / pre-auth welcome screen) as the 5th slide in `OnboardingScreen.swift`, inserted between the interests picker and `PhoneAuthScreen`.
- Overhauled `ProfileSetupScreen.swift` to match the "Create your profile" UI design with dashed squircle avatar, Take Photo/Choose Library buttons, and restyled text field.
- Created `PermissionsScreen.swift` — the "Almost there" screen with Location Services and Real-time Updates cards.
- Created `ReadyScreen.swift` — the "You're ready!" final celebration screen with checkmark icon and First Activity Tip card.
- Updated `AuthViewModel.swift`: removed `isAuthenticated = true` from `saveProfile`, added `completeOnboarding()` method, added `hasCompletedOnboarding` `UserDefaults` flag check in `init()`.
- Added `PermissionsScreen.swift` and `ReadyScreen.swift` to the Xcode project target via `xcodeproj` Ruby script.
- Build verified: `** BUILD SUCCEEDED **`.

### Why
- The "Start Exploring" pre-auth screen was missing from the onboarding flow entirely.
- After OTP verification, the app was skipping Profile Setup, Permissions, and the final Ready screen, jumping straight to the Home screen.

### Files Updated
- `/apps/frontend/Coffee_Call/Coffee_Call/Screens/OnboardingScreen.swift`
- `/apps/frontend/Coffee_Call/Coffee_Call/Screens/Auth/ProfileSetupScreen.swift`
- `/apps/frontend/Coffee_Call/Coffee_Call/Screens/Auth/PermissionsScreen.swift` (NEW)
- `/apps/frontend/Coffee_Call/Coffee_Call/Screens/Auth/ReadyScreen.swift` (NEW)
- `/apps/frontend/Coffee_Call/Coffee_Call/ViewModels/AuthViewModel.swift`
- `/apps/frontend/Coffee_Call/Coffee_Call.xcodeproj/project.pbxproj`

### Next Step
- Test the full onboarding flow end-to-end in the simulator: Onboarding slides → Start Exploring → Phone Auth → OTP → Profile Setup → Permissions → You're ready! → Home.

## Session: Codex OTP Bypass for Development (2026-05-12)

### What Changed
- Codex added a DEBUG-only bypass in `sendOTP` so the app marks the user authenticated immediately.
- Codex stopped the phone auth screen from navigating to the OTP screen when the bypass is active.

### Why
- The OTP flow was still getting stuck on "Sending..." during development and simulator testing.
- This lets the team reach the authenticated main flow immediately while preserving real auth behavior outside DEBUG.

### Files Updated
- `/apps/frontend/Coffee_Call/Coffee_Call/ViewModels/AuthViewModel.swift`
- `/apps/frontend/Coffee_Call/Coffee_Call/Screens/Auth/PhoneAuthScreen.swift`

### Next Step
- Rebuild and confirm the app lands on the authenticated main view after phone number submission.

## Session: Codex Changes - Firebase Access and OTP Debugging (2026-05-12)

### What Changed
- Codex confirmed Firebase CLI login and project access.
- Codex switched the repo default Firebase project to `coffeecall-92f6f`.
- Codex verified the iOS app config matches the Firebase project.
- Codex hardened Firebase phone auth handling in the app:
  - explicit URL scheme in `Info.plist`
  - `UIApplicationDelegate` callback bridge
  - SwiftUI `onOpenURL` fallback
  - simulator test mode enabled
  - OTP send timeout and error handling

### Why
- The app was pointing at a stale Firebase default project and needed the real CoffeeCall project.
- Phone auth was getting stuck on "Sending..." in simulator flows, so the callback and testing path needed tightening.

### Files Updated
- `/.firebaserc`
- `/apps/frontend/Coffee_Call/Coffee_Call/Info.plist`
- `/apps/frontend/Coffee_Call/Coffee_Call/Coffee_CallApp.swift`
- `/apps/frontend/Coffee_Call/Coffee_Call/ViewModels/AuthViewModel.swift`

### Next Step
- Use Firebase test phone numbers in the simulator and retry OTP send.

## Session: OTP Send Timeout and Simulator Test Mode (2026-05-12)

### What Changed
- Enabled Firebase phone auth test mode automatically in the iOS simulator.
- Added a 30-second timeout to `sendOTP` so the UI does not stay stuck on "Sending..." forever.
- Added a guard for missing `verificationID` and better error logging.

### Why
- On the simulator, Firebase phone auth uses app-verification fallback and may hang unless test mode and test phone numbers are used.
- A timeout gives the user a visible failure instead of an indefinite spinner.

### Files Updated
- `/apps/frontend/Coffee_Call/Coffee_Call/ViewModels/AuthViewModel.swift`

### Next Step
- Use Firebase fictional phone numbers in the simulator, then retry OTP send.

## Session: Firebase Phone Auth Test Mode Fix (2026-05-12)

### What Changed
- Added `#if DEBUG` block to `Coffee_CallApp.swift` `init()` to set `Auth.auth().settings?.isAppVerificationDisabledForTesting = true`.

### Why
- Firebase Phone Auth requires this flag to allow "Test Phone Numbers" to bypass the APNs and reCAPTCHA checks when running on the iOS Simulator.

### Files Updated
- `/apps/frontend/Coffee_Call/Coffee_Call/Coffee_CallApp.swift`

### Verification
- Instructed user to rebuild and test the flow using a test number and country code combination.

## Session: Firebase Phone Auth Callback Hardening (2026-05-12)

### What Changed
- Added `UIKit` import to the SwiftUI app entry point.
- Kept the `UIApplicationDelegateAdaptor` bridge and added APNs notification handlers.
- Added a SwiftUI `.onOpenURL` fallback to forward Firebase redirect URLs to `Auth.auth().canHandle(url)`.

### Why
- Firebase phone auth on iOS can rely on a redirect URL callback during reCAPTCHA fallback.
- The SwiftUI-level URL handler makes the callback path more reliable if app delegate forwarding is not enough.

### Files Updated
- `/apps/frontend/Coffee_Call/Coffee_Call/Coffee_CallApp.swift`

### Verification
- Matched the implementation against the official Firebase phone auth iOS guidance.

### Next Step
- Rebuild the app and retry OTP send in the simulator.

## Session: Firebase Phone Auth Fix and Callback Bridge (2026-05-12)

### What Changed
- Added an explicit app `Info.plist` for the iOS target.
- Registered the Firebase phone auth callback URL scheme:
  - `app-1-835897938536-ios-0032b2f3736f46218fe1dd`
- Disabled generated Info.plist handling for the main app target and pointed Xcode at the new plist.
- Added an `AppDelegate` bridge in `Coffee_CallApp.swift` to forward incoming URLs to `Auth.auth().canHandle(url)`.

### Why
- iOS Firebase phone auth requires the custom callback scheme to be present in the built app plist.
- SwiftUI apps also need to pass the callback URL back to Firebase, or the auth flow can fail after OTP/SMS handoff.

### Files Updated
- `/apps/frontend/Coffee_Call/Coffee_Call/Info.plist`
- `/apps/frontend/Coffee_Call/Coffee_Call.xcodeproj/project.pbxproj`
- `/apps/frontend/Coffee_Call/Coffee_Call/Coffee_CallApp.swift`

### Verification
- Confirmed the plist is valid with `plutil -lint`.
- Confirmed the project file now points to the explicit plist.

### Next Step
- Rebuild the app in Xcode and retry phone number sign-in in the simulator.

## Session: Design Scope Validation (2026-05-12)

### What Happened
Validated initial Figma design brief (`CoffeeCall_Final_Figma_Brief.md`) against MVP architecture.

**Finding:** The initial brief was comprehensive but over-scoped - it described a v1.1+ product (15 screens with full reputation system) rather than the 3-week MVP (7-8 screens, no reputation).

### Decision
**Option A: MVP-First Approach** - Align design brief with 3-week timeline and existing architecture decisions.

**Key changes:**
- Reduced from 15 screens to 8 screens
- Removed reputation system (trust scores, badges, flakes)
- Removed post-meetup reviews and ratings
- Removed penalty system
- Removed scanner/radar visualization
- Removed settings screen (v1.2+)
- Kept design system (colors, typography, spacing)

### Deliverables
1. `CoffeeCall_MVP_Design_Brief.md` - finalized governance doc
2. `CoffeeCall_Final_Figma_Brief.md` - archived reference for v1.1+ planning
3. `decisions.md` - updated with design scope decision

### MVP Screens (8 Total)
1. Auth Flow
2. Discovery/Notifications List
3. Post Activity Modal
4. Acceptance Confirmation Dialog
5. Match Confirmed
6. Messages Thread
7. My Activities Dashboard
8. Profile View

### Next Steps
1. Design all 8 screens in Figma/Pencil
2. Build component library
3. Create interactive prototype
4. Handoff to code generation
5. Ship in 3 weeks

### Timeline Lock
- Design phase: Week 1
- Dev phase: Weeks 2-3
- Launch: 2026-05-25

---

**Owner:** Claude (Planner)  
**Status:** Active  
**Usage:** Read before starting a new AI-assisted session
