import SwiftUI

// MARK: - Discovery Screen
// Matches Figma Discovery page: warm background, header with greeting + icon buttons,
// search bar, icon-labelled filter chips, large 4:5 activity cards feed, FAB.
// Join confirm sheet and match confirmation sheet are included here.

struct DiscoveryScreen: View {
    @StateObject private var viewModel = DiscoveryViewModel()

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 0) {
                // Radar View
                RadarView(persons: viewModel.radarPeople)
                    .padding(.horizontal, 20)
                    .padding(.top, AppConstants.Layout.standardPadding)

                Spacer(minLength: AppConstants.Layout.sectionSpacing)

                // Interests Section
                VStack(alignment: .leading, spacing: AppConstants.Layout.elementSpacing) {
                    Text(AppStrings.Discovery.interestsNearby)
                        .font(.system(size: AppConstants.Typography.sizeTitle, weight: .black))
                        .foregroundColor(.textPrimary)
                        .padding(.horizontal, AppConstants.Layout.standardPadding)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: AppConstants.Layout.elementSpacing) {
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
                
                // Create Drift Button (Integrated into content)
                CreateDriftButton(action: {
                    viewModel.createDrift()
                })
                .padding(.horizontal, AppConstants.Layout.standardPadding)
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

    // MARK: - Subviews

}

// MARK: - Previews
struct DiscoveryScreen_Previews: PreviewProvider {
    static var previews: some View {
        DiscoveryScreen()
    }
}
