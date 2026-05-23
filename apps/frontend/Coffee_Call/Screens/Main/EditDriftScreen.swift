import SwiftUI

struct EditDriftScreen: View {
    @ObservedObject var viewModel: ManageDriftViewModel
    @StateObject private var navManager = NavigationManager.shared
    @State private var tabBarVisibilitySource = UUID().uuidString

    var body: some View {
        CreateDriftSheet(
            mode: .edit,
            drift: viewModel.drift,
            onSave: { updated in
                withAnimation {
                    viewModel.drift = updated
                }
            }
        )
        .navigationBarHidden(true)
        .onAppear {
            navManager.setTabBarHidden(true, source: tabBarVisibilitySource)
        }
        .onDisappear {
            navManager.setTabBarHidden(false, source: tabBarVisibilitySource)
        }
    }
}
