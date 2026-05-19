import SwiftUI

// MARK: - Floating Tab Bar
// Redesigned for Social Refresh: Reduced scale (~18% smaller).
// Conforms to the new AppConstants and stays within safe boundaries.

struct CoffeeTab {
    let icon: String
    let activeIcon: String
    let label: String
    let isAction: Bool
}

struct FloatingTabBar: View {
    @Binding var selectedTab: Int
    var onCreateTap: () -> Void

    private let tabs: [CoffeeTab] = [
        CoffeeTab(icon: AppIcons.navAround,  activeIcon: AppIcons.navAround,   label: AppStrings.Tabs.discover, isAction: false),
        CoffeeTab(icon: AppIcons.navDrifts,  activeIcon: AppIcons.navDrifts,   label: AppStrings.Tabs.myPosts,  isAction: false),
        CoffeeTab(icon: "",                 activeIcon: "",                   label: AppStrings.Tabs.create,   isAction: true),
        CoffeeTab(icon: AppIcons.navChats,   activeIcon: AppIcons.navChatsFill, label: AppStrings.Tabs.messages, isAction: false),
        CoffeeTab(icon: AppIcons.navYou,    activeIcon: AppIcons.navYouFill,   label: AppStrings.Tabs.profile,  isAction: false),
    ]

    var body: some View {
        HStack(spacing: 0) {
            ForEach(tabs.indices, id: \.self) { i in
                if tabs[i].isAction {
                    createActionButton()
                } else {
                    tabButton(index: i)
                }
            }
        }
        .padding(.horizontal, 16)
        .frame(height: 78) // Match DESIGN.md spec
        .background(
            ZStack {
                // Main Glassmorphic Body
                RoundedRectangle(cornerRadius: 34, style: .continuous)
                    .fill(Color.surfaceMain.opacity(0.1))
                    .background(.ultraThinMaterial)
                
                // Frosted Highlight (Top edge light)
                RoundedRectangle(cornerRadius: 34, style: .continuous)
                    .stroke(
                        LinearGradient(
                            colors: [.white.opacity(0.6), .white.opacity(0.1), .clear],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.5
                    )
                
                // Outer Border (Subtle depth)
                RoundedRectangle(cornerRadius: 34, style: .continuous)
                    .stroke(Color.appBorder.opacity(0.2), lineWidth: 0.5)
            }
        )
        .clipShape(RoundedRectangle(cornerRadius: 34, style: .continuous))
        // Enhanced shadows for "Floating" glass look
        .shadow(color: Color.textPrimary.opacity(0.05), radius: 10, x: 0, y: 5)
        .shadow(color: Color.textPrimary.opacity(0.03), radius: 20, x: 0, y: 15)
        .padding(.horizontal, 20) // Match DESIGN.md spec (20pt margins)
        .padding(.bottom, 8)
    }

    private func tabButton(index: Int) -> some View {
        let tab = tabs[index]
        let mappedIndex = index > 2 ? index - 1 : index
        let isActive = selectedTab == mappedIndex

        return Button(action: {
            withAnimation(CoffeeAnimation.spring) {
                selectedTab = mappedIndex
            }
        }) {
            VStack(spacing: 2) {
                Image(systemName: isActive ? tab.activeIcon : tab.icon)
                    .font(.system(size: 17, weight: isActive ? .bold : .medium))
                    .foregroundColor(isActive ? .brandPrimary : .textSecondary.opacity(0.4))
                    .frame(height: 22)

                Text(tab.label)
                    .font(.system(size: AppConstants.Typography.sizeMicro, weight: isActive ? .black : .bold))
                    .foregroundColor(isActive ? .brandPrimary : .textSecondary.opacity(0.4))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 6)
        }
        .pressScale(0.92)
    }

    private func createActionButton() -> some View {
        Button(action: onCreateTap) {
            VStack(spacing: 2) {
                ZStack {
                    Circle()
                        .fill(Color.brandPrimary)
                        .frame(width: 38, height: 38)
                        .shadow(color: Color.brandPrimary.opacity(0.2), radius: 5, x: 0, y: 3)
                    
                    AppIcons.plusImage
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                }
                
                Text(AppStrings.Tabs.create)
                    .font(.system(size: AppConstants.Typography.sizeMicro, weight: .bold))
                    .foregroundColor(.textSecondary.opacity(0.4))
            }
            .frame(maxWidth: .infinity)
        }
        .pressScale(0.90)
    }
}
