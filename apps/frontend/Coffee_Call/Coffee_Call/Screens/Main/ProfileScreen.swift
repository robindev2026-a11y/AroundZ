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
    
    @EnvironmentObject var auth: AuthViewModel
    
    var body: some View {
        NavigationStack {
            VStack(spacing: AppConstants.Layout.sectionSpacing) {
                // 1. Identity Card
                identityCard
                
                // 2. Private Stats Grid
                statsSection
                
                // 3. Activity Log
                activityLogSection
                
                // 4. Preferences List
                preferencesSection
                
                // 5. Account Control List
                accountSection
            }
            .padding(.horizontal, AppConstants.Layout.standardPadding)
            .asCoffeeMainPage(
                title: viewModel.title,
                subtitle: viewModel.subtitle ?? ""
            ) {
                CoffeeHeaderButton(icon: AppIcons.settings) {
                    viewModel.showingSettingsSheet = true
                }
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
            .alert("Sign out", isPresented: $showingSignOutAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Sign out", role: .destructive) {
                    viewModel.signOut()
                    auth.signOut()
                }
            } message: {
                Text("Are you sure you want to sign out of your account?")
            }
        }
    }
    
    // MARK: - Identity Card
    private var identityCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .center, spacing: 16) {
                // Circular Avatar (72x72) with premium brand gradient
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color.brandPrimary.opacity(0.25), Color.brandPrimary.opacity(0.05)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 72, height: 72)
                    
                    Image(systemName: AppIcons.person)
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.brandPrimaryDark)
                }
                .overlay(
                    Circle()
                        .stroke(Color.brandPrimary.opacity(0.2), lineWidth: 1.5)
                )
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(viewModel.name)
                        .font(.heading2)
                        .foregroundColor(.textPrimary)
                    
                    HStack(spacing: 4) {
                        Image(systemName: "mappin.and.ellipse")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.textSecondary)
                        
                        Text("Bengaluru • 10 km radius")
                            .font(.captionText)
                            .foregroundColor(.textSecondary)
                    }
                    
                    // Small Mint Phone Verification Pill (Hides phone number)
                    HStack(spacing: 4) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 9, weight: .black))
                            .foregroundColor(.brandPrimary)
                        
                        Text("Verified phone")
                            .font(.metadata)
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
                        Text("Edit profile")
                        Image(systemName: "pencil")
                    }
                    .font(.captionText)
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
            Text("Your stats")
                .font(.system(size: AppConstants.Typography.sizeHeadline, weight: .black))
                .foregroundColor(.textPrimary)
            
            VStack(spacing: 12) {
                HStack(spacing: 12) {
                    // Tile 1: Hosted
                    statTile(
                        icon: "cup.and.saucer.fill",
                        color: Color.brandPrimary,
                        count: "\(viewModel.driftsHosted)",
                        label: "Hosted"
                    )
                    
                    // Tile 2: People Joined
                    statTile(
                        icon: "person.2.fill",
                        color: Color.brandPurple,
                        count: "\(viewModel.driftsJoined)",
                        label: "People joined"
                    )
                }
                
                HStack(spacing: 12) {
                    // Tile 3: No-shows
                    statTile(
                        icon: "calendar",
                        color: Color.brandSecondary,
                        count: "0",
                        label: "No-shows"
                    )
                    
                    // Tile 4: Score (Coming soon)
                    statTile(
                        icon: "clock.fill",
                        color: Color.textSecondary,
                        count: "Coming soon",
                        label: "Score"
                    )
                }
            }
            
            // Privacy Caption
            HStack(spacing: 6) {
                Image(systemName: AppIcons.lock)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.textSecondary)
                
                Text("Stats are private to you.")
                    .font(.captionText)
                    .foregroundColor(.textSecondary)
            }
            .padding(.leading, 4)
        }
    }
    
    private func statTile(icon: String, color: Color, count: String, label: String) -> some View {
        HStack(spacing: 8) { // Reduced spacing from 12 to 8
            // Icon circle well (38x38) - Reduced from 46x46
            ZStack {
                Circle()
                    .fill(color.opacity(0.12))
                    .frame(width: 38, height: 38)
                
                Image(systemName: icon)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(color)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(count)
                    .font(count == "Coming soon" ? .captionText : .heading2)
                    .foregroundColor(count == "Coming soon" ? .textSecondary : .textPrimary)
                    .lineLimit(1)
                
                Text(label)
                    .font(.metadata)
                    .foregroundColor(.textSecondary)
                    .lineLimit(1)
            }
            
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 10) // Reduced horizontal padding from 16 to 10
        .padding(.vertical, 12)   // Reduced vertical padding from 14 to 12
        .frame(maxWidth: .infinity)
        .frame(height: 70)        // Reduced height from 74 to 70 for standard compact UI
        .background(Color.surfaceMain)
        .cornerRadius(AppConstants.UI.cornerRadiusMedium + 2) // radius 22pt
        .overlay(
            RoundedRectangle(cornerRadius: AppConstants.UI.cornerRadiusMedium + 2)
                .stroke(Color.appBorder, lineWidth: 1)
        )
    }
    
    // MARK: - Preferences List
    private var preferencesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Preferences")
                .font(.system(size: AppConstants.Typography.sizeHeadline, weight: .black))
                .foregroundColor(.textPrimary)
            
            VStack(spacing: 0) {
                // Row 1: Interests
                preferenceRow(
                    icon: "heart.fill",
                    color: Color.brandPrimary,
                    title: "Interests",
                    value: viewModel.interests.isEmpty ? "None" : viewModel.interests.map { $0.rawValue.capitalized }.joined(separator: ", ")
                ) {
                    showingInterestsSheet = true
                }
                
                Divider().background(Color.appBorder).padding(.horizontal, 16)
                
                // Row 2: Availability
                preferenceRow(
                    icon: "clock.fill",
                    color: Color.brandPurple,
                    title: "Availability",
                    value: viewModel.availabilitySummary
                ) {
                    showingAvailabilitySheet = true
                }
                
                Divider().background(Color.appBorder).padding(.horizontal, 16)
                
                // Row 3: Notifications
                preferenceRow(
                    icon: "bell.fill",
                    color: Color.brandSecondary,
                    title: "Notifications",
                    value: "Push, In-app"
                ) {
                    showingNotificationsSheet = true
                }
                
                Divider().background(Color.appBorder).padding(.horizontal, 16)
                
                // Row 4: Privacy & Safety
                preferenceRow(
                    icon: "checkmark.shield.fill",
                    color: Color.brandPrimary,
                    title: "Privacy & Safety",
                    value: "Your data, safety tools"
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
            Text("Account")
                .font(.system(size: AppConstants.Typography.sizeHeadline, weight: .black))
                .foregroundColor(.textPrimary)
            
            VStack(spacing: 0) {
                // Row 1: Location
                preferenceRow(
                    icon: "mappin.circle.fill",
                    color: Color.brandPrimary,
                    title: "Location",
                    value: viewModel.location
                ) {
                    showingLocationSheet = true
                }
                
                Divider().background(Color.appBorder).padding(.horizontal, 16)
                
                // Row 2: Help
                preferenceRow(
                    icon: "questionmark.circle.fill",
                    color: Color.brandPurple,
                    title: "Help"
                ) {
                    showingHelpSheet = true
                }
                
                Divider().background(Color.appBorder).padding(.horizontal, 16)
                
                // Row 3: Sign out
                preferenceRow(
                    icon: "arrow.right.square.fill",
                    color: Color.statusError,
                    title: "Sign out",
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
                    .font(.system(size: AppConstants.Typography.sizeBody, weight: .bold))
                    .foregroundColor(isDestructive ? Color.statusError : .textPrimary)
                
                Spacer()
                
                if let value = value {
                    Text(value)
                        .font(.system(size: AppConstants.Typography.sizeCaption + 1, weight: .bold))
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
        .buttonStyle(PlainButtonStyle())
        .pressScale(0.98)
    }
    
    // MARK: - Activity Log
    private var activityLogSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Activity Log")
                .font(.bodyBold)
                .foregroundColor(.textPrimary)
            
            if viewModel.historyDrifts.isEmpty {
                Text("No past activities yet.")
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
                Image(systemName: "calendar")
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
                                
                                Image(systemName: "cup.and.saucer.fill")
                                    .font(.system(size: 36, weight: .bold))
                                    .foregroundColor(.brandPrimary)
                            }
                            
                            Text("CoffeeCall")
                                .font(.system(size: AppConstants.Typography.sizeTitle, weight: .black))
                                .foregroundColor(.textPrimary)
                            
                            Text("Version 1.0.0 (Beta)")
                                .font(.system(size: AppConstants.Typography.sizeCaption, weight: .bold))
                                .foregroundColor(.textSecondary)
                        }
                        .padding(.top, 24)
                        
                        VStack(spacing: 0) {
                            settingsDetailRow(title: "Environment", value: "Production")
                            Divider().background(Color.appBorder).padding(.horizontal, 16)
                            settingsDetailRow(title: "Client ID", value: "iOS-MVP-2026")
                            Divider().background(Color.appBorder).padding(.horizontal, 16)
                            settingsDetailRow(title: "Build Phase", value: "Release Verification")
                        }
                        .background(Color.surfaceMain)
                        .cornerRadius(AppConstants.UI.cornerRadiusMedium)
                        .overlay(
                            RoundedRectangle(cornerRadius: AppConstants.UI.cornerRadiusMedium)
                                .stroke(Color.appBorder, lineWidth: 1)
                        )
                        .padding(.horizontal, 20)
                        
                        Text("© 2026 CoffeeCall Inc. All rights reserved.")
                            .font(.system(size: AppConstants.Typography.sizeTiny, weight: .medium))
                            .foregroundColor(.textSecondary)
                            .padding(.top, 12)
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") {
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
                        Text("Select what you are open to today. This updates your discovery filter.")
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
                                            Image(systemName: "checkmark.circle.fill")
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
            .navigationTitle("Interests")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
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
                        Text("Let others know when you are generally free for nearby activities.")
                            .font(.system(size: AppConstants.Typography.sizeBody - 1, weight: .medium))
                            .foregroundColor(.textSecondary)
                            .padding(.horizontal, 20)
                            .padding(.top, 12)
                        
                        VStack(spacing: 0) {
                            ToggleRow(title: "Weekday evenings", isOn: $viewModel.availabilityWeekdayEvenings)
                            Divider().background(Color.appBorder).padding(.horizontal, 16)
                            ToggleRow(title: "Weekends", isOn: $viewModel.availabilityWeekends)
                            Divider().background(Color.appBorder).padding(.horizontal, 16)
                            ToggleRow(title: "Daytime / Lunch", isOn: $viewModel.availabilityDaytime)
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
            .navigationTitle("Availability")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
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
                        Text("Choose what system notifications you want to receive.")
                            .font(.system(size: AppConstants.Typography.sizeBody - 1, weight: .medium))
                            .foregroundColor(.textSecondary)
                            .padding(.horizontal, 20)
                            .padding(.top, 12)
                        
                        VStack(spacing: 0) {
                            ToggleRow(title: "Push Notifications", isOn: $pushAlerts)
                            Divider().background(Color.appBorder).padding(.horizontal, 16)
                            ToggleRow(title: "In-App Alerts", isOn: $inAppAlerts)
                            Divider().background(Color.appBorder).padding(.horizontal, 16)
                            ToggleRow(title: "Nearby Drift Alerts (<10km)", isOn: $nearbyDriftsAlerts)
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
            .navigationTitle("Notifications")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
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
                        Text("Safety is our top priority. We never share phone numbers or exact locations in the discovery radar.")
                            .font(.system(size: AppConstants.Typography.sizeBody - 1, weight: .bold))
                            .foregroundColor(.brandPrimaryDark)
                            .padding(16)
                            .background(Color.brandPrimary.opacity(0.12))
                            .cornerRadius(AppConstants.UI.cornerRadiusSmall)
                            .padding(.horizontal, 20)
                            .padding(.top, 12)
                        
                        VStack(spacing: 0) {
                            ToggleRow(title: "Show approximate distance only", isOn: $shareApproxLoc)
                            Divider().background(Color.appBorder).padding(.horizontal, 16)
                            ToggleRow(title: "Keep stats private to me", isOn: $privateStats)
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
            .navigationTitle("Privacy & Safety")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
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
                        
                        Image(systemName: "mappin.and.ellipse")
                            .font(.system(size: 48, weight: .bold))
                            .foregroundColor(.brandPrimary)
                    }
                    
                    VStack(spacing: 8) {
                        Text(viewModel.location)
                            .font(.system(size: AppConstants.Typography.sizeTitle, weight: .black))
                            .foregroundColor(.textPrimary)
                        
                        Text("Search is fixed to a 10 km discovery radius.")
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
                                Image(systemName: "location.fill")
                            }
                            
                            Text(isUpdating ? "Updating location..." : "Update current location")
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
            .navigationTitle("Location")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
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
                            Text("Welcome to CoffeeCall!")
                                .font(.system(size: AppConstants.Typography.sizeTitle - 2, weight: .black))
                                .foregroundColor(.textPrimary)
                            
                            Text("CoffeeCall helps you turn nearby interests into real-world meetups. Here's how to stay safe and have fun:")
                                .font(.system(size: AppConstants.Typography.sizeBody - 1, weight: .medium))
                                .foregroundColor(.textSecondary)
                                .lineSpacing(4)
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 16)
                        
                        VStack(alignment: .leading, spacing: 16) {
                            helpItem(title: "1. The Drift is the unit of action", desc: "Always coordinate through Drifts. There are no cold direct messages or private browsing lists. Everything revolves around physical plans.")
                            
                            helpItem(title: "2. Keep details inside pre-meetup chats", desc: "Exact meeting locations and details remain locked in the chat room until a user has hosted or successfully joined the Drift.")
                            
                            helpItem(title: "3. Safe and respectful spaces", desc: "Meet in well-populated public places (e.g. popular local coffee houses, parks, study hubs). Be reliable and keep your no-show rates low.")
                        }
                        .padding(.horizontal, 20)
                    }
                }
            }
            .navigationTitle("Help & Guidelines")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") {
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
