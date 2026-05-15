import SwiftUI

struct DriftDetailScreen: View {
    @Environment(\.dismiss) var dismiss
    @StateObject var viewModel: DriftDetailViewModel
    @StateObject private var navManager = NavigationManager.shared
    
    var body: some View {
        VStack(spacing: 0) {
            SubPageHeader {
                SubHeaderButton(icon: AppIcons.share) { viewModel.shareDrift() }
                SubHeaderButton(icon: AppIcons.bookmark) { viewModel.saveDrift() }
                SubHeaderButton(icon: "bell.badge.fill", color: .brandPrimary) { viewModel.setReminder() }
            }
            
            ScrollView(showsIndicators: false) {
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
                    
                    Spacer(minLength: AppConstants.Layout.screenBottomSpacer + 100)
                }
            }
            
            // Sticky CTA Footer is still managed locally if needed, 
            // but we can also put it in the VStack if it shd be fixed
            stickyCTAFooter
        }
        .background(Color.backgroundMain.ignoresSafeArea())
        .navigationBarHidden(true)
        .onAppear {
            navManager.isTabBarHidden = true
        }
        .onDisappear {
            navManager.isTabBarHidden = false
        }
    }
    
    
    // MARK: - Hero Content
    private var heroSection: some View {
        HStack(alignment: .top, spacing: 20) {
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 8) {
                    // Category Badge
                    HStack(spacing: 4) {
                        Image(systemName: viewModel.drift.category.icon)
                        Text(viewModel.drift.category.rawValue.capitalized)
                    }
                    .font(.system(size: AppConstants.Typography.sizeMicro + 2, weight: .bold))
                    .foregroundColor(.brandPrimary)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Color.brandPrimary.opacity(AppConstants.UI.opacityLight))
                    .cornerRadius(20)
                    
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
                
                Text(viewModel.drift.title)
                    .font(.system(size: AppConstants.Typography.sizeDisplay, weight: .black))
                    .foregroundColor(.textPrimary)
                    .lineLimit(2)
                
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
            
            Button(action: {}) {
                HStack(spacing: AppConstants.Layout.elementSpacing) {
                    ZStack(alignment: .bottomTrailing) {
                        Circle()
                            .fill(Color.appBorder)
                            .frame(width: 48, height: 48)
                            .overlay(
                                Image(systemName: AppIcons.person)
                                    .foregroundColor(.white)
                            )
                        
                        if viewModel.drift.host.isVerified {
                            Image(systemName: AppIcons.verified)
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
                    
                    Image(systemName: AppIcons.chevronRight)
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
                
                Spacer()
                
                Button(AppStrings.Drifts.seeAll) { }
                    .font(.system(size: AppConstants.Typography.sizeCaption + 1, weight: .bold))
                    .foregroundColor(.brandPrimary)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.brandPrimary.opacity(AppConstants.UI.opacityLight))
                    .cornerRadius(12)
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
                    Image(systemName: AppIcons.chevronRight)
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
                Image(systemName: AppIcons.shield)
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
                
                Image(systemName: AppIcons.chevronRight)
                    .font(.system(size: AppConstants.Typography.sizeCaption + 1, weight: .bold))
                    .foregroundColor(.brandPurple)
            }
            .padding(20)
            .background(Color.brandPurple.opacity(AppConstants.UI.opacitySubtle))
            .cornerRadius(AppConstants.UI.cornerRadiusSmall + 4)
            
            HStack(spacing: 8) {
                Image(systemName: AppIcons.lock)
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
            Divider()
            
            HStack {
                if viewModel.joinStatus == .joined {
                    NavigationLink(destination: DriftChatScreen(viewModel: DriftChatViewModel(drift: viewModel.drift))) {
                        ctaButtonContent
                    }
                    .buttonStyle(.plain)
                } else {
                    Button(action: {
                        if viewModel.joinStatus == .notJoined {
                            viewModel.joinDrift()
                        }
                    }) {
                        ctaButtonContent
                    }
                }
            }
            .padding(AppConstants.Layout.standardPadding)
            .background(Color.surfaceMain)
        }
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
            
            Image(systemName: AppIcons.chevronRight)
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
