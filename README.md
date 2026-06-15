# CoffeeCall - Activity-Based Social Meetup

CoffeeCall is a native SwiftUI iOS application that helps users coordinate spontaneous, real-world activities. 

## 🚀 Mission
**Activity first, person second.** We focus on bringing people together through shared interests like coffee, walks, and movies, without the pressure of traditional social or dating apps.

## 📱 Tech Stack
- **iOS Frontend:** SwiftUI
- **Android Frontend:** Planned native Kotlin + Jetpack Compose app in `apps/android`
- **Backend:** Firebase (Auth, Firestore, Storage, Functions)
- **Architecture:** Vertical Slices / Clean Architecture

## 🤖 For AI Agents
This project uses a **Living Knowledge Base** for context management. 
Before starting any task:
1. Read **[AI.md](./AI.md)** for the mandatory protocol.
2. Follow the instructions to warm up the local cache and semantic memory.

## 🛠 Setup & Development
- **Build Tool:** Xcode (Agents must NOT run builds)
- **Firebase:** Ensure `GoogleService-Info.plist` is present.
- **Android Plan:** See `docs/ANDROID_NATIVE_MIGRATION_PLAN.md`.
- **Android Agent Workflow:** See `docs/ANDROID_AGENT_WORKFLOW.md` and update `docs/ANDROID_BATCH_STATUS.md` for each batch.
- **AI Sync:** Run `python3 .ai_cache/update_cache.py` after significant changes.

---
*Developed by Robin George*
