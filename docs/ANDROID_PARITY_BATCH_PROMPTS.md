# Android Parity — Implementation Batch Prompts (for Codex / Antigravity)

Hand these to an implementation agent **one batch at a time, in order**. Each batch is
self-contained: it includes the shared preamble by reference. After each batch, the user
builds/validates before starting the next.

> **How to use:** paste the **Preamble** + **one batch** into the tool. Do not run multiple
> batches at once. Order: P1 → P2 → … → P9.

---

## PREAMBLE (prepend to every batch prompt)

```
You are implementing Android UI/UX parity for the CoffeeCall app (apps/android, Kotlin +
Jetpack Compose). Work ONLY inside apps/android/. Do NOT touch apps/frontend/ (iOS is a
later, separate phase).

AUTHORITATIVE SPEC — read before coding:
- docs/IOS_SCREEN_WIDGET_MAPPER.md  ← source of truth for WHAT each screen must do/show.
- docs/ANDROID_UI_REFRESH_HANDOFF.md ← §3 working rules, §4 component APIs, §9 parity gaps + LOCKED decisions.
- Use native source and current user-provided screen references. Exported markdown templates were removed.

DESIGN SYSTEM (use these, do not reinvent):
- Tokens: core/design/Color.kt, Tokens.kt (CoffeeShapes.xxlarge=28, hero=32, immersive=40).
- Icons: core/design/CoffeeIcons.kt (CoffeeIcons.<name>, CoffeeIcons.category(String)).
- Components: core/design/CoffeeComponentsRefresh.kt — CoffeeButton(+CoffeeButtonVariant),
  CoffeeAvatar, CoffeeGlassBadge, CoffeeDriftCard, categoryAccent(String).

RULES:
- Do NOT run builds; write correct, compiling Kotlin (the user validates builds).
- Presentation/UX only unless the batch says otherwise: do NOT change repositories,
  domain models, or Firestore schemas. Adding ViewModel state/UI plumbing is fine.
- Keep changes additive where possible; only delete legacy code the batch explicitly removes.
- Respect product guardrails: 44dp+ touch targets, maxLines/ellipsis, and any privacy
  gating the mapper specifies (e.g. meeting-point lock).
- Fonts: keep Android FontFamily.SansSerif. Do NOT switch to Inter.
- When done, PREPEND a CHANGELOG.md entry: "## [YYYY-MM-DD] - Android Parity Batch P#: <name>"
  with What changed / Why, and only claim done for what is actually in the code.
```

---

## P1 — Create as center modal + 4-tab nav  *(LOCKED structural decision)*

```
GOAL: Match iOS — Create is a CENTER MODAL action, not a bottom-nav tab.

REFERENCE: IOS_SCREEN_WIDGET_MAPPER.md "Entry And App Shell" (FloatingTabBar = Discovery,
Drifts, Chats, Profile + center create action that does NOT consume a tab index).

FILES:
- core/navigation/CoffeeCallDestination.kt
- core/navigation/CoffeeCallApp.kt

DO:
1. Remove the CREATE entry from CoffeeCallDestinations so the bottom bar has exactly 4 tabs
   (Discovery, Drifts, Chats, Profile). Keep CoffeeCallRoutes.CREATE constant.
2. In CoffeeCallApp's shell, add state for the center action and render the native create surface inside
   a Material3 ModalBottomSheet (or full-height Dialog) when true.
3. Add a center floating "+" action to the bottom navigation (a raised circular button,
   slate-dark per the existing Discovery FAB styling) that sets showCreateSheet = true.
   It must sit visually between Drifts and Chats and NOT highlight as a selected tab.
4. On successful create, dismiss the sheet and navigate to the Drifts tab (preserve the
   existing onCreated behavior).
5. Remove the standalone CREATE composable(){} destination from the NavHost (Create is no
   longer a navigable tab), or keep the route only if other deep links use it — verify.

ACCEPTANCE:
- Bottom bar shows 4 tabs; a center + opens Create as a modal over the current tab.
- Creating a drift closes the modal and lands on Drifts.
- No build errors; no dead references to the removed CREATE destination.
```

---

## P2 — Discovery = radar-only  *(LOCKED structural decision)*

```
GOAL: Match iOS — Discovery is radar-first with NO meetup card feed. Meetup cards live on
the Drifts tab only.

REFERENCE: IOS_SCREEN_WIDGET_MAPPER.md "Home / Around: Discovery" (radar world, presence
toggle, refresh button, draggable bottom sheet whose progress dims/scales/blurs the radar,
drifts-forming pill, interest grid, notifications bell). iOS file: Screens/Main/DiscoveryScreen.swift.

FILES:
- feature/discovery/DiscoveryScreen.kt
- feature/discovery/DiscoveryViewModel.kt (only if removing feed-specific state)

DO:
1. Remove from Discovery: the CoffeeDriftCard meetup feed/list, the search input bar, and
   the category filter-chip row. Remove now-unused feed state from DiscoveryViewModel.
2. Keep / ensure present: radar (AroundRadar) with scanning sweep, presence toggle, refresh
   button (timed scan), draggable bottom sheet with radar parallax, interest grid of premium
   cards, and a "drifts forming" pill.
3. Interest card tap -> set the active interest filter and switch to the Drifts tab
   (mirror iOS NavigationManager.activeInterestFilter behavior; wire via the existing
   nav/tab mechanism).
4. "Drifts forming" pill tap -> switch to the Drifts tab.
5. Leave the bell wiring as-is for now (P3 replaces the Toast with a real sheet).

ACCEPTANCE:
- No meetup card list / search / filter chips on Discovery.
- Radar + sheet + interest grid + pill present and interactive.
- Tapping an interest lands on Drifts filtered by that category.
```

---

## P3 — Notifications sheet (replace bell Toast)

```
GOAL: Match iOS — the bell opens a notifications sheet and routes to the matching drift.

REFERENCE: IOS_SCREEN_WIDGET_MAPPER.md "Notifications" + Screens/Main/NotificationsSheet.swift.

FILES:
- new: feature/discovery/NotificationsSheet.kt (a ModalBottomSheet composable)
- feature/discovery/DiscoveryScreen.kt (bell action -> open sheet)
- DiscoveryViewModel (expose a notifications list if not already available)

DO:
1. Build a NotificationsSheet listing notification items (e.g. join requests / drift updates)
   from existing data; each row shows context + timestamp.
2. Replace the bell's Toast with opening this sheet.
3. Row tap -> navigate to that drift's detail by id (use the existing nav action used by
   drift cards). Keep the unread/dot indicator behavior on the bell.

ACCEPTANCE:
- Bell opens a sheet of notifications; empty state handled.
- Tapping a notification navigates to the correct drift detail.
```

---

## P4 — Profile parity (finish Batch 8)

```
GOAL: Bring ProfileScreen to the iOS spec.

REFERENCE: IOS_SCREEN_WIDGET_MAPPER.md "Profile" (identity card w/ verified-phone pill +
interests; 4 stat tiles hosted/joined/no-shows/score each opening a StatsDetail sheet;
saved/bookmarked drifts row; activity log; preference rows opening sheets: Interests,
Availability, Notifications, Privacy/Safety; account rows: Location, Help, Sign out).
iOS files: Screens/Main/ProfileScreen.swift, EditProfileScreen.swift, ProfileViewModel.swift.

FILES:
- feature/profile/ProfileScreen.kt, ProfileEditScreen.kt, ProfileViewModel.kt

DO:
1. Identity card: large CoffeeAvatar, name, approximate location, verified-phone pill,
   interest chips, edit button.
2. Four stat tiles (hosted/joined/no-shows/score); each opens a stat-detail bottom sheet.
3. Saved drifts horizontal row (bookmarked) routing to drift detail; activity-log row.
4. Preference sheets: Interests (toggle DriftCategory), Availability (weekday/weekend/daytime),
   Notifications, Privacy/Safety — persist via ProfileViewModel/DataStore as the existing
   profile fields do.
5. Account rows: Location (update from GPS/geocode), Help, Sign out (call existing sign-out).
   Use CoffeeButton / CoffeeAvatar / CoffeeIcons.chevronRight throughout.

ACCEPTANCE:
- Every widget the mapper lists is present; sheets open; toggles persist across relaunch.
```

---

## P5 — Host management parity

```
GOAL: Ensure hosts get full management parity with iOS ManageDriftScreen.

REFERENCE: IOS_SCREEN_WIDGET_MAPPER.md "Drift Detail And Host Management"
(ManageDriftScreen: overview, share/edit/close/delete, pending join requests accept/reject,
joined participants, chat entry, safety banner). iOS routes OWNED drifts -> Manage, others -> Detail.

FILES:
- feature/driftDetail/DriftDetailScreen.kt, DriftDetailViewModel.kt
- optionally new: feature/driftDetail/ManageDriftScreen.kt + route in CoffeeCallApp.kt

DO:
1. Verify the current in-Detail host panel (HostRequestsPanel) supports: edit, close, delete,
   accept/reject requests, view participants. Fill any missing host action wired to the VM.
2. Decide structure: EITHER add a dedicated ManageDriftScreen and route owned drifts to it
   (closer to iOS) OR keep host ops in DriftDetail if already complete — document the choice
   in the CHANGELOG entry.

ACCEPTANCE:
- A host can edit, close, delete their drift and accept/reject requests from Android.
- Non-host vs host see the correct screen/controls.
```

---

## P6 — Drift Detail privacy guardrails (verify/fix)

```
GOAL: Enforce iOS privacy gating on Drift Detail.

REFERENCE: IOS_SCREEN_WIDGET_MAPPER.md "Drift Detail" — exact meeting point is blurred/locked
until joined; the "who's coming" participants list is locked before join/request.

FILES: feature/driftDetail/DriftDetailScreen.kt

DO:
1. Pre-join: blur/lock the exact meeting point (show approximate only) and hide the full
   participant list (show count/initials only as iOS does).
2. Post-join: reveal meeting point + full participants.

ACCEPTANCE:
- Not-joined users cannot see exact meeting point or full participant list.
- Joined users can. Matches iOS behavior.
```

---

## P7 — Chats parity (verify/fix)

```
GOAL: Confirm Chats match iOS feature set; fill gaps.

REFERENCE: IOS_SCREEN_WIDGET_MAPPER.md "Chats" — status filter chips (active/upcoming/past),
context chips in thread, composer attachment dialog (camera / photo library / location),
system message rows, detail sheet (mute, view drift, report, block, leave).

FILES: feature/chat/ChatScreen.kt, ChatThreadScreen.kt, ChatThreadViewModel.kt, ChatsListViewModel.kt

DO: Audit against the mapper; add any missing: status filter chips on the list, the
attachment dialog options, system message rows, and the thread detail sheet actions.

ACCEPTANCE: Each mapper-listed Chats widget/action is present and wired.
```

---

## P8 — Auth + Onboarding parity (finish Batch 9)

```
GOAL: Bring onboarding + auth + profile setup to parity and the refreshed style.

REFERENCE: iOS auth flow and native onboarding/auth code, reconciled against current iOS behavior.

FILES: feature/onboarding/OnboardingScreen.kt, feature/auth/AuthScreen.kt, ProfileSetupScreen.kt

DO: Single-column layouts, CTA pinned bottom (CoffeeButton), OTP entry boxes, permission
cards (location + notifications), completion/all-set state. Match the existing onboarding
alignment already done and extend to AuthScreen + ProfileSetupScreen.

ACCEPTANCE: Phone -> OTP -> profile -> permissions -> done flow styled and consistent.
```

---

## P9 — Shell + final consistency pass (finish Batch 10)

```
GOAL: Polish the app shell and do a cross-screen consistency pass.

FILES: core/navigation/CoffeeCallApp.kt (top bar, offline banner, notification permission
dialog), feature/discovery MapView, and a sweep across all screens.

DO: Align shadows, radii (CoffeeShapes), spacing (CoffeeSpacing), and empty/loading/error
states to the refreshed system. Ensure the offline banner, top bar, and dialogs match.
Verify no leftover text-symbol icons remain anywhere.

ACCEPTANCE: Visual consistency across tabs; no legacy symbols; states all styled.
```

---

## Batch dependency / order notes
- **P1 and P2 are the locked structural changes** — do them first; they affect navigation and
  the Discovery layout other batches assume.
- P3–P9 are largely independent and can be reordered, but keep P4 before any further Profile work.
- After all P-batches, a final iOS phase (separate handoff) mirrors anything still divergent.
