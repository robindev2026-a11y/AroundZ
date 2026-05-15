import SwiftUI

// MARK: - Floating Tab Bar

struct CoffeeTab {
    let icon: String
    let activeIcon: String
    let label: String
}

struct FloatingTabBar: View {
    @Binding var selectedTab: Int

    private let tabs: [CoffeeTab] = [
        CoffeeTab(icon: AppIcons.navAround,  activeIcon: AppIcons.navAround,   label: AppStrings.Tabs.discover),
        CoffeeTab(icon: AppIcons.navDrifts,  activeIcon: AppIcons.navDrifts,   label: AppStrings.Tabs.myPosts),
        CoffeeTab(icon: AppIcons.navChats,   activeIcon: AppIcons.navChatsFill, label: AppStrings.Tabs.messages),
        CoffeeTab(icon: AppIcons.navYou,    activeIcon: AppIcons.navYouFill,   label: AppStrings.Tabs.profile),
    ]

    var body: some View {
        HStack(spacing: 0) {
            ForEach(tabs.indices, id: \.self) { i in
                tabButton(index: i)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            ZStack {
                Capsule()
                    .fill(.ultraThinMaterial)
                Capsule()
                    .stroke(Color.white.opacity(0.4), lineWidth: 0.5)
            }
            .shadow(color: Color.black.opacity(0.08), radius: 15, x: 0, y: 8)
        )
        .padding(.horizontal, 32)
        .slideUpEntrance(delay: 0.2)
    }

    private func tabButton(index: Int) -> some View {
        let tab = tabs[index]
        let isActive = selectedTab == index

        return Button(action: {
            withAnimation(CoffeeAnimation.spring) {
                selectedTab = index
            }
        }) {
            VStack(spacing: 4) {
                Image(systemName: isActive ? tab.activeIcon : tab.icon)
                    .font(.system(size: 20, weight: isActive ? .semibold : .regular))
                    .foregroundColor(isActive ? .brandPrimary : .textSecondary)
                    .scaleEffect(isActive ? 1.12 : 1.0)
                    .animation(CoffeeAnimation.spring, value: isActive)

                Text(tab.label)
                    .font(.system(size: 10, weight: isActive ? .semibold : .regular))
                    .foregroundColor(isActive ? .brandPrimary : .textSecondary)
                    .animation(CoffeeAnimation.easeOut, value: isActive)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 6)
        }
        .pressScale(0.90)
    }
}
