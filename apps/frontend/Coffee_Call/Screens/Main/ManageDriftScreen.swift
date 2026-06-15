import SwiftUI

struct ManageDriftScreen: View {
    @State private var showDeleteConfirmation = false
    @StateObject var viewModel: ManageDriftViewModel
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject private var driftStore: GlobalDriftStore
    @StateObject private var navManager = NavigationManager.shared
    @State private var tabBarVisibilitySource = UUID().uuidString
    
    var body: some View {
        ZStack {
            VStack(spacing: AppConstants.Layout.standardPadding) {
                // MARK: - Navigation Space & Title
                HStack {
                    Text(AppStrings.Manage.title)
                        .font(.system(size: AppConstants.Typography.sizeDisplay, weight: .black))
                        .foregroundColor(.textPrimary)
                    Spacer()
                }
                .padding(.top, 20) // Tight spacing under the VStack header
                
                // MARK: - Overview Card
                driftOverviewCard
                
                // MARK: - Host Actions
                hostActionsRow
                
                // MARK: - Join Requests
                if !viewModel.drift.pendingRequests.isEmpty {
                    joinRequestsSection
                }
                
                // MARK: - Joined Participants
                joinedParticipantsSection
                
                // MARK: - Primary Action
                openChatButton
                
                // MARK: - Safety Reminder
                safetyReminderBanner
            }
            .padding(.horizontal, AppConstants.Layout.standardPadding)
            .padding(.bottom, AppConstants.Layout.screenBottomSpacer + 40)
            .asCoffeePage(
                .sub,
                title: "",
                rightView: {
                    HStack(spacing: 8) {
                        CoffeeHeaderButton(icon: AppIcons.share) { viewModel.shareDrift() }
                        CoffeeHeaderButton(icon: AppIcons.ellipsis) { }
                    }
                }
            )
            .navigationBarHidden(true)
            .onAppear {
                navManager.setTabBarHidden(true, source: tabBarVisibilitySource)
                // Ensure edit button respects editability
            }
            .onDisappear {
                navManager.setTabBarHidden(false, source: tabBarVisibilitySource)
            }
            .onChange(of: viewModel.didDelete) { didDelete in
                if didDelete {
                    dismiss()
                }
            }
            .alert(isPresented: $viewModel.showErrorAlert) {
                Alert(
                    title: Text("Error"),
                    message: Text(viewModel.errorAlertMessage),
                    dismissButton: .default(Text(AppStrings.Common.ok))
                )
            }
            .onReceive(driftStore.$drifts) { drifts in
                if let updated = drifts.first(where: { $0.id == viewModel.drift.id }) {
                    JoinRequestDebugTracer.trace(
                        "ManageDriftScreen received drift store update",
                        driftId: updated.id,
                        details: "pendingRequests=\(updated.pendingRequests.count)"
                    )
                    // Update the local view model
                    viewModel.drift = updated
                }
            }
        }
    }
    
    // MARK: - View Components
    private var driftOverviewCard: some View {
        VStack(spacing: AppConstants.Layout.elementSpacing) {
            HStack(alignment: .top, spacing: AppConstants.Layout.elementSpacing) {
                // Thumbnail
                ZStack {
                    RoundedRectangle(cornerRadius: AppConstants.UI.cornerRadiusSmall)
                        .fill(viewModel.drift.category.color.opacity(AppConstants.UI.opacityLight))
                        .frame(width: 80, height: 80)
                    
                    Image(systemName: viewModel.drift.category.icon)
                        .font(.system(size: AppConstants.Typography.sizeDisplay))
                        .foregroundColor(viewModel.drift.category.color)
                }
                
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text(viewModel.drift.title)
                            .font(.system(size: AppConstants.Typography.sizeTitle, weight: .black))
                            .foregroundColor(.textPrimary)
                        
                        Spacer()
                        
                        Text(viewModel.drift.status.rawValue)
                            .font(.system(size: AppConstants.Typography.sizeMicro, weight: .black))
                            .foregroundColor(viewModel.drift.status.color)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(viewModel.drift.status.color.opacity(AppConstants.UI.opacityLight))
                            .cornerRadius(6)
                    }
                    
                    HStack(spacing: 6) {
                        AppIcons.calendarImage
                        Text("\(viewModel.drift.date), \(viewModel.drift.time) – \(viewModel.drift.endTime)")
                    }
                    .font(.system(size: AppConstants.Typography.sizeCaption, weight: .medium))
                    .foregroundColor(.textSecondary)
                    
                    HStack(spacing: 6) {
                        AppIcons.mappinImage
                        Text(viewModel.drift.location)
                    }
                    .font(.system(size: AppConstants.Typography.sizeCaption, weight: .medium))
                    .foregroundColor(.textSecondary)
                    
                    HStack(spacing: 12) {
                        HStack(spacing: 4) {
                            AppIcons.participantsImage
                            Text(AppStrings.Manage.capacity(count: viewModel.drift.capacity))
                        }
                        Text("•")
                        Text(AppStrings.Manage.joinedCount(count: viewModel.drift.participantInitials.count))
                    }
                    .font(.system(size: AppConstants.Typography.sizeCaption, weight: .bold))
                    .foregroundColor(.textSecondary)
                }
            }
            
            if !viewModel.drift.pendingRequests.isEmpty {
                HStack {
                    AppIcons.bellFillImage
                        .foregroundColor(.brandPurple)
                    Text(AppStrings.Manage.requestsPending(count: viewModel.drift.pendingRequests.count))
                        .font(.system(size: AppConstants.Typography.sizeCaption, weight: .bold))
                        .foregroundColor(.textPrimary)
                    Spacer()
                }
                .padding(12)
                .background(Color.brandPurple.opacity(AppConstants.UI.opacitySubtle))
                .cornerRadius(12)
            }
            
            HStack(spacing: 8) {
                AppIcons.lockImage
                    .font(.system(size: AppConstants.Typography.sizeTiny))
                Text(AppStrings.Drifts.Detail.coordinationNote)
                    .font(.system(size: AppConstants.Typography.sizeTiny, weight: .medium))
                Spacer()
            }
            .foregroundColor(.textSecondary)
            .padding(.top, 4)
        }
        .padding(20)
        .background(Color.surfaceMain)
        .cornerRadius(AppConstants.UI.cornerRadiusLarge)
        .overlay(RoundedRectangle(cornerRadius: AppConstants.UI.cornerRadiusLarge).stroke(Color.appBorder, lineWidth: 1))
    }
    
    // MARK: - Action Buttons
    private var hostActionsRow: some View {
        HStack(spacing: AppConstants.Layout.elementSpacing) {
            NavigationLink(destination: EditDriftScreen(viewModel: viewModel)) {
                actionTile(icon: "pencil", label: AppStrings.Manage.edit, color: .textPrimary)
            }
            .buttonStyle(.plain)
            .disabled(!viewModel.canEdit)
            // Share button
            actionButton(icon: AppIcons.share, label: AppStrings.Manage.share, color: .textPrimary, action: viewModel.shareDrift)
            // Close button
            actionButton(icon: "pause.circle", label: AppStrings.Manage.close, color: .brandPurple, action: viewModel.closeDrift)
                .disabled(viewModel.isLoading || viewModel.drift.status == .ended)
            // Delete button triggers alert
            Button(action: { showDeleteConfirmation = true }) {
                actionTile(icon: "trash", label: AppStrings.Manage.delete, color: .statusError)
            }
            .confirmationDialog(
                AppStrings.Manage.deleteConfirmationTitle,
                isPresented: $showDeleteConfirmation,
                titleVisibility: .visible
            ) {
                Button(AppStrings.Manage.delete, role: .destructive) {
                    viewModel.deleteDrift(store: driftStore)
                }
                Button(AppStrings.Common.cancel, role: .cancel) {}
            } message: {
                Text(AppStrings.Manage.deleteConfirmationMessage)
            }
            .disabled(viewModel.isLoading)
        }
    }
    
    private func actionTile(icon: String, label: String, color: Color) -> some View {
        VStack(spacing: AppConstants.Layout.subElementSpacing) {
            Image(systemName: icon)
                .font(.system(size: AppConstants.Typography.sizeTitle))
            Text(label)
                .font(.system(size: AppConstants.Typography.sizeTiny, weight: .bold))
        }
        .foregroundColor(color)
        .frame(maxWidth: .infinity)
        .frame(height: 72)
        .background(Color.surfaceMain)
        .cornerRadius(AppConstants.UI.cornerRadiusSmall)
        .overlay(RoundedRectangle(cornerRadius: AppConstants.UI.cornerRadiusSmall).stroke(Color.appBorder, lineWidth: 1))
        .contentShape(Rectangle())
    }

    private func actionButton(icon: String, label: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            actionTile(icon: icon, label: label, color: color)
        }
    }



    // MARK: - Join Requests Section
    private var joinRequestsSection: some View {
        VStack(alignment: .leading, spacing: AppConstants.Layout.elementSpacing) {
            HStack {
                Text(AppStrings.Manage.requests)
                    .font(.system(size: AppConstants.Typography.sizeBody, weight: .black))
                Text("\(viewModel.drift.pendingRequests.count)")
                    .font(.system(size: AppConstants.Typography.sizeTiny, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(Color.brandPurple)
                    .clipShape(Capsule())
                Spacer()
            }
            
            VStack(spacing: 12) {
                ForEach(viewModel.drift.pendingRequests) { request in
                    JoinRequestRow(request: request, 
                                 onAccept: { viewModel.acceptRequest(request) },
                                 onReject: { viewModel.rejectRequest(request) })
                }
            }
        }
    }
    
    // MARK: - Joined Participants
    private var joinedParticipantsSection: some View {
        VStack(alignment: .leading, spacing: AppConstants.Layout.elementSpacing) {
            HStack {
                Text(AppStrings.Manage.participants)
                    .font(.system(size: AppConstants.Typography.sizeBody, weight: .black))
                Text("\(viewModel.drift.participantInitials.count)")
                    .font(.system(size: AppConstants.Typography.sizeCaption, weight: .bold))
                    .foregroundColor(.textSecondary)
                Spacer()
                Button(action: {}) {
                    Text(AppStrings.Drifts.seeAll)
                        .font(.system(size: AppConstants.Typography.sizeCaption, weight: .bold))
                        .foregroundColor(.brandPrimary)
                }
            }
            
            HStack(spacing: -10) {
                ForEach(Array(viewModel.drift.participantInitials.prefix(5).enumerated()), id: \.offset) { index, initial in
                    Text(initial)
                        .font(.system(size: AppConstants.Typography.sizeTiny, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 40, height: 40)
                        .background(Circle().fill(Color.brandPrimary))
                        .overlay(Circle().stroke(Color.white, lineWidth: 2))
                }
                
                if viewModel.drift.participantInitials.count > 5 {
                    Text("+\(viewModel.drift.participantInitials.count - 5)")
                        .font(.system(size: AppConstants.Typography.sizeTiny, weight: .bold))
                        .foregroundColor(.textSecondary)
                        .frame(width: 40, height: 40)
                        .background(Circle().fill(Color.surfaceSecondary))
                        .padding(.leading, 15)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 2) {
                    Text(AppStrings.Manage.joinedCount(count: viewModel.drift.participantInitials.count))
                        .font(.system(size: AppConstants.Typography.sizeCaption, weight: .bold))
                        .foregroundColor(.textPrimary)
                    Text(AppStrings.Manage.openTo(count: viewModel.drift.capacity))
                        .font(.system(size: AppConstants.Typography.sizeCaption, weight: .medium))
                        .foregroundColor(.textSecondary)
                }
            }
        }
        .padding(20)
        .background(Color.surfaceMain)
        .cornerRadius(AppConstants.UI.cornerRadiusMedium)
        .overlay(RoundedRectangle(cornerRadius: AppConstants.UI.cornerRadiusMedium).stroke(Color.appBorder, lineWidth: 1))
    }
    
    // MARK: - Open Chat Button
    private var openChatButton: some View {
        NavigationLink(destination: LazyView(DriftChatScreen(drift: viewModel.drift))) {
            HStack(spacing: AppConstants.Layout.elementSpacing) {
                ZStack {
                    Circle()
                        .fill(Color.brandPrimary.opacity(AppConstants.UI.opacityLight))
                        .frame(width: 48, height: 48)
                    AppIcons.navChatsFillImage
                        .foregroundColor(.brandPrimary)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(AppStrings.Manage.openChat)
                        .font(.system(size: AppConstants.Typography.sizeBody, weight: .black))
                        .foregroundColor(.textPrimary)
                    Text(AppStrings.Manage.chatSubtitle)
                        .font(.system(size: AppConstants.Typography.sizeCaption, weight: .medium))
                        .foregroundColor(.textSecondary)
                }
                
                Spacer()
                
                AppIcons.chevronRightImage
                    .font(.system(size: AppConstants.Typography.sizeCaption + 1, weight: .bold))
                    .foregroundColor(.textSecondary)
            }
            .padding(AppConstants.Layout.elementSpacing)
            .background(Color.surfaceMain)
            .cornerRadius(AppConstants.UI.cornerRadiusMedium)
            .overlay(RoundedRectangle(cornerRadius: AppConstants.UI.cornerRadiusMedium).stroke(Color.appBorder, lineWidth: 1))
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - Safety Banner
    private var safetyReminderBanner: some View {
        HStack(spacing: AppConstants.Layout.elementSpacing) {
            ZStack {
                Circle()
                    .fill(Color.brandPurple.opacity(AppConstants.UI.opacityLight))
                    .frame(width: 32, height: 32)
                AppIcons.verifiedImage
                    .font(.system(size: AppConstants.Typography.sizeTiny))
                    .foregroundColor(.brandPurple)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(AppStrings.Manage.reminder)
                    .font(.system(size: AppConstants.Typography.sizeTiny, weight: .black))
                    .foregroundColor(.brandPurple)
                Text(AppStrings.Manage.reminderSubtitle)
                    .font(.system(size: AppConstants.Typography.sizeCaption - 1, weight: .medium))
                    .foregroundColor(.textSecondary)
                    .lineSpacing(2)
            }
            
            Spacer()
            
            AppIcons.chevronRightImage
                .font(.system(size: AppConstants.Typography.sizeTiny + 1, weight: .bold))
                .foregroundColor(.brandPurple.opacity(AppConstants.UI.opacityNormal))
        }
        .padding(20)
        .background(Color.brandPurple.opacity(AppConstants.UI.opacitySubtle))
        .cornerRadius(AppConstants.UI.cornerRadiusMedium)
    }
}

// MARK: - Join Request Row
struct JoinRequestRow: View {
    let request: JoinRequest
    let onAccept: () -> Void
    let onReject: () -> Void
    
    var body: some View {
        HStack(alignment: .top, spacing: AppConstants.Layout.elementSpacing) {
            // Avatar
            Text(request.userInitials)
                .font(.system(size: AppConstants.Typography.sizeBody, weight: .bold))
                .foregroundColor(.textPrimary)
                .frame(width: 48, height: 48)
                .background(Circle().fill(Color.surfaceSecondary))
                .overlay(Circle().stroke(Color.appBorder, lineWidth: 1))
            
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(request.userName)
                        .font(.system(size: AppConstants.Typography.sizeBody - 1, weight: .bold))
                        .foregroundColor(.textPrimary)
                    
                    Text(request.timestamp)
                        .font(.system(size: AppConstants.Typography.sizeTiny))
                        .foregroundColor(.textSecondary)
                }
                
                Text(request.userRole)
                    .font(.system(size: AppConstants.Typography.sizeCaption, weight: .medium))
                    .foregroundColor(.textSecondary)
                    .lineLimit(2)
            }
            
            Spacer()
            
            HStack(spacing: AppConstants.Layout.subElementSpacing) {
                Button(action: onAccept) {
                    AppIcons.checkmarkImage
                        .font(.system(size: AppConstants.Typography.sizeCaption + 1, weight: .bold))
                        .foregroundColor(.brandPrimary)
                        .frame(width: 36, height: 36)
                        .background(Color.brandPrimary.opacity(AppConstants.UI.opacityLight))
                        .clipShape(Circle())
                }
                
                Button(action: onReject) {
                    AppIcons.closeImage
                        .font(.system(size: AppConstants.Typography.sizeCaption + 1, weight: .bold))
                        .foregroundColor(.statusError)
                        .frame(width: 36, height: 36)
                        .background(Color.statusError.opacity(AppConstants.UI.opacityLight))
                        .clipShape(Circle())
                }
            }
        }
        .padding(AppConstants.Layout.elementSpacing)
        .background(Color.surfaceMain)
        .cornerRadius(AppConstants.UI.cornerRadiusSmall)
        .overlay(RoundedRectangle(cornerRadius: AppConstants.UI.cornerRadiusSmall).stroke(Color.appBorder, lineWidth: 1))
    }
}

struct ManageDriftScreen_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            ManageDriftScreen(viewModel: ManageDriftViewModel(drift: Drift(
                title: "Coffee Drift",
                description: "Spontaneous coffee meetup at a nice local cafe.",
                location: "Panampilly Nagar, Kochi",
                meetingPoint: "Near the Main Entrance",
                time: "6:30 PM",
                endTime: "7:30 PM",
                date: "Today",
                distance: 1.2,
                status: .open,
                category: .coffee,
                hook: nil,
                host: Host(name: "Arjun", role: "Hosting", imageUrl: nil, isVerified: true),
                peopleGoing: 3,
                spotsLeft: 2,
                capacity: 5,
                vibeTags: ["Casual"],
                whatToBring: ["Good mood"],
                notes: nil,
                participantInitials: ["AL", "RI", "MA"],
                imageUrl: "drift_coffee",
                isMine: true
            )))
        }
        .environmentObject(GlobalDriftStore(driftsService: PreviewDriftsService()))
    }
}
