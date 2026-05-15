import SwiftUI

struct DriftsScreen: View {
    @StateObject private var viewModel = DriftsViewModel()
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Mode Switch
                DriftModeSwitch(selectedMode: $viewModel.selectedMode)
                    .padding(.horizontal, AppConstants.Layout.standardPadding)
                    .padding(.top, AppConstants.Layout.standardPadding)
                
                // Time-State Tabs
                TimeStateTabs(selectedState: $viewModel.selectedTimeState)
                    .padding(.top, AppConstants.Layout.standardPadding)
                
                VStack(alignment: .leading, spacing: AppConstants.Layout.sectionSpacing) {
                    if viewModel.selectedTimeState == .all {
                        // Featured Section
                        VStack(alignment: .leading, spacing: AppConstants.Layout.elementSpacing) {
                            HStack {
                                Image(systemName: AppIcons.sparkles)
                                    .foregroundColor(.brandSecondary)
                                Text(AppStrings.Drifts.featured)
                                    .font(.system(size: AppConstants.Typography.sizeBody, weight: .bold))
                                    .foregroundColor(.textPrimary)
                            }
                            .padding(.horizontal, AppConstants.Layout.standardPadding)
                            
                            if let first = viewModel.drifts.first {
                                NavigationLink(value: first) {
                                    DriftCard(drift: first, isFeatured: true, onJoin: {})
                                }
                                .buttonStyle(.plain)
                                .padding(.horizontal, AppConstants.Layout.standardPadding)
                            }
                        }
                    }
                    
                    // Section: Open now
                    driftSection(title: AppStrings.Drifts.openNow, drifts: viewModel.filteredDrifts.filter { $0.status == .open })
                    
                    // Section: Starting soon
                    driftSection(title: AppStrings.Drifts.startingSoon, drifts: viewModel.filteredDrifts.filter { $0.status == .startingSoon })
                    
                    // Section: Later today
                    driftSection(title: AppStrings.Drifts.laterToday, drifts: viewModel.filteredDrifts.filter { $0.status == .tonight })
                }
                .padding(.top, AppConstants.Layout.sectionSpacing)
            }
            .asCoffeeScreen(config: viewModel)
            .navigationDestination(for: Drift.self) { drift in
                if drift.isMine {
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
                HStack {
                    Text(title)
                        .font(.system(size: AppConstants.Typography.sizeHeadline, weight: .bold))
                        .foregroundColor(.textPrimary)
                    Spacer()
                    Button(AppStrings.Drifts.seeAll) { }
                        .font(.system(size: AppConstants.Typography.sizeCaption + 1, weight: .bold))
                        .foregroundColor(.brandPrimary)
                }
                .padding(.horizontal, AppConstants.Layout.standardPadding)
                
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

struct DriftsScreen_Previews: PreviewProvider {
    static var previews: some View {
        DriftsScreen()
    }
}
