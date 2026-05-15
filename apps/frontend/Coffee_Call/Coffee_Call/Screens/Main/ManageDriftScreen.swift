import SwiftUI

struct ManageDriftScreen: View {
    @StateObject var viewModel: ManageDriftViewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // MARK: - Header & Overview Card
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
            .padding(.horizontal, 24)
            .padding(.top, 20)
            .padding(.bottom, 40)
        }
        .background(Color.backgroundMain.ignoresSafeArea())
        .navigationTitle(AppStrings.Manage.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {}) {
                    Image(systemName: "ellipsis")
                        .foregroundColor(.textPrimary)
                }
            }
        }
    }
    
    // MARK: - Overview Card
    private var driftOverviewCard: some View {
        VStack(spacing: 16) {
            HStack(alignment: .top, spacing: 16) {
                // Thumbnail
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(viewModel.drift.category.color.opacity(0.1))
                        .frame(width: 80, height: 80)
                    
                    Image(systemName: viewModel.drift.category.icon)
                        .font(.system(size: 32))
                        .foregroundColor(viewModel.drift.category.color)
                }
                
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text(viewModel.drift.title)
                            .font(.system(size: 20, weight: .black))
                            .foregroundColor(.textPrimary)
                        
                        Spacer()
                        
                        Text(viewModel.drift.status.rawValue)
                            .font(.system(size: 10, weight: .black))
                            .foregroundColor(viewModel.drift.status.color)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(viewModel.drift.status.color.opacity(0.1))
                            .cornerRadius(6)
                    }
                    
                    HStack(spacing: 6) {
                        Image(systemName: AppIcons.calendar)
                        Text("\(viewModel.drift.date), \(viewModel.drift.time) – \(viewModel.drift.endTime)")
                    }
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.textSecondary)
                    
                    HStack(spacing: 6) {
                        Image(systemName: AppIcons.mappin)
                        Text(viewModel.drift.location)
                    }
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.textSecondary)
                    
                    HStack(spacing: 12) {
                        HStack(spacing: 4) {
                            Image(systemName: AppIcons.participants)
                            Text("Open to \(viewModel.drift.capacity) people")
                        }
                        Text("•")
                        Text("\(viewModel.drift.participantInitials.count) joined")
                    }
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(.textSecondary)
                }
            }
            
            if !viewModel.drift.pendingRequests.isEmpty {
                HStack {
                    Image(systemName: AppIcons.bellFill)
                        .foregroundColor(.brandPurple)
                    Text("\(viewModel.drift.pendingRequests.count) requests pending")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.textPrimary)
                    Spacer()
                }
                .padding(12)
                .background(Color.brandPurple.opacity(0.05))
                .cornerRadius(12)
            }
            
            HStack(spacing: 8) {
                Image(systemName: AppIcons.lock)
                    .font(.system(size: 12))
                Text(AppStrings.Drifts.Detail.coordinationNote)
                    .font(.system(size: 11, weight: .medium))
                Spacer()
            }
            .foregroundColor(.textSecondary)
            .padding(.top, 4)
        }
        .padding(20)
        .background(Color.surfaceMain)
        .cornerRadius(32)
        .overlay(RoundedRectangle(cornerRadius: 32).stroke(Color.appBorder, lineWidth: 1))
    }
    
    // MARK: - Action Buttons
    private var hostActionsRow: some View {
        HStack(spacing: 12) {
            actionButton(icon: "pencil", label: AppStrings.Manage.edit, color: .textPrimary, action: viewModel.editDrift)
            actionButton(icon: AppIcons.share, label: AppStrings.Manage.share, color: .textPrimary, action: viewModel.shareDrift)
            actionButton(icon: "pause.circle", label: AppStrings.Manage.close, color: .brandPurple, action: viewModel.closeDrift)
            actionButton(icon: "trash", label: AppStrings.Manage.delete, color: .statusError, action: viewModel.deleteDrift)
        }
    }
    
    private func actionButton(icon: String, label: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                Text(label)
                    .font(.system(size: 11, weight: .bold))
            }
            .foregroundColor(color)
            .frame(maxWidth: .infinity)
            .frame(height: 72)
            .background(Color.surfaceMain)
            .cornerRadius(20)
            .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.appBorder, lineWidth: 1))
        }
    }
    
    // MARK: - Join Requests Section
    private var joinRequestsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text(AppStrings.Manage.requests)
                    .font(.system(size: 16, weight: .black))
                Text("\(viewModel.drift.pendingRequests.count)")
                    .font(.system(size: 12, weight: .bold))
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
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text(AppStrings.Manage.participants)
                    .font(.system(size: 16, weight: .black))
                Text("\(viewModel.drift.participantInitials.count)")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(.textSecondary)
                Spacer()
                Button(action: {}) {
                    Text(AppStrings.Drifts.seeAll)
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.brandPrimary)
                }
            }
            
            HStack(spacing: -10) {
                ForEach(0..<min(viewModel.drift.participantInitials.count, 5), id: \.self) { index in
                    Text(viewModel.drift.participantInitials[index])
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 40, height: 40)
                        .background(Circle().fill(Color.brandPrimary))
                        .overlay(Circle().stroke(Color.white, lineWidth: 2))
                }
                
                if viewModel.drift.participantInitials.count > 5 {
                    Text("+\(viewModel.drift.participantInitials.count - 5)")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.textSecondary)
                        .frame(width: 40, height: 40)
                        .background(Circle().fill(Color.surfaceSecondary))
                        .padding(.leading, 15)
                }
                
                Spacer()
                
                Text("\(viewModel.drift.participantInitials.count) joined")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(.textPrimary)
                Text("Open to \(viewModel.drift.capacity)")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.textSecondary)
            }
        }
        .padding(20)
        .background(Color.surfaceMain)
        .cornerRadius(24)
        .overlay(RoundedRectangle(cornerRadius: 24).stroke(Color.appBorder, lineWidth: 1))
    }
    
    // MARK: - Open Chat Button
    private var openChatButton: some View {
        NavigationLink(destination: DriftChatScreen(viewModel: DriftChatViewModel(drift: viewModel.drift))) {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(Color.brandPrimary.opacity(0.1))
                        .frame(width: 48, height: 48)
                    Image(systemName: AppIcons.navChatsFill)
                        .foregroundColor(.brandPrimary)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(AppStrings.Manage.openChat)
                        .font(.system(size: 16, weight: .black))
                        .foregroundColor(.textPrimary)
                    Text(AppStrings.Manage.chatSubtitle)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.textSecondary)
                }
                
                Spacer()
                
                Image(systemName: AppIcons.chevronRight)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.textSecondary)
            }
            .padding(16)
            .background(Color.surfaceMain)
            .cornerRadius(24)
            .overlay(RoundedRectangle(cornerRadius: 24).stroke(Color.appBorder, lineWidth: 1))
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - Safety Banner
    private var safetyReminderBanner: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color.brandPurple.opacity(0.1))
                    .frame(width: 32, height: 32)
                Image(systemName: AppIcons.verified)
                    .font(.system(size: 14))
                    .foregroundColor(.brandPurple)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(AppStrings.Manage.reminder)
                    .font(.system(size: 14, weight: .black))
                    .foregroundColor(.brandPurple)
                Text(AppStrings.Manage.reminderSubtitle)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.textSecondary)
                    .lineSpacing(2)
            }
            
            Spacer()
            
            Image(systemName: AppIcons.chevronRight)
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(.brandPurple.opacity(0.4))
        }
        .padding(20)
        .background(Color.brandPurple.opacity(0.04))
        .cornerRadius(24)
    }
}

// MARK: - Join Request Row
struct JoinRequestRow: View {
    let request: JoinRequest
    let onAccept: () -> Void
    let onReject: () -> Void
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Avatar
            Text(request.userInitials)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.textPrimary)
                .frame(width: 48, height: 48)
                .background(Circle().fill(Color.surfaceSecondary))
                .overlay(Circle().stroke(Color.appBorder, lineWidth: 1))
            
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(request.userName)
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(.textPrimary)
                    
                    Text(request.timestamp)
                        .font(.system(size: 11))
                        .foregroundColor(.textSecondary)
                }
                
                Text(request.userRole)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.textSecondary)
                    .lineLimit(2)
            }
            
            Spacer()
            
            HStack(spacing: 8) {
                Button(action: onAccept) {
                    Image(systemName: AppIcons.checkmark)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.brandPrimary)
                        .frame(width: 36, height: 36)
                        .background(Color.brandPrimary.opacity(0.1))
                        .clipShape(Circle())
                }
                
                Button(action: onReject) {
                    Image(systemName: AppIcons.close)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.statusError)
                        .frame(width: 36, height: 36)
                        .background(Color.statusError.opacity(0.1))
                        .clipShape(Circle())
                }
            }
        }
        .padding(16)
        .background(Color.surfaceMain)
        .cornerRadius(20)
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.appBorder, lineWidth: 1))
    }
}
