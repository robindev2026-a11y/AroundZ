# Android UI Refresh — Agent Handoff

**Status:** Code audit on 2026-06-16: Batches 1–3 and 5–7 are Done; Batches 4, 8, 9, and 10 are Partial. Do not rely on older status notes without rechecking code.
**Owner of next work:** any agent. Start by finishing Batch 4 Discovery parity.
**Last updated:** 2026-06-16

---

## 1. Goal

Re-skin the app so **iOS and Android share one look**, matching the Figma "Social Refresh" design. The user wants **Android done first**; iOS is deliberately last (only one iOS component is redesigned so far — see §7).

**Fidelity decision:** "Match, but tasteful" — adopt the bold Figma look (large radii, glass badges, photo-forward cards, heavy weights) but soften anything that fights native conventions.
**Font decision:** keep the existing font stacks; match weights/sizes only. Do **not** switch to Inter. (Android currently uses `FontFamily.SansSerif` in `Type.kt` — leave it unless a later explicit decision bundles Outfit.)

---

## 2. Source of truth — read this first

Use current native product code and user-provided screen references only. Stale exported design markdown has been removed.

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

## 5. Current audit status (Batches 4–10)

For each: open the matching Figma `.tsx`, restyle the Android screen with the §4 components, then log to CHANGELOG. Status below is from direct code inspection, not from older logs.

| Batch | Android file(s) | Audit status / next work |
|------|------------------|--------------------------|
| **4 — Discovery** | `feature/discovery/DiscoveryScreen.kt` | **Done.** Refreshed header, presence toggle, notifications bell with sheet (P3), radar-only view, interest grid, drifts-forming pill, search, filter chips, dark FAB, accept/match dialogs, radar sheet polish are all present. The Figma "map toggle" does not exist on iOS — Discovery is radar-only. |
| **5 — Drifts + Detail** | `feature/drifts/DriftsScreen.kt`, `feature/driftDetail/DriftDetailScreen.kt` | **Done.** Drifts list uses `CoffeeDriftCard` with real haversine distance; 1–10 km filter sheet with slider, Reset, Apply; detail has hero image, `CoffeeAvatar`, `CoffeeGlassBadge`, detail cards, map section, host/request panels, and `CoffeeButton` CTAs. |
| **6 — Chat** | `feature/chat/ChatScreen.kt`, `feature/chat/ChatThreadScreen.kt` | **Done.** Thread list cards use `CoffeeAvatar` and refreshed surfaces; thread bubbles use mint self/surface other styling, rounded composer, `CoffeeIcons.send`, attachment/location actions, and safety menu dialogs. |
| **7 — Profile** | `feature/profile/ProfileScreen.kt`, `feature/profile/ProfileEditScreen.kt` | **Done.** Profile layout aligned with iOS: 2x2 stats grid, "Your stats" header, "Stats are private" note, "Coming soon" reputation score, text-link edit profile, gear icon header, color-differentiated settings rows, "Safety & Privacy" label. |
| **8 — Auth + Onboarding** | `feature/onboarding/OnboardingScreen.kt`, `feature/auth/AuthScreen.kt`, `feature/auth/ProfileSetupScreen.kt` | **Partial.** Onboarding, phone entry, OTP boxes, bottom CTAs, and profile setup photo/name flow are refreshed. Missing: dedicated permissions-card screen/flow. |
| **9 — Shell + polish** | `core/navigation/CoffeeCallApp.kt` (top bar, offline banner, notification dialog), `feature/discovery/...MapView`, consistency pass | **Done.** Real icon bottom nav, top bars, offline banner, notification permission dialog, shadows/spacing/loading states, and P9 consistency pass (text symbols→vector icons, raw dp→CoffeeSpacing tokens) are complete. |

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

1. All visual parity batches (4, 7, 9) are now Done. Batch 8 (Auth + Onboarding) is Partial — missing dedicated permissions-card screen/flow.
2. Run `docs/ANDROID_QA_CHECKLIST.md` on a real device to validate cross-platform data sync.
3. Reconcile stale docs: `apps/android/README.md`, `CURRENT_STATE.md` batch status.
4. Log each completed batch in `CHANGELOG.md` after code inspection confirms the refreshed UI is actually present.

---

## 9. iOS↔Android PARITY — authoritative spec (supersedes Figma where they conflict)

**`docs/IOS_SCREEN_WIDGET_MAPPER.md` is the source of truth for what Android must match.**
It reflects the current iOS app. Re-frame remaining work as *iOS parity*, not exported-template matching.

### Structural decisions (LOCKED by product owner, 2026-06-16)
- **Discovery = radar-only.** Remove the `CoffeeDriftCard` meetup feed and the search/filter
  chips from `DiscoveryScreen`. Keep radar + draggable bottom sheet + interest grid +
  drifts-forming pill. Meetup cards live on the **Drifts** tab only (as on iOS).
- **Create = center action + 4-tab nav.** `CoffeeCallDestinations` stays Discovery / Drifts / Chats / Profile. The center floating action opens `CreateScreen`.

### Parity Gaps checklist (verified against code 2026-06-16)
| # | Sev | Gap | iOS (mapper) | Android now | Action |
|---|-----|-----|--------------|-------------|--------|
| 1 | HIGH | Discovery model | radar-first, no card feed | hybrid radar + card feed + search/chips | Strip feed + search/chips (decision above) |
| 2 | HIGH | Create nav | center modal, 4 tabs | 5th nav tab | Modal + 4 tabs (decision above) |
| 3 | MED | Host management | separate `ManageDriftScreen` (edit/close/delete, accept/reject, participants) | folded into `DriftDetailScreen` (`HostRequestsPanel`) | Verify edit/close/delete parity; split into a Manage screen or confirm in-Detail is sufficient |
| 4 | MED | Notifications | `NotificationsSheet` from bell, routes to drift IDs | bell shows a Toast | Build a notifications sheet/list |
| 5 | MED | Profile | 4 stat tiles (+`StatsDetailSheet`), saved drifts row, activity log, 6 preference sheets, verified-phone pill, account rows | most missing | Build out Profile to mapper spec (Batch 8) |
| 6 | VERIFY | Chats | status filter chips, attachment dialog (camera/library/location), detail sheet (mute/report/block/leave) | confirm present | Audit `ChatScreen`/`ChatThreadScreen` against mapper |
| 7 | VERIFY | Drift Detail guardrails | meeting point blurred/locked until joined; participants sheet gated behind join | confirm present | Privacy guardrail — must match |

### TODO — added 2026-06-16 (architecture/quality, not yet done)
| # | Sev | Item | Detail |
|---|-----|------|--------|
| 8 | LOW | Design-token compliance sweep | **Done (P9).** Raw `.dp`→`CoffeeSpacing` in CreateScreen (34), DiscoveryScreen (16), OnboardingScreen (2). Text symbols/emoji→`CoffeeIcons` across all feature screens. |
| 9 | DECISION | Shared drift-state architecture | iOS centralizes drift state in `GlobalDriftStore` (`@EnvironmentObject`). Android uses independent per-screen ViewModels (no shared store), so cross-screen drift updates differ. Decide: introduce a shared store for true parity, or accept per-screen VMs on Android. |

Also pending from validation (2026-06-16): P7 (Chats) & P8 (Auth+Onboarding) implemented but **unlogged** in CHANGELOG; P9 consistency sweep incomplete (leftover `symbol = "C"` in `ChatScreen.kt:109,123`); confirm P4 Profile has all mapper sheets. A compile bug from the P1/P2 seam (`onNavigateToCreate` on `DiscoveryScreen`) was fixed — `:app:assembleDebug` now succeeds.

### Recommended execution order (Parity batches)
- **P0** (no dependency): #4 NotificationsSheet, #5 Profile sheets, #3 Manage parity check.
- **P1** (the locked structural changes): #1 Discovery radar-only, #2 Create-as-modal + 4-tab nav.
- **Then:** #6/#7 verification passes, finish Batch 8/9/10 visual fills, final consistency pass.
- Log each parity batch in `CHANGELOG.md` (`Android Parity Batch P#: <name>`). Same rules:
  no builds (user validates), additive components, stay in `apps/android/`, iOS is LAST.
