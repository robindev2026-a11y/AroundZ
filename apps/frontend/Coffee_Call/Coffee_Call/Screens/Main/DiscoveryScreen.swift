import SwiftUI

struct DiscoveryScreen: View {
    
    // MARK: - State
    
    @StateObject private var viewModel: DiscoveryViewModel
    @Binding var selectedTab: Int
    
    init(viewModel: DiscoveryViewModel = DiscoveryViewModel(), selectedTab: Binding<Int>) {
        _viewModel = StateObject(wrappedValue: viewModel)
        _selectedTab = selectedTab
    }
    
    @State private var selectedPerson: RadarPerson? = nil
    @State private var showNotificationDropdown = false
    
    // Bottom Sheet
    @State private var sheetOffset: CGFloat = AppConstants.Layout.sheetCollapsedOffset
    @State private var dragOffset: CGFloat = 0
    
    private var isFirebaseEnabled: Bool {
        Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist") != nil
    }
    
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
                                        Button(action: {
                                            // Set active interest filter on global navigation singleton
                                            NavigationManager.shared.activeInterestFilter = category.id
                                            
                                            // Route user to Drifts listing tab (index 1)
                                            withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                                                selectedTab = 1
                                            }
                                        }) {
                                            InterestCard(
                                                title: category.label,
                                                icon: category.icon,
                                                count: category.count,
                                                color: category.color ?? .brandPrimary
                                            )
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }
                            }
                            
                            Spacer(minLength: AppConstants.Layout.screenBottomSpacer + 100)
                        }
                        .padding(.horizontal, AppConstants.Layout.standardPadding)
                    }
                }
                .zIndex(15)
                
                // MARK: Notification Dropdown overlay
                if showNotificationDropdown && !isFirebaseEnabled {
                    Color.black.opacity(0.15)
                        .ignoresSafeArea()
                        .onTapGesture {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                showNotificationDropdown = false
                            }
                        }
                        .zIndex(24)
                    
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Notifications")
                                .font(.system(size: AppConstants.Typography.sizeHeadline, weight: .bold))
                                .foregroundColor(.textPrimary)
                            
                            Spacer()
                            
                            Button(action: {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                    showNotificationDropdown = false
                                }
                            }) {
                                Image(systemName: "xmark")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(.textSecondary)
                                    .padding(6)
                                    .background(Circle().fill(Color.surfaceSecondary))
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 16)
                        
                        Divider()
                            .padding(.horizontal, 16)
                        
                        VStack(spacing: 0) {
                            NotificationRow(
                                icon: "checkmark.circle.fill",
                                iconColor: .brandPrimary,
                                text: "Mira accepted your request to join 'Evening Run' 🏃‍♂️",
                                time: "2m ago"
                            )
                            Divider().padding(.horizontal, 16)
                            NotificationRow(
                                icon: "bolt.fill",
                                iconColor: .brandSecondary,
                                text: "Rahul created a new Coffee Drift nearby ☕️",
                                time: "15m ago"
                            )
                            Divider().padding(.horizontal, 16)
                            NotificationRow(
                                icon: "message.fill",
                                iconColor: .brandPurple,
                                text: "Aditi sent a message in 'Study Group' 📚",
                                time: "1h ago"
                            )
                        }
                        .padding(.bottom, 8)
                    }
                    .background(
                        RoundedRectangle(cornerRadius: AppConstants.UI.cornerRadiusLarge)
                            .fill(Color.surfaceMain)
                            .shadow(color: .black.opacity(0.15), radius: 20, x: 0, y: 10)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: AppConstants.UI.cornerRadiusLarge)
                            .stroke(Color.appBorder.opacity(0.5), lineWidth: 1)
                    )
                    .padding(.horizontal, AppConstants.Layout.standardPadding)
                    .padding(.top, 110)
                    .transition(.asymmetric(
                        insertion: .opacity.combined(with: .move(edge: .top)),
                        removal: .opacity
                    ))
                    .zIndex(25)
                }
            }
        }
        .asCoffeePage(
            .main,
            title: AppStrings.Discovery.title,
            subtitle: AppStrings.Discovery.subtitleDefault,
            topPadding: 0,
            scrollable: false,
            rightView: {
                NotificationIconButton(count: isFirebaseEnabled ? 0 : 3) {
                    if !isFirebaseEnabled {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            showNotificationDropdown.toggle()
                        }
                    }
                }
            }
        )
        .onAppear {
            NavigationManager.shared.resetTabBarVisibility()
            PermissionsManager.shared.requestLocation()
        }
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

struct DiscoveryScreen_Previews: PreviewProvider {
    static var previews: some View {
        DiscoveryScreen(selectedTab: .constant(0))
    }
}

struct NotificationRow: View {
    let icon: String
    let iconColor: Color
    let text: String
    let time: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(iconColor)
                .frame(width: 32, height: 32)
                .background(iconColor.opacity(0.1))
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 2) {
                Text(text)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.textPrimary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                
                Text(time)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.textSecondary)
            }
            
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .contentShape(Rectangle())
    }
}
