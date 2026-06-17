# iOS Screen And Widget Mapper

This mapper is based on the SwiftUI source in `apps/frontend/Coffee_Call` and follows the authenticated app flow from Home/Around through Profile. It is meant to keep iOS notes honest when changelog entries are focused elsewhere.

## Entry And App Shell

| Layer | File | Responsibility |
| --- | --- | --- |
| App root | `App/ContentView.swift` | Chooses the visible root: authenticated users enter `MainTabView`, first launch users see onboarding, signed-out returning users go to phone auth. Also shows the global no-network banner from `NetworkManager`. |
| Main shell | `Screens/Main/MainTabView.swift` | Owns the authenticated tab experience. Renders Discovery, Drifts, Chats, and Profile; opens Create from the center action. Starts `GlobalDriftStore`. |
| Floating nav | `Components/Navigation/FloatingTabBar.swift` | Glass bottom nav. Maps visible buttons to Discovery, Drifts, Chats, Profile, with a center create action that does not consume a tab index. |
| Shared page chrome | `Components/Navigation/CoffeeHeader.swift` | Provides `asCoffeePage`, main/sub headers, back button, notification button, presence toggle, and reusable header icon buttons. |
| Shared drift state | `ViewModels/GlobalDriftStore.swift` | Fetches and merges remote/local drifts, persists local cache, exposes generated join-request notifications, and broadcasts/syncs drift updates. |
| Tab visibility | `ViewModels/NavigationManager.swift` | Shared state for hiding the floating tab bar on detail/chat/manage screens and passing Discovery interest filters into Drifts. |

## Home / Around: Discovery

| Widget / Section | File | Responsibility |
| --- | --- | --- |
| `DiscoveryScreen` | `Screens/Main/DiscoveryScreen.swift` | Home screen. Combines radar, refresh action, collapsed/expanded bottom sheet, notifications sheet, and navigation to detail/manage screens. |
| Radar world | `Components/RadarView.swift` | Anonymous nearby-presence visualization. Draws radar rings, particles, scanning sweep, "You" center marker, people initials, and selected-person tooltip. |
| Presence toggle | `CoffeeHeader.swift` + `PermissionsManager` | Toggles `isRadarVisible`, syncs preference, requests location, and controls whether radar can refresh nearby people. |
| Refresh button | `DiscoveryScreen.swift` | Triggers location refresh and `DiscoveryViewModel.refreshNearby()`, showing a timed scan animation. |
| Bottom sheet | `Components/Navigation/CoffeeBottomSheet.swift` | Draggable sheet container used by Discovery. Its progress dims/scales/blurs the radar layer. |
| Drifts forming pill | `DiscoveryScreen.swift` | Taps to switch the parent tab to Drifts. |
| Interest grid | `DiscoveryScreen.swift` + `Components/InterestCard.swift` | Displays category cards from `DiscoveryViewModel.interestCategories`. Tapping writes `NavigationManager.activeInterestFilter` and routes to Drifts. |
| Notifications | `Screens/Main/NotificationsSheet.swift` | Opens from the bell and navigates to matching drift IDs through the local navigation path. |
| `DiscoveryViewModel` | `ViewModels/DiscoveryViewModel.swift` | Provides interest categories, radar people, scan state, and Firebase/mock discovery service selection. |

## Drifts List

| Widget / Section | File | Responsibility |
| --- | --- | --- |
| `DriftsScreen` | `Screens/Main/DriftsScreen.swift` | Searchable/filterable drift list. Routes owned drifts to Manage and other drifts to Detail. Pull-to-refresh calls `GlobalDriftStore.fetchDrifts()`. |
| Mode switch | `Components/DriftModeSwitch.swift` | Toggles Discover vs Mine list mode. |
| Time tabs | `Components/TimeStateTabs.swift` | Filters by All, Open now, Starting soon, Tonight. |
| Search bar | `DriftsScreen.swift` | Header search toggle exposes debounced text filtering through `DriftsViewModel`. |
| Filter button/sheet | `DriftsScreen.swift` | Opens `DriftsFilterSheet` with distance slider, timeframe chips, activity type chips, apply, and reset. |
| `TactileSlider` | `DriftsScreen.swift` | Custom slider/bubble UI for selected distance radius. |
| Featured card | `Components/DriftCard.swift` | First best-match card in Discover/All state, photo-forward with badges, host row, meta, and join state button. |
| Standard cards | `Components/DriftCard.swift` | Remaining list cards. Join button opens a confirm alert unless already hosting/joined. |
| Empty states | `DriftsScreen.swift` | Separate empty UI for Mine and Discover modes. Mine can switch back to Browse Nearby. |
| `DriftsViewModel` | `ViewModels/DriftsViewModel.swift` | Owns mode, time, category, distance, timeframe, search debounce, active filter count, and interest-to-category mapping from Discovery. |

## Drift Detail And Host Management

| Widget / Section | File | Responsibility |
| --- | --- | --- |
| `DriftDetailScreen` | `Screens/Main/DriftDetailScreen.swift` | Public/participant detail view. Hides tab bar, syncs with `GlobalDriftStore`, and owns join/request/chat/manage routing. |
| Header actions | `DriftDetailScreen.swift` | Share, bookmark, and calendar reminder buttons. |
| Hero section | `DriftDetailScreen.swift` | Shows status, short description, and drift image placeholder. |
| Summary grid | `DriftDetailScreen.swift` | Date/time, approximate place, distance, joined/capacity. |
| Map section | `DriftMapView` | Shows approximate pre-join context and opens maps options when allowed. |
| Host section | `HostContextCardSheet` | Host identity card; opens a richer host context sheet with stats/interests/other drifts. |
| Participants section | `WhoIsComingSheet` | Locked before join/request. After joining, shows participant initials and full participant list. |
| Details list | `DriftDetailScreen.swift` | Time, meeting point, bring list, vibe, notes. Exact meeting point is blurred/locked until joined. |
| Safety banner | `DriftDetailScreen.swift` | Safety/coordinating reminder. |
| Leave section | `DriftDetailScreen.swift` | Shows only for joined non-host users; confirms and calls leave flow. |
| Sticky CTA | `DriftDetailScreen.swift` | Host sees Manage; joined users see Chat; not joined/requested users can request/cancel; full/ended states change CTA copy/color. |
| `DriftDetailViewModel` | `ViewModels/DriftDetailViewModel.swift` | Computes join status, handles request/cancel/leave, participant fetch, host context fetch, bookmark state, share, calendar reminder. |
| `ManageDriftScreen` | `Screens/Main/ManageDriftScreen.swift` | Host-only operations: overview, share/edit/close/delete actions, pending join requests, joined participants, chat entry, safety banner. |
| `JoinRequestRow` | `ManageDriftScreen.swift` | Per-request accept/reject controls wired into `ManageDriftViewModel`. |
| `ManageDriftViewModel` | `ViewModels/ManageDriftViewModel.swift` | Accepts/rejects requests, closes, updates, deletes, shares, and updates local drift state. |

## Chats

| Widget / Section | File | Responsibility |
| --- | --- | --- |
| `ChatsListScreen` | `Screens/Main/ChatsListScreen.swift` | Lists accessible chat rooms from joined/hosted drifts. Routes a row to `DriftChatScreen`. |
| Status chips | `ChatsListScreen.swift` | Filters chat list by `ChatFilter` such as active/upcoming/past. |
| `CompactChatRow` | `ChatsListScreen.swift` | Displays category icon, title, last message, timestamp, and unread count. |
| Empty state | `ChatsListScreen.swift` | Shows no-room message and Explore CTA placeholder. |
| `ChatsViewModel` | `ViewModels/ChatsViewModel.swift` | Loads chat-eligible drifts and filters them by status. |
| `DriftChatScreen` | `Screens/Main/DriftChatScreen.swift` | Thread screen. Hides tab bar, shows context chips, message list, composer, safety footer, and info sheet. |
| `ChatBubble` | `DriftChatScreen.swift` | Renders self/other bubbles, text/image/location content, sender info, and delete affordance. |
| `SystemMessageRow` | `DriftChatScreen.swift` | Centered system notices above chat messages. |
| `ChatComposer` | `DriftChatScreen.swift` | Text input, send button, attachment trigger, keyboard handling. |
| Attachment dialog | `DriftChatScreen.swift` | Offers camera, photo library, or current location share. |
| `ImagePicker` | `DriftChatScreen.swift` | UIKit bridge for camera/library image selection. |
| `DriftChatDetailSheet` | `DriftChatScreen.swift` | Thread info, participants, mute, view drift, report, block, and leave actions. |
| `DriftChatViewModel` | `ViewModels/DriftChatViewModel.swift` | Loads Firebase/mock thread, listens to messages, sends text/image/location messages, deletes messages, leave/report/block flows. |

## Profile

| Widget / Section | File | Responsibility |
| --- | --- | --- |
| `ProfileScreen` | `Screens/Main/ProfileScreen.swift` | Profile tab. Shows identity, private stats, saved drifts, activity log, preferences, account controls, and multiple edit/settings sheets. |
| Identity card | `ProfileScreen.swift` | Avatar/photo fallback, name, approximate location, verified-phone pill, interests, edit button. |
| Stats section | `ProfileScreen.swift` | Four private stat tiles: hosted, joined, no-shows, score. Each opens `StatsDetailSheetView`. |
| Saved drifts | `ProfileScreen.swift` | Horizontal bookmarked drift cards from `BookmarkManager`; routes to `DriftDetailScreen`. |
| Activity log | `ProfileScreen.swift` | Horizontal history cards from real/mock profile history. |
| Preferences section | `ProfileScreen.swift` | Rows for Interests, Availability, Notifications, Privacy/Safety; each opens a dedicated sheet. |
| Account section | `ProfileScreen.swift` | Rows for Location, Help, Sign out. Sign out calls both profile and auth view models. |
| `EditProfileScreen` | `Screens/Main/EditProfileScreen.swift` | Modal edit form for photo, name, and bio with camera/library/remove options. |
| `SettingsSheetView` | `ProfileScreen.swift` | Static settings/about details. |
| `InterestsSheetView` | `ProfileScreen.swift` | Toggles `DriftCategory` interests persisted by `ProfileViewModel`. |
| `AvailabilitySheetView` | `ProfileScreen.swift` | Toggles weekday evening, weekend, and daytime availability flags. |
| `NotificationsSheetView` | `ProfileScreen.swift` | Local notification preference toggles. |
| `PrivacySheetView` | `ProfileScreen.swift` | Local privacy/safety toggles. |
| `LocationSheetView` | `ProfileScreen.swift` | Shows current profile location and can update from GPS/geocoding. |
| `HelpSheetView` | `ProfileScreen.swift` | Static support/help topics. |
| `StatsDetailSheetView` | `ProfileScreen.swift` | Explains the selected private stat. |
| `ProfileViewModel` | `ViewModels/ProfileViewModel.swift` | Persists profile fields to `UserDefaults`, syncs users document to Firebase, loads/saves profile image, loads real/mock history, subscribes to bookmarks, geocodes GPS location, signs out. |

## Shared Supporting Components

| Component | File | Responsibility |
| --- | --- | --- |
| `PrimaryButton` | `Components/PrimaryButton.swift` | Common branded CTA button. |
| `CategoryChip` | `Components/CategoryChip.swift` | Reusable category pill button. |
| `PillBadge` | `Components/PillBadge.swift` | Small badge/pill visual. |
| `GlassmorphicCard` | `Components/GlassmorphicCard.swift` | Frosted card container. |
| `CoffeeImageView` | `Components/CoffeeImageView.swift` | Drift image loading/fallback display. |
| `PhotoPickerModifier`, `CameraPicker`, `LibraryPicker` | `Components/PhotoPickerModifier.swift`, `CameraPicker.swift`, `LibraryPicker.swift` | Shared photo/camera/library permission and picker helpers. |
| `DriftContextCard` | `Components/DriftContextCard.swift` | Compact drift context presentation. |
| `BetaBadge` | `Components/BetaBadge.swift` | Small beta marker. |

## Documentation Sync Notes

- `AI.md` is still accurate about the required pre-task protocol: read `CURRENT_STATE.md` and recent `CHANGELOG.md`.
- `CHANGELOG.md` is currently Android-heavy; it does not describe this iOS widget map until the entry added with this document.
- `CURRENT_STATE.md` had contradictory Android status wording: line 9 said batches 5-10 remain, while the Android status section says batches 0-10 are complete. This mapper does not change Android behavior, but the pointer added to `CURRENT_STATE.md` makes the iOS screen map discoverable.
