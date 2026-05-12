# CoffeeCall MVP: Screen Specifications

## Overview
This file documents screen layouts, user flows, and design specifications for CoffeeCall MVP.

*To be updated with detailed wireframes and user flows after design finalization.*

## Screen List

### 0. Onboarding / Landing
- Full-screen background image representing real-life connections
- Glassmorphic "COFFEECALL BETA" badge at the top
- Large heading emphasizing "real life."
- Floating Glassmorphic cards showcasing nearby activities
- Prominent "Let's Go" primary pill-shaped CTA button
- Transitions smoothly into the Auth flow

### 1. Signup
- Phone number input
- OTP verification
- Profile photo upload
- Name input
- Location permission request
- Confirm button → Main app

### 2. Post Creation
- Location input (auto-populated from device)
- Activity purpose (text input)
- Time picker
- Create button → Success notification

### 3. Discovery / Notifications
- List of nearby posts
- Each post card shows:
  - Poster's profile photo
  - Poster's name
  - Activity purpose
  - Location (address)
  - Time
  - Accept / Reject buttons

### 4. Acceptance Confirmation
- Confirmation dialog showing:
  - Activity details (purpose, location, time)
  - Poster profile info
  - Confirm / Cancel buttons
- On confirm: Dialog closes, message thread opens

### 5. Message Thread
- List of messages in chronological order
- Message input field at bottom
- Send button
- Display sender's name/photo for each message

### 6. Poster Dashboard
- List of all acceptances for this user's posts
- For each acceptance:
  - Acceptor's profile photo
  - Acceptor's name
  - Time they accepted
  - Quick action buttons (if any)

### 7. Profile
- User's profile photo
- User's name
- Stats (posts created, acceptances)
- Edit button
- Logout button

---

**Status:** Awaiting Figma/Pencil design mockups  
**Last Updated:** 2026-05-10
