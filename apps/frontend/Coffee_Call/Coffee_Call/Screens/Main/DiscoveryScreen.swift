import SwiftUI

struct DiscoveryScreen: View {
    
    // MARK: - State
    
    @StateObject private var viewModel = DiscoveryViewModel()
    @Binding var selectedTab: Int
    
    @State private var selectedPerson: RadarPerson? = nil
    
    // Bottom Sheet
    @State private var sheetOffset: CGFloat = AppConstants.Layout.sheetCollapsedOffset
    @State private var dragOffset: CGFloat = 0
    
    // 4 x 2 Grid per DESIGN.md
    private let columns = [
        GridItem(.flexible(), spacing: AppConstants.Layout.elementSpacing),
        GridItem(.flexible(), spacing: AppConstants.Layout.elementSpacing),
        GridItem(.flexible(), spacing: AppConstants.Layout.elementSpacing),
        GridItem(.flexible(), spacing: AppConstants.Layout.elementSpacing)
    ]
    
    // MARK: - Derived Animation Values
    
    private var currentSheetOffset: CGFloat {
        max(AppConstants.Layout.sheetExpandedOffset, min(AppConstants.Layout.sheetCollapsedOffset, sheetOffset + dragOffset))
    }
    
    private var progress: CGFloat {
        let total = AppConstants.Layout.sheetCollapsedOffset - AppConstants.Layout.sheetExpandedOffset
        let moved = AppConstants.Layout.sheetCollapsedOffset - currentSheetOffset
        return max(0, min(1, moved / total))
    }
    
    private var radarScale: CGFloat {
        1.0 - (progress * 0.08)
    }
    
    private var radarOpacity: CGFloat {
        1.0 - (progress * 0.65)
    }
    
    private var radarBlur: CGFloat {
        progress * AppConstants.Layout.radarBlurFactor
    }
    
    // MARK: - Body
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                // MARK: Background Tap dismiss
                Color.clear
                    .contentShape(Rectangle())
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation(.spring()) { selectedPerson = nil }
                    }
                
                // MARK: Radar World
                radarLayer
                    .scaleEffect(radarScale)
                    .opacity(radarOpacity)
                    .blur(radius: radarBlur)
                    .animation(.easeInOut(duration: 0.25), value: progress)
                    .zIndex(1)
                
                // MARK: Refresh Button
                refreshButton
                    .opacity(progress < 0.55 ? 1 : 0)
                    .animation(.easeInOut(duration: 0.2), value: progress)
                    .zIndex(20)
                
                // MARK: Bottom Sheet
                CoffeeBottomSheet(sheetOffset: $sheetOffset, dragOffset: $dragOffset, geo: geo) {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: AppConstants.Layout.sectionSpacing + 6) {
                            // Drift Card (Compact Pill Redesign)
                            Button(action: {
                                selectedTab = 1
                            }) {
                                HStack(spacing: AppConstants.Layout.elementSpacing) {
                                    IconCircle(
                                        icon: AppIcons.participants,
                                        size: AppConstants.Layout.sheetHandleWidth, // 44pt
                                        iconSize: 18
                                    )
                                    
                                    VStack(alignment: .leading, spacing: 0) {
                                        Text(AppStrings.Discovery.driftsForming)
                                            .font(.captionText)
                                            .foregroundColor(.textPrimary)
                                        
                                        Text(AppStrings.Discovery.driftsFormingSub)
                                            .font(.metadata)
                                            .foregroundColor(.textSecondary)
                                    }
                                    
                                    Spacer()
                                    
                                    AppIcons.chevronRightImage
                                        .font(.bodySmall)
                                        .foregroundColor(.brandPrimary.opacity(0.4))
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(Color.surfaceMain)
                                .clipShape(Capsule())
                                .overlay(
                                    Capsule()
                                        .stroke(Color.appBorder.opacity(0.3), lineWidth: 0.5)
                                )
                            }
                            .padding(.horizontal, 4) // Tightening the horizontal margin for the pill
                            .onTapGesture {
                                withAnimation { selectedPerson = nil }
                            }
                            
                            // Interests
                            VStack(alignment: .leading, spacing: AppConstants.Layout.sectionSpacing) {
                                Text(AppStrings.Discovery.interestsNearby)
                                    .font(.system(size: AppConstants.Typography.sizeHeadline, weight: .black))
                                    .foregroundColor(.textPrimary)
                                
                                LazyVGrid(columns: columns, spacing: AppConstants.Layout.elementSpacing + 2) {
                                    ForEach(viewModel.interestCategories) { category in
                                        InterestCard(
                                            title: category.label,
                                            icon: category.icon,
                                            count: category.count,
                                            color: category.color ?? .brandPrimary
                                        )
                                    }
                                }
                            }
                            
                            Spacer(minLength: AppConstants.Layout.screenBottomSpacer + 100)
                        }
                        .padding(.horizontal, AppConstants.Layout.standardPadding)
                    }
                }
                .zIndex(15)
            }
        }
        .asCoffeePage(
            .main,
            title: AppStrings.Discovery.title,
            subtitle: AppStrings.Discovery.subtitleDefault,
            topPadding: 0,
            scrollable: false,
            rightView: {
                NotificationIconButton(count: 3) {
                    // Tap notification
                }
            }
        )
    }
}

// MARK: - Radar Layer

extension DiscoveryScreen {
    
    private var radarLayer: some View {
        VStack(spacing: 0) {
            
            // This spacer pushes the radar center to the middle of the available gap
            Spacer()
                .frame(height: (AppConstants.Layout.headerHeight + AppConstants.Layout.sheetCollapsedOffset) / 2 - 140)
            
            RadarView(
                persons: viewModel.radarPeople,
                isScanning: viewModel.isScanning,
                progress: progress,
                selectedPerson: selectedPerson,
                onPersonTap: { person in
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
                        if selectedPerson?.id == person.id {
                            selectedPerson = nil
                        } else {
                            selectedPerson = person
                        }
                    }
                }
            )
            .frame(height: 380)
            
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .blur(radius: radarBlur)
        .opacity(radarOpacity)
    }
}



// MARK: - Refresh Button

extension DiscoveryScreen {
    
    private var refreshButton: some View {
        
        VStack {
            
            Spacer()
            
            HStack {
                
                Spacer()
                
                Button(action: {
                    viewModel.refreshNearby()
                }) {
                    
                    ZStack {
                        
                        Circle()
                            .fill(.ultraThinMaterial)
                            .frame(width: AppConstants.Layout.refreshButtonSize, height: AppConstants.Layout.refreshButtonSize)
                            .shadow(color: .black.opacity(0.12), radius: 12, x: 0, y: 6)
                            .overlay(Circle().stroke(Color.white.opacity(0.5), lineWidth: 1))
                        
                        AppIcons.refreshImage
                            .font(.system(size: AppConstants.Typography.sizeTitle - 6, weight: .bold))
                            .foregroundColor(.brandPrimary)
                            .rotationEffect(.degrees(viewModel.isScanning ? 360 : 0))
                            .animation(
                                viewModel.isScanning
                                ? .linear(duration: 1).repeatForever(autoreverses: false)
                                : .default,
                                value: viewModel.isScanning
                            )
                    }
                }
                .padding(.trailing, AppConstants.Layout.standardPadding)
                .padding(.bottom, AppConstants.Layout.refreshButtonBottomPadding)
                .zIndex(30) // Explicitly higher than the sheet (15)
            }
        }
    }
}

#Preview {
    DiscoveryScreen(selectedTab: .constant(0))
}
