
# CoffeeCall Project Context

This file is a shared rolling log for all AI tools working on CoffeeCall.

Rules:
- Append new entries at the top under the latest session.
- Keep entries short and factual.
- If this file grows too large, delete the oldest session entries and keep only the most recent ones.
- Retention target: keep the latest 5 session entries or roughly the latest 300 lines, whichever comes first.

## Session: Gemini — Phone Auth Resolution & Onboarding Polish (2026-05-14)

### Changed by: Gemini

**What changed:**
- **Firebase Auth Stability**: Fixed phone number normalization in `AuthViewModel`, resolved simulator timeouts by refactoring `AppDelegate` for reCAPTCHA swizzling, and added granular logging for verification ID retrieval.
- **Onboarding Polish**: Implemented high-fidelity staggered entrance animations for Slide 1. Aligned headline styling (48pt Black), spacing, and interactive feedback (`.pressScale`) with Figma specs.
- **Firestore Verification**: Confirmed project-level Firestore enablement allows profile data persistence; verified transition from Profile Setup to Discovery.
- **Project Config**: Synchronized `GoogleService-Info.plist` with server state and verified URL schemes in `Info.plist`.

**Verification:**
- Successfully verified test number +917012655068 in simulator.
- End-to-end flow verified: Phone -> OTP -> Profile -> Discovery.

**Files updated:**
- `apps/frontend/Coffee_Call/Coffee_Call/ViewModels/AuthViewModel.swift`
- `apps/frontend/Coffee_Call/Coffee_Call/Screens/Auth/PhoneAuthScreen.swift`
- `apps/frontend/Coffee_Call/Coffee_Call/Screens/OnboardingScreen.swift`
- `apps/frontend/Coffee_Call/Coffee_Call/App/Coffee_CallApp.swift`
- `Planning/context.md`

---

## Session: Codex — Fix Phone Auth Navigation (2026-05-14)

### Changed by: Codex

**What changed:**
- `PhoneAuthScreen.swift`: Removed `.navigationDestination(isPresented:)` that was nested inside the root `NavigationStack`. Replaced with conditional view rendering — when `navigateToOTP == true`, the screen renders `OTPVerificationScreen` directly instead of trying to navigate via a nested destination.
- Root cause: Nested `.navigationDestination` blocks in SwiftUI iOS 16+ can fail silently when both the parent and child use navigation APIs, causing state updates to be ignored.

**Files updated:**
- `apps/frontend/Coffee_Call/Coffee_Call/Screens/Auth/PhoneAuthScreen.swift`
- `Planning/context.md`

---

### Changed by: Antigravity

**What changed:**
- `View+Availability.swift`: All wrappers for iOS 16.4+ and iOS 17+ APIs changed to no-ops (`self`) with the real implementations sitting in commented lines beside each function body.
- Root cause: `if #available` is a runtime guard only. If the API symbol doesn't exist in the current SDK headers (Xcode 14.2 = iOS 16.2 SDK), the compiler still rejects the reference inside the `if #available` block.

**Files updated:**
- `apps/frontend/Coffee_Call/Coffee_Call/DesignSystem/View+Availability.swift`
- `Planning/context.md`

---

### Changed by: Antigravity

**What changed:**
- `CategoryChip.swift`: Added SF symbol icons per category.
- `ActivityCardView.swift`: Status badge uses animated mint pulse dot + `.ultraThinMaterial`.
- `DiscoveryScreen.swift`: Full rewrite for high-fidelity activity feed matching Figma Social Refresh.

**Files updated:**
- `apps/frontend/Coffee_Call/Coffee_Call/Components/CategoryChip.swift`
- `apps/frontend/Coffee_Call/Coffee_Call/Components/ActivityCardView.swift`
- `apps/frontend/Coffee_Call/Coffee_Call/Screens/Main/DiscoveryScreen.swift`
- `Planning/context.md`
