# Android Agent Workflow

This file defines how multiple AI agents should work on the native Android app without confusion or conflicts.

## Required Reading Order
Every agent must read these files before editing code:
1. `AI.md`
2. `CURRENT_STATE.md`
3. `CHANGELOG.md`
4. `docs/ANDROID_NATIVE_MIGRATION_PLAN.md`
5. `docs/ANDROID_BATCH_STATUS.md`
6. This file

## Single Source Of Truth
- Strategic plan: `docs/ANDROID_NATIVE_MIGRATION_PLAN.md`
- Sequential status and ownership: `docs/ANDROID_BATCH_STATUS.md`
- Current repo truth: `CURRENT_STATE.md`
- Historical decisions: `CHANGELOG.md`
- Android handoff entry: `apps/android/README.md`

## Conflict-Avoidance Rules
1. Work on exactly one batch at a time.
2. Do not start a batch unless all required prior batches are marked `Done` or the status ledger explicitly says it can run in parallel.
3. Before editing, update `docs/ANDROID_BATCH_STATUS.md` to mark the batch `In Progress` with agent name, date, scope, and touched paths.
4. Keep changes inside the batch-owned paths unless the batch explicitly allows shared files.
5. If a shared file must be changed, record the reason in `docs/ANDROID_BATCH_STATUS.md` before editing it.
6. Never rename Firestore fields, package names, routes, or shared models without recording a schema decision in the status ledger first.
7. Do not modify SwiftUI/iOS files unless the batch specifically requires inspection or the user explicitly asks for iOS changes.
8. Do not modify backend rules, indexes, or Functions unless the batch requires it and the status ledger records the expected compatibility impact.
9. Do not run `xcodebuild`. Android agents may run Gradle checks for Android batches.
10. After finishing, update `docs/ANDROID_BATCH_STATUS.md`, `CHANGELOG.md`, and `CURRENT_STATE.md` if project state changed.

## Batch Ownership Map
Use this ownership map to reduce overlap:

```text
Batch 0: apps/android scaffold, Gradle files, placeholder app shell
Batch 1: apps/android core/design, reusable UI, app shell polish
Batch 2: apps/android core/firebase, data, domain, Firebase config docs
Batch 3: apps/android feature/auth, feature/onboarding, auth repositories
Batch 4: apps/android feature/discovery, core/location, permissions
Batch 6: apps/android feature/driftDetail, join/leave repositories
Batch 7: apps/android feature/chat, message thread repositories
Batch 8: apps/android feature/profile, media/storage repositories
Batch 9: apps/android notifications, deep links, empty/error/offline polish
Batch 10: apps/android release config, signing docs, QA checklist
```

Shared paths that need extra care:
- `apps/android/app/build.gradle.kts`
- `apps/android/settings.gradle.kts`
- `apps/android/gradle/libs.versions.toml`
- `apps/android/app/src/main/AndroidManifest.xml`
- `apps/android/app/src/main/java/.../core/navigation`
- `apps/android/app/src/main/java/.../domain/model`
- `apps/android/app/src/main/java/.../domain/repository`
- `apps/backend`

## Agent Start Procedure
1. Read the required files.
2. Run `git status --short`.
3. Inspect `docs/ANDROID_BATCH_STATUS.md`.
4. Pick the next `Ready` batch.
5. If another batch is `In Progress`, only proceed if your batch is explicitly marked parallel-safe and has no shared paths.
6. Update the status ledger before editing.
7. Implement only the selected batch.
8. Run the batch acceptance checks.
9. Update status ledger with result, commands run, files touched, blockers, and next recommended batch.

## Status Ledger Format
Each batch entry in `docs/ANDROID_BATCH_STATUS.md` must keep:
- Status: `Blocked`, `Ready`, `In Progress`, `Review`, or `Done`
- Owner
- Started date
- Completed date
- Scope
- Touched paths
- Commands run
- Acceptance result
- Blockers
- Handoff notes

## Copy-Paste Master Prompt
Use this when starting any Android batch. Replace bracketed values.

```text
You are working in /Users/robingeorge/Documents/Projects/CoffeeCall.

Task: Implement Android migration Batch [N] - [Batch Name].

Before editing:
1. Read AI.md, CURRENT_STATE.md, CHANGELOG.md, docs/ANDROID_NATIVE_MIGRATION_PLAN.md, docs/ANDROID_BATCH_STATUS.md, and docs/ANDROID_AGENT_WORKFLOW.md.
2. Run git status --short and do not overwrite unrelated existing changes.
3. Confirm Batch [N] is Ready in docs/ANDROID_BATCH_STATUS.md and all prerequisite batches are Done.
4. Update docs/ANDROID_BATCH_STATUS.md to mark Batch [N] In Progress with your owner name, date, intended scope, and paths you expect to touch.

Rules:
- Work only on Batch [N].
- Keep changes inside the owned paths for Batch [N] unless the status ledger records a shared-file reason first.
- Do not modify SwiftUI/iOS files unless only reading them for parity.
- Do not rename Firestore collections or fields.
- Keep Android native Kotlin + Jetpack Compose.
- Run the acceptance checks for Batch [N].

Finish by updating docs/ANDROID_BATCH_STATUS.md with files touched, commands run, acceptance result, blockers, and handoff notes. Update CHANGELOG.md and CURRENT_STATE.md if project state changed.
```

## Batch-Specific Starter Prompts

### Batch 0 Prompt - Project Scaffold
```text
Implement Batch 0 - Project Scaffold for CoffeeCall Android.

Create a buildable native Android skeleton under apps/android using Kotlin, Jetpack Compose, Material 3, Gradle Kotlin DSL, and minSdk 26 or higher. Add placeholder screens for Auth, Discovery, Create, Drifts, Chat, and Profile, plus basic navigation and CoffeeCallTheme brand colors. Do not implement Firebase or real feature logic yet.

Owned paths: apps/android/**, root .gitignore only if Android build outputs are missing.
Acceptance: ./gradlew assembleDebug succeeds from apps/android, and the app has a placeholder shell with navigable placeholder tabs.
```

### Batch 1 Prompt - Design System And App Shell
```text
Implement Batch 1 - Design System And App Shell.

Port CoffeeCall visual tokens from the SwiftUI design system into Compose. Build native reusable components for buttons, badges, chips, drift cards, empty/loading states, top app bar, and bottom navigation. Polish the authenticated app shell. Do not connect Firebase or real data.

Owned paths: apps/android/**/core/design/**, apps/android/**/core/navigation/**, placeholder feature UI files as needed.
Read-only parity files: apps/frontend/Coffee_Call/DesignSystem/AppColors.swift, AppConstants.swift, AppStrings.swift, reusable SwiftUI components.
Acceptance: component previews exist, no text clipping at small widths/font scales, placeholder app shell still builds.
```

### Batch 2 Prompt - Firebase Foundation
```text
Implement Batch 2 - Firebase Foundation.

Add Firebase Android dependencies and initialization. Create DTOs, domain models, mappers, repository interfaces, and Firebase-backed repository skeletons for users, posts, acceptances, and messageThreads. Document google-services.json handling. Do not build feature screens beyond smoke wiring.

Owned paths: apps/android Gradle files, apps/android/**/core/firebase/**, apps/android/**/data/**, apps/android/**/domain/**, AndroidManifest if needed.
Read-only parity files: Swift models and Firebase service files under apps/frontend/Coffee_Call/Models and Services.
Acceptance: Android app starts with Firebase initialized or clearly documented dev placeholder; Firestore field names match iOS usage; Gradle build succeeds.
```

### Batch 3 Prompt - Auth And Onboarding
```text
Implement Batch 3 - Auth And Onboarding.

Build the native Android auth and onboarding flow using Firebase Auth and DataStore. Mirror iOS session routing: new users go through profile setup/onboarding, returning users enter the app shell, and signed-out returning users skip first-run marketing where appropriate.

Owned paths: apps/android/**/feature/auth/**, apps/android/**/feature/onboarding/**, auth-related repositories/use cases.
Read-only parity files: AuthViewModel.swift, OnboardingScreen.swift, ProfileViewModel.swift.
Acceptance: new/returning/signed-out states route correctly, sign-out clears local state, build succeeds.
```

### Batch 4 Prompt - Discovery/Around
```text
Implement Batch 4 - Discovery/Around.

Build Android location permission handling, location provider, nearby Drift discovery, and anonymous Around radar. Use the existing 10km/geohash backend contract and on-demand refresh behavior to avoid excessive Firestore reads.

Owned paths: apps/android/**/feature/discovery/**, apps/android/**/core/location/**, apps/android/**/core/permissions/**, discovery repositories/use cases.
Read-only parity files: DiscoveryViewModel.swift, FirebaseDiscoveryService.swift, RadarService.swift, DiscoveryScreen.swift.
Acceptance: denied/granted location states work, nearby posts load, radar does not expose private profile details, build succeeds.
```

### Batch 6 Prompt - Drift Detail And Join Flow
```text
Implement Batch 6 - Drift Detail And Join Flow.

Build Drift Detail with approximate pre-join map behavior, precise post-join location, open/request join flows, host accept/reject, resilient leave flow, and share intent. Preserve backend compatibility with iOS.

Owned paths: apps/android/**/feature/driftDetail/**, join/leave repositories/use cases.
Read-only parity files: DriftDetailScreen.swift, DriftDetailViewModel.swift, ManageDriftViewModel.swift, FirebaseDriftsService.swift.
Acceptance: join/leave state stays compatible with iOS, Firestore writes follow security rules, build succeeds.
```

### Batch 7 Prompt - Chat
```text
Implement Batch 7 - Chat.

Build Drift-tied chat list and chat screen. Subscribe to messageThreads, send text messages, optionally support image messages if still in MVP, and enforce no cold DMs in UI and repository checks.

Owned paths: apps/android/**/feature/chat/**, chat repositories/use cases.
Read-only parity files: DriftChatScreen.swift, DriftChatViewModel.swift, ChatsViewModel.swift, FirebaseChatService.swift.
Acceptance: Android/iOS messages interoperate through messageThreads, non-participants cannot open/send, build succeeds.
```

### Batch 8 Prompt - Profile And Media
```text
Implement Batch 8 - Profile And Media.

Build profile setup/edit, image picker, optional camera capture, Firebase Storage upload, and profile document updates. Preserve activity-first profile visibility.

Owned paths: apps/android/**/feature/profile/**, media/storage repositories/use cases.
Read-only parity files: ProfileViewModel.swift, ProfileImageHelper.swift, PhotoPickerModifier.swift, CameraPicker.swift.
Acceptance: Android profile data and images display correctly for iOS-compatible documents, storage rules remain respected, build succeeds.
```

### Batch 9 Prompt - Notifications, Reminders, And Polish
```text
Implement Batch 9 - Notifications, Reminders, And Polish.

Add Android 13+ notification permission handling, FCM groundwork if in scope, local reminder support if still MVP, deep-link/share polish, offline/empty/error states, and performance pass for listeners/images.

Owned paths: apps/android notification/deeplink/polish files across features, AndroidManifest as needed.
Read-only parity files: NotificationPermissionService.swift, PermissionsManager.swift, DriftDetailViewModel.swift.
Acceptance: notification permission is handled, no major flow is placeholder-blocked, transient network failures show useful UI, build succeeds.
```

### Batch 10 Prompt - Release Readiness
```text
Implement Batch 10 - Release Readiness.

Prepare Android for internal testing and release. Add signing documentation without committing private keystores, build variants if needed, R8/Proguard rules, crash/analytics decision, internal QA checklist, and debug/release build verification.

Owned paths: apps/android release Gradle/config/docs, docs QA checklist, status docs.
Acceptance: debug build and release build task succeed or blockers are documented; QA checklist exists; no secrets are committed.
```

## Handoff Template
Agents must paste this into `docs/ANDROID_BATCH_STATUS.md` when handing off unfinished work:

```text
Handoff:
- Last completed step:
- Current failing command or blocker:
- Files changed:
- Files that still need work:
- Decisions made:
- Decisions still needed:
- Suggested next command:
```

## Parallel Work Policy
Default: no parallel Android batch work.

Allowed exceptions:
- Documentation-only updates can run while code work is active if they do not edit the active batch status entry.
- A later UI-only batch may prepare design references only, without code edits, while an earlier infrastructure batch is active.
- Two agents may not edit Gradle files, navigation, domain models, repositories, backend rules, or the status ledger at the same time.

If in doubt, wait for the current `In Progress` batch to move to `Review`, `Done`, or `Blocked`.
