import SwiftUI

struct ProfileScreen: View {
    @StateObject private var viewModel = ProfileViewModel()
    @State private var showingEditProfile = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: AppConstants.Layout.standardPadding) {
                // Profile Info
                profileHeaderCard
                
                // Stats
                statsRow
                
                // Interests
                interestsSection
                
                // Availability & Safety Row
                HStack(alignment: .top, spacing: AppConstants.Layout.elementSpacing) {
                    availabilitySection
                    safetySection
                }
                
                // History
                historySection
                
                // Settings
                settingsSection
                
                // Safety Banner
                safetyBanner
            }
            .padding(.horizontal, AppConstants.Layout.standardPadding)
            .asCoffeeScreen(config: viewModel)
            .sheet(isPresented: $showingEditProfile) {
                EditProfileScreen(viewModel: viewModel)
            }
        }
    }
    
    // MARK: - Header
    
    // MARK: - Profile Card
    private var profileHeaderCard: some View {
        HStack(spacing: 20) {
            ZStack(alignment: .bottomTrailing) {
                Text(viewModel.initials)
                    .font(.system(size: AppConstants.Typography.sizeHeadline + 10, weight: .black))
                    .foregroundColor(.brandPrimary)
                    .frame(width: 80, height: 80)
                    .background(Circle().fill(Color.brandPrimary.opacity(AppConstants.UI.opacityLight)))
                
                ZStack {
                    Circle()
                        .fill(Color.white)
                        .frame(width: 28, height: 28)
                    Image(systemName: AppIcons.camera)
                        .font(.system(size: AppConstants.Typography.sizeTiny + 1))
                        .foregroundColor(.textPrimary)
                }
                .shadow(color: Color.textPrimary.opacity(AppConstants.UI.opacityLight), radius: 2)
                .offset(x: 4, y: 4)
            }
            
            VStack(alignment: .leading, spacing: 6) {
                Text(viewModel.name)
                    .font(.system(size: AppConstants.Typography.sizeTitle, weight: .black))
                    .foregroundColor(.textPrimary)
                Text(viewModel.bio)
                    .font(.system(size: AppConstants.Typography.sizeCaption, weight: .medium))
                    .foregroundColor(.textSecondary)
                    .lineLimit(2)
                
                Button(action: { showingEditProfile = true }) {
                    HStack(spacing: 6) {
                        Image(systemName: "pencil")
                        Text(AppStrings.Profile.editProfile)
                    }
                    .font(.system(size: AppConstants.Typography.sizeTiny + 1, weight: .bold))
                    .foregroundColor(.brandPrimary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Capsule().stroke(Color.brandPrimary, lineWidth: 1))
                }
                .padding(.top, 4)
            }
            
            Spacer()
        }
    }
    
    // MARK: - Stats Row
    private var statsRow: some View {
        HStack(spacing: 12) {
            statItem(count: "\(viewModel.driftsJoined)", label: AppStrings.Profile.joined, icon: AppIcons.participants)
            statItem(count: "\(viewModel.driftsHosted)", label: AppStrings.Profile.hosted, icon: "person.badge.plus")
            statItem(count: "\(viewModel.pastDriftsCount)", label: AppStrings.Profile.past, icon: AppIcons.clock)
            statItem(count: AppStrings.Profile.activeStatus, label: AppStrings.Profile.activeThisMonth, icon: AppIcons.calendar, color: .brandPrimary)
        }
    }
    
    private func statItem(count: String, label: String, icon: String, color: Color = .textPrimary) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: AppConstants.Typography.sizeBody))
                .foregroundColor(color.opacity(AppConstants.UI.opacityNormal + 0.2))
            Text(count)
                .font(.system(size: AppConstants.Typography.sizeBody, weight: .black))
                .foregroundColor(color)
            Text(label)
                .font(.system(size: AppConstants.Typography.sizeMicro, weight: .bold))
                .foregroundColor(.textSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(Color.surfaceMain)
        .cornerRadius(AppConstants.UI.cornerRadiusSmall + 4)
        .overlay(RoundedRectangle(cornerRadius: AppConstants.UI.cornerRadiusSmall + 4).stroke(Color.appBorder, lineWidth: 1))
    }
    
    // MARK: - Interests
    private var interestsSection: some View {
        VStack(alignment: .leading, spacing: AppConstants.Layout.elementSpacing) {
            HStack {
                Text(AppStrings.Profile.interests)
                    .font(.system(size: AppConstants.Typography.sizeHeadline, weight: .black))
                Spacer()
                Button(AppStrings.Profile.edit) {}
                    .font(.system(size: AppConstants.Typography.sizeCaption, weight: .bold))
                    .foregroundColor(.brandPrimary)
            }
            
            FlowLayout(spacing: 8) {
                ForEach(viewModel.interests, id: \.self) { category in
                    HStack(spacing: 6) {
                        Image(systemName: category.icon)
                        Text(category.rawValue.capitalized)
                    }
                    .font(.system(size: AppConstants.Typography.sizeCaption, weight: .bold))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color.surfaceMain)
                    .cornerRadius(AppConstants.UI.cornerRadiusTiny + 4)
                    .overlay(RoundedRectangle(cornerRadius: AppConstants.UI.cornerRadiusTiny + 4).stroke(Color.appBorder, lineWidth: 1))
                }
                
                Button(action: {}) {
                    HStack(spacing: 4) {
                        Image(systemName: AppIcons.plus)
                        Text(AppStrings.Profile.addInterest)
                    }
                    .font(.system(size: AppConstants.Typography.sizeCaption, weight: .bold))
                    .foregroundColor(.brandPrimary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Capsule().stroke(Color.brandPrimary, lineWidth: 1).opacity(AppConstants.UI.opacityNormal))
                }
            }
        }
    }
    
    // MARK: - Availability Section
    private var availabilitySection: some View {
        VStack(alignment: .leading, spacing: AppConstants.Layout.elementSpacing) {
            HStack {
                Text(AppStrings.Profile.availability)
                    .font(.system(size: 15, weight: .black))
                Spacer()
                Button(AppStrings.Profile.edit) {}
                    .font(.system(size: AppConstants.Typography.sizeTiny + 1, weight: .bold))
                    .foregroundColor(.brandPrimary)
            }
            
            VStack(alignment: .leading, spacing: 12) {
                availabilityItem(icon: AppIcons.clock, text: AppStrings.Profile.usuallyFree)
                availabilityItem(icon: AppIcons.calendar, text: AppStrings.Profile.weekdayEvenings)
                availabilityItem(icon: AppIcons.calendar, text: AppStrings.Profile.weekends)
                
                Divider().padding(.vertical, 4)
                
                HStack {
                    Image(systemName: AppIcons.visibility)
                        .font(.system(size: 14))
                        .foregroundColor(.textSecondary)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(AppStrings.Profile.visibleToOthers)
                            .font(.system(size: AppConstants.Typography.sizeTiny + 1, weight: .bold))
                        Text(AppStrings.Profile.visibleDesc)
                            .font(.system(size: AppConstants.Typography.sizeMicro))
                            .foregroundColor(.textSecondary)
                    }
                    Spacer()
                    Text(AppStrings.Profile.visibleEveryone)
                        .font(.system(size: AppConstants.Typography.sizeTiny, weight: .bold))
                        .foregroundColor(.textSecondary)
                    Image(systemName: AppIcons.chevronRight)
                        .font(.system(size: AppConstants.Typography.sizeMicro))
                        .foregroundColor(.textSecondary.opacity(AppConstants.UI.opacityNormal + 0.1))
                }
            }
        }
        .padding(16)
        .background(Color.surfaceMain)
        .cornerRadius(AppConstants.UI.cornerRadiusSmall + 4)
        .overlay(RoundedRectangle(cornerRadius: AppConstants.UI.cornerRadiusSmall + 4).stroke(Color.appBorder, lineWidth: 1))
    }
    
    private func availabilityItem(icon: String, text: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(.textSecondary)
            Text(text)
                .font(.system(size: AppConstants.Typography.sizeTiny + 1, weight: .medium))
            Spacer()
        }
    }
    
    // MARK: - Safety Section
    private var safetySection: some View {
        VStack(alignment: .leading, spacing: AppConstants.Layout.elementSpacing) {
            Text(AppStrings.Profile.safety)
                .font(.system(size: 15, weight: .black))
            
            VStack(spacing: 12) {
                safetyItem(icon: AppIcons.lock, title: AppStrings.Profile.phoneNotShared, desc: AppStrings.Profile.phoneCoordination)
                safetyItem(icon: AppIcons.mappin, title: AppStrings.Profile.approxDistance, desc: AppStrings.Profile.locationApprox)
                safetyItem(icon: AppIcons.block, title: AppStrings.Profile.blockedUsers, desc: AppStrings.Profile.blockedDesc)
                safetyItem(icon: AppIcons.report, title: AppStrings.Profile.reportSafety, desc: AppStrings.Profile.reportDesc)
                safetyItem(icon: AppIcons.visibility, title: AppStrings.Profile.locationVisibility, desc: AppStrings.Profile.visibilityDesc)
            }
        }
        .padding(16)
        .background(Color.surfaceMain)
        .cornerRadius(AppConstants.UI.cornerRadiusSmall + 4)
        .overlay(RoundedRectangle(cornerRadius: AppConstants.UI.cornerRadiusSmall + 4).stroke(Color.appBorder, lineWidth: 1))
    }
    
    private func safetyItem(icon: String, title: String, desc: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(.brandPrimary)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: AppConstants.Typography.sizeTiny, weight: .bold))
                    .lineLimit(1)
                Text(desc)
                    .font(.system(size: AppConstants.Typography.sizeMicro))
                    .foregroundColor(.textSecondary)
                    .lineLimit(1)
            }
            Spacer()
            Image(systemName: AppIcons.chevronRight)
                .font(.system(size: AppConstants.Typography.sizeMicro))
                .foregroundColor(.textSecondary.opacity(AppConstants.UI.opacityNormal + 0.1))
        }
    }
    
    // MARK: - History Section
    private var historySection: some View {
        VStack(alignment: .leading, spacing: AppConstants.Layout.elementSpacing) {
            HStack {
                Text(AppStrings.Profile.history)
                    .font(.system(size: AppConstants.Typography.sizeHeadline, weight: .black))
                Spacer()
                Button(AppStrings.Profile.viewAll) {}
                    .font(.system(size: AppConstants.Typography.sizeCaption, weight: .bold))
                    .foregroundColor(.brandPrimary)
            }
            
            // Custom Segmented Control
            HStack(spacing: 0) {
                historyTab(title: AppStrings.Profile.hostedTab, icon: "person.badge.plus", index: 0)
                historyTab(title: AppStrings.Profile.joinedTab, icon: AppIcons.participants, index: 1)
                historyTab(title: AppStrings.Profile.pastTab, icon: AppIcons.clock, index: 2)
            }
            .background(Color.surfaceSecondary.opacity(AppConstants.UI.opacitySubtle))
            .cornerRadius(12)
            .padding(.bottom, 8)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(viewModel.historyDrifts) { drift in
                        HistoryCard(drift: drift)
                    }
                }
            }
            
            Button(action: {}) {
                Text(AppStrings.Profile.createNew)
                    .font(.system(size: AppConstants.Typography.sizeCaption, weight: .bold))
                    .foregroundColor(.brandPrimary)
                    .frame(maxWidth: .infinity)
            }
            .padding(.top, 8)
        }
    }
    
    private func historyTab(title: String, icon: String, index: Int) -> some View {
        Button(action: { withAnimation { viewModel.selectedHistoryTab = index } }) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                Text(title)
            }
            .font(.system(size: AppConstants.Typography.sizeTiny + 1, weight: .bold))
            .frame(maxWidth: .infinity)
            .frame(height: 36)
            .background(viewModel.selectedHistoryTab == index ? Color.surfaceMain : Color.clear)
            .foregroundColor(viewModel.selectedHistoryTab == index ? .brandPrimary : .textSecondary)
            .cornerRadius(10)
            .padding(2)
        }
    }
    
    // MARK: - Settings Section
    private var settingsSection: some View {
        VStack(alignment: .leading, spacing: AppConstants.Layout.elementSpacing) {
            Text(AppStrings.Profile.settings)
                .font(.system(size: AppConstants.Typography.sizeHeadline, weight: .black))
            
            VStack(spacing: 0) {
                settingsRow(icon: AppIcons.bell, title: AppStrings.Profile.notifications, desc: AppStrings.Profile.notificationsDesc)
                Divider().padding(.leading, 50)
                settingsRow(icon: AppIcons.mappin, title: AppStrings.Profile.locPermissions, desc: AppStrings.Profile.locPermsDesc)
                Divider().padding(.leading, 50)
                settingsRow(icon: AppIcons.account, title: AppStrings.Profile.accountSettings, desc: AppStrings.Profile.accountDesc)
                Divider().padding(.leading, 50)
                settingsRow(icon: AppIcons.logout, title: AppStrings.Profile.signOut, desc: AppStrings.Profile.signOutDesc, color: .brandPurple)
            }
            .background(Color.surfaceMain)
            .cornerRadius(AppConstants.UI.cornerRadiusMedium)
            .overlay(RoundedRectangle(cornerRadius: AppConstants.UI.cornerRadiusMedium).stroke(Color.appBorder, lineWidth: 1))
        }
    }
    
    private func settingsRow(icon: String, title: String, desc: String, color: Color = .textPrimary) -> some View {
        Button(action: {}) {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(color.opacity(AppConstants.UI.opacityLight))
                        .frame(width: 40, height: 40)
                    Image(systemName: icon)
                        .foregroundColor(color)
                        .font(.system(size: 16))
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: AppConstants.Typography.sizeCaption + 1, weight: .bold))
                        .foregroundColor(.textPrimary)
                    Text(desc)
                        .font(.system(size: AppConstants.Typography.sizeTiny, weight: .medium))
                        .foregroundColor(.textSecondary)
                }
                
                Spacer()
                
                Image(systemName: AppIcons.chevronRight)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.textSecondary.opacity(AppConstants.UI.opacityNormal - 0.1))
            }
            .padding(16)
        }
    }
    
    // MARK: - Safety Banner
    private var safetyBanner: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color.brandPrimary.opacity(AppConstants.UI.opacityLight))
                    .frame(width: 32, height: 32)
                Image(systemName: AppIcons.shieldVerified)
                    .font(.system(size: 14))
                    .foregroundColor(.brandPrimary)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(AppStrings.Drifts.Detail.safetyTitle)
                    .font(.system(size: 14, weight: .black))
                    .foregroundColor(.brandPrimary)
                Text(AppStrings.Drifts.Detail.safetySubtitle + ". " + AppStrings.Drifts.Detail.coordinationNote)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.textSecondary)
                    .lineSpacing(2)
            }
            
            Spacer()
            
            Image(systemName: AppIcons.chevronRight)
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(.brandPrimary.opacity(AppConstants.UI.opacityNormal))
        }
        .padding(20)
        .background(Color.brandPrimary.opacity(AppConstants.UI.opacitySubtle))
        .cornerRadius(AppConstants.UI.cornerRadiusMedium)
        .padding(.top, 12)
    }
}

// MARK: - History Card Component
struct HistoryCard: View {
    let drift: Drift
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Image
            ZStack(alignment: .topTrailing) {
                viewModelImage
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 140, height: 90)
                    .cornerRadius(12)
                
                // Small Category Icon
                ZStack {
                    Circle().fill(Color.white).frame(width: 24, height: 24)
                    Image(systemName: drift.category.icon)
                        .font(.system(size: 10))
                        .foregroundColor(drift.category.color)
                }
                .padding(6)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(drift.title)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.textPrimary)
                    .lineLimit(2)
                
                Text(drift.location)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(.textSecondary)
                
                HStack(spacing: 4) {
                    Image(systemName: AppIcons.participants)
                        .font(.system(size: 10))
                    Text("\(drift.peopleGoing) joined")
                }
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(.textSecondary)
            }
            .padding(.horizontal, 4)
        }
        .frame(width: 140)
    }
    
    private var viewModelImage: Image {
        // Fallback for mock
        Image(systemName: "photo")
    }
}

// MARK: - FlowLayout Helper
struct FlowLayout: View {
    var spacing: CGFloat
    var content: [AnyView]
    
    init<Views: View>(spacing: CGFloat, @ViewBuilder content: () -> Views) {
        self.spacing = spacing
        // Simplification for mock purposes - normally would use a proper flow layout implementation
        self.content = [AnyView(content())]
    }
    
    var body: some View {
        HStack(spacing: spacing) {
            ForEach(0..<content.count, id: \.self) { index in
                content[index]
            }
        }
    }
}

