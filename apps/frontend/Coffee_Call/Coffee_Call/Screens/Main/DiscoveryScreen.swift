import SwiftUI

struct DiscoveryScreen: View {
    
    // MARK: - State
    
    @StateObject private var viewModel = DiscoveryViewModel()
    @Binding var selectedTab: Int
    
    @State private var selectedPerson: RadarPerson? = nil
    
    // Bottom Sheet
    @State private var sheetOffset: CGFloat = AppConstants.Layout.sheetCollapsedOffset
    @GestureState private var dragOffset: CGFloat = 0
    
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
        progress * 8
    }
    
    // MARK: - Body
    
    var body: some View {
        GeometryReader { geo in
            
            ZStack {
                
                // MARK: Background
                
                Color.backgroundMain
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
                
                // MARK: Header
                
                VStack {
                    CoffeeHeader(
                        title: AppStrings.Discovery.title,
                        subtitle: AppStrings.Discovery.subtitleDefault,
                        notificationCount: 3
                    )
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                    
                    Spacer()
                }
                .zIndex(20)
                
                // MARK: Refresh Button
                
                refreshButton
                    .opacity(progress < 0.55 ? 1 : 0)
                    .animation(.easeInOut(duration: 0.2), value: progress)
                    .zIndex(20)
                
                // MARK: Bottom Sheet
                
                bottomSheet(geo: geo)
                    .zIndex(15)
            }
        }
    }
}

// MARK: - Radar Layer

extension DiscoveryScreen {
    
    private var radarLayer: some View {
        
        VStack {
            
            Spacer()
                .frame(height: AppConstants.Layout.headerHeight + 38)
            
            RadarView(
                persons: viewModel.radarPeople,
                isScanning: viewModel.isScanning,
                selectedPerson: selectedPerson,
                onPersonTap: { person in
                    
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.82)) {
                        
                        if selectedPerson?.id == person.id {
                            selectedPerson = nil
                        } else {
                            selectedPerson = person
                        }
                    }
                }
            )
            
            Spacer()
        }
        .ignoresSafeArea()
    }
}

// MARK: - Bottom Sheet

extension DiscoveryScreen {
    
    @ViewBuilder
    private func bottomSheet(geo: GeometryProxy) -> some View {
        
        VStack(spacing: 0) {
            
            // Handle
            
            Capsule()
                .fill(Color.textSecondary.opacity(0.3))
                .frame(width: 44, height: 5)
                .padding(.top, 10)
                .padding(.bottom, 18)
            
            // Internal Scroll
            
            ScrollView(showsIndicators: false) {
                
                VStack(spacing: 28) {
                    
                    // Drift Card
                    
                    HStack(spacing: 18) {
                        
                        ZStack {
                            
                            Circle()
                                .fill(Color.brandPrimary.opacity(0.1))
                                .frame(width: 62, height: 62)
                            
                            Image(systemName: AppIcons.participants)
                                .font(.system(size: 24))
                                .foregroundColor(.brandPrimary)
                        }
                        
                        VStack(alignment: .leading, spacing: 2) {
                            
                            Text(AppStrings.Discovery.driftsForming)
                                .font(.system(size: 16, weight: .black))
                                .foregroundColor(.textPrimary)
                            
                            Text(AppStrings.Discovery.driftsFormingSub)
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.textSecondary)
                        }
                        
                        Spacer()
                        
                        Button(action: {
                            selectedTab = 1
                        }) {
                            
                            Text(AppStrings.Discovery.seeNearbyDrifts)
                                .font(.system(size: 12, weight: .black))
                                .foregroundColor(.brandPrimary)
                                .padding(.horizontal, AppConstants.Layout.buttonPaddingHorizontal)
                                .padding(.vertical, AppConstants.Layout.buttonPaddingVertical)
                                .background(Color.brandPrimary.opacity(0.12))
                                .clipShape(Capsule())
                        }
                    }
                    .padding(AppConstants.Layout.buttonPaddingHorizontal)
                    .background(Color.surfaceMain)
                    .clipShape(RoundedRectangle(cornerRadius: AppConstants.UI.cornerRadiusLarge))
                    .overlay(
                        RoundedRectangle(cornerRadius: AppConstants.UI.cornerRadiusLarge)
                            .stroke(Color.appBorder.opacity(0.3), lineWidth: 0.5)
                    )
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
                    
                    Spacer(minLength: 180)
                }
                .padding(.horizontal, 20)
            }
        }
        .frame(width: geo.size.width, height: geo.size.height)
        .background(
            RoundedRectangle(cornerRadius: AppConstants.Layout.sheetRadius, style: .continuous)
                .fill(.ultraThinMaterial)
                .shadow(color: .black.opacity(0.08), radius: 18, x: 0, y: -8)
        )
        .offset(y: currentSheetOffset)
        .gesture(
            DragGesture()
                .updating($dragOffset) { value, state, _ in
                    state = value.translation.height
                }
                .onEnded { value in
                    
                    let snapThreshold = AppConstants.Layout.sheetSnapThreshold
                    
                    withAnimation(.spring(response: 0.42, dampingFraction: 0.86)) {
                        
                        if value.translation.height < -snapThreshold {
                            sheetOffset = AppConstants.Layout.sheetExpandedOffset
                        } else if value.translation.height > snapThreshold {
                            sheetOffset = AppConstants.Layout.sheetCollapsedOffset
                        } else {
                            
                            sheetOffset = progress > 0.5
                            ? AppConstants.Layout.sheetExpandedOffset
                            : AppConstants.Layout.sheetCollapsedOffset
                        }
                    }
                }
        )
        .ignoresSafeArea(edges: .bottom)
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
                            .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
                            .overlay(Circle().stroke(Color.white.opacity(0.5), lineWidth: 0.5))
                        
                        Image(systemName: AppIcons.refresh)
                            .font(.system(size: 18, weight: .bold))
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
                .padding(.trailing, 20)
                .padding(.bottom, AppConstants.Layout.refreshButtonBottomPadding)
            }
        }
    }
}

#Preview {
    DiscoveryScreen(selectedTab: .constant(0))
}
