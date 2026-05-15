import SwiftUI

// MARK: - Discovery Screen
// Matches Figma Discovery page: warm background, header with greeting + icon buttons,
// search bar, icon-labelled filter chips, large 4:5 activity cards feed, FAB.
// Join confirm sheet and match confirmation sheet are included here.

struct DiscoveryScreen: View {
    @StateObject private var viewModel = DiscoveryViewModel()

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                Color.backgroundMain.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 0) {
                        // Header
                        headerView
                            .padding(.top, AppConstants.Layout.headerTopPadding)
                            .padding(.horizontal, AppConstants.Layout.standardPadding)

                        Spacer(minLength: AppConstants.Layout.standardPadding)

                        // Radar View
                        RadarView(persons: viewModel.radarPeople)
                            .padding(.horizontal, 20)

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
                        
                        Spacer(minLength: AppConstants.Layout.screenBottomSpacer) // Space for floating CTA + tab bar
                    }
                }
                
                // Floating Primary CTA
                CreateDriftButton(action: {
                    viewModel.createDrift()
                })
                .padding(.horizontal, AppConstants.Layout.standardPadding)
                .padding(.bottom, 110) // Positioned above the floating tab bar
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

    // MARK: - Subviews

    private var headerView: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 3) {
                Text(AppStrings.Tabs.discover)
                    .font(.system(size: AppConstants.Typography.sizeDisplay, weight: .black, design: .default))
                    .foregroundColor(.textPrimary)
                Text("\(viewModel.radarPeople.count) people open to plans around you")
                    .font(.system(size: AppConstants.Typography.sizeCaption + 1, weight: .medium, design: .default))
                    .foregroundColor(.textSecondary)
            }

            Spacer()

            headerIconButton(icon: AppIcons.bell) {}
                .overlay(alignment: .topTrailing) {
                    Circle()
                        .fill(Color.brandPrimary)
                        .frame(width: 9, height: 9)
                        .overlay(Circle().stroke(Color.backgroundMain, lineWidth: 2))
                        .offset(x: -4, y: 4)
                }
        }
    }

    private func headerIconButton(icon: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: AppConstants.Typography.sizeHeadline - 1, weight: .semibold))
                .foregroundColor(icon == AppIcons.bell ? .brandPurple : .brandPrimary)
                .frame(width: 48, height: 48)
                .background(Color.surfaceMain)
                .clipShape(RoundedRectangle(cornerRadius: AppConstants.UI.cornerRadiusSmall, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: AppConstants.UI.cornerRadiusSmall, style: .continuous)
                        .stroke(Color.appBorder, lineWidth: 1)
                )
                .shadow(color: Color.textPrimary.opacity(AppConstants.UI.opacitySubtle), radius: 8, x: 0, y: 2)
        }
        .pressScale(0.90)
    }
}

// MARK: - Previews
struct DiscoveryScreen_Previews: PreviewProvider {
    static var previews: some View {
        DiscoveryScreen()
    }
}
