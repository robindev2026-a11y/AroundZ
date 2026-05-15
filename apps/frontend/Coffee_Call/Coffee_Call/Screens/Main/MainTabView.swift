import SwiftUI

// MARK: - Main Tab View
// Implements the 5-item navigation model with Create as a modal sheet.

struct MainTabView: View {
    @State private var selectedTab = 0
    @State private var isShowingCreateSheet = false

    var body: some View {
        ZStack(alignment: .bottom) {
            // Page content
            Group {
                switch selectedTab {
                case 0: DiscoveryScreen()
                case 1: DriftsScreen()
                case 2: ChatsListScreen()
                case 3: ProfileScreen()
                default: DiscoveryScreen()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            // Bottom Blur Shelf
            // Provides a diffuse blurry feel for content scrolling behind the tab bar
            Rectangle()
                .fill(.ultraThinMaterial)
                .frame(height: 120)
                .mask(
                    LinearGradient(
                        colors: [.clear, .black.opacity(0.8), .black],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .ignoresSafeArea()

            // Floating tab bar
            FloatingTabBar(
                selectedTab: $selectedTab,
                onCreateTap: { isShowingCreateSheet = true }
            )
            .padding(.bottom, AppConstants.Layout.floatingTabBarBottomPadding)
        }
        .ignoresSafeArea(edges: .bottom)
        .sheet(isPresented: $isShowingCreateSheet) {
            CreateDriftScreen()
        }
    }
}

// MARK: - Preview
struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
    }
}
