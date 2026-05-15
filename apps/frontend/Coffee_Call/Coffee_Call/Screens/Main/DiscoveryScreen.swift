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

                        Spacer(minLength: 24)

                        // Radar View
                        RadarView(persons: viewModel.radarPeople)
                            .padding(.horizontal, 20)

                        Spacer(minLength: 32)

                        // Interests Section
                        VStack(alignment: .leading, spacing: 20) {
                            Text(AppStrings.Discovery.interestsNearby)
                                .font(.system(size: 20, weight: .black))
                                .foregroundColor(.textPrimary)
                                .padding(.horizontal, AppConstants.Layout.standardPadding)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 16) {
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
                        
                        // Activity Feed (Horizontal)
                        VStack(alignment: .leading, spacing: 20) {
                            HStack {
                                Text("Starting soon nearby")
                                    .font(.system(size: 20, weight: .black))
                                    .foregroundColor(.textPrimary)
                                Spacer()
                                Button("See all") {}
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(.brandPrimary)
                            }
                            .padding(.horizontal, AppConstants.Layout.standardPadding)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 16) {
                                    ForEach(viewModel.featuredDrifts) { drift in
                                        NavigationLink(value: drift) {
                                            ActivityCardView(drift: drift)
                                                .frame(width: 280)
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }
                                .padding(.horizontal, AppConstants.Layout.standardPadding)
                            }
                        }
                        .padding(.top, 32)
                        
                        // Primary CTA
                        CreateDriftButton(action: {
                            viewModel.createDrift()
                        })
                        .padding(.horizontal, AppConstants.Layout.standardPadding)
                        .padding(.top, 32)
                        
                        Spacer(minLength: 120) // Space for floating tab bar
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

    // MARK: - Subviews

    private var headerView: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 3) {
                Text(AppStrings.Tabs.discover)
                    .font(.system(size: 32, weight: .black, design: .default))
                    .foregroundColor(.textPrimary)
                Text("\(viewModel.radarPeople.count) people open to plans around you")
                    .font(.system(size: 14, weight: .medium, design: .default))
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
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(icon == AppIcons.bell ? .brandPurple : .brandPrimary)
                .frame(width: 48, height: 48)
                .background(Color.surfaceMain)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(Color.appBorder, lineWidth: 1)
                )
                .shadow(color: Color.textPrimary.opacity(0.04), radius: 8, x: 0, y: 2)
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
