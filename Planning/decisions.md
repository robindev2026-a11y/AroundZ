# CoffeeCall MVP: Key Decisions & Rationale

## Architecture Decisions

### 1. SwiftUI iOS for MVP
**Decision:** Build the MVP as a native SwiftUI iOS app. Defer Android to a future phase.

**Rationale:**
- Focuses the MVP on one platform with the fastest path to a polished launch
- Keeps the implementation native to Apple tooling and runtime behavior
- Reduces cross-platform complexity while the product is still being validated

**Trade-off:** Android is not included in this phase, but that keeps the MVP narrower and more executable.

**Status:** Approved

---

### 2. Firebase as Backend
**Decision:** Use Firebase (Auth, Firestore, Cloud Messaging, Storage) vs custom backend.

**Rationale:**
- No backend server to manage (serverless)
- Built-in authentication, real-time database, and push notifications
- Geohashing support for location queries
- Scales easily
- Lower operational cost for MVP

**Alternative considered:** Custom Node.js/PostgreSQL backend (rejected: too much dev time)

**Status:** Approved

---

### 3. Async Messaging (Not Real-Time)
**Decision:** Use Firestore polling + periodic updates instead of real-time listeners.

**Rationale:**
- Simpler to implement (no WebSocket complexity)
- Sufficient for activity coordination (messages don't need instant delivery)
- Lower battery drain (no constant listeners)
- Reduces Firebase quota usage
- MVP-appropriate latency (2-5 seconds acceptable)

**Alternative considered:** Real-time Firestore listeners (rejected: adds complexity, not needed for MVP)

**Status:** Approved

---

### 4. Posts Stay Active (Group Meetups)
**Decision:** Posts remain visible and active after first acceptance. Poster can accept multiple people.

**Rationale:**
- Allows flexible group activities (coffee with multiple people, group jog, etc.)
- Simpler than managing post closure logic
- Users naturally coordinate in message thread
- More scalable for recurring activities

**Alternative considered:** One-on-one only (auto-close after first accept) (rejected: too limiting)

**Status:** Approved

---

### 5. No Phone Number Exchange in MVP
**Decision:** All communication happens via in-app messages. Phone numbers hidden until needed.

**Rationale:**
- Better safety (no phone number leakage to strangers)
- Simpler to implement (no need for private info sharing flow)
- Maintains platform control (can ban/report without direct contact)
- Users can share contact info in message thread if they want

**Alternative considered:** Automatic phone sharing after acceptance (rejected: privacy risk)

**Status:** Approved

---

### 6. Geohashing for Location Queries
**Decision:** Use geohashing on Firestore (Firebase best practice) for 10km radius queries.

**Rationale:**
- Efficient querying (avoids scanning entire posts collection)
- Firebase officially recommends for geo queries
- Better performance as user base grows

**Alternative considered:** Client-side filtering (rejected: doesn't scale)

**Status:** Approved

---

### 7. No Scoring/Reputation in MVP
**Decision:** Exclude reputation score system from MVP.

**Rationale:**
- Adds significant complexity (score calculation, penalties, display logic)
- Not critical for first 3 weeks
- Can be added in v1.1 once user base grows
- MVP focus: core activity flow works

**Alternative considered:** Basic 1-5 star reviews (rejected: adds data model + review screen)

**Status:** Approved

---

## UX Decisions

### 1. Notification-First Discovery
**Decision:** Users discover posts primarily via notifications, not a feed/map browsing.

**Rationale:**
- Push notifications are engaging (users don't need to open app constantly)
- Simpler discovery UX (no complex feed algorithms)
- Natural 10km radius filtering (notification sent only to nearby users)
- Discovery notifications should surface active Drifts and interest signals, not expose nearby people for random pings.

**Trade-off:** Users must allow notifications (permission dialog on signup)

**Status:** Approved

---

### 2. Immediate Message Thread on Acceptance
**Decision:** Message thread opens automatically after user accepts post.

**Rationale:**
- Reduces friction (no extra click to start messaging)
- Natural UX flow (post → accept → chat)
- Encourages immediate coordination

**Alternative considered:** Message thread created but not auto-opened (rejected: more clicks)

**Status:** Approved

---

### 3. Poster Dashboard vs Activity Feed
**Decision:** Poster sees list of acceptances in a dashboard, not a traditional feed.

**Rationale:**
- Clearer for poster to manage who's joining
- Simple list view (faster to implement than complex feed)
- Avoids real-time presence updates

**Status:** Approved

### 4. No Cold Outreach
**Decision:** Discovery should not support direct person-to-person messaging or "say hi" entry points from radar or interest views.

**Rationale:**
- Keeps the product activity-first instead of turning it into a people browser
- Reduces spam, safety overhead, and dating-style behavior
- Forces the user to create a meaningful Drift with context, not just ping a stranger

**Status:** Approved

### 5. Drift Hooks
**Decision:** Optional hooks or offers can be attached to a Drift to make it more tempting.

**Rationale:**
- Hooks give people a reason to join without turning the app into a coupon marketplace
- Examples include `coffee on me`, `2 movie coupons`, or `free entry with me`
- The Drift stays the primary object; the hook is support, not the product

**Status:** Approved

### 6. Reputation as v2 Subsystem
**Decision:** Keep scoring/reputation out of the MVP core loop, but design it later as a separate bounded context with append-only events and derived summaries.

**Rationale:**
- Lets the current app stay activity-first and light
- Avoids rewriting discovery, messaging, or post creation later
- Gives a clean path for trust signals, moderation, and ranking if the product needs them

**Status:** Approved for future planning

---

## Tech Stack Decisions

### 1. No Maps API in MVP
**Decision:** Exclude Google Maps integration; use address text only.

**Rationale:**
- Reduces complexity (no map rendering, marker placement)
- Location text + 10km radius notification sufficient
- Can add map view in v1.1

**Status:** Approved (pushed to v1.1)

---

### 2. Firebase Cloud Functions for Notifications
**Decision:** Use Cloud Functions (serverless) to trigger 10km radius notifications.

**Rationale:**
- No additional server management
- Scales automatically
- Integrates seamlessly with Firestore

**Status:** Approved

---

## Timeline Decisions

### 1. 3-Week Aggressive Timeline
**Decision:** Ship complete MVP in 3 weeks (Week 1: UI+Setup, Week 2: Core Flow, Week 3: Polish+Testing).

**Rationale:**
- Fast feedback loop from real users
- Identifies core UX issues early
- Allows pivot if needed
- Realistic given SwiftUI + Firebase

**Risk:** Limited polish time. QA/bug-fixing compressed.

**Mitigation:** Focus on happy path testing; rough edges acceptable for MVP.

**Status:** Approved

---

### 3. Design Brief Scope: MVP-First Approach
**Decision:** Create streamlined MVP design brief (8 screens) instead of aspirational v1.1 brief (15 screens).

**Rationale:**
- Original brief included reputation system, reviews, badges, flakes — all deferred to v1.1
- Keeping design focused on 3-week timeline prevents scope creep
- Clear separation: MVP (basic activity coordination) vs v1.1 (trust/reputation)
- Faster design handoff to dev team (fewer screens = faster build)

**Alternative considered:** Extended timeline (5-6 weeks) to include full reputation system (rejected: locks us into longer MVP)

**Result:**
- 8 screens finalized (auth, discovery, post, accept, confirm, messages, dashboard, profile)
- Reputation, reviews, badges, penalties deferred to v1.1
- New brief: `CoffeeCall_MVP_Design_Brief.md` (governance document)
- Original brief archived as `CoffeeCall_Final_Figma_Brief.md` (reference for v1.1 planning)

**Status:** Approved (2026-05-12)

---

## Future Decisions (Post-MVP)

These are noted for v1.1+ planning:

- [ ] Add scoring/reputation system
- [ ] Implement post-meetup reviews & ratings
- [ ] Add flake badges & penalties
- [ ] Implement real-time chat (if users demand)
- [ ] Add Google Maps view
- [ ] Implement badge system (verified, trusted, etc.)
- [ ] Add activity history/analytics
- [ ] Implement follow/friend system
- [ ] Add in-app payment for premium features
- [ ] Expand radar into richer ambient discovery states if user research supports it

---

**Last Updated:** 2026-05-12
**Reviewed By:** Claude (Planner)
**Status:** All MVP decisions approved
