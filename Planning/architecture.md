# CoffeeCall MVP Architecture

## Context
CoffeeCall is an activity-based meetup platform. Users post what they're doing (coffee, jog, movie) with location, time, and an optional hook or offer. People within 10km see active drifts and interest signals. They join a Drift, confirm, and then message inside that context. The MVP focuses on the core loop: post → discover → join/accept → confirm → message.

## MVP Scope (3 Weeks)

### Core Features
1. **Location Fix** — Geolocation capture + 10km radius discovery via Firebase Cloud Messaging
2. **Drift Hooks** — Optional offer text on a drift such as `coffee on me`, `2 movie coupons`, or `free entry with me`
3. **Acceptance Flow** — Post creation (Purpose + Location + Time + optional hook) → discovery delivery → user views Drift details → accept/reject → confirmation popup
4. **Meeting Confirmation** — Confirmation popup shows activity details, message thread opens inside the Drift
5. **Simple Messages** — Async message tracking (not real-time chat). Users can send/receive messages only after joining a Drift.
6. **Poster Dashboard** — Poster sees list of all acceptances + notifications for each new acceptance. Posts stay active for group meetups.

### NOT in MVP
- Scoring/reputation system
- Real-time chat
- Penalty system
- Post-meetup reviews or face verification

## Key Screens (7 Total - MVP)
1. **Signup** — Phone + OTP + profile photo + name input
2. **Profile** — User's profile view + edit capability
3. **Post Creation** — 3-field form (Purpose, Location, Time) + location picker + submit
4. **Discovery/Notifications** — List of nearby posts with poster profile + accept/reject buttons
5. **Acceptance Confirmation** — Dialog with activity details + poster info + confirm/cancel
6. **Messages** — Async message thread view (chronological list + input) + send button
7. **Poster Dashboard** — List of all acceptances for posted activities

## Backend Architecture (Firebase)

### Authentication
- **Phone signup** — Firebase Authentication with phone number
- **Session management** — Firebase auth tokens

### Firestore Data Models
```
/users/{userId}
  - uid: string
  - phoneNumber: string
  - name: string
  - profilePhoto: url
  - lastLocation: {latitude, longitude}
  - lastLocationUpdate: timestamp
  - createdAt: timestamp

/posts/{postId}
  - creatorId: string
  - purpose: string
  - location: {latitude, longitude, address}
  - time: timestamp
  - hookText: string (optional)
  - offerSummary: string (optional)
  - interestTags: [string]
  - createdAt: timestamp
  - expiresAt: timestamp (optional)
  - isActive: boolean
  - participantCount: number

/acceptances/{acceptanceId}
  - postId: string
  - acceptorId: string
  - acceptedAt: timestamp
  - status: "accepted" | "rejected" | "cancelled"

/messages/{messageThreadId}
  - postId: string
  - participants: [userId1, userId2]
  - createdAt: timestamp

/messages/{messageThreadId}/messages/{messageId}
  - senderId: string
  - text: string
  - timestamp: timestamp
```

### Cloud Functions
- **Notification trigger** — When post created, query users within 10km, send FCM discovery notification
- **Acceptance handler** — When user accepts, create message thread, notify poster
- **Message sync** — Store/retrieve messages from Firestore

### Cloud Messaging
- **Topic**: `location_posts_{radius}` — Broadcast discovery signals to users in 10km radius
- **Payload**: Post ID, creator info, activity summary, optional hook

## Frontend Architecture (SwiftUI iOS)

### Navigation Structure
```
TabBar
├── Home/Discovery
│   ├── Radar/Interest Overview
│   ├── Nearby Posts List
│   ├── Drift Detail
│   └── Accept/Join Flow
├── My Posts
│   ├── Active Posts List
│   └── Acceptances Dashboard
├── Messages
│   ├── Thread List
│   └── Message Thread View
└── Profile
    ├── Profile View
    └── Edit Profile
```

### Key Components
- **PostCreationForm** — 3-field input (Purpose, Location, Time) plus optional hook
- **PostCard** — Display drift summary with poster profile and optional offer
- **AcceptanceDialog** — Confirmation popup
- **MessageThread** — Display/send messages
- **LocationPicker** — Map/address selection (if needed)

### Geolocation
- Request user location permission on app launch
- Capture location on app open + post creation
- Store in Firestore user document
- Query posts within 10km using geohashing (Firebase best practice)

## Tech Stack

| Layer | Technology | Notes |
|-------|-----------|-------|
| **Frontend** | SwiftUI | Native iOS MVP |
| **Backend** | Firebase | Auth, Firestore, Storage, Cloud Messaging |
| **Geolocation** | Native iOS (CoreLocation) | Client-side capture |
| **Messages** | Firestore Realtime + Polling | Async, not real-time |
| **Notifications** | Firebase Cloud Messaging (FCM) | Push notifications |
| **Storage** | Firebase Storage | Profile photos |
| **Maps** | Google Maps (v1.1) | Not MVP |

## Key Decisions

1. **No real-time chat for MVP** — Async messages (Firestore polling) are simpler and sufficient for coordination
2. **Client-side geolocation** — Avoids constant server queries; posts filtered on client
3. **Firestore geohashing** — Standard Firebase pattern for location queries
4. **Firebase Cloud Messaging** — Handles 10km radius notifications at scale
5. **SwiftUI iOS MVP** — Narrower scope lets us ship the first version faster and keep implementation native
6. **Posts stay active** — Allows group meetups; poster manually manages acceptances
7. **In-app messages only** — No phone exchange in MVP (security + simplicity)
8. **Poster dashboard** — Centralized view of all acceptances
9. **No direct person pings** — Discovery surfaces interest and active drifts, but users only message after joining a Drift
10. **Hooks are optional** — Incentives such as coupons or `coffee on me` belong to the Drift, not to a cold outreach flow

## 3-Week Timeline

### Week 1: Core UI + Firebase Setup
- [ ] Firebase project setup (Auth, Firestore, Cloud Messaging)
- [ ] Phone signup + auth flow
- [ ] Profile creation + photo upload
- [ ] Post creation form (Purpose, Location, Time)
- [ ] Basic app navigation/tab structure

### Week 2: Discovery + Acceptance
- [ ] Geolocation implementation (iOS)
- [ ] Firestore geohashing + queries (10km radius)
- [ ] Cloud Messaging setup + notification delivery
- [ ] Notification view (nearby posts list)
- [ ] Accept/reject logic + confirmation dialog
- [ ] Message thread creation

### Week 3: Messages + Poster Dashboard + Testing
- [ ] Message send/receive/display
- [ ] Poster dashboard (list acceptances)
- [ ] End-to-end testing
- [ ] App Store/Play Store submission prep
- [ ] Bug fixes + UX polish

## Critical Files/Modules (By Component)

### Backend
- `functions/triggers.js` — Post creation notification trigger
- `functions/acceptanceHandler.js` — Acceptance logic
- `firestore.rules` — Security rules
- `firestore-indexes.js` — Geohashing indexes

### Frontend
- `Models/Post.swift/kt` — Post data structure
- `Models/User.swift/kt` — User data structure
- `Models/Message.swift/kt` — Message data structure
- `Views/PostCreation.swift/kt` — Form + Firestore write
- `Views/Discovery.swift/kt` — List of nearby posts
- `Views/AcceptanceFlow.swift/kt` — Accept/reject dialog
- `Views/Messages.swift/kt` — Message thread view
- `Views/PosterDashboard.swift/kt` — Acceptances list
- `Views/Profile.swift/kt` — User profile
- `Services/LocationManager.swift/kt` — Geolocation
- `Services/FirebaseManager.swift/kt` — Auth, Firestore, Cloud Messaging
- `Services/GeohashService.swift/kt` — Location queries

## Verification Plan

### User Journey Testing
1. **Signup** — Phone auth → profile creation → location capture
2. **Post Creation** — User creates post with Purpose, Location, Time → Firebase stores
3. **Notification** — User within 10km receives notification
4. **Discovery** — App shows nearby posts with poster info
5. **Acceptance** — User accepts → confirmation dialog appears
6. **Messages** — Message thread opens, users can coordinate
7. **Poster View** — Poster sees all acceptances in dashboard
8. **End-to-End** — Post → notification → accept → confirm → message → ready for meetup

### Quality Checks
- Location accuracy (within 10km radius)
- Notification delivery latency
- Message persistence
- iOS UX consistency

## Implementation Notes
- Posts stay active after first acceptance (group meetup support)
- Contact info exchanged via in-app messages only (no phone number display in MVP)
- Poster can see all acceptances + receive notifications for each new acceptance
- Message threads are async (not real-time), sufficient for coordination
- Geohashing implementation prevents inefficient location queries (Firebase best practice)

## Future System Design: Trust and Reputation (v2+)

This subsystem is intentionally excluded from the MVP core loop. If added later, it should be designed as a separate bounded context so it does not force rewrites in discovery, messaging, or post creation.

### Goals
- Provide lightweight trust signals for meeting strangers
- Keep the core activity flow unchanged
- Avoid turning CoffeeCall into a reputation-first app
- Support moderation, safety, and ranking without coupling them to the UI layer

### Architecture Pattern
- **Core app domain**: users, posts, drifts, acceptances, messages
- **Trust domain**: reputation events, trust summary, moderation cases
- **Append-only event ledger**: record what happened, never overwrite history
- **Derived read model**: show current trust state in profile or discovery cards
- **Async processing**: Cloud Functions update summaries after new events

### Firestore Data Model
```
/reputationEvents/{eventId}
  - actorId: string
  - targetUserId: string
  - postId: string?
  - driftId: string?
  - type: "joined" | "completed" | "cancelled" | "no_show" | "reported"
  - weight: number
  - source: "system" | "poster" | "participant" | "moderation"
  - createdAt: timestamp

/reputationSummaries/{userId}
  - trustScore: number
  - reliabilityScore: number
  - joinCount: number
  - completionCount: number
  - noShowCount: number
  - reportCount: number
  - lastUpdatedAt: timestamp

/moderationCases/{caseId}
  - targetUserId: string
  - reporterId: string
  - relatedEventId: string?
  - reason: string
  - status: "open" | "reviewed" | "dismissed" | "actioned"
  - createdAt: timestamp
```

### Event Flow
1. User joins or completes a Drift.
2. Cloud Function writes a reputation event.
3. Cloud Function recomputes the affected user summary.
4. UI reads the summary doc only.
5. Moderation cases are handled separately from score math.

### Non-Negotiables
- Do not calculate score in the SwiftUI client.
- Do not use reputation as the primary discovery mechanic.
- Do not block core Drift creation or join flow on score availability.
- Do not overwrite reputation history; append events and derive summaries.
- Keep moderation and reputation separate from message transport.

### UI Impact Later
- Small trust summary on profile
- Optional trust indicator on Drift detail
- Safety labels for hosts or repeat participants
- Ranking or filtering only after the trust layer is proven useful

### What Stays Stable
- Auth
- Profiles
- Discovery
- Drift creation
- Acceptance flow
- Messages
- Poster dashboard

### What May Change Later
- Discovery ranking
- Trust badges or safety labels
- Moderation dashboards
- Report handling
- Profile summary cards

---

**Last Updated:** 2026-05-13
**Status:** Architecture finalized; implementation in progress
**Next Step:** Coding, build verification, and Figma parity checks
