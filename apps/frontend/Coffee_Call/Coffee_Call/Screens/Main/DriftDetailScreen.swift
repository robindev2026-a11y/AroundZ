import SwiftUI

struct DriftDetailScreen: View {
    @Environment(\.dismiss) var dismiss
    @StateObject var viewModel: DriftDetailViewModel
    @StateObject private var navManager = NavigationManager.shared
    @State private var tabBarVisibilitySource = UUID().uuidString
    @State private var showingHostContext = false
    @State private var showingWhoIsComing = false
    @State private var selectedDriftForNavigation: Drift? = nil
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            heroSection
                .padding(.horizontal, AppConstants.Layout.standardPadding)
                .padding(.top, 20) // Pushed up under the VStack header
            
            // Summary Info Grid
            summaryInfoGrid
                .padding(.horizontal, AppConstants.Layout.standardPadding)
                .padding(.top, AppConstants.Layout.sectionSpacing)
            
            VStack(alignment: .leading, spacing: AppConstants.Layout.sectionSpacing) {
                // About Section
                aboutSection
                
                // Hosted By Section
                hostSection
                
                // Who's Coming Section
                participantsSection
                
                // Details List Section
                detailsListSection
                
                // Safety Banner
                safetyBanner
            }
            .padding(.horizontal, AppConstants.Layout.standardPadding)
            .padding(.top, AppConstants.Layout.sectionSpacing + 4)
            
            Spacer(minLength: AppConstants.Layout.screenBottomSpacer + 100) // Padding for overlay sticky CTA
        }
        .asCoffeePage(
            .sub,
            title: viewModel.drift.title,
            subtitle: viewModel.drift.category.rawValue.capitalized,
            categoryIcon: viewModel.drift.category.icon,
            categoryColor: viewModel.drift.category.color,
            rightView: {
                HStack(spacing: 8) {
                    CoffeeHeaderButton(icon: AppIcons.share) { viewModel.shareDrift() }
                    CoffeeHeaderButton(icon: viewModel.isBookmarked ? AppIcons.bookmarkFill : AppIcons.bookmark, color: viewModel.isBookmarked ? .brandPrimary : .textPrimary) { viewModel.saveDrift() }
                    CoffeeHeaderButton(icon: "bell.badge.fill", color: .brandPrimary) { viewModel.setReminder() }
                }
            }
        )
        .overlay(alignment: .bottom) {
            stickyCTAFooter
        }
        .sheet(isPresented: $showingHostContext) {
            HostContextCardSheet(host: viewModel.drift.host) { targetDrift in
                showingHostContext = false
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    selectedDriftForNavigation = targetDrift
                }
            }
            .presentationDetents([.fraction(0.85)])
            .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $showingWhoIsComing) {
            WhoIsComingSheet(participants: viewModel.participants)
                .presentationDetents([.fraction(0.65), .large])
                .presentationDragIndicator(.visible)
        }
        .navigationDestination(isPresented: Binding(
            get: { selectedDriftForNavigation != nil },
            set: { if !$0 { selectedDriftForNavigation = nil } }
        )) {
            if let targetDrift = selectedDriftForNavigation {
                DriftDetailScreen(viewModel: DriftDetailViewModel(drift: targetDrift))
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            navManager.setTabBarHidden(true, source: tabBarVisibilitySource)
        }
        .onDisappear {
            navManager.setTabBarHidden(false, source: tabBarVisibilitySource)
        }
    }
    
    
    // MARK: - Hero Content
    private var heroSection: some View {
        HStack(alignment: .top, spacing: 20) {
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 8) {
                    // Status Badge
                    HStack(spacing: 4) {
                        Circle().fill(viewModel.drift.status.color).frame(width: 6, height: 6)
                        Text(viewModel.drift.status.rawValue)
                    }
                    .font(.system(size: AppConstants.Typography.sizeMicro + 2, weight: .bold))
                    .foregroundColor(viewModel.drift.status.color)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(viewModel.drift.status.color.opacity(AppConstants.UI.opacityLight))
                    .cornerRadius(20)
                }
                
                Text(viewModel.drift.description.split(separator: ".").first ?? "")
                    .font(.system(size: AppConstants.Typography.sizeBody, weight: .medium))
                    .foregroundColor(.textSecondary)
            }
            
            Spacer()
            
            // Hero Image
            Image("drift_walk") // Placeholder for viewModel.drift.imageUrl
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 120, height: 120)
                .clipShape(RoundedRectangle(cornerRadius: AppConstants.UI.cornerRadiusMedium))
                .shadow(color: Color.textPrimary.opacity(AppConstants.UI.opacityLight), radius: 10, x: 0, y: 5)
        }
    }
    
    
//    private func headerAction(icon: String, isSpecial: Bool = false, action: @escaping () -> Void) -> some View {
//        Button(action: action) {
//            Image(systemName: icon)
//                .font(.system(size: 16, weight: .bold))
//                .foregroundColor(isSpecial ? .brandPrimary : .textPrimary)
//                .frame(width: 40, height: 40)
//                .background(Color.surfaceMain)
//                .cornerRadius(AppConstants.UI.cornerRadiusSmall)
//                .overlay(RoundedRectangle(cornerRadius: AppConstants.UI.cornerRadiusSmall).stroke(Color.appBorder, lineWidth: 1))
//        }
//    }
    
    
    // MARK: - Summary Info Grid
    private var summaryInfoGrid: some View {
        HStack(spacing: 0) {
            summaryInfoItem(icon: AppIcons.calendar, title: viewModel.drift.date, subtitle: viewModel.drift.time)
            Divider().frame(height: 40).padding(.horizontal, 10)
            summaryInfoItem(icon: AppIcons.location, title: viewModel.drift.location.split(separator: ",").first?.trimmingCharacters(in: .whitespaces) ?? "", subtitle: viewModel.drift.location.split(separator: ",").last?.trimmingCharacters(in: .whitespaces) ?? "")
            Divider().frame(height: 40).padding(.horizontal, 10)
            summaryInfoItem(icon: AppIcons.mappin, title: String(format: "%.1f km", viewModel.drift.distance), subtitle: "from you")
            Divider().frame(height: 40).padding(.horizontal, 10)
            summaryInfoItem(icon: AppIcons.participants, title: AppStrings.Manage.joinedCount(count: viewModel.drift.peopleGoing), subtitle: AppStrings.Manage.openTo(count: viewModel.drift.capacity))
        }
        .padding(.vertical, 20)
        .frame(maxWidth: .infinity)
        .background(Color.surfaceMain)
        .cornerRadius(AppConstants.UI.cornerRadiusMedium)
        .overlay(RoundedRectangle(cornerRadius: AppConstants.UI.cornerRadiusMedium).stroke(Color.appBorder, lineWidth: 1))
    }
    
    private func summaryInfoItem(icon: String, title: String, subtitle: String) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: AppConstants.Typography.sizeTitle))
                .foregroundColor(.brandPrimary)
            
            VStack(spacing: 2) {
                Text(title)
                    .font(.system(size: AppConstants.Typography.sizeCaption, weight: .black))
                    .foregroundColor(.textPrimary)
                Text(subtitle)
                    .font(.system(size: AppConstants.Typography.sizeTiny, weight: .medium))
                    .foregroundColor(.textSecondary)
            }
        }
        .frame(maxWidth: .infinity)
    }
    
    // MARK: - About Section
    private var aboutSection: some View {
        VStack(alignment: .leading, spacing: AppConstants.Layout.elementSpacing) {
            Text(AppStrings.Drifts.Detail.aboutHeader)
                .font(.system(size: AppConstants.Typography.sizeHeadline, weight: .bold))
                .foregroundColor(.textPrimary)
            
            Text(viewModel.drift.description)
                .font(.system(size: AppConstants.Typography.sizeBody, weight: .medium))
                .foregroundColor(.textSecondary)
                .lineSpacing(4)
            
            HStack(spacing: 8) {
                ForEach(viewModel.drift.vibeTags, id: \.self) { tag in
                    Text(tag)
                        .font(.system(size: AppConstants.Typography.sizeTiny + 1, weight: .bold))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(tagColor(for: tag).opacity(AppConstants.UI.opacityLight))
                        .foregroundColor(tagColor(for: tag))
                        .cornerRadius(12)
                }
            }
        }
    }
    
    private func tagColor(for tag: String) -> Color {
        if tag == "Casual" || tag == "Chill" { return .brandPrimary }
        if tag == "Friendly" || tag == "Good for conversations" { return .brandPurple }
        return .brandSecondary
    }
    
    // MARK: - Host Section
    private var hostSection: some View {
        VStack(alignment: .leading, spacing: AppConstants.Layout.elementSpacing) {
            Text(AppStrings.Drifts.Detail.hostHeader)
                .font(.system(size: AppConstants.Typography.sizeHeadline, weight: .bold))
                .foregroundColor(.textPrimary)
            
            Button(action: { showingHostContext = true }) {
                HStack(spacing: AppConstants.Layout.elementSpacing) {
                    ZStack(alignment: .bottomTrailing) {
                        Circle()
                            .fill(Color.brandSecondary.opacity(0.15))
                            .frame(width: 48, height: 48)
                            .overlay(
                                Text(viewModel.drift.host.initials)
                                    .font(.system(size: 14, weight: .black))
                                    .foregroundColor(.brandSecondary)
                            )
                        
                        if viewModel.drift.host.isVerified {
                            AppIcons.verifiedImage
                                .font(.system(size: 14))
                                .foregroundColor(.brandPrimary)
                                .background(Circle().fill(Color.white))
                                .offset(x: 2, y: 2)
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(viewModel.drift.host.name)
                            .font(.system(size: AppConstants.Typography.sizeBody, weight: .bold))
                            .foregroundColor(.textPrimary)
                        Text(viewModel.drift.host.role)
                            .font(.system(size: AppConstants.Typography.sizeCaption + 1, weight: .medium))
                            .foregroundColor(.textSecondary)
                    }
                    
                    Spacer()
                    
                    AppIcons.chevronRightImage
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.textSecondary)
                }
                .padding(16)
                .background(Color.surfaceMain)
                .cornerRadius(AppConstants.UI.cornerRadiusSmall + 4)
                .overlay(RoundedRectangle(cornerRadius: AppConstants.UI.cornerRadiusSmall + 4).stroke(Color.appBorder, lineWidth: 1))
            }
        }
    }
    
    // MARK: - Participants Section
    private var participantsSection: some View {
        VStack(alignment: .leading, spacing: AppConstants.Layout.elementSpacing) {
            Text(AppStrings.Drifts.Detail.participantsHeader)
                .font(.system(size: AppConstants.Typography.sizeHeadline, weight: .bold))
                .foregroundColor(.textPrimary)
            
            let isLocked = viewModel.joinStatus == .notJoined || viewModel.joinStatus == .requested
            
            HStack(spacing: AppConstants.Layout.elementSpacing) {
                if isLocked {
                    // MARK: - Locked State
                    HStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(Color.brandPrimary.opacity(0.1))
                                .frame(width: 44, height: 44)
                            AppIcons.lockImage
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.brandPrimary)
                        }
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(AppStrings.Manage.joinedCount(count: viewModel.drift.peopleGoing))
                                .font(.system(size: AppConstants.Typography.sizeCaption + 1, weight: .bold))
                                .foregroundColor(.textPrimary)
                            Text("Join to see participants")
                                .font(.system(size: AppConstants.Typography.sizeCaption, weight: .medium))
                                .foregroundColor(.textSecondary)
                        }
                    }
                    
                    Spacer()
                    
                    AppIcons.chevronRightImage
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.textSecondary.opacity(0.3))
                } else {
                    // MARK: - Open State
                    HStack(spacing: AppConstants.Layout.elementSpacing) {
                        HStack(spacing: -12) {
                            ForEach(0..<min(viewModel.drift.participantInitials.count, 3), id: \.self) { index in
                                Text(viewModel.drift.participantInitials[index])
                                    .font(.system(size: AppConstants.Typography.sizeTiny + 1, weight: .bold))
                                    .foregroundColor(.white)
                                    .frame(width: 40, height: 40)
                                    .background(Circle().fill(Color.brandPrimary))
                                    .overlay(Circle().stroke(Color.white, lineWidth: 2))
                            }
                        }
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(AppStrings.Manage.joinedCount(count: viewModel.drift.peopleGoing))
                                .font(.system(size: AppConstants.Typography.sizeCaption + 1, weight: .bold))
                                .foregroundColor(.textPrimary)
                            Text(AppStrings.Manage.capacity(count: viewModel.drift.capacity))
                                .font(.system(size: AppConstants.Typography.sizeCaption, weight: .medium))
                                .foregroundColor(.textSecondary)
                        }
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        showingWhoIsComing = true
                    }
                    
                    Spacer()
                    
                    Button(AppStrings.Drifts.seeAll) {
                        showingWhoIsComing = true
                    }
                    .font(.system(size: AppConstants.Typography.sizeCaption + 1, weight: .bold))
                    .foregroundColor(.brandPrimary)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.brandPrimary.opacity(AppConstants.UI.opacityLight))
                    .cornerRadius(12)
                }
            }
            .padding(16)
            .background(Color.surfaceMain)
            .cornerRadius(AppConstants.UI.cornerRadiusSmall + 4)
            .overlay(RoundedRectangle(cornerRadius: AppConstants.UI.cornerRadiusSmall + 4).stroke(Color.appBorder, lineWidth: 1))
        }
    }
    
    // MARK: - Details List Section
    private var detailsListSection: some View {
        VStack(alignment: .leading, spacing: AppConstants.Layout.elementSpacing + 4) {
            Text(AppStrings.Drifts.Detail.detailsHeader)
                .font(.system(size: AppConstants.Typography.sizeHeadline, weight: .bold))
                .foregroundColor(.textPrimary)
            
            VStack(spacing: 0) {
                detailRow(icon: AppIcons.clockFill, label: AppStrings.Drifts.Detail.timeLabel, value: "\(viewModel.drift.time) – \(viewModel.drift.endTime)")
                
                // Meeting Point - Restricted until joined
                let isLocked = viewModel.joinStatus == .notJoined || viewModel.joinStatus == .requested
                detailRow(
                    icon: AppIcons.map,
                    label: AppStrings.Drifts.Detail.meetingPointLabel,
                    value: isLocked ? "Join to see exact location" : viewModel.drift.meetingPoint,
                    hasChevron: !isLocked,
                    isLocked: isLocked
                )
                
                detailRow(icon: AppIcons.briefcase, label: AppStrings.Drifts.Detail.bringLabel, value: viewModel.drift.whatToBring.joined(separator: ", "))
                detailRow(icon: AppIcons.sparkles, label: AppStrings.Drifts.Detail.vibeLabel, value: viewModel.drift.vibeTags.joined(separator: " • "))
                detailRow(icon: AppIcons.notes, label: AppStrings.Drifts.Detail.notesLabel, value: viewModel.drift.notes ?? "No extra notes.", isLast: true)
            }
            .padding(16)
            .background(Color.surfaceMain)
            .cornerRadius(AppConstants.UI.cornerRadiusMedium)
            .overlay(RoundedRectangle(cornerRadius: AppConstants.UI.cornerRadiusMedium).stroke(Color.appBorder, lineWidth: 1))
        }
    }
    
    private func detailRow(icon: String, label: String, value: String, hasChevron: Bool = false, isLast: Bool = false, isLocked: Bool = false) -> some View {
        VStack(spacing: 0) {
            HStack(alignment: .top, spacing: AppConstants.Layout.elementSpacing) {
                Image(systemName: isLocked ? AppIcons.lock : icon)
                    .font(.system(size: 18))
                    .foregroundColor(isLocked ? .textSecondary : .brandPrimary)
                    .frame(width: 24)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(label)
                        .font(.system(size: AppConstants.Typography.sizeCaption, weight: .medium))
                        .foregroundColor(.textSecondary)
                    
                    Text(value)
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(isLocked ? .textSecondary : .textPrimary)
                        .blur(radius: isLocked ? 4 : 0)
                }
                
                Spacer()
                
                if hasChevron {
                    AppIcons.chevronRightImage
                        .font(.system(size: AppConstants.Typography.sizeTiny + 1, weight: .bold))
                        .foregroundColor(.textSecondary)
                        .padding(.top, AppConstants.Layout.elementSpacing)
                }
            }
            .padding(.vertical, 16)
            
            if !isLast {
                Divider()
            }
        }
    }
    
    // MARK: - Safety Banner
    private var safetyBanner: some View {
        VStack(spacing: AppConstants.Layout.elementSpacing) {
            HStack {
                AppIcons.shieldImage
                    .font(.system(size: AppConstants.Typography.sizeHeadline))
                    .foregroundColor(.brandPurple)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(AppStrings.Drifts.Detail.safetyTitle)
                        .font(.system(size: AppConstants.Typography.sizeBody - 1, weight: .bold))
                        .foregroundColor(.textPrimary)
                    Text(AppStrings.Drifts.Detail.safetySubtitle)
                        .font(.system(size: AppConstants.Typography.sizeCaption, weight: .medium))
                        .foregroundColor(.textSecondary)
                }
                
                Spacer()
                
                AppIcons.chevronRightImage
                    .font(.system(size: AppConstants.Typography.sizeCaption + 1, weight: .bold))
                    .foregroundColor(.brandPurple)
            }
            .padding(20)
            .background(Color.brandPurple.opacity(AppConstants.UI.opacitySubtle))
            .cornerRadius(AppConstants.UI.cornerRadiusSmall + 4)
            
            HStack(spacing: 8) {
                AppIcons.lockImage
                    .font(.system(size: AppConstants.Typography.sizeTiny + 1))
                Text(AppStrings.Drifts.Detail.coordinationNote)
                    .font(.system(size: AppConstants.Typography.sizeTiny + 1, weight: .medium))
            }
            .foregroundColor(.textSecondary)
        }
    }
    
    // MARK: - Sticky CTA Footer
    private var stickyCTAFooter: some View {
        VStack(spacing: 0) {
            Divider().opacity(0.1)
            
            HStack {
                if viewModel.joinStatus == .joined {
                    NavigationLink(destination: DriftChatScreen(viewModel: DriftChatViewModel(drift: viewModel.drift))) {
                        ctaButtonContent
                    }
                    .buttonStyle(.plain)
                } else {
                    Button(action: {
                        if viewModel.joinStatus == .notJoined {
                            viewModel.requestToJoin()
                        }
                    }) {
                        ctaButtonContent
                    }
                }
            }
            .padding(.horizontal, AppConstants.Layout.standardPadding)
            .padding(.vertical, 12)
        }
        .background(
            Rectangle()
                .fill(.ultraThinMaterial)
                .ignoresSafeArea(edges: .bottom)
        )
    }
    
    private var ctaButtonContent: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(Color.white.opacity(0.2))
                .frame(width: 48, height: 48)
                .overlay(
                    Image(systemName: ctaIcon)
                        .font(.system(size: AppConstants.Typography.sizeTitle, weight: .bold))
                        .foregroundColor(.white)
                )
            
            VStack(alignment: .leading, spacing: 2) {
                Text(ctaTitle)
                    .font(.system(size: AppConstants.Typography.sizeTitle, weight: .black))
                Text(ctaSubtitle)
                    .font(.system(size: AppConstants.Typography.sizeCaption, weight: .medium))
                    .opacity(0.9)
            }
            .foregroundColor(.white)
            
            Spacer()
            
            AppIcons.chevronRightImage
                .font(.system(size: AppConstants.Typography.sizeTitle, weight: .bold))
                .foregroundColor(.white.opacity(0.6))
        }
        .padding(.horizontal, 16)
        .frame(maxWidth: .infinity)
        .frame(height: 80)
        .background(ctaColor)
        .cornerRadius(AppConstants.UI.cornerRadiusMedium)
        .shadow(color: ctaColor.opacity(0.3), radius: AppConstants.UI.shadowRadius, x: 0, y: AppConstants.UI.shadowY)
    }
    
    // MARK: - Computed Properties for CTA
    
    // MARK: - Computed CTA Props
    private var ctaTitle: String {
        switch viewModel.joinStatus {
        case .notJoined: return AppStrings.Drifts.Detail.CTA.join
        case .requested: return AppStrings.Drifts.Detail.CTA.requested
        case .joined: return AppStrings.Drifts.Detail.CTA.joined
        case .full: return AppStrings.Drifts.Detail.CTA.full
        case .ended: return AppStrings.Drifts.Detail.CTA.ended
        }
    }
    
    private var ctaSubtitle: String {
        switch viewModel.joinStatus {
        case .notJoined: return AppStrings.Drifts.Detail.CTA.joinSubtitle
        case .requested: return AppStrings.Drifts.Detail.CTA.requestedSubtitle
        case .joined: return AppStrings.Drifts.Detail.CTA.joinedSubtitle
        case .full: return AppStrings.Drifts.Detail.CTA.fullSubtitle
        case .ended: return AppStrings.Drifts.Detail.CTA.endedSubtitle
        }
    }
    
    private var ctaIcon: String {
        switch viewModel.joinStatus {
        case .notJoined: return AppIcons.participants
        case .requested: return AppIcons.clockFill
        case .joined: return AppIcons.chatGroup
        case .full: return AppIcons.lock
        case .ended: return AppIcons.checkCircleFill
        }
    }
    
    private var ctaColor: Color {
        switch viewModel.joinStatus {
        case .notJoined: return .brandPrimary
        case .requested: return .brandPurple
        case .joined: return .brandPrimary
        case .full, .ended: return .textSecondary
        }
    }
}

struct DriftDetailScreen_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            DriftDetailScreen(viewModel: DriftDetailViewModel(drift: Drift(
                title: "Coffee Drift",
                description: "Spontaneous coffee meetup at a nice local cafe. Open to anyone who wants to chat and meet new people in the area.",
                location: "Panampilly Nagar, Kochi",
                meetingPoint: "Near the Main Entrance",
                time: "6:30 PM",
                endTime: "7:30 PM",
                date: "Today",
                distance: 1.2,
                status: .open,
                category: .coffee,
                hook: "Coffee on me ☕\nFirst round's on me!",
                host: Host(name: "Arjun", role: "Hosting this Drift", imageUrl: "host_arjun", isVerified: true),
                peopleGoing: 3,
                spotsLeft: 2,
                capacity: 5,
                vibeTags: ["Casual", "Friendly"],
                whatToBring: ["Good mood"],
                notes: "Just a quick chat.",
                participantInitials: ["AL", "RI", "MA"],
                imageUrl: "drift_coffee"
            )))
        }
    }
}


// MARK: - Host Context Card Bottom Sheet (ISSUE-013)
struct HostContextCardSheet: View {
    let host: Host
    var onSelectDrift: (Drift) -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            // Soft drag handle line at the top
            Capsule()
                .fill(Color.appBorder)
                .frame(width: AppConstants.Layout.sheetHandleWidth, height: 5)
                .padding(.top, AppConstants.Layout.sheetHandleTopPadding)
                .padding(.bottom, AppConstants.Layout.sheetHandleBottomPadding)
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: AppConstants.Layout.sectionSpacing) {
                    // 1. Identity Header
                    HStack(spacing: 16) {
                        // Circular avatar with soft peach background
                        ZStack {
                            Circle()
                                .fill(Color.brandSecondary.opacity(0.15))
                                .frame(width: 72, height: 72)
                            
                            Text(host.initials)
                                .font(.heading2)
                                .foregroundColor(.brandSecondary)
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            HStack(spacing: 6) {
                                Text(host.name)
                                    .font(.heading2)
                                    .foregroundColor(.textPrimary)
                                
                                if host.verified {
                                    AppIcons.verifiedImage
                                        .font(.system(size: 20))
                                        .foregroundColor(.brandPrimary)
                                }
                            }
                            
                            Text(host.role)
                                .font(.bodySmall)
                                .foregroundColor(.textSecondary)
                        }
                        
                        Spacer()
                    }
                    
                    // 2. Trust Stats 2x2 Grid
                    LazyVGrid(columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)], spacing: 12) {
                        // Hosted
                        statTile(icon: AppIcons.person, color: .brandPrimary, count: "\(host.hostedCount)", label: "Hosted")
                        
                        // Joined
                        statTile(icon: AppIcons.participants, color: .brandSecondary, count: "\(host.joinedCount)", label: "Joined")
                        
                        // Completed
                        statTile(icon: AppIcons.checkCircleFill, color: .brandPrimary, count: "\(host.completedCount)", label: "Completed")
                        
                        // Active since
                        activeSinceTile(icon: AppIcons.calendar, color: .brandPurple, year: "April 2026")
                    }
                    
                    // 3. Interest tags capsule row
                    HStack(spacing: 8) {
                        ForEach(host.interests, id: \.self) { interest in
                            interestCapsule(interest: interest)
                        }
                    }
                    
                    // 4. Other plans section
                    VStack(alignment: .leading, spacing: 14) {
                        Text("Other plans by \(host.name.components(separatedBy: " ").first ?? host.name)")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.textPrimary)
                        
                        if host.otherActiveDrifts.isEmpty {
                            Text("No other upcoming plans.")
                                .font(.bodyStandard)
                                .foregroundColor(.textSecondary)
                                .padding(.vertical, 8)
                        } else {
                            VStack(spacing: 12) {
                                ForEach(host.otherActiveDrifts) { drift in
                                    Button(action: {
                                        onSelectDrift(drift)
                                    }) {
                                        upcomingDriftRow(drift: drift)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                    }
                    
                    // 5. Past completed plans
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Past completed plans")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.textPrimary)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(0..<host.pastDrifts.count, id: \.self) { index in
                                    pastCompletedCard(title: host.pastDrifts[index], index: index)
                                }
                            }
                            .padding(.vertical, 2)
                        }
                    }
                }
                .padding(.horizontal, AppConstants.Layout.standardPadding)
                .padding(.bottom, AppConstants.Layout.screenBottomSpacer)
            }
        }
        .background(Color.surfaceMain.ignoresSafeArea())
    }
    
    // MARK: - Trust Grid Stat Tile
    private func statTile(icon: String, color: Color, count: String, label: String) -> some View {
        HStack(spacing: 10) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.12))
                    .frame(width: 38, height: 38)
                
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(color)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(count)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.textPrimary)
                
                Text(label)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.textSecondary)
            }
            
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .frame(maxWidth: .infinity)
        .background(Color.surfaceMain)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.appBorder, lineWidth: 1)
        )
    }
    
    // MARK: - Trust Grid Active Since Tile
    private func activeSinceTile(icon: String, color: Color, year: String) -> some View {
        HStack(spacing: 10) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.12))
                    .frame(width: 38, height: 38)
                
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(color)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text("Active since")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.textSecondary)
                
                Text(year)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(.textPrimary)
            }
            
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .frame(maxWidth: .infinity)
        .background(Color.surfaceMain)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.appBorder, lineWidth: 1)
        )
    }
    
    // MARK: - Interest Capsules
    private func interestCapsule(interest: String) -> some View {
        let (bgColor, fgColor, iconName) = interestCapsuleDetails(for: interest)
        return HStack(spacing: 6) {
            Image(systemName: iconName)
                .font(.system(size: 12, weight: .bold))
            Text(interest)
                .font(.system(size: 12, weight: .bold))
        }
        .foregroundColor(fgColor)
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .background(bgColor)
        .clipShape(Capsule())
    }
    
    private func interestCapsuleDetails(for interest: String) -> (Color, Color, String) {
        switch interest.lowercased() {
        case "walks", "walk":
            return (Color.brandPrimary.opacity(0.1), Color.brandPrimary, AppIcons.walk)
        case "coffee":
            return (Color.brandSecondary.opacity(0.12), Color.brandSecondary, AppIcons.coffee)
        case "movies", "movie":
            return (Color.brandPurple.opacity(0.12), Color.brandPurple, AppIcons.movie)
        default:
            return (Color.brandPrimary.opacity(0.1), Color.brandPrimary, AppIcons.sparkles)
        }
    }
    
    // MARK: - Upcoming Drift Row
    private func upcomingDriftRow(drift: Drift) -> some View {
        HStack(spacing: 12) {
            // Thumbnail image with rounded corners
            Image(drift.category == .walk ? "drift_walk" : "drift_coffee")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 80, height: 60)
                .cornerRadius(12)
                .clipped()
            
            VStack(alignment: .leading, spacing: 4) {
                Text(drift.title)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.textPrimary)
                    .lineLimit(1)
                
                HStack(spacing: 8) {
                    HStack(spacing: 3) {
                        AppIcons.calendarImage
                            .font(.system(size: 10))
                        Text(drift.date)
                            .font(.system(size: 11, weight: .medium))
                    }
                    
                    Text("•")
                        .font(.system(size: 11))
                    
                    HStack(spacing: 3) {
                        AppIcons.clockImage
                            .font(.system(size: 10))
                        Text(drift.time)
                            .font(.system(size: 11, weight: .medium))
                    }
                }
                .foregroundColor(.textSecondary)
                
                // Category Tag
                HStack(spacing: 4) {
                    Image(systemName: drift.category.icon)
                        .font(.system(size: 9, weight: .bold))
                    Text(drift.category == .walk ? "Outdoors" : "Foodie")
                        .font(.system(size: 9, weight: .bold))
                }
                .foregroundColor(drift.category.color)
                .padding(.horizontal, 8)
                .padding(.vertical, 3)
                .background(drift.category.color.opacity(0.12))
                .clipShape(Capsule())
            }
            
            Spacer()
            
            AppIcons.chevronRightImage
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(.textSecondary.opacity(0.4))
        }
        .padding(12)
        .background(Color.surfaceMain)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.appBorder, lineWidth: 1)
        )
    }
    
    // MARK: - Past Completed Card
    private var pastImages: [String] {
        ["drift_walk", "drift_dinner", "drift_movie"] // Fallbacks
    }
    
    private func pastCompletedCard(title: String, index: Int) -> some View {
        let fallbackImage = pastImages[index % pastImages.count]
        
        return VStack(alignment: .leading, spacing: 8) {
            ZStack(alignment: .topLeading) {
                Image(fallbackImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 120, height: 80)
                    .cornerRadius(12)
                    .clipped()
                
                // Completed grey badge overlay
                Text("Completed")
                    .font(.system(size: 9, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.textSecondary.opacity(0.85))
                    .cornerRadius(8)
                    .padding(6)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.textPrimary)
                    .lineLimit(1)
                
                Text(index == 0 ? "Apr 20" : (index == 1 ? "Apr 12" : "Apr 5"))
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(.textSecondary)
            }
        }
        .padding(8)
        .frame(width: 136)
        .background(Color.surfaceMain)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.appBorder, lineWidth: 1)
        )
    }
}

// MARK: - Who's Coming Participant Sheet (ISSUE-014)
struct WhoIsComingSheet: View {
    let participants: [ParticipantDetail]
    
    var body: some View {
        VStack(spacing: 0) {
            // Soft drag handle line at the top
            Capsule()
                .fill(Color.appBorder)
                .frame(width: AppConstants.Layout.sheetHandleWidth, height: 5)
                .padding(.top, AppConstants.Layout.sheetHandleTopPadding)
                .padding(.bottom, AppConstants.Layout.sheetHandleBottomPadding)
            
            // Header Block
            VStack(spacing: AppConstants.Layout.subElementSpacing) {
                HStack(spacing: 8) {
                    Text("Who's Coming")
                        .font(.heading2)
                        .foregroundColor(.textPrimary)
                    
                    // Badge Count
                    Text("\(participants.count)")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.brandPrimary)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(Color.brandPrimary.opacity(0.15))
                        .clipShape(Capsule())
                }
                
                Text("Precise meeting coordinate is unlocked")
                    .font(.bodyStandard)
                    .foregroundColor(.textSecondary)
            }
            .padding(.bottom, AppConstants.Layout.sectionSpacing)
            
            // Scrollable List
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: AppConstants.Layout.elementSpacing) {
                    ForEach(participants) { participant in
                        HStack(spacing: AppConstants.Layout.elementSpacing) {
                            // Leading: Initials Avatar
                            let brandColor = avatarColor(for: participant.initials)
                            ZStack {
                                Circle()
                                    .fill(brandColor.opacity(0.15))
                                    .frame(width: 44, height: 44)
                                
                                Text(participant.initials)
                                    .font(.system(size: 14, weight: .black))
                                    .foregroundColor(brandColor)
                            }
                            
                            // Center: First name and initial, join time
                            VStack(alignment: .leading, spacing: 2) {
                                Text(participant.name)
                                    .font(.bodyStandard)
                                    .foregroundColor(.textPrimary)
                                
                                Text(participant.joinTimeDescription)
                                    .font(.metadata)
                                    .foregroundColor(.textSecondary)
                            }
                            
                            Spacer()
                            
                            // Trailing: Interest icons
                            HStack(spacing: 8) {
                                ForEach(participant.interests, id: \.self) { interest in
                                    interestIcon(for: interest)
                                        .font(.system(size: 18))
                                        .foregroundColor(interestIconColor(for: interest))
                                }
                            }
                        }
                        .padding(16)
                        .background(Color.surfaceMain)
                        .cornerRadius(AppConstants.UI.cornerRadiusSmall + 4)
                        .overlay(
                            RoundedRectangle(cornerRadius: AppConstants.UI.cornerRadiusSmall + 4)
                                .stroke(Color.appBorder, lineWidth: 1)
                        )
                    }
                }
                .padding(.horizontal, AppConstants.Layout.standardPadding)
                .padding(.bottom, AppConstants.Layout.screenBottomSpacer)
            }
        }
        .background(Color.surfaceMain.ignoresSafeArea())
    }
    
    // Helpers
    private func avatarColor(for initials: String) -> Color {
        if initials == "LJ" || initials == "DG" {
            return Color.brandPrimary
        } else if initials == "MM" {
            return Color.brandPurple
        } else if initials == "SJ" {
            return Color.brandSecondary
        } else {
            return Color.brandPrimary
        }
    }
    
    private func interestIcon(for interest: String) -> Image {
        switch interest.lowercased() {
        case "walks", "walk":
            return AppIcons.walkImage
        case "coffee":
            return AppIcons.coffeeImage
        case "movies", "movie":
            return AppIcons.movieImage
        case "music":
            return Image(systemName: "music.note")
        default:
            return AppIcons.sparklesImage
        }
    }
    
    private func interestIconColor(for interest: String) -> Color {
        switch interest.lowercased() {
        case "walks", "walk":
            return Color.brandPrimary
        case "coffee":
            return Color.brandSecondary
        case "movies", "movie", "music":
            return Color.brandPurple
        default:
            return Color.brandPrimary
        }
    }
}
