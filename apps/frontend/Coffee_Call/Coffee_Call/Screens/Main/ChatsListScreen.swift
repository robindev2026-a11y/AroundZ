import SwiftUI

struct ChatsListScreen: View {
    @StateObject private var viewModel = ChatsViewModel()
    @State private var showPrivacyBanner = true
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 24) {
                // Privacy Banner
                if showPrivacyBanner {
                    privacyBanner
                        .padding(.horizontal, 24)
                }
                
                if viewModel.activeDrifts.isEmpty && viewModel.upcomingDrifts.isEmpty && viewModel.pastDrifts.isEmpty {
                    emptyStateView
                        .padding(.top, 40)
                } else {
                    // Active Section
                    chatSection(title: AppStrings.Chat.active, count: viewModel.activeDrifts.count, drifts: viewModel.activeDrifts)
                    
                    // Upcoming Section
                    chatSection(title: AppStrings.Chat.upcoming, count: viewModel.upcomingDrifts.count, drifts: viewModel.upcomingDrifts)
                    
                    // Past Section
                    chatSection(title: AppStrings.Chat.past, count: viewModel.pastDrifts.count, drifts: viewModel.pastDrifts)
                }
            }
            .asCoffeeMainPage(
                title: viewModel.title,
                subtitle: viewModel.subtitle ?? ""
            ) {
                CoffeeHeaderButton(icon: AppIcons.search) {}
                CoffeeHeaderButton(icon: AppIcons.filter) {}
            }
            .navigationDestination(for: Drift.self) { drift in
                DriftChatScreen(viewModel: DriftChatViewModel(drift: drift))
            }
        }
    }
    
    // MARK: - Privacy Banner
    private var privacyBanner: some View {
        HStack(alignment: .top, spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color.brandPurple.opacity(0.1))
                    .frame(width: 36, height: 36)
                Image(systemName: AppIcons.verified)
                    .font(.system(size: 14))
                    .foregroundColor(.brandPurple)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(AppStrings.Chat.bannerTitle)
                    .font(.system(size: 13, weight: .black))
                    .foregroundColor(.textPrimary)
                Text(AppStrings.Chat.bannerSubtitle)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.textSecondary)
            }
            
            Spacer()
            
            Button(action: { withAnimation { showPrivacyBanner = false } }) {
                Image(systemName: AppIcons.close)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.textSecondary.opacity(0.4))
            }
        }
        .padding(16)
        .background(Color.surfaceMain)
        .cornerRadius(20)
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.appBorder, lineWidth: 1))
    }
    
    // MARK: - Chat Section
    private func chatSection(title: String, count: Int, drifts: [Drift]) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            if !drifts.isEmpty {
                HStack {
                    Text(title)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.textPrimary)
                    Text("\(count)")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Color.brandSecondary)
                        .clipShape(Capsule())
                    
                    Spacer()
                    
                    Button(AppStrings.Chat.viewAll) {}
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.brandPrimary)
                }
                .padding(.horizontal, 24)
                
                VStack(spacing: 12) {
                    ForEach(drifts) { drift in
                        NavigationLink(value: drift) {
                            ChatRow(drift: drift)
                        }
                        .buttonStyle(.plain)
                        .padding(.horizontal, 24)
                    }
                }
            }
        }
    }
    
    // MARK: - Empty State
    private var emptyStateView: some View {
        VStack(spacing: 24) {
            ZStack {
                Circle()
                    .fill(Color.brandPrimary.opacity(0.05))
                    .frame(width: 120, height: 120)
                Image(systemName: "bubble.left.and.bubble.right.fill")
                    .font(.system(size: 40))
                    .foregroundColor(.brandPrimary)
            }
            
            VStack(spacing: 8) {
                Text(AppStrings.Chat.emptyTitle)
                    .font(.system(size: 20, weight: .black))
                    .foregroundColor(.textPrimary)
                Text(AppStrings.Chat.emptySubtitle)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.textSecondary)
                    .multilineTextAlignment(.center)
            }
            
            Button(action: {}) {
                Text(AppStrings.Chat.exploreCTA)
                    .font(.system(size: 16, weight: .black))
                    .foregroundColor(.white)
                    .padding(.horizontal, 32)
                    .frame(height: 56)
                    .background(Color.brandPrimary)
                    .cornerRadius(28)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(32)
        .background(Color.surfaceMain)
        .cornerRadius(32)
        .padding(.horizontal, 24)
    }
}

// MARK: - Chat Row
struct ChatRow: View {
    let drift: Drift
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack(alignment: .bottomTrailing) {
                RoundedRectangle(cornerRadius: 16)
                    .fill(drift.category.color.opacity(0.1))
                    .frame(width: 64, height: 64)
                
                Image(systemName: drift.category.icon)
                    .font(.system(size: 24))
                    .foregroundColor(drift.category.color)
                    .frame(width: 64, height: 64)
                
                ZStack {
                    Circle()
                        .fill(Color.white)
                        .frame(width: 24, height: 24)
                    Image(systemName: drift.category.icon)
                        .font(.system(size: 10))
                        .foregroundColor(drift.category.color)
                }
                .offset(x: 4, y: 4)
                .shadow(color: Color.black.opacity(0.1), radius: 2)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(drift.title)
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(.textPrimary)
                        .lineLimit(1)
                    
                    Spacer()
                    
                    Text(drift.lastMessageTime ?? "")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.textSecondary)
                }
                
                HStack {
                    Text(drift.lastMessage ?? "Start the conversation!")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(drift.unreadCount > 0 ? .textPrimary : .textSecondary)
                        .lineLimit(1)
                    
                    Spacer()
                    
                    HStack(spacing: 8) {
                        Text(drift.status.rawValue)
                            .font(.system(size: 9, weight: .black))
                            .foregroundColor(drift.status.color)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(drift.status.color.opacity(0.1))
                            .cornerRadius(4)
                        
                        if drift.unreadCount > 0 {
                            Text("\(drift.unreadCount)")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(.white)
                                .frame(width: 20, height: 20)
                                .background(Circle().fill(Color.brandSecondary))
                        }
                    }
                }
            }
        }
        .padding(16)
        .background(Color.surfaceMain)
        .cornerRadius(24)
        .overlay(RoundedRectangle(cornerRadius: 24).stroke(Color.appBorder, lineWidth: 1))
    }
}
