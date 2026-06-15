# Android UI Refresh — Agent Handoff

**Status:** Batches 1–4 of 10 complete. Batches 5–10 remain.
**Owner of next work:** any agent. Start at Batch 5.
**Last updated:** 2026-06-15

---

## 1. Goal

Re-skin the app so **iOS and Android share one look**, matching the Figma "Social Refresh" design. The user wants **Android done first**; iOS is deliberately last (only one iOS component is redesigned so far — see §7).

**Fidelity decision:** "Match, but tasteful" — adopt the bold Figma look (large radii, glass badges, photo-forward cards, heavy weights) but soften anything that fights native conventions.
**Font decision:** keep the existing font stacks; match weights/sizes only. Do **not** switch to Inter. (Android currently uses `FontFamily.SansSerif` in `Type.kt` — leave it unless a later explicit decision bundles Outfit.)

---

## 2. Source of truth — read this first

The Figma Make export lives in **`design-reference/`** at the repo root.

- **USE:** the real code — `design-reference/src/app/screens/*.tsx`, `design-reference/src/app/components/*.tsx`, and `design-reference/src/styles/theme.css`.
- **IGNORE (stale):** `design-reference/COFFEECALL_DESIGN_SYSTEM.md` and `design-reference/src/imports/.../coffeecall-mvp-screens.md` — they describe an OLD blue/coral palette that is **not** the live design.

**Live palette** (already in Android `Color.kt`): mint `#53B8A6`, mint-pressed `#3D8D7A`, lavender `#8E7DBE`, peach `#E88C6B`, bg `#F6F1EB`, card `#FFFDF9`, surface-secondary `#F4F4F8`, text-primary `#243447`, text-secondary `#5F6368`, border `#E7DED4`.

---

## 3. Working rules (follow these)

1. **Agents do NOT run builds.** Per project convention the user validates all builds. Write correct code; don't rely on compiling locally.
2. **One batch at a time.** After each batch completes, **prepend a CHANGELOG.md entry** (`## [date] - Android UI Refresh Batch N: <name>` with What changed / Why) and mark the batch done.
3. **Don't break compilation.** The refreshed components are *additive* (new file) so unmigrated screens still build. When you migrate a screen, switch it to the new components; only remove legacy components once nothing references them.
4. Stay within `apps/android/` for these batches. Do not touch `apps/frontend/` (iOS) — that's the last phase.
5. Keep the Figma look but respect Dynamic Type / accessibility (maxLines, ellipsis, 44dp+ touch targets).

---

## 4. What's already done (Batches 1–3)

**Batch 1 — Tokens** (`core/design/`)
- `Color.kt` reconciled to the exact Figma hexes.
- `Tokens.kt` `CoffeeShapes` gained `xxlarge` (28dp), `hero` (32dp), `immersive` (40dp).

**Batch 2 — Icons**
- Added `androidx.compose.material:material-icons-extended` (`gradle/libs.versions.toml` + `app/build.gradle.kts`). **Requires a Gradle sync.**
- New `core/design/CoffeeIcons.kt` — central `ImageVector` map: nav icons, UI/action icons (`search`, `filter`, `bell`, `map`, `location`, `clock`, `people`, `heart`, `arrowUpRight`, `back`, `send`, `chevronRight`, `bolt`, `check`, `close`), and `CoffeeIcons.category(String)` for activity icons.
- `CoffeeCallDestination` now carries `icon: ImageVector`; bottom nav in `core/navigation/CoffeeCallApp.kt` renders real icons.

**Batch 3 — Components** (`core/design/CoffeeComponentsRefresh.kt`, new file)
- `CoffeeButton(title, onClick, variant, enabled, fullWidth, leadingIcon, trailingIcon, height)` + `enum CoffeeButtonVariant { Primary, Accent, Peach, Secondary, Ghost }`.
- `CoffeeAvatar(name, imageUrl, size, background, ringColor)` — Coil + initials fallback.
- `CoffeeGlassBadge(title, icon, showLiveDot, containerColor, contentColor)`.
- `CoffeeDriftCard(title, hostName, category, distanceText, timeText, onJoin, imageUrl, hostImageUrl, statusLabel, vibe, peopleGoing, isFeatured, actionLabel, actionColor, onClick)` — the immersive photo-forward card. **Screens should use this.**
- `categoryAccent(String): Color` helper.
- Legacy `CoffeeCategoryChip` and `CoffeeEmptyState` gained an optional `icon: ImageVector` param.

---

## 5. Remaining batches (4–10)

For each: open the matching Figma `.tsx`, restyle the Android screen with the §4 components, then log to CHANGELOG.

| Batch | Android file(s) | Figma reference (`design-reference/src/app/`) | Notes |
|------|------------------|-----------------------------------------------|-------|
| **4 — Discovery** | `feature/discovery/DiscoveryScreen.kt` | `screens/Discovery.tsx` (+ `MapView.tsx`, `Notifications.tsx`) | "Hey {name}" header; bell/map/avatar actions; floating search bar; filter chips row (use `CoffeeCategoryChip` w/ `CoffeeIcons.category`); feed of `CoffeeDriftCard`; dark FAB; accept + match modals |
| **5 — Drifts + Detail** | `feature/drifts/DriftsScreen.kt`, `feature/driftDetail/DriftDetailScreen.kt` | `screens/MyActivities.tsx`, `screens/ActivityDetails.tsx` | List uses `CoffeeDriftCard`; detail = hero image + glass info + join/leave + directions |
| **6 — Create** | `feature/create/CreateScreen.kt` | `screens/CreateActivity.tsx` (+ `CreateSuccess.tsx`) | Activity chip grid, time/capacity/join-mode selectors, location card, rounded inputs, primary CTA |
| **7 — Chat** | `feature/chat/ChatScreen.kt`, `feature/chat/ChatThreadScreen.kt` | `screens/Messages.tsx` | Thread list cards; bubble styling (self=mint right, other=surface left), rounded input bar w/ `CoffeeIcons.send`, header actions |
| **8 — Profile** | `feature/profile/ProfileScreen.kt`, `feature/profile/ProfileEditScreen.kt` | `screens/Profile.tsx` | Large `CoffeeAvatar` header, interest chips, stat cards, settings rows w/ `chevronRight` |
| **9 — Auth + Onboarding** | `feature/onboarding/OnboardingScreen.kt`, `feature/auth/AuthScreen.kt`, `feature/auth/ProfileSetupScreen.kt` | `screens/Onboarding.tsx`, `screens/auth/{Welcome,PhoneEntry,OTPVerification,CreateProfile,Permissions,AllSet}.tsx` | Single-column, CTA at bottom, OTP boxes, permission cards |
| **10 — Shell + polish** | `core/navigation/CoffeeCallApp.kt` (top bar, offline banner, notification dialog), `feature/discovery/...MapView`, consistency pass | — | Final pass: shadows, spacing, empty/error/loading states, dynamic type |

The ViewModels and data flow are already wired — these batches are **presentation only**. Don't change repositories, navigation routes, or domain models.

---

## 6. Key files map

- Design system: `apps/android/app/src/main/java/com/coffeecall/app/core/design/{Color,Tokens,Type,Theme,CoffeeIcons,Components,CoffeeComponentsRefresh}.kt`
- Navigation/shell: `.../core/navigation/{CoffeeCallApp,CoffeeCallDestination}.kt`
- Screens: `.../feature/<area>/...`
- Domain model: `.../domain/model/DriftPost.kt` (the Android "Drift"; category is a string — feed it to `CoffeeIcons.category` / `categoryAccent`)

---

## 7. iOS (do LAST, not now)

One iOS file is already redesigned to the immersive style as a reference for the target look:
- `apps/frontend/Coffee_Call/Components/DriftCard.swift` (immersive photo card)
- `apps/frontend/Coffee_Call/DesignSystem/AppConstants.swift` (added `cornerRadiusXLarge` 28 / `cornerRadiusXXLarge` 32)

iOS keeps **Outfit + SF Pro**. The full iOS rollout happens after Android is complete.

---

## 8. First step for the next agent

1. Sync Gradle and build to confirm Batches 1–4 compile and show the redesigned Discovery Screen.
2. Start Batch 5 (Drifts + Detail), referencing `design-reference/src/app/screens/MyActivities.tsx` and `ActivityDetails.tsx`.
3. Log each completed batch in `CHANGELOG.md`.
