import SwiftUI

struct DriftsScreen: View {
    @StateObject private var viewModel = DriftsViewModel()
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                Color.backgroundMain.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Top Bar
                    headerView
                        .padding(.top, 16)
                        .padding(.horizontal, 24)
                    
                    // Mode Switch
                    DriftModeSwitch(selectedMode: $viewModel.selectedMode)
                        .padding(.horizontal, 24)
                        .padding(.top, 24)
                    
                    // Time-State Tabs
                    TimeStateTabs(selectedState: $viewModel.selectedTimeState)
                        .padding(.top, 24)
                    
                    // Content List
                    ScrollView(showsIndicators: false) {
                        VStack(alignment: .leading, spacing: 28) {
                            
                            if viewModel.selectedTimeState == .all {
                                // Featured Section
                                VStack(alignment: .leading, spacing: 16) {
                                    HStack {
                                        Image(systemName: AppIcons.sparkles)
                                            .foregroundColor(.brandSecondary)
                                        Text(AppStrings.Drifts.featured)
                                            .font(.system(size: 16, weight: .bold))
                                            .foregroundColor(.textPrimary)
                                    }
                                    .padding(.horizontal, 24)
                                    
                                    if let first = viewModel.drifts.first {
                                        NavigationLink(value: first) {
                                            DriftCard(drift: first, isFeatured: true, onJoin: {})
                                        }
                                        .buttonStyle(.plain)
                                        .padding(.horizontal, 24)
                                    }
                                }
                            }
                            
                            // Section: Open now
                            driftSection(title: AppStrings.Drifts.openNow, drifts: viewModel.filteredDrifts.filter { $0.status == .open })
                            
                            // Section: Starting soon
                            driftSection(title: AppStrings.Drifts.startingSoon, drifts: viewModel.filteredDrifts.filter { $0.status == .startingSoon })
                            
                            // Section: Later today
                            driftSection(title: AppStrings.Drifts.laterToday, drifts: viewModel.filteredDrifts.filter { $0.status == .tonight })
                            
                            Spacer(minLength: 120)
                        }
                        .padding(.top, 28)
                    }
                }
            }
            .navigationDestination(for: Drift.self) { drift in
                if drift.isMine {
                    ManageDriftScreen(viewModel: ManageDriftViewModel(drift: drift))
                } else {
                    DriftDetailScreen(viewModel: DriftDetailViewModel(drift: drift))
                }
            }
        }
    }
    
    private var headerView: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(AppStrings.Drifts.title)
                    .font(.system(size: 32, weight: .black))
                    .foregroundColor(.textPrimary)
                Text(AppStrings.Drifts.subtitle)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.textSecondary)
            }
            
            Spacer()
            
            HStack(spacing: 12) {
                IconButton(icon: AppIcons.search) {}
                IconButton(icon: AppIcons.filter) {}
            }
        }
    }
    
    private func driftSection(title: String, drifts: [Drift]) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            if !drifts.isEmpty {
                HStack {
                    Text(title)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.textPrimary)
                    Spacer()
                    Button(AppStrings.Drifts.seeAll) { }
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.brandPrimary)
                }
                .padding(.horizontal, 24)
                
                ForEach(drifts) { drift in
                    NavigationLink(value: drift) {
                        DriftCard(drift: drift, isFeatured: false, onJoin: {})
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal, 24)
                }
            }
        }
    }
}

private struct IconButton: View {
    let icon: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.textPrimary)
                .frame(width: 44, height: 44)
                .background(Color.surfaceMain)
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.appBorder, lineWidth: 1))
        }
    }
}

struct DriftsScreen_Previews: PreviewProvider {
    static var previews: some View {
        DriftsScreen()
    }
}
