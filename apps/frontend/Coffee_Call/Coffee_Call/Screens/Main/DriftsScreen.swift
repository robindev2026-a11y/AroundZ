import SwiftUI

struct DriftsScreen: View {
    @StateObject private var viewModel: DriftsViewModel
    @State private var showingFilterPanel = false
    
    init(viewModel: DriftsViewModel = DriftsViewModel()) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: AppConstants.Layout.elementSpacing) {
                
                // 1. Search Bar Input (ISSUE-007)
                if viewModel.isSearchActive {
                    HStack(spacing: AppConstants.Layout.subElementSpacing) {
                        HStack(spacing: 8) {
                            Image(systemName: "magnifyingglass")
                                .font(.bodyBold)
                                .foregroundColor(.textSecondary)
                            
                            TextField("Search Drifts...", text: $viewModel.searchQuery)
                                .font(.bodyStandard)
                                .foregroundColor(.textPrimary)
                                .coffeeSubmitLabel(.search)
                                .onSubmit {
                                    hideKeyboard()
                                }
                            
                            if !viewModel.searchQuery.isEmpty {
                                Button(action: { viewModel.searchQuery = "" }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.textSecondary)
                                }
                            }
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 10)
                        .background(Color.surfaceSecondary.opacity(AppConstants.UI.opacityNormal + 0.1))
                        .cornerRadius(12)
                        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
                        
                        Button("Cancel") {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                viewModel.isSearchActive = false
                                viewModel.searchQuery = ""
                            }
                        }
                        .font(.system(size: AppConstants.Typography.sizeBody, weight: .bold))
                        .foregroundColor(.brandPrimary)
                    }
                    .padding(.horizontal, AppConstants.Layout.standardPadding)
                    .padding(.top, 12) // Moved down slightly for better selectability
                    .transition(.move(edge: .top).combined(with: .opacity))
                }
                
                // 2. Interactive Mode Switch & Time Tabs (Lego Blocks!)
                VStack(spacing: AppConstants.Layout.subElementSpacing) {
                    DriftModeSwitch(selectedMode: $viewModel.selectedMode)
                        .padding(.horizontal, AppConstants.Layout.standardPadding)
                        .padding(.top, 4)
                    
                    TimeStateTabs(selectedState: $viewModel.selectedTimeState)
                }
                
                // 4. Main List / Scrollable Container
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: AppConstants.Layout.sectionSpacing) {
                        
                        // Featured Section (Only in discover, default category, "All" time tab)
                        if viewModel.selectedMode == .discover && viewModel.selectedTimeState == .all && viewModel.selectedCategory == nil && viewModel.searchQuery.isEmpty {
                            if let first = viewModel.filteredDrifts.first {
                                NavigationLink(value: first) {
                                    DriftCard(drift: first, isFeatured: true, onJoin: {})
                                }
                                .buttonStyle(.plain)
                                .padding(.horizontal, AppConstants.Layout.standardPadding)
                            }
                        }
                        
                        let remainingDrifts = (viewModel.selectedMode == .discover && viewModel.selectedTimeState == .all && viewModel.selectedCategory == nil && viewModel.searchQuery.isEmpty)
                            ? Array(viewModel.filteredDrifts.dropFirst())
                            : viewModel.filteredDrifts
                        
                        if viewModel.filteredDrifts.isEmpty {
                            emptyStateView
                        } else {
                            ForEach(remainingDrifts) { drift in
                                NavigationLink(value: drift) {
                                    DriftCard(drift: drift, isFeatured: false, onJoin: {})
                                }
                                .buttonStyle(.plain)
                                .padding(.horizontal, AppConstants.Layout.standardPadding)
                            }
                        }
                    }
                    .padding(.top, 8)
                    .padding(.bottom, AppConstants.Layout.screenBottomSpacer)
                }
            }
            .asCoffeePage(
                .main,
                title: viewModel.title,
                subtitle: viewModel.subtitle ?? "",
                scrollable: false,
                rightView: {
                    HStack(spacing: AppConstants.Layout.subElementSpacing) {
                        // Search Toggle Button (ISSUE-006)
                        CoffeeHeaderButton(icon: AppIcons.search) {
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                                viewModel.isSearchActive.toggle()
                                if !viewModel.isSearchActive {
                                    viewModel.searchQuery = ""
                                }
                            }
                        }
                        // Filter Refinement Button (ISSUE-006)
                        ZStack(alignment: .topTrailing) {
                            CoffeeHeaderButton(icon: AppIcons.filter) {
                                showingFilterPanel = true
                            }
                            
                            if viewModel.activeFilterCount > 0 {
                                Text("\(viewModel.activeFilterCount)")
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundColor(.white)
                                    .frame(width: 16, height: 16)
                                    .background(Circle().fill(Color.brandPrimary))
                                    .offset(x: 4, y: -4)
                            }
                        }
                    }
                }
            )
            .navigationDestination(for: Drift.self) { drift in
                if viewModel.selectedMode == .mine {
                    ManageDriftScreen(viewModel: ManageDriftViewModel(drift: drift))
                } else {
                    DriftDetailScreen(viewModel: DriftDetailViewModel(drift: drift))
                }
            }
            .sheet(isPresented: $showingFilterPanel) {
                if #available(iOS 16.4, *) {
                    DriftsFilterSheet(viewModel: viewModel)
                        .presentationDetents([.fraction(0.68)])
                        .presentationDragIndicator(.visible)
                        .presentationBackground(.ultraThinMaterial)
                } else {
                    DriftsFilterSheet(viewModel: viewModel)
                        .presentationDetents([.fraction(0.68)])
                        .presentationDragIndicator(.visible)
                }
            }
            .onAppear {
                NavigationManager.shared.resetTabBarVisibility()
            }
            .dismissKeyboardOnTap()
        }
    }
    
    // MARK: - Category Chips Row Component
    private var categoryChipsRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: AppConstants.Layout.subElementSpacing) {
                // "All" Chip
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
                        viewModel.selectedCategory = nil
                    }
                }) {
                    Text("All")
                        .font(.bodySmall)
                        .foregroundColor(viewModel.selectedCategory == nil ? .brandPrimary : .textSecondary)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(
                            Capsule()
                                .fill(viewModel.selectedCategory == nil ? Color.brandPrimary.opacity(0.12) : Color.surfaceMain)
                        )
                        .overlay(
                            Capsule()
                                .stroke(viewModel.selectedCategory == nil ? Color.brandPrimary.opacity(0.3) : Color.appBorder, lineWidth: 1)
                        )
                }
                .pressScale(0.95)
                
                // Categories
                ForEach(DriftCategory.allCases, id: \.self) { category in
                    Button(action: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
                            viewModel.selectedCategory = category
                        }
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: category.icon)
                                .font(.system(size: 11, weight: .bold))
                            Text(category.rawValue.capitalized)
                                .font(.bodySmall)
                        }
                        .foregroundColor(viewModel.selectedCategory == category ? .brandPrimary : .textSecondary)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(
                            Capsule()
                                .fill(viewModel.selectedCategory == category ? Color.brandPrimary.opacity(0.12) : Color.surfaceMain)
                        )
                        .overlay(
                            Capsule()
                                .stroke(viewModel.selectedCategory == category ? Color.brandPrimary.opacity(0.3) : Color.appBorder, lineWidth: 1)
                        )
                    }
                    .pressScale(0.95)
                }
            }
            .padding(.horizontal, AppConstants.Layout.standardPadding)
        }
    }
    
    // MARK: - Section Lists
    private func driftSection(title: String, drifts: [Drift]) -> some View {
        VStack(alignment: .leading, spacing: AppConstants.Layout.elementSpacing) {
            if !drifts.isEmpty {
                Text(title)
                    .font(.system(size: AppConstants.Typography.sizeHeadline - 2, weight: .black))
                    .foregroundColor(.textPrimary)
                    .padding(.horizontal, AppConstants.Layout.standardPadding)
                    .padding(.top, 4)
                
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
    
    // MARK: - Empty States (DESIGN.md matching specs)
    private var emptyStateView: some View {
        VStack {
            if viewModel.selectedMode == .mine {
                VStack(spacing: AppConstants.Layout.elementSpacing) {
                    ZStack {
                        Circle()
                            .fill(Color.brandPrimary.opacity(0.05))
                            .frame(width: 80, height: 80)
                        Image(systemName: "square.stack.3d.up.fill")
                            .font(.system(size: 28))
                            .foregroundColor(.brandPrimary)
                    }
                    
                    VStack(spacing: 4) {
                        Text("No active Drifts")
                            .font(.system(size: AppConstants.Typography.sizeHeadline, weight: .bold))
                            .foregroundColor(.textPrimary)
                        Text("Joined and hosted Drifts will appear here.")
                            .font(.captionText)
                            .foregroundColor(.textSecondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.horizontal, 16)
                    
                    Button("Browse Nearby") {
                        withAnimation {
                            viewModel.selectedMode = .discover
                        }
                    }
                    .font(.buttonText)
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 10)
                    .background(Color.brandPrimary)
                    .cornerRadius(20)
                }
                .padding(24)
                .frame(maxWidth: .infinity)
                .background(Color.surfaceMain)
                .cornerRadius(24)
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(Color.appBorder, lineWidth: 1)
                )
                .padding(.horizontal, AppConstants.Layout.standardPadding)
                .padding(.top, 40)
            } else {
                VStack(spacing: AppConstants.Layout.elementSpacing) {
                    ZStack {
                        Circle()
                            .fill(Color.brandPrimary.opacity(0.05))
                            .frame(width: 80, height: 80)
                        Image(systemName: "sparkles")
                            .font(.system(size: 28))
                            .foregroundColor(.brandPrimary)
                    }
                    
                    VStack(spacing: 4) {
                        Text("No Drifts nearby yet")
                            .font(.system(size: AppConstants.Typography.sizeHeadline, weight: .bold))
                            .foregroundColor(.textPrimary)
                        Text("Start one and nearby people can join.")
                            .font(.captionText)
                            .foregroundColor(.textSecondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.horizontal, 16)
                }
                .padding(24)
                .frame(maxWidth: .infinity)
                .background(Color.surfaceMain)
                .cornerRadius(24)
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(Color.appBorder, lineWidth: 1)
                )
                .padding(.horizontal, AppConstants.Layout.standardPadding)
                .padding(.top, 40)
            }
        }
    }
    
}

// MARK: - DriftsFilterSheet Subview (Step 4.2 / MVP Refinement)
struct DriftsFilterSheet: View {
    @ObservedObject var viewModel: DriftsViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 0) {
            // Top Pull-Handle Line
            Capsule()
                .fill(Color.textSecondary.opacity(AppConstants.UI.opacityMuted))
                .frame(width: AppConstants.Layout.sheetHandleWidth, height: AppConstants.Layout.sheetHandleHeight)
                .padding(.top, AppConstants.Layout.sheetHandleTopPadding)
                .padding(.bottom, AppConstants.Layout.sheetHandleBottomPadding)
            
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: AppConstants.Layout.sectionSpacing) {
                    // Header Title
                    HStack {
                        Text("Filter Drifts")
                            .font(.outfitBlack(size: 24, relativeTo: .title2))
                            .foregroundColor(.textPrimary)
                        Spacer()
                    }
                    .padding(.horizontal, AppConstants.Layout.standardPadding)
                    
                    // 1. Distance Radius Section
                    VStack(alignment: .leading, spacing: AppConstants.Layout.elementSpacing) {
                        Text("1. Distance")
                            .font(.outfitBold(size: 16, relativeTo: .headline))
                            .foregroundColor(.textPrimary)
                        
                        TactileSlider(value: $viewModel.selectedDistanceRadius, range: 1.0...10.0, step: 0.5)
                    }
                    .padding(.horizontal, AppConstants.Layout.standardPadding)
                    
                    // 2. Time Picker Section
                    VStack(alignment: .leading, spacing: AppConstants.Layout.elementSpacing) {
                        Text("2. Time")
                            .font(.outfitBold(size: 16, relativeTo: .headline))
                            .foregroundColor(.textPrimary)
                        
                        HStack(spacing: 8) {
                            ForEach(["All", "Today", "Tomorrow", "This Weekend"], id: \.self) { timeframe in
                                let isSelected = viewModel.selectedTimeframe == timeframe
                                let tintColor: Color = {
                                    switch timeframe {
                                    case "All": return Color.brandPrimary
                                    case "Today": return Color.brandSecondary
                                    case "Tomorrow": return Color.brandPurple
                                    case "This Weekend": return Color.brandPurple
                                    default: return Color.brandPrimary
                                    }
                                    
                                }()
                                
                                Button(action: {
                                    withAnimation(.spring(response: 0.25, dampingFraction: 0.75)) {
                                        viewModel.selectedTimeframe = timeframe
                                    }
                                }) {
                                    Text(timeframe)
                                        .font(.outfitBold(size: 13, relativeTo: .subheadline))
                                        .foregroundColor(isSelected ? tintColor : .textSecondary)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 10)
                                        .background(
                                            Capsule()
                                                .fill(isSelected ? tintColor.opacity(0.12) : Color.surfaceMain.opacity(0.3))
                                                .background(Capsule().fill(.ultraThinMaterial))
                                        )
                                        .overlay(
                                            Capsule()
                                                .stroke(isSelected ? tintColor.opacity(0.3) : Color.appBorder.opacity(0.5), lineWidth: 1)
                                        )
                                }
                                .buttonStyle(.plain)
                                .pressScale(0.96)
                            }
                        }
                    }
                    .padding(.horizontal, AppConstants.Layout.standardPadding)
                    
                    // 3. Activity Types Section
                    VStack(alignment: .leading, spacing: AppConstants.Layout.elementSpacing) {
                        Text("3. Activity Types")
                            .font(.outfitBold(size: 16, relativeTo: .headline))
                            .foregroundColor(.textPrimary)
                        
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                            ForEach(DriftCategory.allCases, id: \.self) { category in
                                let isSelected = viewModel.selectedCategory == category
                                Button(action: {
                                    withAnimation(.spring(response: 0.25, dampingFraction: 0.75)) {
                                        if isSelected {
                                            viewModel.selectedCategory = nil
                                        } else {
                                            viewModel.selectedCategory = category
                                        }
                                    }
                                }) {
                                    HStack(spacing: 6) {
                                        Image(systemName: category.icon)
                                            .font(.system(size: 11, weight: .bold))
                                        Text(category.rawValue.capitalized)
                                            .font(.outfitMedium(size: 12, relativeTo: .caption))
                                            .lineLimit(1)
                                    }
                                    .foregroundColor(isSelected ? .brandPrimary : .textSecondary)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 8)
                                    .background(
                                        Capsule()
                                            .fill(isSelected ? Color.brandPrimary.opacity(0.12) : Color.surfaceMain.opacity(0.3))
                                            .background(Capsule().fill(.ultraThinMaterial))
                                    )
                                    .overlay(
                                        Capsule()
                                            .stroke(isSelected ? Color.brandPrimary.opacity(0.3) : Color.appBorder.opacity(0.5), lineWidth: 1)
                                    )
                                }
                                .buttonStyle(.plain)
                                .pressScale(0.96)
                            }
                        }
                    }
                    .padding(.horizontal, AppConstants.Layout.standardPadding)
                    
                    // Action Buttons (Apply & Reset)
                    VStack(spacing: AppConstants.Layout.elementSpacing) {
                        Button(action: {
                            dismiss()
                        }) {
                            Text("Apply Filters")
                                .font(.outfitBlack(size: 16, relativeTo: .headline))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(Color.brandPrimary)
                                .cornerRadius(AppConstants.UI.cornerRadiusLarge)
                                .shadow(color: Color.brandPrimary.opacity(0.2), radius: 8, x: 0, y: 4)
                        }
                        .pressScale(0.96)
                        
                        Button("Reset") {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                viewModel.selectedDistanceRadius = 10.0
                                viewModel.selectedCategories.removeAll()
                                viewModel.selectedTimeframe = "All"
                                viewModel.selectedCategory = nil
                                viewModel.selectedTimeState = .all
                            }
                        }
                        .font(.outfitBold(size: 14, relativeTo: .subheadline))
                        .foregroundColor(.brandPrimary)
                        .padding(.vertical, 8)
                    }
                    .padding(.horizontal, AppConstants.Layout.standardPadding)
                    .padding(.top, 8)
                }
                .padding(.bottom, 32)
            }
        }
        .background(Color.surfaceMain.opacity(0.45))
    }
}

// MARK: - Custom Tactile Slider with floating bubble
struct TactileSlider: View {
    @Binding var value: Double
    let range: ClosedRange<Double>
    let step: Double
    
    var body: some View {
        VStack(spacing: 6) {
            GeometryReader { geometry in
                let width = geometry.size.width
                let percentage = CGFloat((value - range.lowerBound) / (range.upperBound - range.lowerBound))
                let thumbSize: CGFloat = 20
                let bubbleWidth: CGFloat = 90
                // Calculate centered position for the bubble above thumb
                let bubbleOffset = percentage * (width - thumbSize) + thumbSize / 2 - bubbleWidth / 2
                
                ZStack(alignment: .leading) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.brandPrimary.opacity(0.08))
                            .background(RoundedRectangle(cornerRadius: 12).fill(.ultraThinMaterial))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.brandPrimary.opacity(0.2), lineWidth: 0.8)
                            )
                        
                        Text("\(Int(value)) km radius")
                            .font(.outfitBold(size: 11, relativeTo: .caption))
                            .foregroundColor(.brandPrimary)
                    }
                    .frame(width: bubbleWidth, height: 26)
                    .offset(x: bubbleOffset)
                }
            }
            .frame(height: 26)
            
            Slider(value: $value, in: range, step: step)
                .accentColor(.brandPrimary)
            
            HStack {
                Text("\(Int(range.lowerBound)) km")
                    .font(.outfitMedium(size: 11, relativeTo: .caption))
                    .foregroundColor(.textSecondary)
                Spacer()
                Text("\(Int(range.upperBound)) km")
                    .font(.outfitMedium(size: 11, relativeTo: .caption))
                    .foregroundColor(.textSecondary)
            }
        }
    }
}

// MARK: - Category Chip Model
struct FilterCategoryItem: Identifiable {
    let id = UUID()
    let name: String
    let iconName: String
    let category: DriftCategory
}

struct DriftsScreen_Previews: PreviewProvider {
    static var previews: some View {
        DriftsScreen()
    }
}
