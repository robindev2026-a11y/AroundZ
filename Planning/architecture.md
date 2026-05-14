# CoffeeCall MVP Architecture

## Context
CoffeeCall is an activity-based meetup platform. Users post what they're doing (coffee, jog, movie) with location and time. People within 10km get notified. They can accept and meet up. The MVP focuses on the core loop: post → discover → accept → confirm → message.

## MVP Scope (3 Weeks)

### Core Features
1. **Location Fix** — Geolocation capture + 10km radius notifications via Firebase Cloud Messaging
2. **Acceptance Flow** — Post creation (Purpose + Location + Time) → notification delivery → user views poster profile → accept/reject → confirmation popup
3. **Meeting Confirmation** — Confirmation popup shows activity details, message thread opens immediately
4. **Simple Messages** — Async message tracking (not real-time chat). Users can send/receive messages in a thread to coordinate.
5. **Poster Dashboard** — Poster sees list of all acceptances + notifications for each new acceptance. Posts stay active for group meetups.

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
  - createdAt: timestamp
  - expiresAt: timestamp (optional)
  - isActive: boolean

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
- **Notification trigger** — When post created, query users within 10km, send FCM notification
- **Acceptance handler** — When user accepts, create message thread, notify poster
- **Message sync** — Store/retrieve messages from Firestore

### Cloud Messaging
- **Topic**: `location_posts_{radius}` — Broadcast to users in 10km radius
- **Payload**: Post ID, creator info, activity summary

## Frontend Architecture (SwiftUI iOS)

### Navigation Structure
```
TabBar
├── Home/Discovery
│   ├── Notifications/Nearby Posts List
│   ├── Post Detail
│   └── Accept/Reject Flow
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
- **PostCreationForm** — 3-field input (Purpose, Location, Time)
- **PostCard** — Display post summary with poster profile
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

---

**Last Updated:** 2026-05-13
**Status:** Architecture finalized; implementation in progress
**Next Step:** Coding, build verification, and Figma parity checks
