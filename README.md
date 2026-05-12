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

## Setup Notes

- Add the real `GoogleService-Info.plist` to `apps/frontend/Config/Firebase/`
- Run `pod install` inside `apps/frontend/` after Firebase project details are ready
- Run Firebase CLI from repo root with the root `firebase.json`
