import SwiftUI

struct ProfileScreen: View {
    @StateObject private var viewModel = ProfileViewModel()
    @State private var showingEditProfile = false
    @State private var showingSignOutAlert = false
    
    // Interactive Sheet States
    @State private var showingInterestsSheet = false
    @State private var showingAvailabilitySheet = false
    @State private var showingNotificationsSheet = false
    @State private var showingPrivacySheet = false
    @State private var showingLocationSheet = false
    @State private var showingHelpSheet = false
    
    // Stats Details State
    @State private var showingStatsSheet = false
    @State private var selectedStatType: StatType? = nil
    
    @EnvironmentObject var auth: AuthViewModel
    
    var body: some View {
        NavigationStack {
            VStack(spacing: AppConstants.Layout.sectionSpacing) {
                // 1. Identity Card
                identityCard
                
                // 2. Private Stats Grid
                statsSection
                
                // Saved Drifts Row
                savedDriftsSection
                
                // 3. Activity Log
                activityLogSection
                
                // 4. Preferences List
                preferencesSection
                
                // 5. Account Control List
                accountSection
            }
            .padding(.horizontal, AppConstants.Layout.standardPadding)
            .asCoffeePage(
                .main,
                title: viewModel.title,
                subtitle: viewModel.subtitle ?? "",
                rightView: {
                    CoffeeHeaderButton(icon: AppIcons.settings) {
                        viewModel.showingSettingsSheet = true
                    }
                }
            )
            .navigationDestination(for: Drift.self) { drift in
                DriftDetailScreen(viewModel: DriftDetailViewModel(drift: drift))
            }
            .sheet(isPresented: $showingEditProfile) {
                EditProfileScreen(viewModel: viewModel)
            }
            .sheet(isPresented: $viewModel.showingSettingsSheet) {
                SettingsSheetView()
            }
            .sheet(isPresented: $showingInterestsSheet) {
                InterestsSheetView(viewModel: viewModel)
            }
            .sheet(isPresented: $showingAvailabilitySheet) {
                AvailabilitySheetView(viewModel: viewModel)
            }
            .sheet(isPresented: $showingNotificationsSheet) {
                NotificationsSheetView()
            }
            .sheet(isPresented: $showingPrivacySheet) {
                PrivacySheetView()
            }
            .sheet(isPresented: $showingLocationSheet) {
                LocationSheetView(viewModel: viewModel)
            }
            .sheet(isPresented: $showingHelpSheet) {
                HelpSheetView()
            }
            .sheet(isPresented: $showingStatsSheet) {
                if let selectedStatType {
                    StatsDetailSheetView(
                        type: selectedStatType,
                        count: countForStat(selectedStatType)
                    )
                }
            }
            .alert(AppStrings.Profile.signOut, isPresented: $showingSignOutAlert) {
                Button(AppStrings.Common.cancel, role: .cancel) {}
                Button(AppStrings.Profile.signOut, role: .destructive) {
                    viewModel.signOut()
                    auth.signOut()
                }
            } message: {
                Text(AppStrings.Profile.signOutConfirmation)
            }
        }
        .onAppear {
            NavigationManager.shared.resetTabBarVisibility()
        }
    }
    
    // MARK: - Identity Card
    private var identityCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .center, spacing: 16) {
                // Circular Avatar (72x72) — profile photo or initials fallback
                ZStack {
                    if let profileImage = viewModel.profileImage {
                        Image(uiImage: profileImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 72, height: 72)
                            .clipShape(Circle())
                    } else {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [Color.brandPrimary.opacity(0.25), Color.brandPrimary.opacity(0.05)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 72, height: 72)
                            .overlay(
                                AppIcons.personImage
                                    .font(.system(size: 32, weight: .bold))
                                    .foregroundColor(.brandPrimaryDark)
                            )
                    }
                }
                .overlay(
                    Circle()
                        .stroke(Color.brandPrimary.opacity(0.2), lineWidth: 1.5)
                )
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(viewModel.name)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.textPrimary)
                    
                    HStack(spacing: 4) {
                        AppIcons.mappinImage
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.textSecondary)
                        
                        Text("\(viewModel.location.components(separatedBy: ",").first ?? viewModel.location)\(AppStrings.Profile.tenKmRadiusSuffix)")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.textSecondary)
                    }
                    
                    // Small Mint Phone Verification Pill (Hides phone number)
                    HStack(spacing: 4) {
                        AppIcons.checkCircleFillImage
                            .font(.system(size: 9, weight: .black))
                            .foregroundColor(.brandPrimary)
                        
                        Text(AppStrings.Profile.verifiedPhone)
                            .font(.system(size: 9, weight: .bold))
                            .foregroundColor(.brandPrimaryDark)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(Color.brandPrimary.opacity(AppConstants.UI.opacityLight))
                    .clipShape(Capsule())
                }
                
                Spacer()
            }
            
            // Active Interests Capsule Tag Cloud
            if !viewModel.interests.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: AppConstants.Layout.miniPadding * 2) {
                        ForEach(viewModel.interests, id: \.self) { category in
                            HStack(spacing: 4) {
                                Image(systemName: category.icon)
                                    .font(.captionText)
                                Text(category.rawValue.capitalized)
                                    .font(.captionText)
                            }
                            .foregroundColor(category.color)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(category.color.opacity(0.12))
                            .clipShape(Capsule())
                        }
                    }
                    .padding(.vertical, 2)
                }
            }
            
            Divider()
                .background(Color.appBorder.opacity(0.6))
            
            HStack {
                Spacer()
                
                // Edit Profile Button pushed cleanly to the bottom right of the card
                Button(action: { showingEditProfile = true }) {
                    HStack(spacing: 4) {
                        Text(AppStrings.Profile.editProfile)
                        AppIcons.editImage
                    }
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.brandPrimary)
                }
                .pressScale(0.92)
            }
        }
        .padding(16)
        .background(Color.surfaceMain)
        .cornerRadius(AppConstants.UI.cornerRadiusLarge + 2) // radius 26pt
        .overlay(
            RoundedRectangle(cornerRadius: AppConstants.UI.cornerRadiusLarge + 2)
                .stroke(Color.appBorder, lineWidth: 1)
        )
        .shadow(color: Color.textPrimary.opacity(0.04), radius: 12, x: 0, y: 6)
    }
    
    // MARK: - Private Stats Grid
    private var statsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(AppStrings.Profile.statsHeader)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.textPrimary)
            
            VStack(spacing: 12) {
                HStack(spacing: 12) {
                    // Tile 1: Hosted
                    statTile(type: .hosted, count: "\(viewModel.driftsHosted)")
                    
                    // Tile 2: People Joined
                    statTile(type: .joined, count: "\(viewModel.driftsJoined)")
                }
                
                HStack(spacing: 12) {
                    // Tile 3: No-shows
                    statTile(type: .noShows, count: "\(viewModel.noShowsCount)")
                    
                    // Tile 4: Score (Coming soon)
                    statTile(type: .score, count: viewModel.score)
                }
            }
            
            // Privacy Caption
            HStack(spacing: 6) {
                AppIcons.lockImage
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(.textSecondary)
                
                Text(AppStrings.Profile.statsPrivate)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.textSecondary)
            }
            .padding(.leading, 4)
        }
    }
    
    // MARK: - Saved Drifts Section
    private var savedDriftsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Saved Drifts")
                    .font(.heading2)
                    .foregroundColor(.textPrimary)
                
                Spacer()
                
                if !viewModel.savedDrifts.isEmpty {
                    Text("\(viewModel.savedDrifts.count)")
                        .font(.captionText)
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.brandPrimary)
                        .clipShape(Capsule())
                }
            }
            
            if viewModel.savedDrifts.isEmpty {
                VStack(spacing: AppConstants.Layout.subElementSpacing) {
                    ZStack {
                        Circle()
                            .fill(Color.brandPrimary.opacity(0.05))
                            .frame(width: 48, height: 48)
                        Image(systemName: AppIcons.bookmark)
                            .font(.system(size: 18))
                            .foregroundColor(.brandPrimary)
                    }
                    
                    Text("Your bookmarked plans will appear here.")
                        .font(.bodySmall)
                        .foregroundColor(.textSecondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 24)
                .background(Color.surfaceMain)
                .cornerRadius(AppConstants.UI.cornerRadiusMedium)
                .overlay(
                    RoundedRectangle(cornerRadius: AppConstants.UI.cornerRadiusMedium)
                        .stroke(Color.appBorder, lineWidth: 1)
                )
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: AppConstants.Layout.elementSpacing) {
                        ForEach(viewModel.savedDrifts) { drift in
                            NavigationLink(value: drift) {
                                savedDriftCard(drift)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 4)
                    .padding(.vertical, 4)
                }
            }
        }
    }
    
    private func savedDriftCard(_ drift: Drift) -> some View {
        HStack(spacing: AppConstants.Layout.elementSpacing) {
            ZStack {
                Circle()
                    .fill(drift.category.color.opacity(AppConstants.UI.opacityLight * 1.5))
                    .frame(width: 40, height: 40)
                
                Image(systemName: drift.category.icon)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(drift.category.color)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                HStack(alignment: .top) {
                    Text(drift.title)
                        .font(.custom("Outfit-Bold", size: AppConstants.Typography.sizeHeadline - 2))
                        .foregroundColor(.textPrimary)
                        .lineLimit(1)
                    
                    Spacer()
                    
                    Image(systemName: AppIcons.bookmarkFill)
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.brandPrimary)
                }
                
                Text("\(drift.date) \(drift.time)")
                    .font(.captionText)
                    .foregroundColor(.textSecondary)
                    .lineLimit(1)
                
                HStack {
                    Text(drift.status.rawValue)
                        .font(.system(size: AppConstants.Typography.sizeMicro, weight: .black))
                        .foregroundColor(drift.status.color)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 3)
                        .background(drift.status.color.opacity(AppConstants.UI.opacityLight))
                        .cornerRadius(AppConstants.UI.cornerRadiusTiny)
                    
                    Spacer()
                }
            }
        }
        .frame(width: 260)
        .padding(14)
        .background(Color.surfaceMain)
        .cornerRadius(AppConstants.UI.cornerRadiusMedium)
        .overlay(
            RoundedRectangle(cornerRadius: AppConstants.UI.cornerRadiusMedium)
                .stroke(Color.appBorder, lineWidth: 1)
        )
        .shadow(color: Color.textPrimary.opacity(0.02), radius: 6, x: 0, y: 3)
        .opacity(drift.status == .ended ? 0.4 : 1.0)
    }
    
    private func statTile(type: StatType, count: String) -> some View {
        Button(action: {
            selectedStatType = type
            showingStatsSheet = true
        }) {
            HStack(spacing: 8) {
                // Icon circle well (38x38)
                ZStack {
                    Circle()
                        .fill(type.color.opacity(0.12))
                        .frame(width: 38, height: 38)
                    
                    Image(systemName: type.icon)
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(type.color)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(count)
                        .font(.system(size: count == "Coming soon" ? 12 : 22, weight: .bold))
                        .foregroundColor(count == "Coming soon" ? .textSecondary : .textPrimary)
                        .lineLimit(1)
                    
                    Text(type.title)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.textSecondary)
                        .lineLimit(1)
                }
                
                Spacer(minLength: 0)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity)
            .frame(height: 70)
            .background(Color.surfaceMain)
            .cornerRadius(AppConstants.UI.cornerRadiusMedium + 2)
            .overlay(
                RoundedRectangle(cornerRadius: AppConstants.UI.cornerRadiusMedium + 2)
                    .stroke(Color.appBorder, lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
        .pressScale(0.96)
    }
    
    private func countForStat(_ type: StatType) -> String {
        switch type {
        case .hosted: return "\(viewModel.driftsHosted)"
        case .joined: return "\(viewModel.driftsJoined)"
        case .noShows: return "\(viewModel.noShowsCount)"
        case .score: return viewModel.score
        }
    }
    
    // MARK: - Preferences List
    private var preferencesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(AppStrings.Profile.preferences)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.textPrimary)
            
            VStack(spacing: 0) {
                // Row 1: Interests
                preferenceRow(
                    icon: AppIcons.heartFill,
                    color: Color.brandPrimary,
                    title: AppStrings.Profile.interests,
                    value: viewModel.interests.isEmpty ? "None" : viewModel.interests.map { $0.rawValue.capitalized }.joined(separator: ", ")
                ) {
                    showingInterestsSheet = true
                }
                
                Divider().background(Color.appBorder).padding(.horizontal, 16)
                
                // Row 2: Availability
                preferenceRow(
                    icon: AppIcons.clockFill,
                    color: Color.brandPurple,
                    title: AppStrings.Profile.availability,
                    value: viewModel.availabilitySummary
                ) {
                    showingAvailabilitySheet = true
                }
                
                Divider().background(Color.appBorder).padding(.horizontal, 16)
                
                // Row 3: Notifications
                preferenceRow(
                    icon: AppIcons.bellFill,
                    color: Color.brandSecondary,
                    title: AppStrings.Profile.notifications,
                    value: viewModel.notificationsSummary
                ) {
                    showingNotificationsSheet = true
                }
                
                Divider().background(Color.appBorder).padding(.horizontal, 16)
                
                // Row 4: Privacy & Safety
                preferenceRow(
                    icon: AppIcons.shieldVerified,
                    color: Color.brandPrimary,
                    title: AppStrings.Profile.safety,
                    value: viewModel.privacySummary
                ) {
                    showingPrivacySheet = true
                }
            }
            .background(Color.surfaceMain)
            .cornerRadius(24) // corner radius 24pt
            .overlay(
                RoundedRectangle(cornerRadius: 24)
                    .stroke(Color.appBorder, lineWidth: 1)
            )
        }
    }
    
    // MARK: - Account List
    private var accountSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(AppStrings.Profile.accountHeader)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.textPrimary)
            
            VStack(spacing: 0) {
                // Row 1: Location
                preferenceRow(
                    icon: AppIcons.mappinCircle,
                    color: Color.brandPrimary,
                    title: AppStrings.Profile.locationLabel,
                    value: viewModel.location
                ) {
                    showingLocationSheet = true
                }
                
                Divider().background(Color.appBorder).padding(.horizontal, 16)
                
                // Row 2: Help
                preferenceRow(
                    icon: AppIcons.help,
                    color: Color.brandPurple,
                    title: AppStrings.Profile.help
                ) {
                    showingHelpSheet = true
                }
                
                Divider().background(Color.appBorder).padding(.horizontal, 16)
                
                // Row 3: Sign out
                preferenceRow(
                    icon: AppIcons.logoutFill,
                    color: Color.statusError,
                    title: AppStrings.Profile.signOut,
                    isDestructive: true
                ) {
                    showingSignOutAlert = true
                }
            }
            .background(Color.surfaceMain)
            .cornerRadius(24) // corner radius 24pt
            .overlay(
                RoundedRectangle(cornerRadius: 24)
                    .stroke(Color.appBorder, lineWidth: 1)
            )
        }
    }
    
    // MARK: - Row Builder
    private func preferenceRow(icon: String, color: Color, title: String, value: String? = nil, isDestructive: Bool = false, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 14) {
                // Icon circle well (36x36)
                ZStack {
                    Circle()
                        .fill(color.opacity(0.12))
                        .frame(width: 36, height: 36)
                    
                    Image(systemName: icon)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(color)
                }
                
                Text(title)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(isDestructive ? Color.statusError : .textPrimary)
                
                Spacer()
                
                if let value = value {
                    Text(value)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.textSecondary)
                }
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.textSecondary.opacity(0.4))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .contentShape(Rectangle())
        }
        .pressScale(0.98)
    }
    
    // MARK: - Activity Log
    private var activityLogSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(AppStrings.Profile.activityLog)
                .font(.bodyBold)
                .foregroundColor(.textPrimary)
            
            if viewModel.historyDrifts.isEmpty {
                Text(AppStrings.Profile.noActivities)
                    .font(.bodyStandard)
                    .foregroundColor(.textSecondary)
                    .padding(.vertical, 8)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(viewModel.historyDrifts) { drift in
                            activityCard(drift: drift)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
        }
    }
    
    private func activityCard(drift: Drift) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(drift.category.color.opacity(0.12))
                        .frame(width: 32, height: 32)
                    
                    Image(systemName: drift.category.icon)
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(drift.category.color)
                }
                
                Spacer()
                
                // Status badge
                Text(drift.status.rawValue)
                    .font(.micro)
                    .foregroundColor(drift.status.color)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(drift.status.color.opacity(0.12))
                    .clipShape(Capsule())
            }
            
            Text(drift.title)
                .font(.captionText)
                .foregroundColor(.textPrimary)
                .lineLimit(2)
                .frame(height: 38, alignment: .topLeading)
            
            Divider().background(Color.appBorder.opacity(0.6))
            
            HStack {
                AppIcons.calendarImage
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.textSecondary)
                
                Text(drift.location) // This has e.g. "Open • Yesterday" or "Ended • 5 days ago"
                    .font(.metadata)
                    .foregroundColor(.textSecondary)
            }
        }
        .padding(12)
        .frame(width: 160, height: 136)
        .background(Color.surfaceMain)
        .cornerRadius(AppConstants.UI.cornerRadiusMedium)
        .overlay(
            RoundedRectangle(cornerRadius: AppConstants.UI.cornerRadiusMedium)
                .stroke(Color.appBorder, lineWidth: 1)
        )
        .shadow(color: Color.textPrimary.opacity(0.02), radius: 6, x: 0, y: 3)
    }
}

// MARK: - Settings Sheet View
struct SettingsSheetView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.backgroundMain.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: AppConstants.Layout.sectionSpacing) {
                        VStack(spacing: 8) {
                            ZStack {
                                Circle()
                                    .fill(Color.brandPrimary.opacity(0.12))
                                    .frame(width: 80, height: 80)
                                
                                AppIcons.coffeeFillImage
                                    .font(.system(size: 36, weight: .bold))
                                    .foregroundColor(.brandPrimary)
                            }
                            
                            Text(AppStrings.Common.appName)
                                .font(.system(size: AppConstants.Typography.sizeTitle, weight: .black))
                                .foregroundColor(.textPrimary)
                            
                            Text(AppStrings.Common.appVersion)
                                .font(.system(size: AppConstants.Typography.sizeCaption, weight: .bold))
                                .foregroundColor(.textSecondary)
                        }
                        .padding(.top, 24)
                        
                        VStack(spacing: 0) {
                            settingsDetailRow(title: AppStrings.Common.environment, value: AppStrings.Common.production)
                            Divider().background(Color.appBorder).padding(.horizontal, 16)
                            settingsDetailRow(title: AppStrings.Common.clientIdLabel, value: AppStrings.Common.clientIdValue)
                            Divider().background(Color.appBorder).padding(.horizontal, 16)
                            settingsDetailRow(title: AppStrings.Common.buildPhaseLabel, value: AppStrings.Common.buildPhaseValue)
                        }
                        .background(Color.surfaceMain)
                        .cornerRadius(AppConstants.UI.cornerRadiusMedium)
                        .overlay(
                            RoundedRectangle(cornerRadius: AppConstants.UI.cornerRadiusMedium)
                                .stroke(Color.appBorder, lineWidth: 1)
                        )
                        .padding(.horizontal, 20)
                        
                        Text(AppStrings.Common.copyright)
                            .font(.system(size: AppConstants.Typography.sizeTiny, weight: .medium))
                            .foregroundColor(.textSecondary)
                            .padding(.top, 12)
                    }
                }
            }
            .navigationTitle(AppStrings.Profile.settings)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(AppStrings.Common.close) {
                        dismiss()
                    }
                    .font(.system(size: AppConstants.Typography.sizeBody, weight: .bold))
                    .foregroundColor(.brandPrimary)
                }
            }
        }
    }
    
    private func settingsDetailRow(title: String, value: String) -> some View {
        HStack {
            Text(title)
                .font(.system(size: AppConstants.Typography.sizeBody - 1, weight: .bold))
                .foregroundColor(.textPrimary)
            
            Spacer()
            
            Text(value)
                .font(.system(size: AppConstants.Typography.sizeCaption + 1, weight: .bold))
                .foregroundColor(.textSecondary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }
}

// MARK: - Interests Sheet View
struct InterestsSheetView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: ProfileViewModel
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.backgroundMain.ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        Text(AppStrings.Profile.interestsDescription)
                            .font(.system(size: AppConstants.Typography.sizeBody - 1, weight: .medium))
                            .foregroundColor(.textSecondary)
                            .padding(.horizontal, 20)
                            .padding(.top, 12)
                        
                        VStack(spacing: 0) {
                            ForEach(DriftCategory.allCases, id: \.self) { category in
                                Button(action: {
                                    if viewModel.interests.contains(category) {
                                        viewModel.interests.removeAll(where: { $0 == category })
                                    } else {
                                        viewModel.interests.append(category)
                                    }
                                }) {
                                    HStack(spacing: 14) {
                                        ZStack {
                                            Circle()
                                                .fill(category.color.opacity(0.12))
                                                .frame(width: 36, height: 36)
                                            
                                            Image(systemName: category.icon)
                                                .font(.system(size: 14, weight: .bold))
                                                .foregroundColor(category.color)
                                        }
                                        
                                        Text(category.rawValue.capitalized)
                                            .font(.system(size: AppConstants.Typography.sizeBody, weight: .bold))
                                            .foregroundColor(.textPrimary)
                                        
                                        Spacer()
                                        
                                        if viewModel.interests.contains(category) {
                                            AppIcons.checkCircleFillImage
                                                .font(.system(size: 20, weight: .bold))
                                                .foregroundColor(.brandPrimary)
                                        } else {
                                            Circle()
                                                .stroke(Color.appBorder, lineWidth: 1.5)
                                                .frame(width: 20, height: 20)
                                        }
                                    }
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 14)
                                }
                                .buttonStyle(PlainButtonStyle())
                                
                                if category != DriftCategory.allCases.last {
                                    Divider().background(Color.appBorder).padding(.horizontal, 16)
                                }
                            }
                        }
                        .background(Color.surfaceMain)
                        .cornerRadius(AppConstants.UI.cornerRadiusMedium)
                        .overlay(
                            RoundedRectangle(cornerRadius: AppConstants.UI.cornerRadiusMedium)
                                .stroke(Color.appBorder, lineWidth: 1)
                        )
                        .padding(.horizontal, 20)
                    }
                }
            }
            .navigationTitle(AppStrings.Profile.interests)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(AppStrings.Common.done) {
                        dismiss()
                    }
                    .font(.system(size: AppConstants.Typography.sizeBody, weight: .bold))
                    .foregroundColor(.brandPrimary)
                }
            }
        }
    }
}

// MARK: - Availability Sheet View
struct AvailabilitySheetView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: ProfileViewModel
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.backgroundMain.ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        Text(AppStrings.Profile.availabilityDescription)
                            .font(.system(size: AppConstants.Typography.sizeBody - 1, weight: .medium))
                            .foregroundColor(.textSecondary)
                            .padding(.horizontal, 20)
                            .padding(.top, 12)
                        
                        VStack(spacing: 0) {
                            ToggleRow(title: AppStrings.Profile.weekdayEvenings, isOn: $viewModel.availabilityWeekdayEvenings)
                            Divider().background(Color.appBorder).padding(.horizontal, 16)
                            ToggleRow(title: AppStrings.Profile.weekends, isOn: $viewModel.availabilityWeekends)
                            Divider().background(Color.appBorder).padding(.horizontal, 16)
                            ToggleRow(title: AppStrings.Profile.daytimeLunch, isOn: $viewModel.availabilityDaytime)
                        }
                        .background(Color.surfaceMain)
                        .cornerRadius(AppConstants.UI.cornerRadiusMedium)
                        .overlay(
                            RoundedRectangle(cornerRadius: AppConstants.UI.cornerRadiusMedium)
                                .stroke(Color.appBorder, lineWidth: 1)
                        )
                        .padding(.horizontal, 20)
                    }
                }
            }
            .navigationTitle(AppStrings.Profile.availability)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(AppStrings.Common.done) {
                        dismiss()
                    }
                    .font(.system(size: AppConstants.Typography.sizeBody, weight: .bold))
                    .foregroundColor(.brandPrimary)
                }
            }
        }
    }
}

// MARK: - Notifications Sheet View
struct NotificationsSheetView: View {
    @Environment(\.dismiss) var dismiss
    @State private var pushAlerts = true
    @State private var inAppAlerts = true
    @State private var nearbyDriftsAlerts = true
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.backgroundMain.ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        Text(AppStrings.Profile.notificationsDescription)
                            .font(.system(size: AppConstants.Typography.sizeBody - 1, weight: .medium))
                            .foregroundColor(.textSecondary)
                            .padding(.horizontal, 20)
                            .padding(.top, 12)
                        
                        VStack(spacing: 0) {
                            ToggleRow(title: AppStrings.Profile.pushNotifications, isOn: $pushAlerts)
                            Divider().background(Color.appBorder).padding(.horizontal, 16)
                            ToggleRow(title: AppStrings.Profile.inAppAlerts, isOn: $inAppAlerts)
                            Divider().background(Color.appBorder).padding(.horizontal, 16)
                            ToggleRow(title: AppStrings.Profile.nearbyDriftsLabel, isOn: $nearbyDriftsAlerts)
                        }
                        .background(Color.surfaceMain)
                        .cornerRadius(AppConstants.UI.cornerRadiusMedium)
                        .overlay(
                            RoundedRectangle(cornerRadius: AppConstants.UI.cornerRadiusMedium)
                                .stroke(Color.appBorder, lineWidth: 1)
                        )
                        .padding(.horizontal, 20)
                    }
                }
            }
            .navigationTitle(AppStrings.Profile.notifications)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(AppStrings.Common.done) {
                        dismiss()
                    }
                    .font(.system(size: AppConstants.Typography.sizeBody, weight: .bold))
                    .foregroundColor(.brandPrimary)
                }
            }
        }
    }
}

// MARK: - Privacy & Safety Sheet View
struct PrivacySheetView: View {
    @Environment(\.dismiss) var dismiss
    @State private var shareApproxLoc = true
    @State private var privateStats = true
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.backgroundMain.ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        Text(AppStrings.Profile.privacyDescription)
                            .font(.system(size: AppConstants.Typography.sizeBody - 1, weight: .bold))
                            .foregroundColor(.brandPrimaryDark)
                            .padding(16)
                            .background(Color.brandPrimary.opacity(0.12))
                            .cornerRadius(AppConstants.UI.cornerRadiusSmall)
                            .padding(.horizontal, 20)
                            .padding(.top, 12)
                        
                        VStack(spacing: 0) {
                            ToggleRow(title: AppStrings.Profile.approxDistanceLabel, isOn: $shareApproxLoc)
                            Divider().background(Color.appBorder).padding(.horizontal, 16)
                            ToggleRow(title: AppStrings.Profile.keepStatsPrivate, isOn: $privateStats)
                        }
                        .background(Color.surfaceMain)
                        .cornerRadius(AppConstants.UI.cornerRadiusMedium)
                        .overlay(
                            RoundedRectangle(cornerRadius: AppConstants.UI.cornerRadiusMedium)
                                .stroke(Color.appBorder, lineWidth: 1)
                        )
                        .padding(.horizontal, 20)
                    }
                }
            }
            .navigationTitle(AppStrings.Profile.privacySafetyHeader)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(AppStrings.Common.done) {
                        dismiss()
                    }
                    .font(.system(size: AppConstants.Typography.sizeBody, weight: .bold))
                    .foregroundColor(.brandPrimary)
                }
            }
        }
    }
}

// MARK: - Location Sheet View
struct LocationSheetView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: ProfileViewModel
    @State private var isUpdating = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.backgroundMain.ignoresSafeArea()
                
                VStack(spacing: AppConstants.Layout.sectionSpacing) {
                    Spacer()
                    
                    ZStack {
                        Circle()
                            .fill(Color.brandPrimary.opacity(0.12))
                            .frame(width: 100, height: 100)
                        
                        AppIcons.mappinImage
                            .font(.system(size: 48, weight: .bold))
                            .foregroundColor(.brandPrimary)
                    }
                    
                    VStack(spacing: 8) {
                        Text(viewModel.location)
                            .font(.system(size: AppConstants.Typography.sizeTitle, weight: .black))
                            .foregroundColor(.textPrimary)
                        
                        Text(AppStrings.Profile.fixedRadiusLabel)
                            .font(.system(size: AppConstants.Typography.sizeCaption + 1, weight: .bold))
                            .foregroundColor(.textSecondary)
                    }
                    
                    Button(action: {
                        isUpdating = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                            isUpdating = false
                            viewModel.location = "Bengaluru, Karnataka"
                        }
                    }) {
                        HStack(spacing: 8) {
                            if isUpdating {
                                ProgressView()
                                    .tint(.white)
                            } else {
                                AppIcons.locationImage
                            }
                            
                            Text(isUpdating ? AppStrings.Profile.updatingLoc : AppStrings.Profile.updateLoc)
                        }
                        .font(.system(size: AppConstants.Typography.sizeBody, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 14)
                        .background(isUpdating ? Color.brandPrimaryDark : Color.brandPrimary)
                        .cornerRadius(28)
                        .shadow(color: Color.brandPrimary.opacity(0.2), radius: 8, x: 0, y: 4)
                    }
                    .disabled(isUpdating)
                    
                    Spacer()
                }
                .padding(20)
            }
            .navigationTitle(AppStrings.Profile.locationLabel)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(AppStrings.Common.done) {
                        dismiss()
                    }
                    .font(.system(size: AppConstants.Typography.sizeBody, weight: .bold))
                    .foregroundColor(.brandPrimary)
                }
            }
        }
    }
}

// MARK: - Help Sheet View
struct HelpSheetView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.backgroundMain.ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        VStack(alignment: .leading, spacing: 14) {
                            Text(AppStrings.Profile.welcomeLabel)
                                .font(.system(size: AppConstants.Typography.sizeTitle - 2, weight: .black))
                                .foregroundColor(.textPrimary)
                            
                            Text(AppStrings.Profile.helpDescription)
                                .font(.system(size: AppConstants.Typography.sizeBody - 1, weight: .medium))
                                .foregroundColor(.textSecondary)
                                .lineSpacing(4)
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 16)
                        
                        VStack(alignment: .leading, spacing: 16) {
                            helpItem(title: AppStrings.Profile.helpTitle1, desc: AppStrings.Profile.helpDesc1)
                            
                            helpItem(title: AppStrings.Profile.helpTitle2, desc: AppStrings.Profile.helpDesc2)
                            
                            helpItem(title: AppStrings.Profile.helpTitle3, desc: AppStrings.Profile.helpDesc3)
                        }
                        .padding(.horizontal, 20)
                    }
                }
            }
            .navigationTitle(AppStrings.Profile.helpGuidelinesHeader)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(AppStrings.Common.close) {
                        dismiss()
                    }
                    .font(.system(size: AppConstants.Typography.sizeBody, weight: .bold))
                    .foregroundColor(.brandPrimary)
                }
            }
        }
    }
    
    private func helpItem(title: String, desc: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.system(size: AppConstants.Typography.sizeBody - 1, weight: .black))
                .foregroundColor(.brandPrimaryDark)
            
            Text(desc)
                .font(.system(size: AppConstants.Typography.sizeCaption + 1, weight: .medium))
                .foregroundColor(.textSecondary)
                .lineSpacing(3)
        }
        .padding(16)
        .background(Color.surfaceMain)
        .cornerRadius(AppConstants.UI.cornerRadiusSmall)
        .overlay(
            RoundedRectangle(cornerRadius: AppConstants.UI.cornerRadiusSmall)
                .stroke(Color.appBorder, lineWidth: 1)
        )
    }
}

// MARK: - Toggle Row Helper
struct ToggleRow: View {
    let title: String
    @Binding var isOn: Bool
    
    var body: some View {
        Toggle(isOn: $isOn) {
            Text(title)
                .font(.system(size: AppConstants.Typography.sizeBody - 1, weight: .bold))
                .foregroundColor(.textPrimary)
        }
        .tint(.brandPrimary)
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }
}

// MARK: - Stat Type Enum
enum StatType: String, CaseIterable, Identifiable {
    case hosted
    case joined
    case noShows
    case score
    
    var id: String { self.rawValue }
    
    var title: String {
        switch self {
        case .hosted: return AppStrings.Profile.hostedDetailTitle
        case .joined: return AppStrings.Profile.joinedDetailTitle
        case .noShows: return AppStrings.Profile.noShowsDetailTitle
        case .score: return AppStrings.Profile.scoreDetailTitle
        }
    }
    
    var icon: String {
        switch self {
        case .hosted: return AppIcons.coffeeFill
        case .joined: return AppIcons.participants
        case .noShows: return AppIcons.calendar
        case .score: return AppIcons.clockFill
        }
    }
    
    var color: Color {
        switch self {
        case .hosted: return .brandPrimary
        case .joined: return .brandPurple
        case .noShows: return .brandSecondary
        case .score: return .textSecondary
        }
    }
}

// MARK: - Stats Detail Sheet View
struct StatsDetailSheetView: View {
    @Environment(\.dismiss) var dismiss
    let type: StatType
    let count: String
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.backgroundMain.ignoresSafeArea()
                
                VStack(spacing: AppConstants.Layout.sectionSpacing) {
                    Spacer()
                    
                    // Large Premium Icon Visual
                    ZStack {
                        Circle()
                            .fill(type.color.opacity(0.12))
                            .frame(width: 100, height: 100)
                        
                        Image(systemName: type.icon)
                            .font(.system(size: 44, weight: .bold))
                            .foregroundColor(type.color)
                    }
                    .shadow(color: type.color.opacity(0.1), radius: 10, x: 0, y: 5)
                    
                    VStack(spacing: 8) {
                        Text(count)
                            .font(.system(size: count == "Coming soon" ? 20 : 44, weight: .black))
                            .foregroundColor(.textPrimary)
                        
                        Text(type.title)
                            .font(.system(size: AppConstants.Typography.sizeHeadline, weight: .bold))
                            .foregroundColor(.textSecondary)
                    }
                    
                    // Stat Card with beautiful description
                    VStack(alignment: .leading, spacing: 14) {
                        HStack(spacing: 8) {
                            AppIcons.shieldVerifiedImage
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.brandPrimary)
                            
                            Text("About \(type.title)")
                                .font(.system(size: 14, weight: .black))
                                .foregroundColor(.brandPrimaryDark)
                        }
                        
                        Text(description(for: type))
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.textSecondary)
                            .lineSpacing(4)
                    }
                    .padding(20)
                    .background(Color.surfaceMain)
                    .cornerRadius(AppConstants.UI.cornerRadiusMedium)
                    .overlay(
                        RoundedRectangle(cornerRadius: AppConstants.UI.cornerRadiusMedium)
                            .stroke(Color.appBorder, lineWidth: 1)
                    )
                    .padding(.horizontal, 20)
                    
                    Spacer()
                    
                    // Dismiss Button
                    Button(action: { dismiss() }) {
                        Text(AppStrings.Common.done)
                            .font(.system(size: AppConstants.Typography.sizeBody, weight: .bold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(Color.brandPrimary)
                            .cornerRadius(28)
                            .shadow(color: Color.brandPrimary.opacity(0.2), radius: 8, x: 0, y: 4)
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                }
            }
            .navigationTitle(type.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(AppStrings.Common.close) {
                        dismiss()
                    }
                    .font(.system(size: AppConstants.Typography.sizeBody, weight: .bold))
                    .foregroundColor(.brandPrimary)
                }
            }
        }
    }
    
    private func description(for type: StatType) -> String {
        switch type {
        case .hosted:
            return AppStrings.Profile.hostedDetailDesc
        case .joined:
            return AppStrings.Profile.joinedDetailDesc
        case .noShows:
            return AppStrings.Profile.noShowsDetailDesc
        case .score:
            return AppStrings.Profile.scoreDetailDesc
        }
    }
}

struct ProfileScreen_Previews: PreviewProvider {
    static var previews: some View {
        ProfileScreen()
            .environmentObject(AuthViewModel())
    }
}
