import SwiftUI

struct DriftChatScreen: View {
    @StateObject var viewModel: DriftChatViewModel
    @StateObject private var navManager = NavigationManager.shared
    @Environment(\.dismiss) var dismiss
    @State private var showInfoSheet = false
    
    var body: some View {
        VStack(spacing: 0) {
            // 1. Custom Sub-Banner Context Row
            subBanner
                .padding(.horizontal, AppConstants.Layout.standardPadding)
                .padding(.bottom, AppConstants.Layout.elementSpacing)
                .background(Color.backgroundMain)
            
            // MARK: - Message List
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(spacing: AppConstants.Layout.standardPadding) {
                        // System Messages (Top)
                        ForEach(viewModel.systemMessages) { msg in
                            SystemMessageRow(message: msg)
                        }
                        
                        // Chat Messages
                        ForEach(viewModel.messages) { msg in
                            ChatBubble(message: msg)
                                .id(msg.id)
                        }
                    }
                    .padding(.vertical, AppConstants.Layout.standardPadding)
                    .padding(.horizontal, AppConstants.Layout.elementSpacing)
                }
                .onChange(of: viewModel.messages.count) { _ in
                    if let last = viewModel.messages.last {
                        withAnimation {
                            proxy.scrollTo(last.id, anchor: .bottom)
                        }
                    }
                }
            }
            .background(Color.backgroundMain)
            
            // MARK: - Bottom Area (Composer + Safety)
            VStack(spacing: 0) {
                if viewModel.drift.status == .ended {
                    endedBanner
                } else {
                    ChatComposer(text: $viewModel.messageText, onSend: viewModel.sendMessage)
                }
                
                safetyBanner
            }
            .background(Color.surfaceMain)
            .shadow(color: Color.textPrimary.opacity(AppConstants.UI.opacitySubtle), radius: 10, x: 0, y: -5)
        }
        .sheet(isPresented: $showInfoSheet) {
            if #available(iOS 16.4, *) {
                DriftChatDetailSheet(drift: viewModel.drift)
                    .presentationDetents([.fraction(0.85)])
                    .presentationDragIndicator(.visible)
                    .presentationCornerRadius(30)
            } else {
                DriftChatDetailSheet(drift: viewModel.drift)
                    .presentationDetents([.fraction(0.85)])
                    .presentationDragIndicator(.visible)
            }
        }
        .onAppear {
            navManager.isTabBarHidden = true
        }
        .onDisappear {
            navManager.isTabBarHidden = false
        }
        .asCoffeePage(
            .sub,
            title: viewModel.drift.title,
            subtitle: "\(viewModel.drift.time.replacingOccurrences(of: " • ", with: " ")) • \(AppStrings.Chat.locationUnlocked)",
            categoryIcon: viewModel.drift.category.icon,
            categoryColor: viewModel.drift.category.color,
            scrollable: false,
            rightView: {
                CoffeeHeaderButton(icon: AppIcons.infoCircle, color: .textPrimary) {
                    showInfoSheet = true
                }
            }
        )
    }
    
    // Custom Sub-Header Banner Context Chips
    private var subBanner: some View {
        HStack(spacing: AppConstants.Layout.subElementSpacing) {
            // Time Chip
            HStack(spacing: AppConstants.Layout.miniPadding + 2) {
                AppIcons.clockImage
                    .font(.captionText)
                    .foregroundColor(.brandPrimary)
                Text(viewModel.drift.time.replacingOccurrences(of: " • ", with: " "))
                    .font(.captionText)
                    .foregroundColor(.textPrimary)
            }
            .padding(.horizontal, AppConstants.Layout.subElementSpacing + 2)
            .padding(.vertical, AppConstants.Layout.subElementSpacing - 2)
            .background(Color.surfaceSecondary.opacity(AppConstants.UI.opacityNormal))
            .cornerRadius(AppConstants.UI.cornerRadiusSmall)
            
            // Participants Chip
            HStack(spacing: AppConstants.Layout.miniPadding + 2) {
                AppIcons.participantsImage
                    .font(.captionText)
                    .foregroundColor(.textSecondary)
                Text("\(viewModel.drift.peopleGoing) \(AppStrings.Chat.participantsLabel)")
                    .font(.captionText)
                    .foregroundColor(.textPrimary)
            }
            .padding(.horizontal, AppConstants.Layout.subElementSpacing + 2)
            .padding(.vertical, AppConstants.Layout.subElementSpacing - 2)
            .background(Color.surfaceSecondary.opacity(AppConstants.UI.opacityNormal))
            .cornerRadius(AppConstants.UI.cornerRadiusSmall)
            
            // Joined Badge
            Text(AppStrings.Chat.joined)
                .font(.micro)
                .foregroundColor(.brandPurple)
                .padding(.horizontal, AppConstants.Layout.subElementSpacing + 2)
                .padding(.vertical, AppConstants.Layout.subElementSpacing - 2)
                .background(Color.brandPurple.opacity(AppConstants.UI.opacityLight))
                .cornerRadius(AppConstants.UI.cornerRadiusSmall)
        }
        .padding(.horizontal, AppConstants.Layout.elementSpacing)
        .padding(.vertical, AppConstants.Layout.subElementSpacing)
        .background(Color.white.opacity(0.6))
        .cornerRadius(AppConstants.UI.cornerRadiusMedium - 2)
    }
    
    private var endedBanner: some View {
        HStack {
            AppIcons.bellImage
                .foregroundColor(.brandPurple)
            Text(AppStrings.Chat.endedRoomBanner)
                .font(.captionText)
                .foregroundColor(.textSecondary)
            Spacer()
        }
        .padding(AppConstants.Layout.elementSpacing)
        .background(Color.brandPurple.opacity(AppConstants.UI.opacitySubtle))
    }
    
    private var safetyBanner: some View {
        HStack(spacing: AppConstants.Layout.subElementSpacing) {
            AppIcons.verifiedImage
                .font(.captionText)
                .foregroundColor(.brandPurple)
            Text(AppStrings.Chat.safetyBannerText)
                .font(.metadata)
                .foregroundColor(.textSecondary)
            Spacer()
            AppIcons.ellipsisImage
                .font(.captionText)
                .foregroundColor(.textSecondary)
        }
        .padding(.horizontal, AppConstants.Layout.standardPadding)
        .padding(.vertical, AppConstants.Layout.elementSpacing)
        .padding(.bottom, AppConstants.Layout.subElementSpacing)
        .background(Color.surfaceMain)
    }
}

// MARK: - Message Bubble Shape with Tail
struct MessageBubbleShape: Shape {
    let isSelf: Bool
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: isSelf ? 
                [.topLeft, .topRight, .bottomLeft] : 
                [.topLeft, .topRight, .bottomRight],
            cornerRadii: CGSize(width: AppConstants.UI.cornerRadiusMedium - 4, height: AppConstants.UI.cornerRadiusMedium - 4)
        )
        return Path(path.cgPath)
    }
}

// MARK: - Chat Bubble
struct ChatBubble: View {
    let message: ChatMessage
    
    var body: some View {
        HStack(alignment: .bottom, spacing: AppConstants.Layout.subElementSpacing) {
            if !message.isSelf {
                // Avatar
                Text(message.senderInitials)
                    .font(.micro)
                    .foregroundColor(.brandPrimary)
                    .frame(width: AppConstants.Layout.subElementSpacing * 4, height: AppConstants.Layout.subElementSpacing * 4)
                    .background(Circle().fill(Color.brandPrimary.opacity(AppConstants.UI.opacityLight)))
            } else {
                Spacer()
            }
            
            VStack(alignment: message.isSelf ? .trailing : .leading, spacing: AppConstants.Layout.miniPadding) {
                if !message.isSelf {
                    Text(message.senderName)
                        .font(.captionText)
                        .foregroundColor(.textSecondary)
                        .padding(.leading, AppConstants.Layout.miniPadding)
                }
                
                HStack(alignment: .bottom, spacing: AppConstants.Layout.subElementSpacing - 2) {
                    if message.isSelf {
                        HStack(spacing: AppConstants.Layout.miniPadding) {
                            Text(message.timestamp, style: .time)
                                .font(.metadata)
                                .foregroundColor(.textSecondary)
                            Text("✓✓")
                                .font(.metadata)
                                .foregroundColor(.brandPrimary)
                        }
                        .padding(.bottom, AppConstants.Layout.miniPadding / 2)
                    }
                    
                    Text(message.content)
                        .font(.bodyStandard)
                        .padding(.horizontal, AppConstants.Layout.standardPadding - 4)
                        .padding(.vertical, AppConstants.Layout.elementSpacing)
                        .foregroundColor(.textPrimary)
                        .background(
                            MessageBubbleShape(isSelf: message.isSelf)
                                .fill(message.isSelf ? Color.brandPrimary.opacity(AppConstants.UI.opacityLight) : Color.white)
                        )
                        .overlay(
                            MessageBubbleShape(isSelf: message.isSelf)
                                .stroke(Color.appBorder, lineWidth: message.isSelf ? 0 : 1)
                        )
                    
                    if !message.isSelf {
                        Text(message.timestamp, style: .time)
                            .font(.metadata)
                            .foregroundColor(.textSecondary)
                            .padding(.bottom, AppConstants.Layout.miniPadding / 2)
                    }
                }
            }
            
            if message.isSelf {
                // Outgoing visual balance spacing
            } else {
                Spacer()
            }
        }
    }
}

// MARK: - System Message Row
struct SystemMessageRow: View {
    let message: SystemMessage
    
    var body: some View {
        HStack(spacing: AppConstants.Layout.subElementSpacing) {
            if let icon = message.icon {
                Image(systemName: icon)
                    .font(.captionText)
            }
            Text(message.content)
                .font(.captionText)
            Text(message.timestamp, style: .time)
                .font(.metadata)
                .foregroundColor(.textSecondary.opacity(AppConstants.UI.opacityNormal + 0.2))
        }
        .foregroundColor(.textSecondary)
        .padding(.horizontal, AppConstants.Layout.standardPadding - 4)
        .padding(.vertical, AppConstants.Layout.subElementSpacing)
        .background(Color.surfaceSecondary.opacity(AppConstants.UI.opacityNormal + 0.1))
        .clipShape(Capsule())
    }
}

// MARK: - Chat Composer
struct ChatComposer: View {
    @Binding var text: String
    let onSend: () -> Void
    
    var body: some View {
        HStack(spacing: AppConstants.Layout.elementSpacing) {
            Button(action: {}) {
                AppIcons.paperclipImage
                    .font(.system(size: 18))
                    .foregroundColor(.textSecondary)
            }
            
            TextField(AppStrings.Chat.composerPlaceholder, text: $text)
                .font(.bodyStandard)
                .padding(.horizontal, AppConstants.Layout.standardPadding - 4)
                .frame(height: AppConstants.Layout.createDriftButtonHeight - 8)
                .background(Color.surfaceSecondary.opacity(AppConstants.UI.opacitySubtle))
                .cornerRadius(AppConstants.UI.cornerRadiusLarge)
            
            Button(action: onSend) {
                AppIcons.paperplaneFillImage
                    .font(.system(size: 16))
                    .foregroundColor(.white)
                    .frame(width: AppConstants.Layout.createDriftButtonHeight - 8, height: AppConstants.Layout.createDriftButtonHeight - 8)
                    .background(Color.brandPrimary)
                    .clipShape(Circle())
            }
            .disabled(text.trimmingCharacters(in: .whitespaces).isEmpty)
        }
        .padding(.horizontal, AppConstants.Layout.elementSpacing)
        .padding(.vertical, AppConstants.Layout.elementSpacing)
    }
}

// MARK: - Chat Detail bottom sheet
struct DriftChatDetailSheet: View {
    let drift: Drift
    @Environment(\.dismiss) var dismiss
    @State private var isMuted = false
    @State private var showBlockAlert = false
    @State private var selectedUserToBlock = ""
    
    var participants: [ParticipantInfo] {
        AppConstants.MockData.chatParticipants
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text(AppStrings.Chat.aboutDrift)
                    .font(.heading2).fontWeight(.bold)
                    .foregroundColor(.textPrimary)
                
                Spacer()
                
                Button(action: { dismiss() }) {
                    AppIcons.closeImage
                        .font(.captionText)
                        .foregroundColor(.textSecondary)
                        .frame(width: AppConstants.Layout.subElementSpacing * 4, height: AppConstants.Layout.subElementSpacing * 4)
                        .background(Color.surfaceSecondary.opacity(AppConstants.UI.opacityNormal))
                        .clipShape(Circle())
                }
            }
            .padding(.horizontal, AppConstants.Layout.standardPadding)
            .padding(.top, AppConstants.Layout.sectionSpacing)
            .padding(.bottom, AppConstants.Layout.elementSpacing)
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: AppConstants.Layout.standardPadding) {
                    
                    // Card 1: Drift Details Card (Mockup style Image 4)
                    VStack(alignment: .leading, spacing: AppConstants.Layout.standardPadding - 4) {
                        // Row 1: Purpose
                            HStack(spacing: AppConstants.Layout.elementSpacing) {
                                ZStack {
                                    Circle()
                                        .fill(drift.category.color.opacity(AppConstants.UI.opacityLight))
                                        .frame(width: AppConstants.Layout.subElementSpacing * 4.5, height: AppConstants.Layout.subElementSpacing * 4.5)
                                    Image(systemName: drift.category.icon)
                                        .font(.bodyStandard)
                                        .foregroundColor(drift.category.color)
                                }
                                
                                VStack(alignment: .leading, spacing: AppConstants.Layout.miniPadding / 2) {
                                    Text(AppStrings.Drifts.Detail.detailsHeader)
                                        .font(.captionText)
                                        .foregroundColor(.textSecondary)
                                    Text(drift.title)
                                        .font(.bodyBold)
                                        .foregroundColor(.textPrimary)
                                }
                            }
                            
                            // Row 2: Time
                            HStack(spacing: AppConstants.Layout.elementSpacing) {
                                ZStack {
                                    Circle()
                                        .fill(Color.brandPrimary.opacity(AppConstants.UI.opacityLight))
                                        .frame(width: AppConstants.Layout.subElementSpacing * 4.5, height: AppConstants.Layout.subElementSpacing * 4.5)
                                    AppIcons.clockImage
                                        .font(.bodyStandard)
                                        .foregroundColor(.brandPrimary)
                                }
                                
                                VStack(alignment: .leading, spacing: AppConstants.Layout.miniPadding / 2) {
                                    Text(AppStrings.Drifts.Detail.timeLabel)
                                        .font(.captionText)
                                        .foregroundColor(.textSecondary)
                                    Text(drift.time)
                                        .font(.bodyBold)
                                        .foregroundColor(.textPrimary)
                                }
                            }
                            
                            // Row 3: Location
                            HStack(spacing: AppConstants.Layout.elementSpacing) {
                                ZStack {
                                    Circle()
                                        .fill(Color.brandPrimary.opacity(AppConstants.UI.opacityLight))
                                        .frame(width: AppConstants.Layout.subElementSpacing * 4.5, height: AppConstants.Layout.subElementSpacing * 4.5)
                                    AppIcons.locationImage
                                        .font(.bodyStandard)
                                        .foregroundColor(.brandPrimary)
                                }
                                
                                VStack(alignment: .leading, spacing: AppConstants.Layout.miniPadding / 2) {
                                    Text(AppStrings.Drifts.Detail.meetingPointLabel)
                                        .font(.captionText)
                                        .foregroundColor(.textSecondary)
                                    Text(AppStrings.Chat.locationUnlocked)
                                        .font(.bodyBold)
                                        .foregroundColor(.brandPrimary)
                                }
                            }
                            
                            // Row 4: Host note
                            HStack(spacing: AppConstants.Layout.elementSpacing) {
                                ZStack {
                                    Circle()
                                        .fill(Color.brandPrimary.opacity(AppConstants.UI.opacityLight))
                                        .frame(width: AppConstants.Layout.subElementSpacing * 4.5, height: AppConstants.Layout.subElementSpacing * 4.5)
                                    AppIcons.navChatsImage
                                        .font(.bodyStandard)
                                        .foregroundColor(.brandPrimary)
                                }
                                
                                VStack(alignment: .leading, spacing: AppConstants.Layout.miniPadding / 2) {
                                    Text(AppStrings.Drifts.Detail.notesLabel)
                                        .font(.captionText)
                                        .foregroundColor(.textSecondary)
                                    Text(drift.notes ?? "Meet near the entrance, quick hello.")
                                        .font(.bodyStandard)
                                        .foregroundColor(.textPrimary)
                                }
                            }
                        
                        Divider()
                        
                        HStack(spacing: AppConstants.Layout.elementSpacing) {
                            Button(action: { dismiss() }) {
                                Text(AppStrings.Chat.viewDrift)
                                    .font(.bodySmall)
                                    .foregroundColor(.brandPrimary)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: AppConstants.Layout.minTouchTarget)
                                    .background(Color.white)
                                    .cornerRadius(AppConstants.Layout.minTouchTarget / 2)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: AppConstants.Layout.minTouchTarget / 2)
                                            .stroke(Color.brandPrimary, lineWidth: 1)
                                    )
                            }
                            
                            Button(action: {
                                withAnimation {
                                    isMuted.toggle()
                                }
                            }) {
                                HStack(spacing: AppConstants.Layout.miniPadding + 2) {
                                    Image(systemName: isMuted ? "bell.slash.fill" : AppIcons.bell)
                                    Text(AppStrings.Chat.muteRoom)
                                }
                                .font(.bodySmall)
                                .foregroundColor(.textSecondary)
                                .frame(maxWidth: .infinity)
                                .frame(height: AppConstants.Layout.minTouchTarget)
                                .background(Color.white)
                                .cornerRadius(AppConstants.Layout.minTouchTarget / 2)
                                .overlay(
                                    RoundedRectangle(cornerRadius: AppConstants.Layout.minTouchTarget / 2)
                                        .stroke(Color.appBorder, lineWidth: 1)
                                )
                            }
                        }
                    }
                    .padding(AppConstants.Layout.standardPadding)
                    .background(Color.surfaceMain)
                    .cornerRadius(AppConstants.UI.cornerRadiusLarge)
                    .overlay(
                        RoundedRectangle(cornerRadius: AppConstants.UI.cornerRadiusLarge)
                            .stroke(Color.appBorder, lineWidth: 1)
                    )
                    
                    // Card 2: Participants Card (Mockup style Image 4)
                    VStack(alignment: .leading, spacing: AppConstants.Layout.elementSpacing) {
                        HStack {
                            Text("\(AppStrings.Chat.participantsTitle) (\(participants.count))")
                                .font(.bodyBold)
                                .foregroundColor(.textPrimary)
                            
                            Spacer()
                            
                            Text(AppStrings.Chat.hosted)
                                .font(.micro)
                                .foregroundColor(.brandPrimary)
                                .padding(.horizontal, AppConstants.Layout.subElementSpacing)
                                .padding(.vertical, AppConstants.Layout.miniPadding)
                                .background(Color.brandPrimary.opacity(AppConstants.UI.opacityLight))
                                .cornerRadius(AppConstants.UI.cornerRadiusTiny)
                        }
                        
                        VStack(spacing: AppConstants.Layout.elementSpacing + 2) {
                            ForEach(participants) { p in
                                HStack(spacing: AppConstants.Layout.elementSpacing) {
                                    ZStack {
                                        Circle()
                                            .fill(p.color.opacity(AppConstants.UI.opacityLight))
                                            .frame(width: AppConstants.Layout.subElementSpacing * 4.5, height: AppConstants.Layout.subElementSpacing * 4.5)
                                        Text(p.initials)
                                            .font(.micro)
                                            .foregroundColor(p.color)
                                    }
                                    
                                    Text(p.isHost ? "\(p.name) (\(AppStrings.Chat.hosted))" : p.name)
                                        .font(.bodySmall)
                                        .foregroundColor(.textPrimary)
                                    
                                    Spacer()
                                    
                                    if !p.isMe && !p.isHost {
                                        Button(action: {}) {
                                            AppIcons.navChatsImage
                                                .font(.bodyStandard)
                                                .foregroundColor(.textSecondary)
                                                .frame(width: AppConstants.Layout.subElementSpacing * 4, height: AppConstants.Layout.subElementSpacing * 4)
                                                .background(Color.white)
                                                .clipShape(Circle())
                                                .overlay(Circle().stroke(Color.appBorder, lineWidth: 1))
                                        }
                                    }
                                }
                                if p.initials != "Y" {
                                    Divider()
                                }
                            }
                        }
                        
                        HStack(spacing: AppConstants.Layout.miniPadding + 2) {
                            AppIcons.lockImage
                                .font(.captionText)
                                .foregroundColor(.textSecondary)
                            Text(AppStrings.Chat.contextMessageWarning)
                                .font(.metadata)
                                .foregroundColor(.textSecondary)
                        }
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.top, AppConstants.Layout.subElementSpacing)
                    }
                    .padding(AppConstants.Layout.standardPadding)
                    .background(Color.surfaceMain)
                    .cornerRadius(AppConstants.UI.cornerRadiusLarge)
                    .overlay(
                        RoundedRectangle(cornerRadius: AppConstants.UI.cornerRadiusLarge)
                            .stroke(Color.appBorder, lineWidth: 1)
                    )
                    
                    // Card 3: Safety & Controls Card (Mockup style Image 4)
                    VStack(alignment: .leading, spacing: AppConstants.Layout.elementSpacing) {
                        Text(AppStrings.Chat.safetyControls)
                            .font(.bodyBold)
                            .foregroundColor(.textPrimary)
                        
                        VStack(spacing: 0) {
                            // Report Drift
                            Button(action: {}) {
                                HStack {
                                    AppIcons.reportImage
                                        .foregroundColor(.statusError)
                                    Text(AppStrings.Chat.reportDrift)
                                        .font(.bodySmall)
                                        .foregroundColor(.statusError)
                                    Spacer()
                                    AppIcons.chevronRightImage
                                        .font(.captionText)
                                        .foregroundColor(.statusError)
                                }
                                .padding(.vertical, AppConstants.Layout.elementSpacing + 2)
                            }
                            
                            Divider()
                            
                            // Block user
                            Button(action: {
                                selectedUserToBlock = drift.host.name
                                showBlockAlert = true
                            }) {
                                HStack {
                                    AppIcons.blockImage
                                        .foregroundColor(.statusError)
                                    Text(AppStrings.Chat.blockUser)
                                        .font(.bodySmall)
                                        .foregroundColor(.statusError)
                                    Spacer()
                                    AppIcons.chevronRightImage
                                        .font(.captionText)
                                        .foregroundColor(.statusError)
                                }
                                .padding(.vertical, AppConstants.Layout.elementSpacing + 2)
                            }
                            
                            Divider()
                            
                            // Leave Drift
                            Button(action: {}) {
                                HStack {
                                    AppIcons.logoutImage
                                        .foregroundColor(.statusError)
                                    Text(AppStrings.Chat.leaveDrift)
                                        .font(.bodySmall)
                                        .foregroundColor(.statusError)
                                    Spacer()
                                    AppIcons.chevronRightImage
                                        .font(.captionText)
                                        .foregroundColor(.statusError)
                                }
                                .padding(.vertical, AppConstants.Layout.elementSpacing + 2)
                            }
                        }
                    }
                    .padding(AppConstants.Layout.standardPadding)
                    .background(Color.surfaceMain)
                    .cornerRadius(AppConstants.UI.cornerRadiusLarge)
                    .overlay(
                        RoundedRectangle(cornerRadius: AppConstants.UI.cornerRadiusLarge)
                            .stroke(Color.appBorder, lineWidth: 1)
                    )
                    
                }
                .padding(.horizontal, AppConstants.Layout.standardPadding)
                .padding(.bottom, 40)
            }
        }
        .background(Color.backgroundMain.ignoresSafeArea())
        .alert(isPresented: $showBlockAlert) {
            Alert(
                title: Text("Block \(selectedUserToBlock)?"),
                message: Text("You will no longer see their Drifts or messages."),
                primaryButton: .destructive(Text("Block")) {
                    // Block execution logic
                },
                secondaryButton: .cancel()
            )
        }
    }
}

struct DriftChatScreen_Previews: PreviewProvider {
    static var previews: some View {
        let mockHost = Host(name: "Arjun", role: "Hosting", imageUrl: nil, isVerified: true)
        let mockDrift = Drift(
            title: "Coffee Drift",
            description: "Spontaneous coffee meetup.",
            location: "Indiranagar",
            meetingPoint: "Main Entrance",
            time: "6:30 PM",
            endTime: "7:30 PM",
            date: "Today",
            distance: 1.2,
            status: .open,
            category: .coffee,
            hook: nil,
            host: mockHost,
            peopleGoing: 3,
            spotsLeft: 2,
            capacity: 5,
            vibeTags: ["Casual"],
            whatToBring: ["Good mood"],
            notes: nil,
            participantInitials: ["AL", "RI", "MA"],
            imageUrl: "drift_coffee"
        )
        
        return NavigationStack {
            DriftChatScreen(viewModel: DriftChatViewModel(drift: mockDrift))
        }
    }
}
