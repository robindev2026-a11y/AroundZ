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
                .padding(.bottom, 10)
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
        HStack(spacing: 8) {
            // Time Chip
            HStack(spacing: 6) {
                Image(systemName: AppIcons.clock)
                    .font(.system(size: 11))
                    .foregroundColor(.brandPrimary)
                Text(viewModel.drift.time.replacingOccurrences(of: " • ", with: " "))
                    .font(.captionText)
                    .foregroundColor(.textPrimary)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(Color.surfaceSecondary.opacity(0.4))
            .cornerRadius(12)
            
            // Participants Chip
            HStack(spacing: 6) {
                Image(systemName: AppIcons.participants)
                    .font(.system(size: 11))
                    .foregroundColor(.textSecondary)
                Text("\(viewModel.drift.peopleGoing) people")
                    .font(.captionText)
                    .foregroundColor(.textPrimary)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(Color.surfaceSecondary.opacity(0.4))
            .cornerRadius(12)
            
            // Joined Badge
            Text("Joined")
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(.brandPurple)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(Color.brandPurple.opacity(0.12))
                .cornerRadius(12)
            
            Spacer()
            
            // View Drift Link
            Button(action: { showInfoSheet = true }) {
                HStack(spacing: 2) {
                    Text(AppStrings.Chat.viewDrift)
                    Image(systemName: AppIcons.chevronRight)
                        .font(.system(size: 8, weight: .bold))
                }
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(.brandPrimary)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color.white.opacity(0.6))
        .cornerRadius(18)
    }
    
    private var endedBanner: some View {
        HStack {
            Image(systemName: AppIcons.bell)
                .foregroundColor(.brandPurple)
            Text("This Drift has ended. You can still view messages but can't send new ones.")
                .font(.captionText)
                .foregroundColor(.textSecondary)
            Spacer()
        }
        .padding(AppConstants.Layout.elementSpacing)
        .background(Color.brandPurple.opacity(AppConstants.UI.opacitySubtle))
    }
    
    private var safetyBanner: some View {
        HStack(spacing: 8) {
            Image(systemName: AppIcons.verified)
                .font(.system(size: 14))
                .foregroundColor(.brandPurple)
            Text(AppStrings.Chat.safetyBannerText)
                .font(.metadata)
                .foregroundColor(.textSecondary)
            Spacer()
            Image(systemName: AppIcons.ellipsis)
                .font(.system(size: 14))
                .foregroundColor(.textSecondary)
        }
        .padding(.horizontal, AppConstants.Layout.standardPadding)
        .padding(.vertical, 12)
        .padding(.bottom, 8)
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
            cornerRadii: CGSize(width: 16, height: 16)
        )
        return Path(path.cgPath)
    }
}

// MARK: - Chat Bubble
struct ChatBubble: View {
    let message: ChatMessage
    
    var body: some View {
        HStack(alignment: .bottom, spacing: 8) {
            if !message.isSelf {
                // Avatar
                Text(message.senderInitials)
                    .font(.micro)
                    .foregroundColor(.brandPrimary)
                    .frame(width: 32, height: 32)
                    .background(Circle().fill(Color.brandPrimary.opacity(0.1)))
            } else {
                Spacer()
            }
            
            VStack(alignment: message.isSelf ? .trailing : .leading, spacing: 4) {
                if !message.isSelf {
                    Text(message.senderName)
                        .font(.captionText)
                        .foregroundColor(.textSecondary)
                        .padding(.leading, 4)
                }
                
                HStack(alignment: .bottom, spacing: 6) {
                    if message.isSelf {
                        HStack(spacing: 4) {
                            Text(message.timestamp, style: .time)
                                .font(.metadata)
                                .foregroundColor(.textSecondary)
                            Text("✓✓")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(.brandPrimary)
                        }
                        .padding(.bottom, 2)
                    }
                    
                    Text(message.content)
                        .font(.bodyStandard)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .foregroundColor(.textPrimary)
                        .background(
                            MessageBubbleShape(isSelf: message.isSelf)
                                .fill(message.isSelf ? Color.brandPrimary.opacity(0.12) : Color.white)
                        )
                        .overlay(
                            MessageBubbleShape(isSelf: message.isSelf)
                                .stroke(Color.appBorder, lineWidth: message.isSelf ? 0 : 1)
                        )
                    
                    if !message.isSelf {
                        Text(message.timestamp, style: .time)
                            .font(.metadata)
                            .foregroundColor(.textSecondary)
                            .padding(.bottom, 2)
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
        HStack(spacing: 8) {
            if let icon = message.icon {
                Image(systemName: icon)
                    .font(.system(size: 11))
            }
            Text(message.content)
                .font(.captionText)
            Text(message.timestamp, style: .time)
                .font(.metadata)
                .foregroundColor(.textSecondary.opacity(AppConstants.UI.opacityNormal + 0.2))
        }
        .foregroundColor(.textSecondary)
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(Color.surfaceSecondary.opacity(AppConstants.UI.opacityNormal + 0.1))
        .clipShape(Capsule())
    }
}

// MARK: - Chat Composer
struct ChatComposer: View {
    @Binding var text: String
    let onSend: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            Button(action: {}) {
                Image(systemName: AppIcons.paperclip)
                    .font(.system(size: 18))
                    .foregroundColor(.textSecondary)
            }
            
            TextField(AppStrings.Chat.composerPlaceholder, text: $text)
                .font(.bodyStandard)
                .padding(.horizontal, 16)
                .frame(height: 48)
                .background(Color.surfaceSecondary.opacity(AppConstants.UI.opacitySubtle))
                .cornerRadius(24)
            
            Button(action: onSend) {
                Image(systemName: AppIcons.paperplaneFill)
                    .font(.system(size: 16))
                    .foregroundColor(.white)
                    .frame(width: 48, height: 48)
                    .background(Color.brandPrimary)
                    .clipShape(Circle())
            }
            .disabled(text.trimmingCharacters(in: .whitespaces).isEmpty)
        }
        .padding(.horizontal, AppConstants.Layout.elementSpacing)
        .padding(.vertical, 12)
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
                    .font(.heading2)
                    .foregroundColor(.textPrimary)
                
                Spacer()
                
                Button(action: { dismiss() }) {
                    Image(systemName: AppIcons.close)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.textSecondary)
                        .frame(width: 32, height: 32)
                        .background(Color.surfaceSecondary.opacity(0.4))
                        .clipShape(Circle())
                }
            }
            .padding(.horizontal, AppConstants.Layout.standardPadding)
            .padding(.top, 24)
            .padding(.bottom, AppConstants.Layout.elementSpacing)
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: AppConstants.Layout.standardPadding) {
                    
                    // Card 1: Drift Details Card (Mockup style Image 4)
                    VStack(alignment: .leading, spacing: 20) {
                        Text(AppStrings.Chat.driftDetails)
                            .font(.bodyBold)
                            .foregroundColor(.textPrimary)
                        
                        VStack(alignment: .leading, spacing: 16) {
                            // Row 1: Purpose
                            HStack(spacing: 12) {
                                ZStack {
                                    Circle()
                                        .fill(drift.category.color.opacity(0.12))
                                        .frame(width: 36, height: 36)
                                    Image(systemName: drift.category.icon)
                                        .font(.system(size: 16))
                                        .foregroundColor(drift.category.color)
                                }
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Purpose")
                                        .font(.captionText)
                                        .foregroundColor(.textSecondary)
                                    Text(drift.title)
                                        .font(.bodyBold)
                                        .foregroundColor(.textPrimary)
                                }
                            }
                            
                            // Row 2: Time
                            HStack(spacing: 12) {
                                ZStack {
                                    Circle()
                                        .fill(Color.brandPrimary.opacity(0.12))
                                        .frame(width: 36, height: 36)
                                    Image(systemName: AppIcons.clock)
                                        .font(.system(size: 16))
                                        .foregroundColor(.brandPrimary)
                                }
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Time")
                                        .font(.captionText)
                                        .foregroundColor(.textSecondary)
                                    Text(drift.time)
                                        .font(.bodyBold)
                                        .foregroundColor(.textPrimary)
                                }
                            }
                            
                            // Row 3: Location
                            HStack(spacing: 12) {
                                ZStack {
                                    Circle()
                                        .fill(Color.brandPrimary.opacity(0.12))
                                        .frame(width: 36, height: 36)
                                    Image(systemName: AppIcons.location)
                                        .font(.system(size: 16))
                                        .foregroundColor(.brandPrimary)
                                }
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Location")
                                        .font(.captionText)
                                        .foregroundColor(.textSecondary)
                                    Text(AppStrings.Chat.locationUnlocked)
                                        .font(.bodyBold)
                                        .foregroundColor(.brandPrimary)
                                }
                            }
                            
                            // Row 4: Host note
                            HStack(spacing: 12) {
                                ZStack {
                                    Circle()
                                        .fill(Color.brandPrimary.opacity(0.12))
                                        .frame(width: 36, height: 36)
                                    Image(systemName: "bubble.left")
                                        .font(.system(size: 16))
                                        .foregroundColor(.brandPrimary)
                                }
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Host note")
                                        .font(.captionText)
                                        .foregroundColor(.textSecondary)
                                    Text(drift.notes ?? "Meet near the entrance, quick hello.")
                                        .font(.bodyStandard)
                                        .foregroundColor(.textPrimary)
                                }
                            }
                        }
                        
                        Divider()
                        
                        HStack(spacing: 12) {
                            Button(action: { dismiss() }) {
                                Text(AppStrings.Chat.viewDrift)
                                    .font(.bodySmall)
                                    .foregroundColor(.brandPrimary)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 44)
                                    .background(Color.white)
                                    .cornerRadius(22)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 22)
                                            .stroke(Color.brandPrimary, lineWidth: 1)
                                    )
                            }
                            
                            Button(action: {
                                withAnimation {
                                    isMuted.toggle()
                                }
                            }) {
                                HStack(spacing: 6) {
                                    Image(systemName: isMuted ? "bell.slash.fill" : AppIcons.bell)
                                    Text(AppStrings.Chat.muteRoom)
                                }
                                .font(.bodySmall)
                                .foregroundColor(.textSecondary)
                                .frame(maxWidth: .infinity)
                                .frame(height: 44)
                                .background(Color.white)
                                .cornerRadius(22)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 22)
                                        .stroke(Color.appBorder, lineWidth: 1)
                                )
                            }
                        }
                    }
                    .padding(20)
                    .background(Color.surfaceMain)
                    .cornerRadius(24)
                    .overlay(
                        RoundedRectangle(cornerRadius: 24)
                            .stroke(Color.appBorder, lineWidth: 1)
                    )
                    
                    // Card 2: Participants Card (Mockup style Image 4)
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text("Participants (5)")
                                .font(.bodyBold)
                                .foregroundColor(.textPrimary)
                            
                            Spacer()
                            
                            Text("Host")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(.brandPrimary)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.brandPrimary.opacity(0.12))
                                .cornerRadius(6)
                        }
                        
                        VStack(spacing: 14) {
                            ForEach(participants) { p in
                                HStack(spacing: 12) {
                                    ZStack {
                                        Circle()
                                            .fill(p.color.opacity(0.12))
                                            .frame(width: 36, height: 36)
                                        Text(p.initials)
                                            .font(.micro)
                                            .foregroundColor(p.color)
                                    }
                                    
                                    Text(p.isHost ? "\(p.name) (Host)" : p.name)
                                        .font(.bodySmall)
                                        .foregroundColor(.textPrimary)
                                    
                                    Spacer()
                                    
                                    if !p.isMe && !p.isHost {
                                        Button(action: {}) {
                                            Image(systemName: "bubble.left")
                                                .font(.system(size: 14))
                                                .foregroundColor(.textSecondary)
                                                .frame(width: 32, height: 32)
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
                        
                        HStack(spacing: 6) {
                            Image(systemName: "lock.fill")
                                .font(.system(size: 10))
                                .foregroundColor(.textSecondary)
                            Text(AppStrings.Chat.contextMessageWarning)
                                .font(.metadata)
                                .foregroundColor(.textSecondary)
                        }
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.top, 8)
                    }
                    .padding(20)
                    .background(Color.surfaceMain)
                    .cornerRadius(24)
                    .overlay(
                        RoundedRectangle(cornerRadius: 24)
                            .stroke(Color.appBorder, lineWidth: 1)
                    )
                    
                    // Card 3: Safety & Controls Card (Mockup style Image 4)
                    VStack(alignment: .leading, spacing: 16) {
                        Text(AppStrings.Chat.safetyControls)
                            .font(.bodyBold)
                            .foregroundColor(.textPrimary)
                        
                        VStack(spacing: 0) {
                            // Report Drift
                            Button(action: {}) {
                                HStack {
                                    Image(systemName: AppIcons.report)
                                        .foregroundColor(.statusError)
                                    Text(AppStrings.Chat.reportDrift)
                                        .font(.bodySmall)
                                        .foregroundColor(.statusError)
                                    Spacer()
                                    Image(systemName: AppIcons.chevronRight)
                                        .font(.system(size: 12, weight: .bold))
                                        .foregroundColor(.statusError)
                                }
                                .padding(.vertical, 14)
                            }
                            
                            Divider()
                            
                            // Block user
                            Button(action: {
                                selectedUserToBlock = drift.host.name
                                showBlockAlert = true
                            }) {
                                HStack {
                                    Image(systemName: AppIcons.block)
                                        .foregroundColor(.statusError)
                                    Text(AppStrings.Chat.blockUser)
                                        .font(.bodySmall)
                                        .foregroundColor(.statusError)
                                    Spacer()
                                    Image(systemName: AppIcons.chevronRight)
                                        .font(.system(size: 12, weight: .bold))
                                        .foregroundColor(.statusError)
                                }
                                .padding(.vertical, 14)
                            }
                            
                            Divider()
                            
                            // Leave Drift
                            Button(action: {}) {
                                HStack {
                                    Image(systemName: "rectangle.portrait.and.arrow.right")
                                        .foregroundColor(.statusError)
                                    Text(AppStrings.Chat.leaveDrift)
                                        .font(.bodyBold)
                                        .foregroundColor(.statusError)
                                    Spacer()
                                    Image(systemName: AppIcons.chevronRight)
                                        .font(.system(size: 12, weight: .bold))
                                        .foregroundColor(.statusError)
                                }
                                .padding(.vertical, 14)
                            }
                        }
                    }
                    .padding(20)
                    .background(Color.surfaceMain)
                    .cornerRadius(24)
                    .overlay(
                        RoundedRectangle(cornerRadius: 24)
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
