# CoffeeCall Android Release QA Checklist

This document details the smoke-test paths required to validate native Android release builds of CoffeeCall prior to app store release.

---

## 📱 1. Authentication & Onboarding Flow

- [ ] **First Launch Routing:**
  - Clear app data/cache and launch.
  - Verify the onboarding pager slides are shown (Marketing onboarding).
  - Verify that completing onboarding navigates to the Phone Login screen.
  - Close and reopen the app: verify it bypasses the marketing slides and goes straight to the Login screen (Local completed onboarding state).
- [ ] **Phone Authentication:**
  - Input a valid test phone number.
  - Verify the verification code input appears.
  - Enter the verification code: verify it authenticates and redirects based on profile state (New profile setup vs returning session).
- [ ] **Profile Onboarding Setup:**
  - Create a new account.
  - Verify you can input name, bio, availability preference tags.
  - Upload a profile picture (Coil loader test).
  - Verify that saving navigates to the main App Shell (Around tab).
- [ ] **Sign Out:**
  - Tap "Sign Out" in the top bar.
  - Verify that local storage preference state is cleared and you return to the Login screen.

---

## 📍 2. Discovery & Around Feed

- [ ] **Location Permissions Prompt:**
  - Launch Around with location permission denied: verify the screen displays a "Location permission denied" warning card with an action button to "Browse nearby" or request access.
  - Grant coarse/fine location permission: verify it queries and resolves coordinates.
- [ ] **GPS Presence Sync:**
  - Enable Radar: verify your initials show up on the anonymous Around Radar.
  - Disable Radar: verify your avatar/initials are removed immediately.
- [ ] **10km Drift Discovery Feed:**
  - Verify that on-demand nearby Drifts load (within 10km) using geohash prefix queries.
  - Test pull-to-refresh: verify loading spinner indicates active querying.

---

## ☕ 3. Drift Creation Flow

- [ ] **Form Validation:**
  - Tap "+" tab to open the Create Drift screen.
  - Try to submit with an empty title: verify custom validation warning displays.
  - Validate vibe selection, spots capacity limits, and manual coordinate fields.
- [ ] **Drift Place Picker:**
  - Search a location: verify that debounced Geocoder search resolves matching locality suggestions.
  - Select a location: verify that coordinates populate and a custom preview map displays.
- [ ] **Document Creation & Synchronization:**
  - Submit the form: verify it commits a new post document to the `posts` collection in Firestore.
  - Verify a matching thread document is created simultaneously in `messageThreads`.
  - Validate that the post is visible in the creator's "Hosting" tab and to nearby users in their "Around" feed.

---

## 🤝 4. Joins & Host Actions

- [ ] **Join Request:**
  - Log in with a different user account.
  - Open the detail screen for an approval-required Drift.
  - Verify approximate map representation (concentric dashed circles) is shown instead of coordinates.
  - Tap "Request to Join": verify status transitions to "Requested".
- [ ] **Host Approvals/Rejections:**
  - Switch back to the host account.
  - Open the Drift Detail page: verify the "Join Requests" panel displays the requester.
  - Tap "Accept": verify requester is added to participant initials, spots left decreases, and requester is added to the thread participants list in Firestore.
- [ ] **Detail Reveal:**
  - Switch back to the guest account.
  - Verify that details (meeting point, coordinates maps) are now fully revealed.

---

## 💬 5. Chat & Leave Flows

- [ ] **Realtime Messaging thread:**
  - Open the Chats tab: verify your active threads display.
  - Tap a thread: verify it loads messages with a realtime Firestore snapshot listener.
  - Send text messages: verify it appears instantly.
- [ ] **Attachments:**
  - Test sending location and image attachments (uploading successfully to Firebase Storage and appending url payload).
- [ ] **Safety Actions:**
  - Tap the header settings menu: verify you can block, report, or leave.
- [ ] **Resilient Leave Transaction:**
  - Tap "Leave Drift": verify that the participant is removed from `messageThreads` participants array, acceptance documents are deleted, and post spots increment atomically.

---

## 🔗 6. Deep Linking & Platform Integrations

- [ ] **Intent Interception:**
  - Trigger custom scheme deep link via ADB:
    ```bash
    adb shell am start -W -a android.intent.action.VIEW -d "coffeecall://drift/your-drift-uuid" com.coffeecall.app
    ```
  - Verify that the app boots directly to the Drift Detail page for `your-drift-uuid`.
- [ ] **Web URL Interception:**
  - Trigger web URL deep link:
    ```bash
    adb shell am start -W -a android.intent.action.VIEW -d "https://coffeecall.app/drift/your-drift-uuid" com.coffeecall.app
    ```
  - Verify it redirects to the native app instead of a web browser.
- [ ] **Calendar Intent pre-fill:**
  - Tap "Add Calendar" on a Drift Detail screen.
  - Verify it launches the system calendar app with the pre-filled Title, Description (Category, Meeting Point, Notes), Location, and parsed epoch millisecond times.

---

## 📡 7. Offline Resilience

- [ ] **Network State Notice:**
  - Turn off Wi-Fi/Cellular data: verify the amber warning banner ("Device is offline") slides down immediately.
  - Turn network back on: verify the banner slides up and disappears.
- [ ] **Local Fallbacks:**
  - Load feature lists while offline: verify they use cached fallback representations instead of blank/freeze states.
