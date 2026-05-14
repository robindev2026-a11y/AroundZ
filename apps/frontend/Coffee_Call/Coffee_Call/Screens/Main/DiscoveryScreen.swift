import SwiftUI

// MARK: - Discovery Screen
// Matches Figma Discovery page: warm background, header with greeting + icon buttons,
// search bar, icon-labelled filter chips, large 4:5 activity cards feed, FAB.
// Join confirm sheet and match confirmation sheet are included here.

struct DiscoveryScreen: View {
    @State private var selectedCategory = AppStrings.Discovery.Categories.all
    @State private var searchText = ""

    // Modal state
    @State private var showJoinSheet = false
    @State private var showMatchSheet = false
    @State private var selectedActivity: Activity? = nil

    private let userName = "Robin"
    private let userInitials = "RO"

    @State private var activities: [Activity] = [
        Activity(
            userName: "Alex",
            userInitials: "AL",
            backgroundImageURL: "https://images.unsplash.com/photo-1552968431-f18ca2292af0?w=800&q=80",
            title: "Sunset walk and casual conversation? 🌅 Anyone down?",
            category: AppStrings.Discovery.Categories.walks,
            distanceKm: 0.4,
            time: "6:30 PM",
            attendeeCount: 4,
            vibeTag: "RELAXED",
            status: .startingSoon
        ),
        Activity(
            userName: "Riley",
            userInitials: "RI",
            backgroundImageURL: "https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?w=800&q=80",
            title: "Grabbing an iced oat latte at Blue Bottle. Come say hi and talk music!",
            category: AppStrings.Discovery.Categories.coffee,
            distanceKm: 1.2,
            time: "4:00 PM",
            attendeeCount: 2,
            vibeTag: "CHILL",
            status: .happening
        ),
        Activity(
            userName: "Priya",
            userInitials: "PR",
            backgroundImageURL: "https://images.unsplash.com/photo-1517048676732-d65bc937f952?w=800&q=80",
            title: "Co-working session at the public library. Deep work mode today.",
            category: AppStrings.Discovery.Categories.study,
            distanceKm: 2.3,
            time: "3:00 PM",
            attendeeCount: 3,
            vibeTag: "PRODUCTIVE",
            status: .startingSoon
        ),
        Activity(
            userName: "Marco",
            userInitials: "MA",
            backgroundImageURL: "https://images.unsplash.com/photo-1511632765486-a01980e01a18?w=800&q=80",
            title: "Quick smash burgers for dinner? Craving something messy and local.",
            category: AppStrings.Discovery.Categories.food,
            distanceKm: 3.1,
            time: "7:00 PM",
            attendeeCount: 6,
            vibeTag: "SOCIAL",
            status: .later
        ),
        Activity(
            userName: "Sana",
            userInitials: "SA",
            backgroundImageURL: "https://images.unsplash.com/photo-1551963831-b3b1ca40c98e?w=800&q=80",
            title: "Street photography session around the historic district. 📸",
            category: AppStrings.Discovery.Categories.walks,
            distanceKm: 1.8,
            time: "5:30 PM",
            attendeeCount: 1,
            vibeTag: "CREATIVE",
            status: .happening
        )
    ]

    // MARK: - Category chip definitions (label + SF symbol)
    private let chipDefs: [(id: String, label: String, icon: String)] = [
        ("All",     AppStrings.Discovery.Categories.all,    "bolt.fill"),
        ("Coffee",  AppStrings.Discovery.Categories.coffee, "cup.and.saucer"),
        ("Walks",   AppStrings.Discovery.Categories.walks,  "figure.walk"),
        ("Study",   AppStrings.Discovery.Categories.study,  "book"),
        ("Food",    AppStrings.Discovery.Categories.food,   "fork.knife"),
        ("Gaming",  AppStrings.Discovery.Categories.gaming, "gamecontroller"),
        ("Startup", AppStrings.Discovery.Categories.startup,"lightbulb")
    ]

    var filteredActivities: [Activity] {
        activities.filter { activity in
            (selectedCategory == AppStrings.Discovery.Categories.all
             || activity.category == selectedCategory)
            &&
            (searchText.isEmpty
             || activity.title.localizedCaseInsensitiveContains(searchText)
             || activity.userName.localizedCaseInsensitiveContains(searchText))
        }
    }

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            Color.backgroundMain.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {

                    // Header
                    headerView
                        .padding(.top, 16)
                        .padding(.horizontal, 24)
                        .slideUpEntrance(delay: 0)

                    // Search bar
                    searchBar
                        .padding(.top, 20)
                        .padding(.horizontal, 24)
                        .slideUpEntrance(delay: 0.06)

                    // Category filter chips
                    categoryChips
                        .padding(.top, 16)
                        .slideUpEntrance(delay: 0.12)

                    // Activity feed
                    LazyVStack(spacing: 28) {
                        ForEach(Array(filteredActivities.enumerated()), id: \.element.id) { index, activity in
                            ActivityCardView(
                                activity: activity,
                                onJoin: {
                                    selectedActivity = activity
                                    withAnimation(CoffeeAnimation.spring) {
                                        showJoinSheet = true
                                    }
                                },
                                onSave: {
                                    withAnimation(CoffeeAnimation.springSnap) {
                                        if let i = activities.firstIndex(where: { $0.id == activity.id }) {
                                            activities[i].isSaved.toggle()
                                        }
                                    }
                                }
                            )
                            .slideUpEntrance(delay: 0.18 + Double(index) * 0.07)
                        }
                    }
                    .padding(.top, 20)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 120)
                }
            }

            // FAB — create activity
            fabButton
                .padding(.trailing, 24)
                .padding(.bottom, 96)
                .slideUpEntrance(delay: 0.3)
        }
        .navigationBarHidden(true)
        // Join confirm sheet
        .sheet(isPresented: $showJoinSheet) {
            if let activity = selectedActivity {
                JoinConfirmSheet(
                    activity: activity,
                    userName: userName,
                    onConfirm: {
                        showJoinSheet = false
                        // Mark as joined
                        if let i = activities.firstIndex(where: { $0.id == activity.id }) {
                            activities[i].isJoined = true
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                            withAnimation(CoffeeAnimation.spring) {
                                showMatchSheet = true
                            }
                        }
                    },
                    onDismiss: { showJoinSheet = false }
                )
                .presentationDetents([.height(520)])
                .coffeeSheetCornerRadius(40)
                .coffeeSheetDragIndicator(.visible)
            }
        }
        // Match celebration sheet
        .sheet(isPresented: $showMatchSheet) {
            if let activity = selectedActivity {
                MatchCelebrationSheet(
                    activity: activity,
                    userName: userName,
                    onDismiss: { showMatchSheet = false }
                )
                .presentationDetents([.large])
                .coffeeSheetCornerRadius(40)
                .coffeeSheetDragIndicator(.hidden)
            }
        }
    }

    // MARK: - Subviews

    private var headerView: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 3) {
                Text("Hey \(userName) 👋")
                    .font(.system(size: 30, weight: .black, design: .default))
                    .foregroundColor(.textPrimary)
                Text("\(activities.count) meetups happening nearby")
                    .font(.system(size: 14, weight: .medium, design: .default))
                    .foregroundColor(.textSecondary)
            }

            Spacer()

            HStack(spacing: 10) {
                // Bell with mint notification dot
                headerIconButton(icon: "bell") {}
                    .overlay(alignment: .topTrailing) {
                        Circle()
                            .fill(Color.brandPrimary)
                            .frame(width: 9, height: 9)
                            .overlay(Circle().stroke(Color.backgroundMain, lineWidth: 2))
                            .offset(x: -4, y: 4)
                    }

                // Map toggle
                headerIconButton(icon: "map") {}

                // User initials avatar with mint ring
                Button(action: {}) {
                    Text(userInitials)
                        .font(.system(size: 14, weight: .bold, design: .default))
                        .foregroundColor(.brandPrimary)
                        .frame(width: 48, height: 48)
                        .background(Color.brandPrimary.opacity(0.12))
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .stroke(Color.brandPrimary.opacity(0.25), lineWidth: 2)
                        )
                        .shadow(color: Color.textPrimary.opacity(0.04), radius: 8, x: 0, y: 2)
                }
                .pressScale(0.90)
            }
        }
    }

    private func headerIconButton(icon: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(icon == "bell" ? .brandPurple : .brandPrimary)
                .frame(width: 48, height: 48)
                .background(Color.surfaceMain)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(Color.appBorder, lineWidth: 1)
                )
                .shadow(color: Color.textPrimary.opacity(0.04), radius: 8, x: 0, y: 2)
        }
        .pressScale(0.90)
    }

    private var searchBar: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.textSecondary)

            TextField(AppStrings.Discovery.searchPlaceholder, text: $searchText)
                .font(.system(size: 15, weight: .medium, design: .default))
                .foregroundColor(.textPrimary)
                .tint(.brandPrimary)

            Spacer()

            Button(action: {}) {
                Image(systemName: "line.3.horizontal.decrease")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.textSecondary)
                    .frame(width: 36, height: 36)
                    .background(Color.backgroundMain)
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            }
            .pressScale(0.88)
        }
        .padding(.horizontal, 16)
        .frame(height: 56)
        .background(Color.surfaceMain)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(Color.appBorder, lineWidth: 1)
        )
        .shadow(color: Color.textPrimary.opacity(0.04), radius: 12, x: 0, y: 4)
    }

    private var categoryChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(chipDefs, id: \.id) { chip in
                    CategoryChip(
                        title: chip.label,
                        isSelected: selectedCategory == chip.label,
                        icon: chip.icon
                    ) {
                        withAnimation(CoffeeAnimation.spring) {
                            selectedCategory = chip.label
                        }
                    }
                    // iOS 17+: selection haptic per chip tap
                    .coffeeSelectionFeedback(trigger: selectedCategory)
                }
            }
            .coffeeScrollTargetLayout()            // iOS 17+: snap to chip items
            .padding(.horizontal, 24)
            .padding(.vertical, 4)
        }
        .coffeeScrollBounceBehaviorBasedOnSize()  // iOS 16.4+: no bounce when list fits
    }

    private var fabButton: some View {
        Button(action: {}) {
            Image(systemName: "plus")
                .font(.system(size: 26, weight: .bold))
                .foregroundColor(.white)
                .frame(width: 64, height: 64)
                .background(Color.textPrimary)
                .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .stroke(Color.surfaceMain, lineWidth: 4)
                )
                .shadow(color: Color.textPrimary.opacity(0.3), radius: 20, x: 0, y: 10)
        }
        .pressScale(0.88)
    }
}

// MARK: - Join Confirm Sheet
// Matches Figma "Accept" modal: avatar + activity info + time/location + send request CTA

private struct JoinConfirmSheet: View {
    let activity: Activity
    let userName: String
    let onConfirm: () -> Void
    let onDismiss: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            // Drag indicator spacer
            Spacer().frame(height: 8)

            ScrollView(showsIndicators: false) {
                VStack(spacing: 28) {

                    // Avatar + icon badge
                    ZStack {
                        Circle()
                            .fill(Color.brandPrimary.opacity(0.10))
                            .frame(width: 120, height: 120)
                            .blur(radius: 24)

                        Text(activity.userInitials)
                            .font(.system(size: 28, weight: .bold, design: .default))
                            .foregroundColor(.textPrimary)
                            .frame(width: 88, height: 88)
                            .background(Color.surfaceSecondary)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.backgroundMain, lineWidth: 6))
                            .shadow(color: Color.textPrimary.opacity(0.08), radius: 20, x: 0, y: 8)

                        // Activity type emoji badge
                        Text(categoryEmoji(activity.category))
                            .font(.system(size: 18))
                            .frame(width: 38, height: 38)
                            .background(Color.brandPrimary)
                            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .stroke(Color.white, lineWidth: 3)
                            )
                            .shadow(color: Color.brandPrimary.opacity(0.35), radius: 8, x: 0, y: 4)
                            .offset(x: 34, y: 30)
                    }
                    .frame(height: 110)
                    .padding(.top, 16)

                    // Title
                    VStack(spacing: 8) {
                        Text("Join \(activity.userName)?")
                            .font(.system(size: 28, weight: .black, design: .default))
                            .foregroundColor(.textPrimary)
                            .multilineTextAlignment(.center)

                        Text(activity.title)
                            .font(.system(size: 15, weight: .medium, design: .default))
                            .foregroundColor(.textSecondary)
                            .multilineTextAlignment(.center)
                            .lineLimit(3)
                            .padding(.horizontal, 16)
                    }

                    // Info card — time + location
                    VStack(spacing: 12) {
                        HStack(spacing: 12) {
                            Circle()
                                .fill(Color.surfaceMain)
                                .frame(width: 36, height: 36)
                                .overlay(
                                    Image(systemName: "clock")
                                        .font(.system(size: 15, weight: .semibold))
                                        .foregroundColor(.brandPurple)
                                )
                            Text(activity.time)
                                .font(.system(size: 15, weight: .black, design: .default))
                                .foregroundColor(.textPrimary)
                            Spacer()
                        }

                        HStack(spacing: 12) {
                            Circle()
                                .fill(Color.surfaceMain)
                                .frame(width: 36, height: 36)
                                .overlay(
                                    Image(systemName: "mappin.and.ellipse")
                                        .font(.system(size: 15, weight: .semibold))
                                        .foregroundColor(.brandPrimary)
                                )
                            Text(String(format: "%.1f km away", activity.distanceKm))
                                .font(.system(size: 15, weight: .bold, design: .default))
                                .foregroundColor(.textSecondary)
                            Spacer()
                        }
                    }
                    .padding(20)
                    .background(Color.backgroundMain)
                    .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 28, style: .continuous)
                            .stroke(Color.appBorder, lineWidth: 1)
                    )
                    .padding(.horizontal, 4)

                    // CTAs
                    VStack(spacing: 12) {
                        PrimaryButton(
                            title: "Send Request",
                            height: 64,
                            cornerRadius: 24,
                            action: onConfirm
                        )

                        Button(action: onDismiss) {
                            Text("Maybe later")
                                .font(.system(size: 14, weight: .black, design: .default))
                                .foregroundColor(.textSecondary)
                        }
                        .pressScale(0.95)
                    }

                    Spacer(minLength: 16)
                }
                .padding(.horizontal, 28)
            }
        }
        .background(Color.surfaceMain.ignoresSafeArea())
    }

    private func categoryEmoji(_ category: String) -> String {
        switch category {
        case AppStrings.Discovery.Categories.coffee: return "☕"
        case AppStrings.Discovery.Categories.walks:  return "🚶"
        case AppStrings.Discovery.Categories.study:  return "📚"
        case AppStrings.Discovery.Categories.food:   return "🍔"
        case AppStrings.Discovery.Categories.gaming: return "🎮"
        default:                                     return "✨"
        }
    }
}

// MARK: - Match Celebration Sheet
// Matches Figma "It's a Match!" modal: full mint background, large emoji, overlapping avatars

private struct MatchCelebrationSheet: View {
    let activity: Activity
    let userName: String
    let onDismiss: () -> Void

    var body: some View {
        ZStack {
            Color.brandPrimary.ignoresSafeArea()

            // Decorative blobs
            Circle()
                .fill(Color.white.opacity(0.08))
                .frame(width: 180, height: 180)
                .blur(radius: 40)
                .offset(x: -100, y: -180)

            Circle()
                .fill(Color.brandPurple.opacity(0.25))
                .frame(width: 120, height: 120)
                .blur(radius: 30)
                .offset(x: 110, y: 200)

            VStack(spacing: 36) {
                Spacer()

                // Handshake icon
                Text("🤝")
                    .font(.system(size: 60))
                    .frame(width: 100, height: 100)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 32, style: .continuous))
                    .shadow(color: Color.black.opacity(0.15), radius: 24, x: 0, y: 12)
                    .slideUpEntrance(delay: 0.05)

                // Match headline
                VStack(spacing: 10) {
                    Text("It's a Match!")
                        .font(.system(size: 40, weight: .black, design: .default))
                        .foregroundColor(.white)
                        .tracking(-0.5)

                    Text("You and \(activity.userName) are hanging out!")
                        .font(.system(size: 18, weight: .bold, design: .default))
                        .foregroundColor(.white.opacity(0.88))
                        .multilineTextAlignment(.center)
                }
                .slideUpEntrance(delay: 0.1)

                // Overlapping avatars
                HStack(spacing: -22) {
                    Text(String(userName.prefix(2)).uppercased())
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(.brandPrimary)
                        .frame(width: 80, height: 80)
                        .background(Color.white)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.brandPrimary, lineWidth: 5))
                        .shadow(color: Color.black.opacity(0.15), radius: 16, x: 0, y: 8)
                        .zIndex(1)

                    Text(activity.userInitials)
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(.brandPrimary)
                        .frame(width: 80, height: 80)
                        .background(Color.white)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.brandPrimary, lineWidth: 5))
                        .shadow(color: Color.black.opacity(0.15), radius: 16, x: 0, y: 8)
                }
                .slideUpEntrance(delay: 0.15)

                // Activity info pill
                VStack(spacing: 4) {
                    Text("MOMENT")
                        .font(.system(size: 11, weight: .black, design: .default))
                        .foregroundColor(.white.opacity(0.7))
                        .tracking(2.0)
                    Text("\(categoryEmoji(activity.category)) \(activity.category)")
                        .font(.system(size: 18, weight: .bold, design: .default))
                        .foregroundColor(.white)
                }
                .padding(.horizontal, 28)
                .padding(.vertical, 16)
                .background(Color.black.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .stroke(Color.white.opacity(0.18), lineWidth: 1)
                )
                .slideUpEntrance(delay: 0.18)

                Spacer()

                // CTAs
                VStack(spacing: 14) {
                    Button(action: onDismiss) {
                        Text("Say Hello")
                            .font(.system(size: 18, weight: .black, design: .default))
                            .foregroundColor(.brandPrimary)
                            .frame(maxWidth: .infinity)
                            .frame(height: 64)
                            .background(Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                            .shadow(color: Color.black.opacity(0.12), radius: 16, x: 0, y: 8)
                    }
                    .pressScale()

                    Button(action: onDismiss) {
                        Text("KEEP DISCOVERING")
                            .font(.system(size: 12, weight: .black, design: .default))
                            .foregroundColor(.white.opacity(0.75))
                            .tracking(1.5)
                    }
                    .pressScale(0.95)
                }
                .padding(.bottom, 40)
            }
            .padding(.horizontal, 28)
        }
    }

    private func categoryEmoji(_ category: String) -> String {
        switch category {
        case AppStrings.Discovery.Categories.coffee: return "☕"
        case AppStrings.Discovery.Categories.walks:  return "🚶"
        case AppStrings.Discovery.Categories.study:  return "📚"
        case AppStrings.Discovery.Categories.food:   return "🍔"
        case AppStrings.Discovery.Categories.gaming: return "🎮"
        default:                                     return "✨"
        }
    }
}

// MARK: - Previews
struct DiscoveryScreen_Previews: PreviewProvider {
    static var previews: some View {
        DiscoveryScreen()
    }
}
