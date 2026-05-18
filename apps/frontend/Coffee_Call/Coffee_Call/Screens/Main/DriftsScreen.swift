import SwiftUI

struct DriftsScreen: View {
    @StateObject private var viewModel = DriftsViewModel()
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: AppConstants.Layout.sectionSpacing) {
                // Interactive Mode Switch & Time Tabs (Lego Blocks!)
                VStack(spacing: 8) {
                    DriftModeSwitch(selectedMode: $viewModel.selectedMode)
                        .padding(.horizontal, AppConstants.Layout.standardPadding)
                        .padding(.top, 4)
                    
                    TimeStateTabs(selectedState: $viewModel.selectedTimeState)
                }
                .padding(.bottom, 8)
                
                if viewModel.selectedMode == .discover && viewModel.selectedTimeState == .all {
                    // Featured Section
                    if let first = viewModel.drifts.first {
                        NavigationLink(value: first) {
                            DriftCard(drift: first, isFeatured: true, onJoin: {})
                        }
                        .buttonStyle(.plain)
                        .padding(.horizontal, AppConstants.Layout.standardPadding)
                    }
                }
                
                // Section: Open now
                driftSection(title: AppStrings.Drifts.openNow, drifts: viewModel.filteredDrifts.filter { $0.status == .open })
                
                // Section: Starting soon
                driftSection(title: AppStrings.Drifts.startingSoon, drifts: viewModel.filteredDrifts.filter { $0.status == .startingSoon })
                
                // Section: Later today
                driftSection(title: AppStrings.Drifts.laterToday, drifts: viewModel.filteredDrifts.filter { $0.status == .tonight })
            }
            .asCoffeePage(
                .main,
                title: viewModel.title,
                subtitle: viewModel.subtitle ?? "",
                rightView: {
                    CoffeeHeaderButton(icon: AppIcons.search) {}
                    CoffeeHeaderButton(icon: AppIcons.filter) {}
                }
            )
            .navigationDestination(for: Drift.self) { drift in
                if viewModel.selectedMode == .mine {
                    ManageDriftScreen(viewModel: ManageDriftViewModel(drift: drift))
                } else {
                    DriftDetailScreen(viewModel: DriftDetailViewModel(drift: drift))
                }
            }
        }
    }
    
    private func driftSection(title: String, drifts: [Drift]) -> some View {
        VStack(alignment: .leading, spacing: AppConstants.Layout.elementSpacing) {
            if !drifts.isEmpty {
                ForEach(drifts) { drift in
                    NavigationLink(value: drift) {
                        DriftCard(drift: drift, isFeatured: false, onJoin: {})
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal, AppConstants.Layout.standardPadding)
                }
            }
        }
    }
}

#Preview {
    DriftsScreen()
}
