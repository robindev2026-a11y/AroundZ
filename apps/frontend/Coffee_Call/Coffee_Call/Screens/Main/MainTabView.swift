import SwiftUI

// MARK: - Main Tab View
// Implements the 5-item navigation model with Create as a modal sheet.

struct MainTabView: View {
    @State private var selectedTab = 0
    @State private var isShowingCreateSheet = false
    @StateObject private var navManager = NavigationManager.shared

    var body: some View {
        ZStack(alignment: .bottom) {
            // Page content
            Group {
                switch selectedTab {
                case 0: DiscoveryScreen(selectedTab: $selectedTab)
                case 1: DriftsScreen()
                case 2: ChatsListScreen()
                case 3: ProfileScreen()
                default: DiscoveryScreen(selectedTab: $selectedTab)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            if !navManager.isTabBarHidden {
                // Bottom Blur Shelf
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
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .ignoresSafeArea()

                // Floating tab bar
                FloatingTabBar(
                    selectedTab: $selectedTab,
                    onCreateTap: { isShowingCreateSheet = true }
                )
                .padding(.bottom, AppConstants.Layout.floatingTabBarBottomPadding)
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .ignoresSafeArea(edges: .bottom)
        .animation(.spring(), value: navManager.isTabBarHidden)
        .sheet(isPresented: $isShowingCreateSheet) {
            CreateDriftScreen()
        }
    }
}

// MARK: - Preview
struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
            .environmentObject(AuthViewModel())
    }
}
