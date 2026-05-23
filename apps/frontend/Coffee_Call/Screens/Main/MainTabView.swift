import SwiftUI

// MARK: - Main Tab View
// Implements the 5-item navigation model with Create as a modal sheet.

struct MainTabView: View {
    @State private var selectedTab = 0
    @State private var showCreateDriftSheet = false
    @StateObject private var driftsViewModel = DriftsViewModel()
    @StateObject private var navManager = NavigationManager.shared

    var body: some View {
        ZStack(alignment: .bottom) {
            // Page content
            Group {
                switch selectedTab {
                case 0: DiscoveryScreen(selectedTab: $selectedTab)
                case 1: DriftsScreen(viewModel: driftsViewModel)
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
                    onCreateTap: {
                        showCreateDriftSheet = true
                    }
                )
                .padding(.bottom, AppConstants.Layout.floatingTabBarBottomPadding)
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .ignoresSafeArea(edges: .bottom)
        .animation(.spring(), value: navManager.isTabBarHidden)
        .sheet(isPresented: $showCreateDriftSheet) {
            if #available(iOS 16.4, *) {
                CreateDriftSheet(onCreateSucceeded: {
                    selectedTab = 1
                    driftsViewModel.selectedMode = .mine
                    driftsViewModel.selectedTimeState = .all
                    driftsViewModel.selectedTimeframe = "All"
                    driftsViewModel.selectedCategory = nil
                    driftsViewModel.selectedCategories = []
                    driftsViewModel.selectedDistanceRadius = 10.0
                    driftsViewModel.searchQuery = ""
                    driftsViewModel.debouncedSearchQuery = ""
                    driftsViewModel.isSearchActive = false
                })
                    .presentationDetents([.fraction(0.96)])
                    .presentationCornerRadius(AppConstants.Layout.createSheetRadius)
                    .presentationBackground(.clear)
                    .presentationDragIndicator(.hidden)
            } else {
                CreateDriftSheet(onCreateSucceeded: {
                    selectedTab = 1
                    driftsViewModel.selectedMode = .mine
                    driftsViewModel.selectedTimeState = .all
                    driftsViewModel.selectedTimeframe = "All"
                    driftsViewModel.selectedCategory = nil
                    driftsViewModel.selectedCategories = []
                    driftsViewModel.selectedDistanceRadius = 10.0
                    driftsViewModel.searchQuery = ""
                    driftsViewModel.debouncedSearchQuery = ""
                    driftsViewModel.isSearchActive = false
                })
                    .presentationDetents([.fraction(0.96)])
                    .presentationDragIndicator(.hidden)
            }
        }
    }
}

// MARK: - Preview
// Force preview thunk refresh after DerivedData cleanup
struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
            .environmentObject(AuthViewModel())
    }
}
