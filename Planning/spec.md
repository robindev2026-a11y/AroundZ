# CoffeeCall MVP: Comprehensive Specification

## 1. Project Overview

**Name:** CoffeeCall
**Type:** Activity-based meetup platform
**MVP Timeline:** 3 weeks
**Target Users:** People seeking casual social activities (coffee, movies, jogging, etc.)

### Problem Statement
Existing meetup apps are complex and designed for dating. CoffeeCall solves this by providing a lightweight, activity-focused platform where people can quickly post what they're doing and find others nearby to join them.

### Success Criteria
- MVP launches in 3 weeks with core features
- Users can post, discover, accept, and coordinate meetups
- System handles 10km radius notifications reliably
- 50+ users in closed beta

---

## 2. Features & Requirements

### 2.1 Core Features

#### Feature: Phone Signup
**User Story:**
As a new user, I want to sign up with my phone number, so I can start posting activities.

**Acceptance Criteria:**
- [ ] User can enter phone number
- [ ] OTP verification code sent via SMS
- [ ] User verifies OTP and signs in
- [ ] Session persists across app closes
- [ ] User redirected to profile creation after signup

**Priority:** High
**Scope:** MVP

---

#### Feature: User Profile
**User Story:**
As a user, I want to set up my profile with a photo and name, so others can see who I am.

**Acceptance Criteria:**
- [ ] User can upload profile photo
- [ ] User can set/edit name
- [ ] Profile photo displays in all posts
- [ ] User can view/edit own profile
- [ ] Phone number hidden until after acceptance

**Priority:** High
**Scope:** MVP

---

#### Feature: Post Activity
**User Story:**
As a user, I want to post an activity with location and time, so others nearby can join me.

**Acceptance Criteria:**
- [ ] User sees 3-field form: Purpose, Location, Time
- [ ] Location auto-populated from device GPS
- [ ] User can adjust location if needed
- [ ] User selects time via time picker
- [ ] Submit button saves post to Firestore
- [ ] Post appears in Discovery for nearby users within 2 seconds

**Priority:** High
**Scope:** MVP

**Technical Details:**
- Location accuracy: ±50 meters
- Firestore geohashing for 10km queries
- Post TTL: 24 hours (soft delete after no acceptances)

---

#### Feature: Discover Nearby Activities
**User Story:**
As a user, I want to see activities happening nearby, so I can find something to join.

**Acceptance Criteria:**
- [ ] User receives push notification when post created within 10km
- [ ] Notification opens Discovery view in app
- [ ] Discovery shows list of nearby posts (sorted by time)
- [ ] Each post shows: poster profile photo, activity purpose, location, time
- [ ] User can accept or reject each post from list

**Priority:** High
**Scope:** MVP

**Technical Details:**
- Firebase Cloud Messaging for notifications
- Firestore geohashing (posts filtered on client)
- Notification latency: <10 seconds from post creation
- Only users who have enabled notifications receive alerts

---

#### Feature: Accept/Reject Activity
**User Story:**
As a user, I want to accept or reject an activity, so I can commit to joining or skip it.

**Acceptance Criteria:**
- [ ] User sees Accept/Reject buttons on each post
- [ ] Clicking Accept shows confirmation dialog
- [ ] Dialog displays: activity details (purpose, location, time), poster info
- [ ] User can confirm or cancel acceptance
- [ ] On confirm: Acceptance recorded, message thread opens, notification sent to poster
- [ ] On reject: Post hidden from user, no notification sent

**Priority:** High
**Scope:** MVP

**Technical Details:**
- Acceptance creates record in Firestore (acceptances collection)
- Poster receives in-app notification immediately
- Post remains visible (allows multiple acceptances)

---

#### Feature: Message Coordination
**User Story:**
As users who accepted an activity, I want to message each other, so we can coordinate meetup details.

**Acceptance Criteria:**
- [ ] Message thread opens automatically after acceptance
- [ ] Thread shows poster and acceptor names
- [ ] User can type message and tap Send
- [ ] Messages display chronologically
- [ ] Messages persist across app closes
- [ ] New messages load within 2-5 seconds (async acceptable)
- [ ] No real-time notifications (async polling only)

**Priority:** High
**Scope:** MVP

**Technical Details:**
- Firestore messages collection (one document per thread)
- Async message fetching (2-5 sec latency acceptable)
- No typing indicators or presence (v1.1)

---

#### Feature: Poster Dashboard
**User Story:**
As someone who posted an activity, I want to see who accepted, so I can manage joiners.

**Acceptance Criteria:**
- [ ] Poster can access "My Posts" section
- [ ] Shows list of all active posts they created
- [ ] For each post, shows count of acceptances
- [ ] Clicking a post shows list of acceptors (name, profile photo, accept time)
- [ ] Poster gets notification when someone accepts

**Priority:** High
**Scope:** MVP

**Technical Details:**
- Real-time query of acceptances for poster's posts
- Dashboard updates within 2 seconds of new acceptance

---

### 2.2 Non-Functional Requirements

| Requirement | Target | Rationale |
|-----------|--------|-----------|
| Notification latency | <10 seconds | Users expect quick discovery |
| Message sync | 2-5 seconds | Async acceptable for coordination |
| Location accuracy | ±50 meters | Sufficient for 10km radius |
| Uptime | 99.5% | Firebase managed service |
| Max 10km radius | Hard limit | Privacy + local focus |
| No phone number sharing in MVP | Hard requirement | Privacy + safety |
| Async messaging only | Hard requirement | Simplifies MVP scope |

---

## 3. Architecture & Data Models

### 3.1 Firestore Collections

```
/users/{userId}
  - uid: string (Firebase UID)
  - phoneNumber: string (encrypted)
  - name: string
  - profilePhotoUrl: string
  - lastLocation: {latitude: number, longitude: number}
  - lastLocationGeoHash: string (for geohashing)
  - lastLocationUpdate: timestamp
  - createdAt: timestamp

/posts/{postId}
  - creatorId: string (reference to user)
  - purpose: string (e.g., "Coffee", "Movie", "Jog")
  - location: {latitude: number, longitude: number, address: string}
  - locationGeoHash: string (for geohashing)
  - time: timestamp (activity start time)
  - createdAt: timestamp
  - expiresAt: timestamp (24 hours after creation)
  - isActive: boolean (soft delete)
  - acceptanceCount: number (denormalized for quick access)

/acceptances/{acceptanceId}
  - postId: string (reference to post)
  - acceptorId: string (reference to user)
  - acceptedAt: timestamp
  - status: "accepted" | "cancelled"

/messageThreads/{threadId}
  - postId: string
  - participants: [creatorId, acceptorId]
  - createdAt: timestamp

/messageThreads/{threadId}/messages/{messageId}
  - senderId: string
  - text: string
  - timestamp: timestamp
```

### 3.2 API Endpoints (Cloud Functions)

```
POST /createPost
  Request: {purpose, latitude, longitude, time}
  Response: {postId, status}
  Triggers: Geohashing, notification generation

POST /acceptPost
  Request: {postId, userId}
  Response: {acceptanceId, threadId}
  Triggers: Message thread creation, notification to poster

POST /sendMessage
  Request: {threadId, senderId, text}
  Response: {messageId, status}
  Side effect: Persists to Firestore

GET /getNearbyPosts
  Query: {latitude, longitude, radius: 10km}
  Response: [{postId, creatorInfo, purpose, location, time}, ...]

GET /getPosterDashboard
  Query: {userId}
  Response: {posts: [{postId, acceptances: [{acceptorInfo, acceptTime}, ...]}]}
```

---

## 4. UI/UX Specification

See `/Design/screens.md`, `/Design/design-tokens.md`, and `/Design/component-specs.md` for detailed wireframes, design tokens, and component specifications.

### 4.1 Key Screens (7 Total - MVP)
1. **Signup** — Phone number input + OTP verification + profile photo upload + name input
2. **Profile** — User's profile view (photo, name, stats) + edit capability
3. **Post Creation** — 3-field form (Purpose, Location, Time) with location picker + submit
4. **Discovery/Notifications** — List of nearby posts (10km radius) with poster profile + accept/reject buttons
5. **Acceptance Confirmation** — Modal dialog showing activity details + poster info + confirm/cancel
6. **Messages** — Message thread view with chronological message list + message input + send button
7. **Poster Dashboard** — List of all acceptances for poster's posts with acceptor info + accept time

### 4.2 Navigation Flow
```
Signup → Profile → Home (Discovery/My Posts tabs) → Post Detail → Messages
                          ↓
                    Poster Dashboard
```

---

## 5. Tech Stack & Architecture

### 5.1 Frontend
- **Framework:** SwiftUI
- **iOS Target:** 15.0+
- **Android Target:** Deferred to a future phase
- **Package Manager:** Swift Package Manager / Xcode project

### 5.2 Backend
- **Platform:** Firebase
- **Services Used:**
  - Authentication (Phone OTP)
  - Firestore (Database)
  - Cloud Storage (Photos)
  - Cloud Messaging (Notifications)
  - Cloud Functions (Backend logic)

### 5.3 Geolocation
- **iOS:** CoreLocation
- **Android:** Deferred to a future phase
- **Geohashing:** Firestore best practice

### 5.4 DevOps
- **Version Control:** Git
- **CI/CD:** GitHub Actions (optional for MVP)
- **App Distribution:** TestFlight (Android deferred)

---

## 6. Testing Strategy

### 6.1 Unit Tests
- Location geohashing calculations
- Acceptance logic
- Message persistence

### 6.2 Integration Tests
- End-to-end flow: Post → Notification → Accept → Message
- Firestore operations
- Cloud Function triggers
- Firebase Authentication

### 6.3 Manual Testing Checklist
- [ ] Signup flow with valid/invalid phone numbers
- [ ] OTP verification
- [ ] Profile photo upload
- [ ] Post creation with various locations/times
- [ ] Receiving notification within 10 seconds
- [ ] Accepting post and seeing confirmation
- [ ] Sending/receiving messages (2-5 sec sync)
- [ ] Poster seeing acceptances in dashboard
- [ ] Rejecting post removes it from view
- [ ] iOS consistency

### 6.4 Performance Tests
- App startup time: <2 seconds
- Post creation: <2 seconds
- Message send: <1 second (visible after 2-5 sec sync)
- Notification delivery: <10 seconds

---

## 7. Constraints & Assumptions

### Constraints
- 3-week MVP timeline (aggressive)
- No real-time messaging for MVP
- No scoring/reputation system for MVP
- 10km radius fixed (no customization)
- No maps view for MVP
- Posts stay active (not one-on-one only)
- Phone numbers only shared in-app (not exchanged directly)

### Assumptions
- Users allow location + notification permissions
- Users have stable internet connection
- Firebase quotas sufficient for early user base (<10k users)
- SwiftUI iOS client uses geohashing-compatible data from Firebase
- Cloud Messaging reliable for 10km broadcast

---

## 8. Success Metrics (MVP)

| Metric | Target |
|--------|--------|
| User signup completion | >80% |
| Post creation success | >95% |
| Notification delivery | >99% (Firebase SLA) |
| Message persistence | 100% |
| App crash rate | <0.1% |
| Session duration | >5 minutes |
| Acceptance rate | >30% of notified users |

---

## 9. Out of Scope (v1.1+)

- Scoring/reputation system
- Real-time messaging
- Maps view
- Post review/ratings
- Penalty system for no-shows
- Payment/tipping
- Activity history analytics
- Follow/friend system
- Face verification

---

## 10. Appendix: Acceptance Criteria Template

```markdown
## Feature: [Name]

**User Story:**
As a [role], I want to [action], so that [benefit]

**Acceptance Criteria:**
- [ ] [Criterion 1]
- [ ] [Criterion 2]
- [ ] [Criterion 3]

**Priority:** [High/Medium/Low]
**Scope:** [MVP/v1.1/Future]
**Technical Details:** [If applicable]
```

---

**Document Status:** Finalized
**Last Updated:** 2026-05-10
**Owner:** Claude (Planner)
