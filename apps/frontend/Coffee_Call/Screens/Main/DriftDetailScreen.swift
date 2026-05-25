import SwiftUI

struct DriftDetailScreen: View {
    @Environment(\.dismiss) var dismiss
    @StateObject var viewModel: DriftDetailViewModel
    @StateObject private var navManager = NavigationManager.shared
    @EnvironmentObject private var driftStore: GlobalDriftStore
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
                .padding(.top, AppConstants.Layout.elementSpacing)

            VStack(alignment: .leading, spacing: AppConstants.Layout.sectionSpacing) {
                // About Section
                aboutSection

                // Map Section
                mapSection

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
                HStack(spacing: AppConstants.Layout.subElementSpacing) {
                    CoffeeHeaderButton(icon: AppIcons.share) { viewModel.shareDrift() }
                    CoffeeHeaderButton(icon: viewModel.isBookmarked ? AppIcons.bookmarkFill : AppIcons.bookmark, color: viewModel.isBookmarked ? .brandPrimary : .textPrimary) { viewModel.saveDrift() }
                    CoffeeHeaderButton(icon: viewModel.isReminderSet ? AppIcons.bellFill : AppIcons.bell, color: viewModel.isReminderSet ? .brandPrimary : .textPrimary) { viewModel.setReminder() }
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
        .sheet(isPresented: $viewModel.showingRequestSentConfirmation) {
            RequestSentConfirmationSheet(drift: viewModel.drift)
                .presentationDetents([.height(AppConstants.Layout.confirmationSheetHeight)])
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
        .onReceive(driftStore.$drifts) { drifts in
            if let updated = drifts.first(where: { $0.id == viewModel.drift.id }) {
                // Keep drift up to date
                viewModel.drift = updated

                // If we were waiting for approval and are now in the participants list, upgrade status!
                if viewModel.joinStatus == .requested {
                    let userInitials = UserDefaults.standard.string(forKey: "profile_initials") ?? AppConstants.MockData.userInitials
                    if updated.participantInitials.contains(userInitials) {
                        viewModel.joinStatus = .joined
                    }
                }
            }
        }
        .alert("Add to Calendar?", isPresented: $viewModel.showCalendarAddConfirmation) {
            Button("Add", role: .none) {
                viewModel.confirmAddReminderToCalendar()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This will schedule '\(viewModel.drift.title)' in your Apple Calendar.")
        }
        .alert("Remove from Calendar", isPresented: $viewModel.showCalendarUntapDisclaimer) {
            Button("Close", role: .cancel) {}
        } message: {
            Text("This Drift is already scheduled in your Apple Calendar. To remove it, please delete the event manually from the Calendar app.")
        }
    }


    // MARK: - Hero Content
    private var heroSection: some View {
        HStack(alignment: .top, spacing: AppConstants.Layout.standardPadding) {
            VStack(alignment: .leading, spacing: AppConstants.Layout.elementSpacing) {
                HStack(spacing: AppConstants.Layout.subElementSpacing) {
                    // Status Badge
                    HStack(spacing: AppConstants.Layout.miniPadding) {
                        Circle().fill(viewModel.drift.status.color).frame(width: AppConstants.Layout.miniPadding + 2, height: AppConstants.Layout.miniPadding + 2)
                        Text(viewModel.drift.status.rawValue)
                    }
                    .font(.system(size: AppConstants.Typography.sizeMicro + 2, weight: .bold))
                    .foregroundColor(viewModel.drift.status.color)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(viewModel.drift.status.color.opacity(AppConstants.UI.opacityLight))
                    .cornerRadius(AppConstants.UI.cornerRadiusMedium)
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
                .frame(width: AppConstants.Layout.cardGalleryWidth, height: AppConstants.Layout.cardGalleryWidth)
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
            Divider().frame(height: AppConstants.Layout.mapGridStep).padding(.horizontal, AppConstants.Layout.miniPadding + 6)
            summaryInfoItem(icon: AppIcons.location, title: viewModel.drift.location.split(separator: ",").first?.trimmingCharacters(in: .whitespaces) ?? "", subtitle: viewModel.drift.location.split(separator: ",").last?.trimmingCharacters(in: .whitespaces) ?? "")
            Divider().frame(height: AppConstants.Layout.mapGridStep).padding(.horizontal, AppConstants.Layout.miniPadding + 6)
            summaryInfoItem(icon: AppIcons.mappin, title: String(format: "%.1f km", viewModel.drift.distance), subtitle: "from you")
            Divider().frame(height: AppConstants.Layout.mapGridStep).padding(.horizontal, AppConstants.Layout.miniPadding + 6)
            summaryInfoItem(icon: AppIcons.participants, title: AppStrings.Manage.joinedCount(count: viewModel.drift.peopleGoing), subtitle: AppStrings.Manage.openTo(count: viewModel.drift.capacity))
        }
        .padding(.vertical, AppConstants.Layout.standardPadding)
        .frame(maxWidth: .infinity)
        .background(Color.surfaceMain)
        .cornerRadius(AppConstants.UI.cornerRadiusMedium)
        .overlay(RoundedRectangle(cornerRadius: AppConstants.UI.cornerRadiusMedium).stroke(Color.appBorder, lineWidth: 1))
    }

    private func summaryInfoItem(icon: String, title: String, subtitle: String) -> some View {
        VStack(spacing: AppConstants.Layout.miniPadding + 2) {
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

    // MARK: - Map Section
    private var mapSection: some View {
        DriftMapView(joinStatus: viewModel.joinStatus, location: viewModel.drift.location)
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
                            .fill(Color.brandSecondary.opacity(AppConstants.UI.opacityLight))
                            .frame(width: AppConstants.Layout.avatarSizeLarge, height: AppConstants.Layout.avatarSizeLarge)
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
                .padding(AppConstants.Layout.buttonPaddingHorizontal)
                .background(Color.surfaceMain)
                .cornerRadius(AppConstants.UI.cornerRadiusSmall + AppConstants.Layout.miniPadding)
                .overlay(RoundedRectangle(cornerRadius: AppConstants.UI.cornerRadiusSmall + AppConstants.Layout.miniPadding).stroke(Color.appBorder, lineWidth: 1))
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
                            Text(AppStrings.Manage.joinToSeeParticipants)
                                .font(.system(size: AppConstants.Typography.sizeCaption, weight: .medium))
                                .foregroundColor(.textSecondary)
                        }
                    }

                    Spacer()

                    AppIcons.chevronRightImage
                        .font(.system(size: AppConstants.Layout.elementSpacing + 2, weight: .bold))
                        .foregroundColor(.textSecondary.opacity(AppConstants.UI.opacityMuted))
                } else {
                    // MARK: - Open State
                    HStack(spacing: AppConstants.Layout.elementSpacing) {
                        HStack(spacing: -(AppConstants.Layout.elementSpacing)) {
                            ForEach(Array(viewModel.drift.participantInitials.prefix(3).enumerated()), id: \.offset) { index, initial in
                                Text(initial)
                                    .font(.system(size: AppConstants.Typography.sizeTiny + 1, weight: .bold))
                                    .foregroundColor(.white)
                                    .frame(width: AppConstants.Layout.mapGridStep, height: AppConstants.Layout.mapGridStep)
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
                    .padding(.horizontal, AppConstants.Layout.buttonPaddingHorizontal)
                    .padding(.vertical, AppConstants.Layout.buttonPaddingVertical)
                    .background(Color.brandPrimary.opacity(AppConstants.UI.opacityLight))
                    .cornerRadius(AppConstants.UI.cornerRadiusSmall)
                }
            }
            .padding(AppConstants.Layout.buttonPaddingHorizontal)
            .background(Color.surfaceMain)
            .cornerRadius(AppConstants.UI.cornerRadiusSmall + AppConstants.Layout.miniPadding)
            .overlay(RoundedRectangle(cornerRadius: AppConstants.UI.cornerRadiusSmall + AppConstants.Layout.miniPadding).stroke(Color.appBorder, lineWidth: 1))
        }
    }

    // MARK: - Details List Section
    private var detailsListSection: some View {
        VStack(alignment: .leading, spacing: AppConstants.Layout.elementSpacing + AppConstants.Layout.miniPadding) {
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
            .padding(AppConstants.Layout.buttonPaddingHorizontal)
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
                    .frame(width: AppConstants.Layout.sectionSpacing)

                VStack(alignment: .leading, spacing: AppConstants.Layout.miniPadding) {
                    Text(label)
                        .font(.system(size: AppConstants.Typography.sizeCaption, weight: .medium))
                        .foregroundColor(.textSecondary)

                    Text(value)
                        .font(.system(size: AppConstants.Typography.sizeBody, weight: .bold))
                        .foregroundColor(isLocked ? .textSecondary : .textPrimary)
                        .blur(radius: isLocked ? AppConstants.Layout.miniPadding : 0)
                }

                Spacer()

                if hasChevron {
                    AppIcons.chevronRightImage
                        .font(.system(size: AppConstants.Typography.sizeTiny + 1, weight: .bold))
                        .foregroundColor(.textSecondary)
                        .padding(.top, AppConstants.Layout.elementSpacing)
                }
            }
            .padding(.vertical, AppConstants.Layout.buttonPaddingHorizontal)

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

                VStack(alignment: .leading, spacing: AppConstants.Layout.miniPadding) {
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
            .padding(AppConstants.Layout.standardPadding)
            .background(Color.brandPurple.opacity(AppConstants.UI.opacitySubtle))
            .cornerRadius(AppConstants.UI.cornerRadiusSmall + AppConstants.Layout.miniPadding)

            HStack(spacing: AppConstants.Layout.subElementSpacing) {
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
                if viewModel.drift.isMine {
                    NavigationLink(destination: LazyView(ManageDriftScreen(viewModel: ManageDriftViewModel(drift: viewModel.drift)))) {
                        manageButtonContent
                    }
                    .buttonStyle(.plain)
                } else if viewModel.joinStatus == .joined {
                    NavigationLink(destination: LazyView(DriftChatScreen(viewModel: DriftChatViewModel(drift: viewModel.drift)))) {
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

    private var manageButtonContent: some View {
        HStack(spacing: AppConstants.Layout.elementSpacing) {
            Circle()
                .fill(Color.white.opacity(AppConstants.UI.opacityLight))
                .frame(width: AppConstants.Layout.avatarSizeLarge, height: AppConstants.Layout.avatarSizeLarge)
                .overlay(
                    Image(systemName: "slider.horizontal.3")
                        .font(.system(size: AppConstants.Typography.sizeTitle, weight: .bold))
                        .foregroundColor(.white)
                )

            VStack(alignment: .leading, spacing: 2) {
                Text(AppStrings.Manage.title)
                    .font(.system(size: AppConstants.Typography.sizeTitle, weight: .black))
                Text("Manage your drift & guest requests")
                    .font(.system(size: AppConstants.Typography.sizeCaption, weight: .medium))
                    .opacity(0.9)
            }
            .foregroundColor(.white)

            Spacer()

            AppIcons.chevronRightImage
                .font(.system(size: AppConstants.Typography.sizeTitle, weight: .bold))
                .foregroundColor(.white.opacity(0.6))
        }
        .padding(.horizontal, AppConstants.Layout.buttonPaddingHorizontal)
        .frame(maxWidth: .infinity)
        .frame(height: 80)
        .background(Color.brandPurple)
        .cornerRadius(AppConstants.UI.cornerRadiusMedium)
        .shadow(color: Color.brandPurple.opacity(AppConstants.UI.opacityMuted), radius: AppConstants.UI.shadowRadius, x: 0, y: AppConstants.UI.shadowY)
    }

    private var ctaButtonContent: some View {
        HStack(spacing: AppConstants.Layout.elementSpacing) {
            Circle()
                .fill(Color.white.opacity(AppConstants.UI.opacityLight))
                .frame(width: AppConstants.Layout.avatarSizeLarge, height: AppConstants.Layout.avatarSizeLarge)
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
        .padding(.horizontal, AppConstants.Layout.buttonPaddingHorizontal)
        .frame(maxWidth: .infinity)
        .frame(height: 80)
        .background(ctaColor)
        .cornerRadius(AppConstants.UI.cornerRadiusMedium)
        .shadow(color: ctaColor.opacity(AppConstants.UI.opacityMuted), radius: AppConstants.UI.shadowRadius, x: 0, y: AppConstants.UI.shadowY)
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
                .frame(width: AppConstants.Layout.sheetHandleWidth, height: AppConstants.Layout.sheetHandleHeight)
                .padding(.top, AppConstants.Layout.sheetHandleTopPadding)
                .padding(.bottom, AppConstants.Layout.sheetHandleBottomPadding)

            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: AppConstants.Layout.sectionSpacing) {
                    // 1. Identity Header
                    HStack(spacing: AppConstants.Layout.buttonPaddingHorizontal) {
                        // Circular avatar with soft peach background
                        ZStack {
                            Circle()
                                .fill(Color.brandSecondary.opacity(AppConstants.UI.opacityLight))
                                .frame(width: AppConstants.Layout.avatarSizeXXLarge, height: AppConstants.Layout.avatarSizeXXLarge)

                            Text(host.initials)
                                .font(.heading2)
                                .foregroundColor(.brandSecondary)
                        }

                        VStack(alignment: .leading, spacing: AppConstants.Layout.miniPadding) {
                            HStack(spacing: AppConstants.Layout.subElementSpacing - 2) {
                                Text(host.name)
                                    .font(.heading2)
                                    .foregroundColor(.textPrimary)

                                if host.verified {
                                    AppIcons.verifiedImage
                                        .font(.system(size: AppConstants.Layout.standardPadding))
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
                    LazyVGrid(columns: [GridItem(.flexible(), spacing: AppConstants.Layout.elementSpacing), GridItem(.flexible(), spacing: AppConstants.Layout.elementSpacing)], spacing: AppConstants.Layout.elementSpacing) {
                        // Hosted
                        statTile(icon: AppIcons.person, color: .brandPrimary, count: "\(host.hostedCount)", label: AppStrings.Profile.hostedLabel)

                        // Joined
                        statTile(icon: AppIcons.participants, color: .brandSecondary, count: "\(host.joinedCount)", label: AppStrings.Profile.joinedLabel)

                        // Completed
                        statTile(icon: AppIcons.checkCircleFill, color: .brandPrimary, count: "\(host.completedCount)", label: "Completed")

                        // Active since
                        activeSinceTile(icon: AppIcons.calendar, color: .brandPurple, year: "April 2026")
                    }

                    // 3. Interest tags capsule row
                    HStack(spacing: AppConstants.Layout.subElementSpacing) {
                        ForEach(host.interests, id: \.self) { interest in
                            interestCapsule(interest: interest)
                        }
                    }

                    // 4. Other plans section
                    VStack(alignment: .leading, spacing: AppConstants.Layout.elementSpacing + 2) {
                        Text(String(format: AppStrings.Manage.otherPlans, host.name.components(separatedBy: " ").first ?? host.name))
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.textPrimary)

                        if host.otherActiveDrifts.isEmpty {
                            Text(AppStrings.Manage.noOtherPlans)
                                .font(.bodyStandard)
                                .foregroundColor(.textSecondary)
                                .padding(.vertical, AppConstants.Layout.subElementSpacing)
                        } else {
                            VStack(spacing: AppConstants.Layout.elementSpacing) {
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
                    VStack(alignment: .leading, spacing: AppConstants.Layout.elementSpacing) {
                        Text(AppStrings.Manage.pastPlans)
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.textPrimary)

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: AppConstants.Layout.elementSpacing) {
                                ForEach(Array(host.pastDrifts.enumerated()), id: \.offset) { index, pastDrift in
                                    pastCompletedCard(title: pastDrift, index: index)
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
                    .fill(color.opacity(AppConstants.UI.opacityLight - 0.03))
                    .frame(width: AppConstants.Layout.avatarSizeSmall, height: AppConstants.Layout.avatarSizeSmall)

                Image(systemName: icon)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(color)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(count)
                    .font(.system(size: AppConstants.Typography.sizeTitle, weight: .bold))
                    .foregroundColor(.textPrimary)

                Text(label)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.textSecondary)
            }

            Spacer(minLength: 0)
        }
        .padding(.horizontal, AppConstants.Layout.elementSpacing)
        .padding(.vertical, 10)
        .frame(maxWidth: .infinity)
        .background(Color.surfaceMain)
        .cornerRadius(AppConstants.UI.cornerRadiusMedium - 4)
        .overlay(
            RoundedRectangle(cornerRadius: AppConstants.UI.cornerRadiusMedium - 4)
                .stroke(Color.appBorder, lineWidth: 1)
        )
    }

    // MARK: - Trust Grid Active Since Tile
    private func activeSinceTile(icon: String, color: Color, year: String) -> some View {
        HStack(spacing: 10) {
            ZStack {
                Circle()
                    .fill(color.opacity(AppConstants.UI.opacityLight - 0.03))
                    .frame(width: AppConstants.Layout.avatarSizeSmall, height: AppConstants.Layout.avatarSizeSmall)

                Image(systemName: icon)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(color)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(AppStrings.Manage.activeSince)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.textSecondary)

                Text(year)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(.textPrimary)
            }

            Spacer(minLength: 0)
        }
        .padding(.horizontal, AppConstants.Layout.elementSpacing)
        .padding(.vertical, 10)
        .frame(maxWidth: .infinity)
        .background(Color.surfaceMain)
        .cornerRadius(AppConstants.UI.cornerRadiusMedium - 4)
        .overlay(
            RoundedRectangle(cornerRadius: AppConstants.UI.cornerRadiusMedium - 4)
                .stroke(Color.appBorder, lineWidth: 1)
        )
    }

    // MARK: - Interest Capsules
    private func interestCapsule(interest: String) -> some View {
        let (bgColor, fgColor, iconName) = interestCapsuleDetails(for: interest)
        return HStack(spacing: AppConstants.Layout.subElementSpacing - 2) {
            Image(systemName: iconName)
                .font(.system(size: AppConstants.Layout.elementSpacing, weight: .bold))
            Text(interest)
                .font(.system(size: AppConstants.Layout.elementSpacing, weight: .bold))
        }
        .foregroundColor(fgColor)
        .padding(.horizontal, 14)
        .padding(.vertical, AppConstants.Layout.subElementSpacing)
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
        HStack(spacing: AppConstants.Layout.elementSpacing) {
            // Thumbnail image with rounded corners
            Image(drift.category == .walk ? "drift_walk" : "drift_coffee")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: AppConstants.Layout.cardThumbnailWidth, height: AppConstants.Layout.cardThumbnailHeight)
                .cornerRadius(AppConstants.UI.cornerRadiusSmall)
                .clipped()

            VStack(alignment: .leading, spacing: 4) {
                Text(drift.title)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.textPrimary)
                    .lineLimit(1)

                HStack(spacing: AppConstants.Layout.subElementSpacing) {
                    HStack(spacing: 3) {
                        AppIcons.calendarImage
                            .font(.system(size: AppConstants.Typography.sizeTiny))
                        Text(drift.date)
                            .font(.system(size: 11, weight: .medium))
                    }

                    Text("•")
                        .font(.system(size: 11))

                    HStack(spacing: 3) {
                        AppIcons.clockImage
                            .font(.system(size: AppConstants.Typography.sizeTiny))
                        Text(drift.time)
                            .font(.system(size: 11, weight: .medium))
                    }
                }
                .foregroundColor(.textSecondary)

                // Category Tag
                HStack(spacing: AppConstants.Layout.miniPadding) {
                    Image(systemName: drift.category.icon)
                        .font(.system(size: 9, weight: .bold))
                    Text(drift.category == .walk ? "Outdoors" : "Foodie")
                        .font(.system(size: 9, weight: .bold))
                }
                .foregroundColor(drift.category.color)
                .padding(.horizontal, AppConstants.Layout.subElementSpacing)
                .padding(.vertical, 3)
                .background(drift.category.color.opacity(0.12))
                .clipShape(Capsule())
            }

            Spacer()

            AppIcons.chevronRightImage
                .font(.system(size: AppConstants.Layout.elementSpacing, weight: .bold))
                .foregroundColor(.textSecondary.opacity(AppConstants.UI.opacityNormal))
        }
        .padding(AppConstants.Layout.elementSpacing)
        .background(Color.surfaceMain)
        .cornerRadius(AppConstants.UI.cornerRadiusMedium - 4)
        .overlay(
            RoundedRectangle(cornerRadius: AppConstants.UI.cornerRadiusMedium - 4)
                .stroke(Color.appBorder, lineWidth: 1)
        )
    }

    // MARK: - Past Completed Card
    private var pastImages: [String] {
        ["drift_walk", "drift_dinner", "drift_movie"] // Fallbacks
    }

    private func pastCompletedCard(title: String, index: Int) -> some View {
        let fallbackImage = pastImages[index % pastImages.count]

        return VStack(alignment: .leading, spacing: AppConstants.Layout.subElementSpacing) {
            ZStack(alignment: .topLeading) {
                Image(fallbackImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: AppConstants.Layout.cardGalleryWidth, height: AppConstants.Layout.cardGalleryHeight)
                    .cornerRadius(AppConstants.UI.cornerRadiusSmall)
                    .clipped()

                // Completed grey badge overlay
                Text("Completed")
                    .font(.system(size: 9, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, AppConstants.Layout.subElementSpacing)
                    .padding(.vertical, AppConstants.Layout.miniPadding)
                    .background(Color.textSecondary.opacity(AppConstants.UI.opacityOverlay))
                    .cornerRadius(AppConstants.UI.cornerRadiusSmall - 4)
                    .padding(AppConstants.Layout.cornerRadiusTiny)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: AppConstants.Layout.elementSpacing, weight: .bold))
                    .foregroundColor(.textPrimary)
                    .lineLimit(1)

                Text(index == 0 ? "Apr 20" : (index == 1 ? "Apr 12" : "Apr 5"))
                    .font(.system(size: AppConstants.Typography.sizeTiny, weight: .medium))
                    .foregroundColor(.textSecondary)
            }
        }
        .padding(AppConstants.Layout.subElementSpacing)
        .frame(width: AppConstants.Layout.cardGalleryContainerWidth)
        .background(Color.surfaceMain)
        .cornerRadius(AppConstants.UI.cornerRadiusMedium - 4)
        .overlay(
            RoundedRectangle(cornerRadius: AppConstants.UI.cornerRadiusMedium - 4)
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
                .frame(width: AppConstants.Layout.sheetHandleWidth, height: AppConstants.Layout.sheetHandleHeight)
                .padding(.top, AppConstants.Layout.sheetHandleTopPadding)
                .padding(.bottom, AppConstants.Layout.sheetHandleBottomPadding)

            // Header Block
            VStack(spacing: AppConstants.Layout.subElementSpacing) {
                HStack(spacing: AppConstants.Layout.subElementSpacing) {
                    Text(AppStrings.Manage.whoIsComing)
                        .font(.heading2)
                        .foregroundColor(.textPrimary)

                    // Badge Count
                    Text("\(participants.count)")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.brandPrimary)
                        .padding(.horizontal, 10)
                        .padding(.vertical, AppConstants.Layout.miniPadding)
                        .background(Color.brandPrimary.opacity(AppConstants.UI.opacityLight))
                        .clipShape(Capsule())
                }

                Text(AppStrings.Manage.preciseLocationNote)

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
                                    .fill(brandColor.opacity(AppConstants.UI.opacityLight))
                                    .frame(width: AppConstants.Layout.avatarSizeMedium, height: AppConstants.Layout.avatarSizeMedium)

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

// MARK: - Drift Map View (ISSUE-017)
struct DriftMapView: View {
    let joinStatus: DriftDetailViewModel.JoinStatus
    let location: String

    var body: some View {
        VStack(alignment: .leading, spacing: AppConstants.Layout.elementSpacing) {
            Text(AppStrings.Drifts.Detail.locationHeader)
                .font(.system(size: AppConstants.Typography.sizeHeadline, weight: .bold))
                .foregroundColor(.textPrimary)

            ZStack {
                // Background stylized map
                RoundedRectangle(cornerRadius: AppConstants.UI.cornerRadiusMedium)
                    .fill(Color.backgroundMain)
                    .frame(height: AppConstants.Layout.mapPreviewHeight)
                    .overlay(
                        // Stylized grid/roads placeholder
                        GeometryReader { geo in
                            Path { path in
                                let step: CGFloat = AppConstants.Layout.mapGridStep
                                for x in stride(from: 0, to: geo.size.width, by: step) {
                                    path.move(to: CGPoint(x: x, y: 0))
                                    path.addLine(to: CGPoint(x: x + AppConstants.Layout.mapGridOffset, y: geo.size.height))
                                }
                                for y in stride(from: 0, to: geo.size.height, by: step) {
                                    path.move(to: CGPoint(x: 0, y: y))
                                    path.addLine(to: CGPoint(x: geo.size.width, y: y + AppConstants.Layout.mapGridOffsetSmall))
                                }
                            }
                            .stroke(Color.appBorder.opacity(AppConstants.UI.opacityNormal), lineWidth: 1)
                        }
                    )

                if joinStatus == .joined {
                    // Precise Pin
                    VStack(spacing: AppConstants.Layout.miniPadding) {
                        AppIcons.mappinImage
                            .font(.system(size: AppConstants.Layout.mappinSize))
                            .foregroundColor(.brandPrimary)
                            .shadow(color: Color.black.opacity(AppConstants.UI.opacityLight), radius: 8, x: 0, y: 4)

                        Text(location)
                            .font(.system(size: AppConstants.Typography.sizeTiny + 1, weight: .black))
                            .padding(.horizontal, 10)
                            .padding(.vertical, AppConstants.Layout.miniPadding)
                            .background(Color.white)
                            .cornerRadius(8)
                            .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                    }
                } else {
                    // 500m radius highlight ring
                    Circle()
                        .stroke(Color.brandPrimary.opacity(AppConstants.UI.opacityMuted), lineWidth: 2)
                        .background(Circle().fill(Color.brandPrimary.opacity(AppConstants.UI.opacityLight)))
                        .frame(width: AppConstants.Layout.mapRadiusSize, height: AppConstants.Layout.mapRadiusSize)

                    VStack(spacing: AppConstants.Layout.miniPadding) {
                        Text(AppStrings.Drifts.Detail.Location.approxTitle)
                            .font(.system(size: AppConstants.Typography.sizeTiny, weight: .bold))
                            .foregroundColor(.brandPrimary)
                        Text(AppStrings.Drifts.Detail.Location.unlockedSubtitle)
                            .font(.system(size: AppConstants.Typography.sizeMicro, weight: .medium))
                            .foregroundColor(.brandPrimary.opacity(0.7))
                    }
                    .offset(y: AppConstants.Layout.mapTextOffset)
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: AppConstants.UI.cornerRadiusMedium))
            .overlay(RoundedRectangle(cornerRadius: AppConstants.UI.cornerRadiusMedium).stroke(Color.appBorder, lineWidth: 1))

            if joinStatus == .joined {
                Button(action: {
                    // Open in Apple Maps
                    let url = URL(string: "maps://?q=\(location.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")")!
                    if UIApplication.shared.canOpenURL(url) {
                        UIApplication.shared.open(url)
                    }
                }) {
                    HStack(spacing: AppConstants.Layout.subElementSpacing - 2) {
                        AppIcons.mapImage
                            .font(.system(size: 14, weight: .bold))
                        Text(AppStrings.Drifts.Detail.Location.openMaps)
                            .font(.system(size: 14, weight: .bold))
                    }
                    .foregroundColor(.brandPrimary)
                    .padding(.vertical, AppConstants.Layout.subElementSpacing)
                }
            }
        }
    }
}

// MARK: - Request Sent Confirmation Sheet (ISSUE-016)
struct RequestSentConfirmationSheet: View {
    let drift: Drift
    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack(spacing: 0) {
            // Soft drag handle line at the top
            Capsule()
                .fill(Color.appBorder)
                .frame(width: AppConstants.Layout.sheetHandleWidth, height: AppConstants.Layout.sheetHandleHeight)
                .padding(.top, AppConstants.Layout.sheetHandleTopPadding)
                .padding(.bottom, AppConstants.Layout.sheetHandleBottomPadding)

            VStack(spacing: AppConstants.Layout.sectionSpacing) {
                // Success Icon
                ZStack {
                    Circle()
                        .fill(Color.brandPrimary.opacity(AppConstants.UI.opacityLight))
                        .frame(width: AppConstants.Layout.avatarSizeXXXLarge, height: AppConstants.Layout.avatarSizeXXXLarge)

                    AppIcons.checkCircleFillImage
                        .font(.system(size: AppConstants.Layout.mapGridStep, weight: .bold))
                        .foregroundColor(.brandPrimary)
                }

                VStack(spacing: AppConstants.Layout.subElementSpacing) {
                    Text(AppStrings.Drifts.Detail.CTA.requested)
                        .font(.heading1)
                        .foregroundColor(.textPrimary)

                    Text(String(format: AppStrings.Drifts.Detail.Confirmation.sentSubtitle, drift.title, drift.host.name))
                        .font(.bodyStandard)
                        .foregroundColor(.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, AppConstants.Layout.sectionSpacing + AppConstants.Layout.subElementSpacing)
                }

                VStack(spacing: AppConstants.Layout.elementSpacing) {
                    HStack(spacing: AppConstants.Layout.subElementSpacing) {
                        AppIcons.clockFillImage
                            .font(.system(size: 14))
                        Text(AppStrings.Drifts.Detail.Confirmation.notifyNote)
                    }
                    .font(.metadata)
                    .foregroundColor(.brandPurple)
                    .padding(.horizontal, AppConstants.Layout.buttonPaddingHorizontal)
                    .padding(.vertical, AppConstants.Layout.buttonPaddingVertical)
                    .background(Color.brandPurple.opacity(AppConstants.UI.opacityLight))
                    .cornerRadius(AppConstants.UI.cornerRadiusSmall)
                }

                Spacer()

                Button(action: { dismiss() }) {
                    Text(AppStrings.Common.ok)
                        .font(.buttonText)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: AppConstants.Layout.createDriftButtonHeight)
                        .background(Color.brandPrimary)
                        .cornerRadius(AppConstants.UI.cornerRadiusMedium)
                        .shadow(color: Color.brandPrimary.opacity(AppConstants.UI.opacityMuted), radius: 8, x: 0, y: 4)
                }
                .padding(.horizontal, AppConstants.Layout.standardPadding)
                .padding(.bottom, AppConstants.Layout.standardPadding)
            }
        }
        .background(Color.surfaceMain.ignoresSafeArea())
    }
}
