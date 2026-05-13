import SwiftUI

// MARK: - Main Tab View

struct MainTabView: View {
    @State private var selectedTab = 0

    var body: some View {
        ZStack(alignment: .bottom) {

            // Page content — no native TabView chrome
            Group {
                switch selectedTab {
                case 0: DiscoveryScreen()
                case 1: placeholderView(title: AppStrings.Tabs.myPosts,   icon: "list.bullet")
                case 2: placeholderView(title: AppStrings.Tabs.messages,  icon: "bubble.left.fill")
                case 3: placeholderView(title: AppStrings.Tabs.profile,   icon: "person.fill")
                default: DiscoveryScreen()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            // Floating tab bar sits on top
            FloatingTabBar(selectedTab: $selectedTab)
                .padding(.bottom, 20)
        }
        .ignoresSafeArea(edges: .bottom)
    }

    private func placeholderView(title: String, icon: String) -> some View {
        VStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 48, weight: .light))
                .foregroundColor(.brandPrimary)
            Text(title)
                .font(.heading1)
                .foregroundColor(.textPrimary)
            Text("Coming soon")
                .font(.bodyStandard)
                .foregroundColor(.textSecondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.backgroundMain.ignoresSafeArea())
    }
}

// MARK: - Preview
struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
    }
}
