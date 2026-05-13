import SwiftUI

// MARK: - Discovery Screen

struct DiscoveryScreen: View {
    @State private var selectedCategory = AppStrings.Discovery.Categories.all
    @State private var searchText = ""

    private let userName = "Hey Robin"
    private let userInitials = "ER"
    private let nearbyCount = 2

    @State private var activities: [Activity] = [
        Activity(
            userName: "Alex",
            userInitials: "AL",
            backgroundImageURL: "https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=800&q=80",
            title: "Taking a break from work. Anyone up for a walk and good conversation?",
            category: "Walks",
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
            title: "Grabbing a flat white at Blue Tokai, anyone want to join?",
            category: "Coffee",
            distanceKm: 1.2,
            time: "4:00 PM",
            attendeeCount: 2,
            vibeTag: "CHILL",
            status: .happening
        ),
        Activity(
            userName: "Priya",
            userInitials: "PR",
            backgroundImageURL: "https://images.unsplash.com/photo-1551963831-b3b1ca40c98e?w=800&q=80",
            title: "Board game night + pizza. The more the merrier!",
            category: "Food",
            distanceKm: 3.1,
            time: "7:00 PM",
            attendeeCount: 6,
            vibeTag: "SOCIAL",
            status: .later
        )
    ]

    let categories = [
        AppStrings.Discovery.Categories.all,
        AppStrings.Discovery.Categories.coffee,
        AppStrings.Discovery.Categories.walks,
        AppStrings.Discovery.Categories.gaming,
        AppStrings.Discovery.Categories.study,
        AppStrings.Discovery.Categories.food,
        AppStrings.Discovery.Categories.startup
    ]

    var filteredActivities: [Activity] {
        activities.filter { activity in
            (selectedCategory == AppStrings.Discovery.Categories.all || activity.category == selectedCategory) &&
            (searchText.isEmpty || activity.title.localizedCaseInsensitiveContains(searchText))
        }
    }

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            Color.backgroundMain.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {

                    // Header — slides up on appear
                    headerView
                        .padding(.top, 16)
                        .padding(.horizontal, 20)
                        .slideUpEntrance(delay: 0)

                    // Search — slides up slightly after header
                    searchBar
                        .padding(.top, 20)
                        .padding(.horizontal, 20)
                        .slideUpEntrance(delay: 0.06)

                    // Category chips
                    categoryChips
                        .padding(.top, 20)
                        .slideUpEntrance(delay: 0.12)

                    // Feed — each card staggered
                    LazyVStack(spacing: 16) {
                        ForEach(Array(filteredActivities.enumerated()), id: \.element.id) { index, activity in
                            ActivityCardView(
                                activity: activity,
                                onJoin: {
                                    withAnimation(CoffeeAnimation.spring) {
                                        if let i = activities.firstIndex(where: { $0.id == activity.id }) {
                                            activities[i].isJoined.toggle()
                                        }
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
                            .slideUpEntrance(delay: 0.18 + Double(index) * 0.08)
                        }
                    }
                    .padding(.top, 20)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 120)
                }
            }

            // FAB
            fabButton
                .padding(.trailing, 20)
                .padding(.bottom, 28)
                .slideUpEntrance(delay: 0.3)
        }
        .navigationBarHidden(true)
    }

    // MARK: - Subviews

    private var headerView: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 2) {
                Text(userName)
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(.textPrimary)
                Text("\(nearbyCount) meetups happening nearby")
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(.textSecondary)
            }

            Spacer()

            HStack(spacing: 10) {
                headerIconButton(icon: "bell") {}
                headerIconButton(icon: "map") {}

                Button(action: {}) {
                    Text(userInitials)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.brandPrimary)
                        .frame(width: 40, height: 40)
                        .background(Color.brandPrimary.opacity(0.15))
                        .clipShape(Circle())
                }
                .pressScale(0.90)
            }
        }
    }

    private func headerIconButton(icon: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .regular))
                .foregroundColor(.textPrimary)
                .frame(width: 40, height: 40)
                .background(Color.surfaceMain)
                .clipShape(Circle())
        }
        .pressScale(0.90)
    }

    private var searchBar: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 16))
                .foregroundColor(.textSecondary)
            TextField(AppStrings.Discovery.searchPlaceholder, text: $searchText)
                .font(.system(size: 15))
                .foregroundColor(.textPrimary)
            Spacer()
            Button(action: {}) {
                Image(systemName: "line.3.horizontal.decrease")
                    .font(.system(size: 16))
                    .foregroundColor(.textSecondary)
            }
            .pressScale(0.88)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(Color.surfaceMain)
        .cornerRadius(14)
    }

    private var categoryChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(categories, id: \.self) { category in
                    CategoryChip(
                        title: category,
                        isSelected: selectedCategory == category
                    ) {
                        withAnimation(CoffeeAnimation.spring) {
                            selectedCategory = category
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
        }
    }

    private var fabButton: some View {
        Button(action: {}) {
            Image(systemName: "plus")
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(.white)
                .frame(width: 56, height: 56)
                .background(Color(red: 0.1, green: 0.12, blue: 0.22))
                .clipShape(Circle())
                .shadow(color: Color.black.opacity(0.25), radius: 12, x: 0, y: 6)
        }
        .pressScale(0.88)
    }
}

// MARK: - Previews
struct DiscoveryScreen_Previews: PreviewProvider {
    static var previews: some View {
        DiscoveryScreen()
    }
}
