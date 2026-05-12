---
version: 1.0.0
author: Codex
date: 2026-05-10
status: production
model: gpt-5.5
parameters:
  temperature: 0.5
  max_tokens: 4000
description: Frontend code generation for SwiftUI iOS
tested_with: Xcode previews, Firebase
---

# CoffeeCall Frontend Prompt

You are generating the frontend for CoffeeCall MVP in `apps/frontend/` using SwiftUI for iOS. Read and follow:

- `Planning/spec.md`
- `Planning/architecture.md`
- `Planning/decisions.md`
- `Design/design-tokens.md`
- `Design/screens.md`

`Design/component-specs.md` is referenced by the project docs, but if it is missing in the repository, infer the component contract from the screens and design tokens rather than inventing new product scope.

## Product Summary

CoffeeCall is an activity-based meetup app. Users sign up with phone OTP, complete a profile, post activities, discover nearby activities within 10km, accept or reject, coordinate through async in-app messaging, and view acceptance activity in a poster dashboard.

## Non-Negotiable MVP Constraints

- Not a dating app.
- Async messaging only. No real-time chat semantics, no typing indicators, no presence.
- Posts stay active after acceptance.
- No phone exchange in MVP.
- 10km radius is fixed.
- No reputation, scoring, reviews, penalties, or friend/follow features.
- No map UI in MVP.

## Target Platform and Stack

- SwiftUI iOS frontend.
- iOS 15.0+ target.
- Firebase Auth, Firestore, Storage, and FCM integration.
- Native geolocation via CoreLocation.

## Design System Requirements

Use `Design/design-tokens.md` as the source of truth.

### Color Usage

- Primary CTAs and highlights: `color-primary` (#8B6F47)
- Positive actions: `color-success` (#10B981)
- Negative actions and errors: `color-error` (#EF4444)
- Neutral surfaces and cards: `color-surface` and `color-surface-alt`
- Text: `color-text-primary`, `color-text-secondary`, `color-text-tertiary`

### Typography

- Use Inter as the primary font family.
- Page titles should follow the 32px heading token.
- Body copy should follow the 16px body token.
- Keep the hierarchy obvious and readable on mobile.

### Spacing, Radius, and Depth

- Use the documented spacing scale only.
- Use radius tokens for cards, inputs, buttons, and avatars.
- Use subtle shadows from the design tokens.
- Keep touch targets at least 44x44.

### Interaction Rules

- Use token-based states for default, focused, loading, disabled, success, and error.
- Avoid hardcoded colors and ad hoc spacing.
- Keep animations subtle and purposeful. Prefer short, clear transitions.

## Required Screen Set

Implement all 7 screens documented in `Design/screens.md` and the project brief.

### 1. Signup

Responsibilities:

- Phone number entry.
- OTP verification.
- Profile photo upload.
- Name entry.
- Location permission request.
- Progression into the main app only after the required steps are complete.

Behavior:

- Persist auth session across launches.
- Guide the user clearly through each step.
- Show validation and network error states.

### 2. Post Creation

Responsibilities:

- 3-field form: purpose, location, time.
- Auto-populate location from device GPS.
- Allow user adjustment if needed.
- Submit to backend create post flow.

Behavior:

- Validate all fields before submission.
- Show loading and success feedback.
- Navigate back or continue to discovery after success.

### 3. Discovery / Notifications

Responsibilities:

- Show nearby posts within the fixed 10km radius.
- Surface push-driven discovery entry points.
- Display post cards with poster photo, name, purpose, location, and time.
- Provide accept and reject actions.

Behavior:

- Use async refresh or polling, not real-time listeners.
- Respect notification opt-in state.
- Support empty states, error states, and loading states.

### 4. Acceptance Confirmation

Responsibilities:

- Present a confirmation dialog or bottom sheet after accept is tapped.
- Show activity details and poster info.
- Allow confirm or cancel.

Behavior:

- On confirm, call the backend accept flow.
- On success, open the message thread automatically.
- On cancel, return to discovery with no mutation.

### 5. Message Thread

Responsibilities:

- Show chronological messages.
- Compose and send text messages.
- Display sender identity with avatars or names.

Behavior:

- Poll or refresh messages periodically.
- Do not use real-time listeners.
- Keep the composer pinned to the bottom.
- Preserve scroll position sensibly when new messages arrive.

### 6. Poster Dashboard

Responsibilities:

- List the user’s active posts.
- Show acceptance counts.
- Show acceptor names, avatars, and accept times.

Behavior:

- Refresh when the user returns to the screen.
- Surface new acceptances quickly enough for the MVP.
- Keep the layout simple and scannable.

### 7. Profile

Responsibilities:

- Show current user photo and name.
- Allow editing profile details.
- Expose basic activity history or counts if available.
- Provide logout.

Behavior:

- Keep phone number private in the UI.
- Support profile image upload and replacement.

## Navigation Structure

Implement a clear app flow:

- Auth and onboarding flow first.
- Main tab or shell after onboarding.
- Discovery as a primary entry point.
- My Posts / Poster Dashboard as a primary entry point.
- Messages as a primary entry point.
- Profile as a primary entry point.
- Post creation reachable from a prominent action, not buried.

Keep navigation consistent across the iOS app.

## Component Contracts

If a formal component-specs file is unavailable, create reusable components that cover the screens above. At minimum, build:

- `AppShell`
- `AuthFlow`
- `PhoneEntry`
- `OtpEntry`
- `ProfileSetup`
- `PermissionGate`
- `PostComposer`
- `PostCard`
- `PostList`
- `AcceptanceDialog`
- `MessageThreadView`
- `MessageComposer`
- `PosterDashboard`
- `AcceptanceRow`
- `ProfileHeader`
- `Avatar`
- `PrimaryButton`
- `SecondaryButton`
- `TextField`
- `EmptyState`
- `ErrorState`
- `LoadingState`
- `Toast` or inline feedback component

Keep the components composable and reusable. Favor small components over duplicated screen code.

## State Management Requirements

Use a predictable state model that handles:

- authentication state
- onboarding completion
- profile completion
- location permission and last known location
- discovery feed state
- selected post and acceptance confirmation state
- active message thread state
- poster dashboard state
- profile edit state
- upload and network status

Requirements:

- State should survive ordinary app switching.
- The UI should not depend on real-time listeners for correctness.
- Separate local UI state from Firebase-backed state.
- Keep the code easy to test.

## Firebase Integration Requirements

### Auth

- Phone number sign-in with OTP.
- Session persistence.
- Clear error handling for invalid codes, expired codes, and network issues.

### Firestore

- Read nearby posts for discovery.
- Create posts through the backend endpoint.
- Accept posts through the backend endpoint.
- Send messages through the backend endpoint.
- Load poster dashboard data from the backend endpoint or a secure Firestore pattern that matches backend rules.

### Storage

- Upload profile photos.
- Show upload progress and failure recovery.

### FCM

- Register for notifications.
- Request notification permissions.
- Open the correct screen from notification taps.

## Geolocation Requirements

- Request location permission on app launch or during onboarding, per the spec.
- Capture current location for discovery and post creation.
- Update the backend or user state when location changes enough to matter.
- Handle denied, restricted, and unavailable states gracefully.

## Async Messaging Requirements

- Messages must feel responsive without real-time infrastructure.
- Use polling, refresh-on-open, and refresh-on-return patterns.
- Keep the UI honest about sync timing where needed.
- Do not implement presence, typing indicators, or live cursors.

## Error Handling Requirements

Cover at least:

- OTP verification failure
- location permission denied
- no GPS fix
- photo upload failure
- post creation failure
- acceptance failure
- message send failure
- network offline
- empty discovery feed
- empty dashboard

Show clear, user-friendly states for each.

## Accessibility Requirements

- Respect dynamic type where possible.
- Maintain contrast using the design tokens.
- Keep controls labeled and screen-reader friendly.
- Ensure 44x44 minimum touch targets.
- Do not encode meaning with color alone.

## Testing Requirements

Generate tests or testable structure for:

- auth flow state transitions
- onboarding and profile completion gating
- post creation form validation
- discovery list rendering
- acceptance confirmation flow
- message thread loading and sending
- poster dashboard rendering
- notification tap routing

## Implementation Structure

Create a clean SwiftUI app structure under `apps/frontend/` with modules for:

- app root and navigation
- screens
- reusable UI components
- Firebase services
- location services
- messaging services
- models
- state management
- utilities and formatting helpers

Use clear naming and keep the codebase consistent across the iOS target.

## Acceptance Criteria

The generated frontend is complete only when:

- All 7 screens are implemented.
- The app uses the design tokens instead of hardcoded visual values.
- Auth, storage, messaging, and discovery flows are integrated.
- Async messaging is implemented without real-time listeners.
- The app honors the fixed 10km radius and MVP constraints.
- Posts stay active after acceptance.
- Phone numbers remain private in the UI.
- The app is navigable, testable, and preview-friendly.

## Deliverable

Generate the frontend code only. Do not generate backend code here. Keep the implementation aligned with `Planning/spec.md`, `Planning/architecture.md`, and `Design/design-tokens.md`.
