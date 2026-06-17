# Android ↔ iOS Architecture Parity — Implemented Plan

Goal: make the Android architecture mirror the iOS architecture. Android already has the
same MVVM + design-system + repository/service abstraction (and cleaner domain/data layering).
This plan closes the **real** gaps only. Do NOT flatten Android's clean layers to copy iOS
folders — just add the missing shared-state patterns and tighten token discipline.

Run as ordered batches (A1 → A5), one at a time. Same rules as the UI parity work:
no builds (user validates), Android-only, log each batch in CHANGELOG, source-of-truth =
`docs/IOS_SCREEN_WIDGET_MAPPER.md`.

---

## Current Android architecture (reference)
- `core/` — design (tokens/components), navigation, firebase, location, notifications,
  permissions, session, storage, common.
- `domain/` — `model/` + `repository/` interfaces.
- `data/` — `repository/` Firebase impls + `remote/dto/` + `mapper/`.
- `feature/<area>/` — `Screen.kt` + `ViewModel.kt` (StateFlow uiState) vertical slices.

## iOS architecture being matched
- `DesignSystem/`, `Screens/`, `Components/`, `ViewModels/` (incl. shared `GlobalDriftStore`,
  `NavigationManager`, `BookmarkManager`, `PermissionsManager`), `Services/` (protocol +
  Firebase/mock), `Domain/`, `Models/`, `Helpers/`.
- Patterns: vertical slices, stateless SwiftUI, MVVM, protocol services w/ mock impls,
  **shared global state via @EnvironmentObject**, **shared NavigationManager**.

---

## A1 — Shared DriftStore (mirror iOS `GlobalDriftStore`)  [HIGH]
**Why:** iOS has one app-scoped source of truth for drifts; cross-screen updates (join/leave,
new drift) propagate everywhere. Android currently has each ViewModel fetch independently, so
state can diverge between Discovery/Drifts/Detail.

**Do:**
- Create `core/state/GlobalDriftStore.kt`: an app-scoped holder (singleton via Application or
  a DI-provided object) exposing `StateFlow<List<DriftPost>>`, plus `fetch()`, `refresh()`,
  cache merge (remote + local), `requestToJoin()/leave()` that update the flow, and a
  derived notifications flow (mirror iOS `GlobalDriftStore` responsibilities in the mapper).
- Provide it to Compose via a `CompositionLocalProvider` (or inject into ViewModels).
- Refactor `DriftsViewModel`, `DiscoveryViewModel`, `DriftDetailViewModel` to OBSERVE the
  store instead of each calling the repository directly. Keep repository calls inside the store.

**Acceptance:** joining/leaving/creating a drift on one screen reflects on the others without
a manual reload; one fetch path; no duplicate per-screen polling.

---

## A2 — Shared NavigationManager (mirror iOS `NavigationManager`)  [MED]
**Why:** iOS centralizes tab-bar visibility (hidden on detail/chat) and passes the Discovery
interest filter into Drifts. Android does this with scattered local state.

**Do:**
- Create `core/navigation/NavigationManager.kt`: shared state holder with
  `isTabBarHidden: StateFlow<Boolean>` and `activeInterestFilter: StateFlow<String?>`.
- In `CoffeeCallApp`, hide the floating bottom nav on detail/chat/manage routes via the store.
- Route Discovery interest taps through `activeInterestFilter` (replace the current ad-hoc
  arg passing) and have Drifts read it.

**Acceptance:** bottom nav auto-hides on Detail/Chat like iOS; interest filter flows
Discovery → Drifts through the shared manager.

---

## A3 — Service/repository mock parity + naming  [MED]
**Why:** iOS pairs each service protocol with Firebase + mock/preview impls
(`DriftsServiceProtocol` / `PreviewDriftsService`) and a documented offline path.

**Do:**
- Ensure every `domain/repository` interface has BOTH a Firebase impl (`data/repository`) and
  a lightweight mock/fake used when `google-services.json` is absent (extend
  `FirebaseRepositoryGuard`). Add fakes where missing.
- Align naming so the Firebase/mock pairing is obvious and discoverable.

**Acceptance:** app runs in a mock/offline mode with seeded data when Firebase config is
absent, mirroring iOS preview/mock behavior.

---

## A4 — Design-token compliance sweep (= UI handoff TODO #8)  [LOW]
**Why:** iOS forces all spacing/typography/colors through tokens; Android still has raw `.dp`,
hardcoded `fontSize`, and raw hex values in feature UI.

**Do:** Replace raw `.dp` → `CoffeeSpacing.*`, hardcoded `fontSize = .sp` →
`MaterialTheme.typography.*`, raw `Color(0x..)` → `Color.kt` tokens, across `feature/`.

**Acceptance:** near-zero raw `.dp`/hex/`fontSize` in `feature/`; values come from tokens.

---

## A5 — DI standardization  [OPTIONAL]
**Why:** ViewModels are built via hand-rolled `factory(application)` calls; iOS uses
`@EnvironmentObject`. Optional consistency improvement.

**Do:** Either standardize the factory pattern across all ViewModels, or adopt Hilt
(`@HiltViewModel`) consistently. Provide the A1 store + A2 manager through the same mechanism.

**Acceptance:** one consistent construction/injection pattern; shared store + nav manager
injected the same way everywhere.

---

## Order & notes
- A1 first (it's the backbone other screens observe), then A2, A3, A4, A5.
- Presentation/state plumbing only — do NOT change Firestore schema or domain model shapes.
- Log each as `## [date] - Android Arch Batch A#: <name>` in CHANGELOG.
- After A1–A2, re-run `:app:assembleDebug` and smoke-test cross-screen updates.
