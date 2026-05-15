import SwiftUI

struct DriftChatScreen: View {
    @StateObject var viewModel: DriftChatViewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(spacing: 0) {
            // MARK: - Context Header
            DriftContextStrip(drift: viewModel.drift)
            
            // MARK: - Message List
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(spacing: 20) {
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
                    .padding(.vertical, 24)
                    .padding(.horizontal, 20)
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
                if viewModel.drift.status == .tonight { // Simulating ended drift if needed
                    endedBanner
                } else {
                    ChatComposer(text: $viewModel.messageText, onSend: viewModel.sendMessage)
                }
                
                safetyBanner
            }
            .background(Color.surfaceMain)
            .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: -5)
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                VStack(spacing: 2) {
                    Text(viewModel.drift.title)
                        .font(.system(size: 16, weight: .bold))
                    HStack(spacing: 4) {
                        Circle()
                            .fill(Color.brandPrimary)
                            .frame(width: 6, height: 6)
                        Text("\(viewModel.drift.participantInitials.count) joined")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(.textSecondary)
                    }
                }
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {}) {
                    Image(systemName: "info.circle")
                        .foregroundColor(.textPrimary)
                }
            }
        }
    }
    
    private var endedBanner: some View {
        HStack {
            Image(systemName: AppIcons.bell)
                .foregroundColor(.brandPurple)
            Text("This Drift has ended. You can still view messages but can't send new ones.")
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.textSecondary)
            Spacer()
        }
        .padding(16)
        .background(Color.brandPurple.opacity(0.05))
    }
    
    private var safetyBanner: some View {
        HStack(spacing: 8) {
            Image(systemName: AppIcons.verified)
                .font(.system(size: 14))
                .foregroundColor(.brandPurple)
            Text("Chats are for coordination only. No phone numbers. Be respectful.")
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(.textSecondary)
            Spacer()
            Image(systemName: "ellipsis")
                .font(.system(size: 14))
                .foregroundColor(.textSecondary)
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 12)
        .padding(.bottom, 8)
        .background(Color.surfaceMain)
    }
}

// MARK: - Drift Context Strip
struct DriftContextStrip: View {
    let drift: Drift
    
    var body: some View {
        HStack(spacing: 12) {
            // Thumbnail
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(drift.category.color.opacity(0.1))
                    .frame(width: 48, height: 48)
                Image(systemName: drift.category.icon)
                    .font(.system(size: 20))
                    .foregroundColor(drift.category.color)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(drift.title)
                    .font(.system(size: 15, weight: .bold))
                HStack(spacing: 6) {
                    Text(drift.time)
                    Text("•")
                    Text(drift.location)
                }
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.textSecondary)
                .lineLimit(1)
            }
            
            Spacer()
            
            Button(action: {}) {
                HStack(spacing: 4) {
                    Text("View Details")
                    Image(systemName: AppIcons.chevronRight)
                }
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(.brandPrimary)
            }
        }
        .padding(16)
        .background(Color.surfaceMain)
        .overlay(Divider(), alignment: .bottom)
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
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.textPrimary)
                    .frame(width: 32, height: 32)
                    .background(Circle().fill(Color.surfaceSecondary))
            } else {
                Spacer()
            }
            
            VStack(alignment: message.isSelf ? .trailing : .leading, spacing: 4) {
                if !message.isSelf {
                    Text(message.senderName)
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.textSecondary)
                        .padding(.leading, 4)
                }
                
                Text(message.content)
                    .font(.system(size: 15, weight: .medium))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .foregroundColor(message.isSelf ? .white : .textPrimary)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(message.isSelf ? Color.brandPrimary : Color.surfaceMain)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color.appBorder, lineWidth: message.isSelf ? 0 : 1)
                            )
                    )
            }
            
            if !message.isSelf {
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
                    .font(.system(size: 12))
            }
            Text(message.content)
                .font(.system(size: 12, weight: .bold))
            Text(message.timestamp, style: .time)
                .font(.system(size: 10))
                .foregroundColor(.textSecondary.opacity(0.6))
        }
        .foregroundColor(.textSecondary)
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(Color.surfaceSecondary.opacity(0.5))
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
                Image(systemName: "paperclip")
                    .font(.system(size: 20))
                    .foregroundColor(.textSecondary)
            }
            
            TextField("Message the Drift...", text: $text)
                .font(.system(size: 15, weight: .medium))
                .padding(.horizontal, 16)
                .frame(height: 48)
                .background(Color.surfaceSecondary)
                .cornerRadius(24)
            
            Button(action: onSend) {
                Image(systemName: "paperplane.fill")
                    .font(.system(size: 18))
                    .foregroundColor(.white)
                    .frame(width: 48, height: 48)
                    .background(Color.brandPrimary)
                    .clipShape(Circle())
            }
            .disabled(text.trimmingCharacters(in: .whitespaces).isEmpty)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
    }
}
