# CoffeeCall MVP: Feature Breakdown

## Core Features

### 1. Location Fix
**Purpose:** Enable geographic discovery of nearby users and activities.

**Requirements:**
- Capture user's current location on app launch
- Request location permission on first use
- Update location in Firestore on open + post creation
- Query posts within 10km radius using geohashing
- Display location address in post details

**Acceptance Criteria:**
- User location captured with <50m accuracy
- 10km radius queries return relevant posts
- Location updates happen within 5 seconds of app open

---

### 2. Post Creation
**Purpose:** Allow users to post activities they're planning.

**Requirements:**
- Form with 3 fields: Purpose, Location, Time
- Location auto-populated from current location
- Time picker for activity start time
- Submit button saves to Firestore
- Creator's profile auto-attached to post

**Acceptance Criteria:**
- Post creates within 2 seconds
- All 3 fields required (form validation)
- Post immediately visible in Discovery for creator

---

### 3. Discovery (Notifications)
**Purpose:** Notify nearby users of new posts and show them available activities.

**Requirements:**
- Firebase Cloud Messaging (FCM) notification trigger on post creation
- Query users within 10km radius
- Send notification with post summary
- Notification opens app to Discovery view
- Display list of nearby posts with:
  - Poster's profile photo + name
  - Activity purpose
  - Location + time
  - Accept/Reject buttons

**Acceptance Criteria:**
- Notifications delivered within 10 seconds of post creation
- Notification delivery to users within 10km radius only
- Rejection or acceptance within notification view

---

### 4. Acceptance Flow
**Purpose:** Allow users to commit to an activity.

**Requirements:**
- Accept/Reject buttons on each post
- Accept triggers confirmation dialog
- Dialog shows:
  - Activity details (purpose, location, time)
  - Poster's profile info
  - Confirm/Cancel buttons
- Confirmation creates Acceptance record in Firestore
- Automatically opens message thread

**Acceptance Criteria:**
- Acceptance recorded within 1 second
- Confirmation dialog appears immediately after accept click
- Message thread auto-opens without manual action

---

### 5. Message Threading
**Purpose:** Enable coordination between acceptor and poster.

**Requirements:**
- Create message thread automatically after acceptance
- Thread participants: acceptor + poster
- Message input field (text only, no media)
- Send button stores message to Firestore
- Display messages chronologically
- Async message loading (not real-time)

**Acceptance Criteria:**
- Messages persist in Firestore
- Message display within 2-5 seconds of send (acceptable latency)
- All messages in thread visible on open

---

### 6. Poster Dashboard
**Purpose:** Allow post creators to see who accepted and manage acceptances.

**Requirements:**
- View list of all acceptances for creator's posts
- Show acceptor profile info for each acceptance
- Show timestamp of acceptance
- Receive in-app notification for each new acceptance
- (Optional) Accept/reject individual acceptances

**Acceptance Criteria:**
- Dashboard loads within 2 seconds
- All acceptances displayed in chronological order
- Notification received when someone accepts

---

### 7. User Profile
**Purpose:** Display user identity and history.

**Requirements:**
- Phone number authentication
- Profile photo (required on signup)
- Profile view shows:
  - Photo + name
  - Phone number (only visible to matched users)
  - Activity count (posts created + acceptances)
- Edit profile to update photo/name

**Acceptance Criteria:**
- Profile photo uploads within 5 seconds
- Profile data persists across sessions
- Phone number shared only after acceptance (in message thread)

---

## NOT in MVP

- Scoring/reputation system
- Real-time messaging (async only)
- Post expiration/auto-deletion
- Review/rating system
- Face verification
- Penalty system
- Maps view (list only)
- Payment/tipping
- Follow/friend system

---

**Last Updated:** 2026-05-10
