# CoffeeCall Android

This folder contains the native Android CoffeeCall app scaffold.

## Direction
The Android app will be built with Kotlin and Jetpack Compose while the existing iOS app remains in SwiftUI under `apps/frontend`.

Skip is not the active path for Android. Keep Android native and share behavior through Firebase schemas, backend rules, and product contracts.

## Before Coding
Read these files:
1. `AI.md`
2. `CURRENT_STATE.md`
3. `CHANGELOG.md`
4. `docs/ANDROID_NATIVE_MIGRATION_PLAN.md`
5. `docs/ANDROID_AGENT_WORKFLOW.md`
6. `docs/ANDROID_BATCH_STATUS.md`

## Batch Workflow
Implement one migration batch at a time from `docs/ANDROID_NATIVE_MIGRATION_PLAN.md`.

For each batch:
1. Confirm the batch scope.
2. Update `docs/ANDROID_BATCH_STATUS.md` to claim ownership before editing.
3. Inspect the matching SwiftUI/iOS files.
4. Implement native Android code.
5. Run the Android acceptance checks for that batch.
6. Update `docs/ANDROID_BATCH_STATUS.md`, the migration plan, `CURRENT_STATE.md`, and `CHANGELOG.md` when the state changes.

## Current Status
Batch 3 is complete. The app is a Kotlin + Jetpack Compose + Material 3 skeleton with Firebase foundation code, DataStore-backed auth/onboarding routing, and placeholder tabs for Discovery, Create, Drifts, Chat, and Profile.

Build from this directory:

```bash
./gradlew assembleDebug
```

## Firebase Configuration
Do not commit a real Firebase Android config file. Place local config at:

```text
apps/android/app/google-services.json
```

The file is ignored by source control. If it is missing, the app still builds and starts in a documented Firebase-not-configured mode; repository calls should be treated as unavailable until a valid Firebase config is provided.
