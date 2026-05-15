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
        CoffeeTab(icon: "antenna.radiowaves.left.and.right", activeIcon: "antenna.radiowaves.left.and.right", label: AppStrings.Tabs.discover),
        CoffeeTab(icon: "calendar",                          activeIcon: "calendar",                          label: AppStrings.Tabs.myPosts),
        CoffeeTab(icon: "bubble.left",                       activeIcon: "bubble.left.fill",                 label: AppStrings.Tabs.messages),
        CoffeeTab(icon: "person",                            activeIcon: "person.fill",                      label: AppStrings.Tabs.profile),
    ]

    var body: some View {
        HStack(spacing: 0) {
            ForEach(tabs.indices, id: \.self) { i in
                tabButton(index: i)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 32, style: .continuous)
                .fill(Color.backgroundMain)
                .shadow(color: Color.black.opacity(0.12), radius: 20, x: 0, y: 8)
        )
        .padding(.horizontal, 24)
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
