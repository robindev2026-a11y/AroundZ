import SwiftUI

struct ChatsListScreen: View {
    @StateObject private var viewModel = ChatsViewModel()
    @State private var selectedFilter: ChatFilter = .active
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: AppConstants.Layout.elementSpacing) {
                // 1. Status Filter Chips Row
                statusChipsRow
                    .padding(.top, AppConstants.Layout.subElementSpacing)
                
                // 2. Main Content Mode Selector
                let chats = viewModel.filteredChats(for: selectedFilter)
                
                if chats.isEmpty {
                    emptyStateView
                        .padding(.top, AppConstants.Layout.sectionSpacing)
                } else {
                    compactListView(chats: chats)
                }
            }
            .asCoffeePage(
                .main,
                title: viewModel.title,
                subtitle: viewModel.subtitle ?? AppStrings.Chat.subtitle,
                scrollable: false
            )
            .navigationDestination(for: Drift.self) { drift in
                DriftChatScreen(viewModel: DriftChatViewModel(drift: drift))
            }
        }
        .onAppear {
            NavigationManager.shared.resetTabBarVisibility()
        }
    }
    
    // MARK: - Status Filter Row
    private var statusChipsRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: AppConstants.Layout.subElementSpacing) {
                ForEach(ChatFilter.allCases) { filter in
                    Button(action: {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                            selectedFilter = filter
                        }
                    }) {
                        Text(filter.title)
                            .font(.bodySmall)
                            .foregroundColor(selectedFilter == filter ? .brandPrimary : .textSecondary)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(
                                Capsule()
                                    .fill(selectedFilter == filter ? Color.brandPrimary.opacity(0.12) : Color.surfaceMain)
                            )
                            .overlay(
                                Capsule()
                                    .stroke(selectedFilter == filter ? Color.brandPrimary.opacity(0.3) : Color.appBorder, lineWidth: 1)
                            )
                    }
                    .pressScale(0.95)
                }
            }
            .padding(.horizontal, AppConstants.Layout.standardPadding)
        }
    }
    

    
    // MARK: - Compact Rooms List View Mode
    private func compactListView(chats: [Drift]) -> some View {
        ScrollView {
            VStack(spacing: 12) {
                ForEach(chats) { drift in
                    NavigationLink(value: drift) {
                        CompactChatRow(drift: drift)
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal, AppConstants.Layout.standardPadding)
                }
            }
            .padding(.vertical, 12)
        }
    }
    

    
    // MARK: - Empty State
    private var emptyStateView: some View {
        VStack(spacing: AppConstants.Layout.elementSpacing) {
            ZStack {
                Circle()
                    .fill(Color.brandPrimary.opacity(0.05))
                    .frame(width: 100, height: 100)
                Image(systemName: "bubble.left.and.bubble.right.fill")
                    .font(.system(size: 36))
                    .foregroundColor(.brandPrimary)
            }
            
            VStack(spacing: AppConstants.Layout.subElementSpacing - 2) {
                Text(AppStrings.Chat.emptyTitle)
                    .font(.heading2)
                    .foregroundColor(.textPrimary)
                Text(AppStrings.Chat.emptySubtitle)
                    .font(.bodyStandard)
                    .foregroundColor(.textSecondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, AppConstants.Layout.elementSpacing)
            
            Button(action: {
                // Return to Discover Screen tab index or Nearby Drifts (handled by Parent Router)
            }) {
                Text(AppStrings.Chat.exploreCTA)
                    .font(.buttonText)
                    .foregroundColor(.white)
                    .padding(.horizontal, 32)
                    .frame(height: 56)
                    .background(Color.brandPrimary)
                    .cornerRadius(28)
                    .shadow(color: Color.brandPrimary.opacity(0.2), radius: 8, x: 0, y: 4)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(AppConstants.Layout.sectionSpacing)
        .background(Color.surfaceMain)
        .cornerRadius(AppConstants.UI.cornerRadiusLarge)
        .overlay(
            RoundedRectangle(cornerRadius: AppConstants.UI.cornerRadiusLarge)
                .stroke(Color.appBorder, lineWidth: 1)
        )
        .padding(.horizontal, AppConstants.Layout.standardPadding)
    }
}



// MARK: - Reusable Compact Row View
struct CompactChatRow: View {
    let drift: Drift
    
    var body: some View {
        HStack(spacing: 12) {
            // Icon well (38x38 circle)
            ZStack {
                Circle()
                    .fill(drift.category.color.opacity(0.12))
                    .frame(width: 38, height: 38)
                
                Image(systemName: drift.category.icon)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(drift.category.color)
            }
            
            VStack(alignment: .leading, spacing: 3) {
                HStack(alignment: .firstTextBaseline) {
                    Text(drift.title)
                        .font(.bodySmall)
                        .foregroundColor(.textPrimary)
                        .lineLimit(1)
                    
                    Spacer()
                    
                    Text(drift.lastMessageTime ?? "")
                        .font(.metadata)
                        .foregroundColor(.textSecondary)
                }
                
                HStack(spacing: 8) {
                    Text(drift.lastMessage ?? "Start coordinating!")
                        .font(.captionText)
                        .foregroundColor(drift.unreadCount > 0 ? .textPrimary : .textSecondary)
                        .lineLimit(1)
                    
                    Spacer()
                    
                    if drift.unreadCount > 0 {
                        ZStack {
                            Circle()
                                .fill(Color.statusSuccess)
                                .frame(width: 18, height: 18)
                            
                            if drift.unreadCount > 1 {
                                Text("\(drift.unreadCount)")
                                    .font(.system(size: 9, weight: .black))
                                    .foregroundColor(.white)
                            }
                        }
                    }
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .frame(height: 60)
        .background(Color.surfaceMain)
        .cornerRadius(18)
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(Color.appBorder, lineWidth: 1)
        )
        .pressScale(0.98)
    }
}



struct ChatsListScreen_Previews: PreviewProvider {
    static var previews: some View {
        ChatsListScreen()
    }
}
