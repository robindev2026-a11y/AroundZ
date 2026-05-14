# CoffeeCall Project Context

This file is a shared rolling log for all AI tools working on CoffeeCall.

Rules:
- Append new entries at the top under the latest session.
- Keep entries short and factual.
- If this file grows too large, delete the oldest session entries and keep only the most recent ones.
- Retention target: keep the latest 5 session entries or roughly the latest 300 lines, whichever comes first.

## Session: Antigravity — Fix View+Availability SDK Compatibility (2026-05-14)

### Changed by: Antigravity

**What changed:**
- `View+Availability.swift`: All wrappers for iOS 16.4+ and iOS 17+ APIs changed to no-ops (`self`) with the real implementations sitting in commented lines beside each function body.
- Root cause: `if #available` is a runtime guard only. If the API symbol doesn't exist in the current SDK headers (Xcode 14.2 = iOS 16.2 SDK), the compiler still rejects the reference inside the `if #available` block.

**Upgrade path (no call-site changes needed):**
- **Xcode 14.3+** (iOS 16.4 SDK): uncomment lines in `coffeeSheetCornerRadius`, `coffeeSheetDragIndicator`, `coffeeScrollBounceBehaviorBasedOnSize`.
- **Xcode 15+** (iOS 17 SDK): uncomment lines in `coffeeScrollTargetLayout`, `coffeeImpactFeedback`, `coffeeSelectionFeedback`, `coffeeBounceSymbol`, `coffeeNumericContentTransition`.

**Files updated:**
- `apps/frontend/Coffee_Call/Coffee_Call/DesignSystem/View+Availability.swift`
- `Planning/context.md`

---



### Changed by: Antigravity

**What changed:**
- `CategoryChip.swift`: Added SF symbol icons per category (bolt, cup.and.saucer, figure.walk, book, fork.knife, gamecontroller, lightbulb). Active chip now has scale-1.05 animation matching Figma.
- `ActivityCardView.swift`: Status badge uses animated mint pulse dot + `.ultraThinMaterial` `.clipShape(Capsule())`. Vibe badge clipped to `Capsule()`. Participant count badge is mint `Capsule`. Join button has mint shadow.
- `DiscoveryScreen.swift` (full rewrite):
  - Header: mint notification dot overlay on bell, mint ring on user avatar button.
  - Search bar corner radius 20 (was 16); filter button uses `backgroundMain` tinted pill.
  - Category chips now pass icons from chip definitions array.
  - 5 richly varied sample activities (walks, coffee, study, food, street photo).
  - Join tap opens `JoinConfirmSheet` (avatar + info card + PrimaryButton) via `.sheet`.
  - On confirm, triggers `MatchCelebrationSheet` (full mint background, overlapping avatars, handshake emoji, keep-discovering CTA).
  - Removed `presentationCornerRadius`/`presentationDragIndicator` — not available on iOS 16.2 target.

**Verification:**
- `BUILD SUCCEEDED` on iPhone 14 Pro simulator (iOS 16.2).
- Searched all three touched `.swift` files for old blue/coral/`.rounded` drift — none found.
- All colors use semantic tokens from `Color+Extensions.swift`; no hardcoded hex.

**Files updated:**
- `apps/frontend/Coffee_Call/Coffee_Call/Components/CategoryChip.swift`
- `apps/frontend/Coffee_Call/Coffee_Call/Components/ActivityCardView.swift`
- `apps/frontend/Coffee_Call/Coffee_Call/Screens/Main/DiscoveryScreen.swift`
- `Planning/context.md`

---

## Session: Codex — Auth To Discovery Figma Parity Pass (2026-05-14)

### Changed by: Codex

**What changed:**
- Rechecked the onboarding/auth/profile/permissions/ready/discovery path against `/Users/development/Downloads/figmaCoffe`.
- Restored the authenticated app gate in `ContentView` so `ReadyScreen` can enter `MainTabView`/Discovery.
- Corrected `PrimaryButton` to use mint `#53B8A6` as the default fill instead of pressed mint.
- Added a semantic `surfaceSecondary` SwiftUI token and matching `coffeeSurfaceSecondary` asset for `#F4F4F8`.
- Updated phone, OTP, profile setup, permissions, ready, onboarding, discovery header, chips, FAB, and activity cards to better match Figma fonts, colors, radii, spacing, and feed proportions.

**Verification:**
- Searched SwiftUI sources for old blue/coral/rounded-font drift after the pass.
- Attempted `xcodebuild`; sandbox/CoreSimulator/package graph errors blocked a useful result, and the elevated retry was interrupted by the user.

---

## Session: Codex — Markdown Design Source Cleanup (2026-05-13)

### Changed by: Codex

**What changed:**
- Updated active markdown docs so development follows the current Figma export at `/Users/development/Downloads/figmaCoffe`.
- Replaced old placeholder/blue-coral design docs with active Social Refresh tokens and current component/screen guidance.
- Marked earlier design sprint, prompt-generation, and Design UX files as archived/historical where they could mislead future AI tools.
- Updated AI entry docs to state the current phase is coding and verification, not planning or prompt generation.
- Trimmed this rolling context file to current/recent sessions only.

**Active visual source now documented:**
- Mint `#53B8A6`
- Pressed mint `#3D8D7A`
- Lavender `#8E7DBE`
- Peach `#E88C6B`
- Warm background `#F6F1EB`
- Card surface `#FFFDF9`
- Secondary surface `#F4F4F8`
- Text primary `#243447`
- Text secondary `#5F6368`
- Border `#E7DED4`

**Verification:**
- Searched markdown for the old blue/coral palette and old phase markers after cleanup.

---

## Session: Codex — Color & Font Token Alignment (2026-05-13)

### Changed by: Codex

**What changed:**
- Fixed malformed `coffeePurple.colorset` so Xcode can load the asset correctly.
- Aligned `coffeePurple` with the Figma prototype lavender token `#8E7DBE`.
- Updated app typography helpers and remaining explicit `.rounded` font usages to default system typography with heavier title/button weights.

**Scope kept intentionally narrow:**
- No screen-building work.
- No layout or navigation changes.
- No new visual components.

**Files updated:**
- `apps/frontend/Coffee_Call/Coffee_Call/Assets.xcassets/coffeePurple.colorset/Contents.json`
- `apps/frontend/Coffee_Call/Coffee_Call/DesignSystem/Font+Extensions.swift`
- `apps/frontend/Coffee_Call/Coffee_Call/Components/ActivityCardView.swift`
- `apps/frontend/Coffee_Call/Coffee_Call/Screens/Auth/OTPVerificationScreen.swift`
- `apps/frontend/Coffee_Call/Coffee_Call/Screens/Auth/PermissionsScreen.swift`
- `apps/frontend/Coffee_Call/Coffee_Call/Screens/Auth/ProfileSetupScreen.swift`
- `apps/frontend/Coffee_Call/Coffee_Call/Screens/Auth/ReadyScreen.swift`
- `apps/frontend/Coffee_Call/Coffee_Call/Screens/Main/DiscoveryScreen.swift`
- `apps/frontend/Coffee_Call/Coffee_Call/Screens/OnboardingScreen.swift`
- `Planning/context.md`

---

## Session: Antigravity — Navigation Stability & UI Polish (2026-05-13)

### Changed by: Antigravity

**What changed:**
- Migrated onboarding/auth flow to a single `NavigationStack` root in `ContentView`.
- Removed redundant nested `NavigationStack` wrappers from child screens.
- Added `navigateToAuth` state to `OnboardingScreen` and implemented it via `.navigationDestination`.
- Enhanced `PrimaryButton` with `.contentShape(Rectangle())`.
- Replaced legacy `NavigationLink` in onboarding Slide 5 with `PrimaryButton`.

**Why:**
- Nested `NavigationStack`s were causing navigation triggers to fail.
- Heterogeneous child signatures in page-style `TabView` caused type inference/build issues.

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
- Hid the navigation bar with `.toolbar(.hidden, for: .navigationBar)`.
- Moved onboarding image backgrounds into a root `ZStack` behind the `TabView`, keyed by `currentPage`.

**What was learned:**
- `TabView(selection: $currentPage)` and `.tag(0...4)` wiring was correct.
- The bug was not a button or binding problem.
- Root cause was SwiftUI page `TabView`'s underlying `UICollectionView` getting invalid sizing when the whole pager ignored safe areas inside `NavigationStack`.
- Keep full-bleed imagery behind the `TabView`; apply `.ignoresSafeArea()` only to the background layer.

**Separate warnings:**
- Firebase Crashlytics/Messaging logs were unrelated to onboarding paging.
- `UIBackgroundModes` remote-notification warning was unrelated to onboarding paging.
- Missing `coffeePurple` asset warning was separate visual/config cleanup.

**Files updated:**
- `apps/frontend/Coffee_Call/Coffee_Call/App/ContentView.swift`
- `apps/frontend/Coffee_Call/Coffee_Call/Screens/OnboardingScreen.swift`

---

## Session: Antigravity — Navigation & Build System Fixes (2026-05-13)

### Changed by: Antigravity

**What changed:**
- Migrated auth screens from deprecated `NavigationLink(destination:isActive:)` to `.navigationDestination(isPresented:)`.
- Updated `PrimaryButton` to support optional `height`, `cornerRadius`, and `icon` parameters.
- Corrected `.ultraThinMaterial` usage in `BetaBadge` and `GlassmorphicCard`.
- Replaced hardcoded color strings with semantic extensions in `BetaBadge`.
- Created `docs/Planning/build-guidelines.md` for recurring build/design issues.
- Fixed Xcode folder-reference issue by converting `Models/` from a blue folder reference to a proper group and adding `Activity.swift` to the target sources.

**Why:**
- Navigation APIs needed iOS 16-compatible patterns.
- Xcode folder references caused Swift files to be treated as resources instead of compiled sources.

**Files updated:**
- `apps/frontend/Coffee_Call/Coffee_Call/Screens/OnboardingScreen.swift`
- `apps/frontend/Coffee_Call/Coffee_Call/Components/PrimaryButton.swift`
- `apps/frontend/Coffee_Call/Coffee_Call/Components/GlassmorphicCard.swift`
- `apps/frontend/Coffee_Call/Coffee_Call/Components/BetaBadge.swift`
- `apps/frontend/Coffee_Call/Coffee_Call.xcodeproj/project.pbxproj`
- `docs/Planning/build-guidelines.md`
