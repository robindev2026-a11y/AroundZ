# CoffeeCall UI Flow & Rules (MVP)

This document serves as the master checklist and flow structure for the CoffeeCall MVP.

## 1. Core Navigation
*   **Structure**: Floating Tab Bar with 4 primary destinations:
    *   **Around**: Ambient radar and interest discovery (activity-first).
    *   **Drifts**: Active meetups feed (Discover + Mine).
    *   **Chats**: Coordination for joined/hosted drifts.
    *   **You**: Personal profile, settings, and active drift status.

## 2. Global Social Rules
*   **No People Browsing**: "Around" screen focuses on ambient interest, not a list of users to browse.
*   **No Cold DMs**: Direct messages are only possible after joining/hosting a Drift.
*   **No "Say Hi"**: Removed random outreach mechanisms.
*   **No Full Profiles**: Users only see what's necessary for the Drift; no deep social/dating profile browsing.
*   **Privacy First**: No phone number exchange or reputation/scoring mechanics in MVP.

## 3. Drift Discovery & Detail Flow
*   **Feed**: "Discover" tab shows active drifts.
*   **Mine**: Nested inside Drifts screen; shows your hosted and joined drifts.
*   **Pre-Join (Detail View)**:
    *   Show approximate location (distance).
    *   Show Drift description, host (basic info), and participants (initials).
*   **Join/Accept Flow**:
    *   Users request to join or join directly (if open).
    *   Host accepts/manages requests.
*   **Post-Join/Acceptance**:
    *   **Exact Coordination**: Precise meeting point and chat access unlocked ONLY after acceptance.
    *   **Safety First**: Safety and coordination banners are present to build trust.

## 4. Screen Specific Rules

### Around (Discovery)
*   **Radar**: 0.3mi, 0.6mi, 0.8mi rings. Ambient presence only.
*   **Interests**: Lead to Drifts filtered by category.
*   **Primary CTA**: Create action.

### Drifts
*   **Discover Tab**: Publicly available drifts nearby.
*   **Mine Tab**: Manage your own involvement.
*   **States**: Open, Starting Soon, Tonight.

### Chats
*   **Context**: Group/Direct chats tied specific to a Drift.
*   **Scope**: Async coordination focus.

### Drift Detail
*   **Sticky Footer**: Multi-state CTA (Join, Requested, Joined, Full, Ended).
*   **Info Grid**: Date, Time, Distance, Participants.
*   **Dynamic Labels**: Use `AppStrings` and `AppIcons` for all UI elements.

### Manage Drift (Host View)
*   **Functionality**: Approve/reject requests, edit drift details, end drift.

## 5. MVP Omissions (Out of Scope)
*   Real-time chat complexity (keep it simple/async).
*   Phone number exchange.
*   Reputation/Scoring/Reviews.
*   Friend graphs/Followers.
*   Mandatory reminders (optional/later).
