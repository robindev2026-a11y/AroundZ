# CoffeeCall

CoffeeCall is an activity-based meetup app.

## Current Stack

- iOS frontend: SwiftUI
- Backend: Firebase
- Notifications: Firebase Cloud Messaging
- Storage: Firebase Storage

## Repo Layout

- `apps/frontend/` - SwiftUI iOS app
- `apps/backend/` - Firebase Functions and rules
- `Design/` - active Figma-derived design tokens and component direction
- `Planning/context.md` - latest AI/session handoff log

## Design Source

- Current Figma export/prototype: `/Users/development/Downloads/figmaCoffe`
- Active tokens: `Design/design-tokens.md`
- Do not use older blue/coral or placeholder design docs for implementation

## Setup Notes

- Add the real `GoogleService-Info.plist` to `apps/frontend/Config/Firebase/`
- Run `pod install` inside `apps/frontend/` after Firebase project details are ready
- Run Firebase CLI from repo root with the root `firebase.json`
