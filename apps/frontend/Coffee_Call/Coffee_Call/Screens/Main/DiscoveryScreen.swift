import SwiftUI

struct DiscoveryScreen: View {
    @Binding var selectedTab: Int
    @StateObject private var viewModel = DiscoveryViewModel()

    var body: some View {
        NavigationStack {
            VStack{
                VStack(alignment: .leading, spacing: 0) {
                    // 1. Radar Section
                    ZStack(alignment: .bottomTrailing) {
                        RadarView(
                            persons: viewModel.radarPeople,
                            isScanning: viewModel.isScanning
                        )
                        .frame(height: 310) // Slightly taller to fill vertical space
                        
                        // Refresh Button at Bottom Right of Radar
                        Button(action: { viewModel.refreshNearby() }) {
                            ZStack {
                                Circle()
                                    .fill(Color.surfaceMain)
                                    .frame(width: 38, height: 38)
                                    .shadow(color: Color.black.opacity(0.08), radius: 6, x: 0, y: 3)
                                
                                Image(systemName: AppIcons.refresh)
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(.brandPrimary)
                                    .rotationEffect(.degrees(viewModel.isScanning ? 360 : 0))
                            }
                        }
                        .disabled(viewModel.isScanning)
                        .padding(.trailing, AppConstants.Layout.standardPadding)
                        .padding(.bottom, AppConstants.Layout.standardPadding)
                        .animation(viewModel.isScanning ? .linear(duration: 1).repeatForever(autoreverses: false) : .default, value: viewModel.isScanning)
                    }
                    .padding(.top, 8)

                    // 2. Context Card (Tightened)
                    contextCard
                        .padding(.horizontal, AppConstants.Layout.standardPadding)
                        .padding(.top, AppConstants.Layout.elementSpacing)

                    // 3. Interests Section
                    VStack(alignment: .leading, spacing: AppConstants.Layout.elementSpacing) {
                        HStack {
                            Text(AppStrings.Discovery.interestsNearby)
                                .font(.heading2)
                                .foregroundColor(.textPrimary)
                            
                            Spacer()
                        }
                        .padding(.horizontal, AppConstants.Layout.standardPadding)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: AppConstants.Layout.subElementSpacing * 1.5) {
                                ForEach(viewModel.interestCategories) { category in
                                    InterestCard(
                                        title: category.label,
                                        icon: category.icon,
                                        count: category.count,
                                        isSelected: viewModel.selectedCategory == category.label,
                                        action: {
                                            viewModel.selectCategory(category.label)
                                        }
                                    )
                                }
                            }
                            .padding(.horizontal, AppConstants.Layout.standardPadding)
                        }
                    }
                    .padding(.top, 40) // More space to fill the screen
                    .padding(.bottom, AppConstants.Layout.screenBottomSpacer)
                }
            }
            .background(Color.backgroundMain.ignoresSafeArea())
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

    private var contextCard: some View {
        HStack(spacing: 10) {
            ZStack {
                Circle()
                    .fill(Color.brandPrimary.opacity(0.1))
                    .frame(width: 38, height: 38)
                Image(systemName: AppIcons.participants)
                    .foregroundColor(.brandPrimary)
                    .font(.system(size: 15))
            }
            
            VStack(alignment: .leading, spacing: 0) {
                Text(AppStrings.Discovery.contextTitle)
                    .font(.system(size: 12, weight: .black))
                    .foregroundColor(.textPrimary)
                Text(AppStrings.Discovery.contextSubtitle)
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.textSecondary.opacity(0.7))
            }
            
            Spacer()
            
            Button(AppStrings.Discovery.seeNearbyDrifts) {
                withAnimation(CoffeeAnimation.spring) {
                    selectedTab = 1
                }
            }
            .font(.system(size: 10, weight: .black))
            .foregroundColor(.brandPrimary)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(Color.brandPrimary.opacity(0.08))
            .clipShape(Capsule())
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 10)
        .background(Color.surfaceMain)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Color.appBorder.opacity(0.4), lineWidth: 1)
        )
    }
}


// MARK: - Preview
struct DiscoveryScreen_Previews: PreviewProvider {
    static var previews: some View {
        DiscoveryScreen(selectedTab: .constant(0))
    }
}
