import SwiftUI

struct CreateDriftScreen: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel = CreateDriftViewModel()
    @State private var showDiscardAlert = false
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: AppConstants.Layout.sectionSpacing) {
                        // Required Sections
                        Group {
                            // 1. What's the plan? (Activity)
                            sectionHeader(title: AppStrings.Create.step1)
                            activityGrid
                            
                            // 2. Plan title
                            sectionHeader(title: AppStrings.Create.step2)
                            TextField(AppStrings.Create.titlePlaceholder, text: $viewModel.planTitle)
                                .font(.system(size: 15))
                                .padding(AppConstants.Layout.elementSpacing)
                                .background(Color.surfaceSecondary)
                                .cornerRadius(AppConstants.UI.cornerRadiusSmall)
                                .overlay(
                                    RoundedRectangle(cornerRadius: AppConstants.UI.cornerRadiusSmall)
                                        .stroke(Color.appBorder.opacity(0.5), lineWidth: 1)
                                )
                            
                            // 3. When?
                            sectionHeader(title: AppStrings.Create.step3)
                            timeSelection
                            
                            // 4. Where?
                            sectionHeader(title: AppStrings.Create.step4)
                            locationSection
                        }
                        
                        Group {
                            // 5. Capacity
                            sectionHeader(title: AppStrings.Create.step5)
                            capacitySelection
                            
                            // 6. Join mode
                            sectionHeader(title: AppStrings.Create.step6)
                            joinModeSelection
                        }
                        
                        // Optional Sections
                        VStack(alignment: .leading, spacing: AppConstants.Layout.sectionSpacing) {
                            Divider()
                                .padding(.vertical, 8)
                            
                            // 7. Optional hook
                            VStack(alignment: .leading, spacing: AppConstants.Layout.elementSpacing) {
                                sectionHeader(title: "7. Optional hook")
                                hookSelection
                            }
                            
                            // 8. Vibe
                            VStack(alignment: .leading, spacing: AppConstants.Layout.elementSpacing) {
                                sectionHeader(title: "8. Vibe")
                                vibeSelection
                            }
                            
                            // 9. Notes
                            VStack(alignment: .leading, spacing: AppConstants.Layout.elementSpacing) {
                                sectionHeader(title: "9. Notes")
                                TextField("e.g. Let's enjoy a relaxed evening walk and catch up with good people.", text: $viewModel.notes, axis: .vertical)
                                    .font(.system(size: 14))
                                    .lineLimit(3...5)
                                    .padding(AppConstants.Layout.elementSpacing)
                                    .background(Color.surfaceSecondary)
                                    .cornerRadius(AppConstants.UI.cornerRadiusSmall)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: AppConstants.UI.cornerRadiusSmall)
                                            .stroke(Color.appBorder.opacity(0.5), lineWidth: 1)
                                    )
                                
                                Text("\(viewModel.notes.count)/200")
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundColor(.textSecondary.opacity(0.6))
                                    .frame(maxWidth: .infinity, alignment: .trailing)
                            }
                        }
                        
                        Spacer(minLength: 120) // Ensure content clears sticky CTA
                    }
                    .padding(.horizontal, AppConstants.Layout.standardPadding)
                    .padding(.top, 10)
                }
                
                // Sticky Bottom CTA
                bottomStickyArea
            }
            .background(Color.backgroundMain.ignoresSafeArea())
            .navigationTitle(AppStrings.Create.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        if viewModel.isDirty {
                            showDiscardAlert = true
                        } else {
                            dismiss()
                        }
                    } label: {
                        Image(systemName: AppIcons.close)
                            .font(.system(size: 12, weight: .black))
                            .foregroundColor(.textSecondary)
                            .padding(8)
                            .background(Color.surfaceSecondary)
                            .clipShape(Circle())
                    }
                }
            }
            .interactiveDismissDisabled(viewModel.isDirty)
            .overlay {
                if viewModel.isCreating {
                    loadingOverlay
                }
                if viewModel.isSuccess {
                    successOverlay
                }
            }
            .alert(AppStrings.Create.discardTitle, isPresented: $showDiscardAlert) {
                Button(AppStrings.Create.discardAction, role: .destructive) { dismiss() }
                Button(AppStrings.Create.continueEditing, role: .cancel) { }
            } message: {
                Text(AppStrings.Create.discardMessage)
            }
        }
    }
    
    // MARK: - Components
    
    private func sectionHeader(title: String) -> some View {
        Text(title)
            .font(.system(size: 15, weight: .bold))
            .foregroundColor(.textPrimary)
    }
    
    private var activityGrid: some View {
        let columns = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]
        return LazyVGrid(columns: columns, spacing: 12) {
            ForEach(viewModel.activities, id: \.self) { activity in
                activityButton(activity: activity)
            }
        }
    }
    
    private func activityButton(activity: String) -> some View {
        let isSelected = viewModel.selectedActivity == activity
        return Button { viewModel.selectedActivity = activity } label: {
            VStack(spacing: 6) {
                Image(systemName: activityIcon(for: activity))
                    .font(.system(size: 18))
                Text(activity)
                    .font(.system(size: 12, weight: .semibold))
            }
            .frame(maxWidth: .infinity)
            .frame(height: 64)
            .background(isSelected ? Color.brandPrimary.opacity(0.12) : Color.surfaceMain)
            .foregroundColor(isSelected ? .brandPrimary : .textSecondary)
            .cornerRadius(AppConstants.UI.cornerRadiusMedium)
            .overlay(
                RoundedRectangle(cornerRadius: AppConstants.UI.cornerRadiusMedium)
                    .stroke(isSelected ? Color.brandPrimary : Color.appBorder.opacity(0.6), lineWidth: isSelected ? 1.5 : 1)
            )
        }
        .buttonStyle(.plain)
    }
    
    private var timeSelection: some View {
        VStack(alignment: .leading, spacing: 12) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(viewModel.times.prefix(4), id: \.self) { time in
                        timeButton(time: time)
                    }
                }
            }
            
            customTimeButton
        }
    }
    
    private func timeButton(time: String) -> some View {
        let isSelected = viewModel.selectedTime == time
        return Button { viewModel.selectedTime = time } label: {
            Text(time)
                .font(.system(size: 12, weight: .semibold))
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(isSelected ? Color.brandPrimary.opacity(0.12) : Color.surfaceMain)
                .foregroundColor(isSelected ? .brandPrimary : .textSecondary)
                .cornerRadius(AppConstants.UI.cornerRadiusSmall)
                .overlay(
                    RoundedRectangle(cornerRadius: AppConstants.UI.cornerRadiusSmall)
                        .stroke(isSelected ? Color.brandPrimary : Color.appBorder.opacity(0.6), lineWidth: isSelected ? 1.2 : 1)
                )
        }
    }
    
    private var customTimeButton: some View {
        let isSelected = viewModel.selectedTime == "Custom"
        return Button { viewModel.selectedTime = "Custom" } label: {
            HStack(spacing: 6) {
                Image(systemName: AppIcons.calendar)
                    .font(.system(size: 12))
                Text("Custom")
                    .font(.system(size: 12, weight: .semibold))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(isSelected ? Color.brandPrimary.opacity(0.12) : Color.surfaceMain)
            .foregroundColor(isSelected ? .brandPrimary : .textSecondary)
            .cornerRadius(AppConstants.UI.cornerRadiusSmall)
            .overlay(
                RoundedRectangle(cornerRadius: AppConstants.UI.cornerRadiusSmall)
                    .stroke(isSelected ? Color.brandPrimary : Color.appBorder.opacity(0.6), lineWidth: isSelected ? 1.2 : 1)
            )
        }
    }
    
    private var locationSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            switch viewModel.locationState {
            case .resolving:
                resolvingLocationCard
            case .permissionMissing:
                permissionMissingLocationCard
            case .resolved:
                resolvedLocationCard
            }
            
            locationNoteArea
        }
    }
    
    private var resolvingLocationCard: some View {
        locationCard {
            HStack(spacing: 12) {
                ProgressView()
                    .scaleEffect(0.8)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Resolving your location...")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.textSecondary)
                    Text(AppStrings.Create.locationApprox)
                        .font(.system(size: 11))
                        .foregroundColor(.textSecondary.opacity(0.6))
                }
            }
        }
    }
    
    private var permissionMissingLocationCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            locationCard {
                HStack(spacing: 12) {
                    Image(systemName: "location.slash.fill")
                        .foregroundColor(.brandSecondary)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Location permission is off")
                            .font(.system(size: 13, weight: .medium))
                        Text("Enable location to create nearby Drifts.")
                            .font(.system(size: 11))
                            .foregroundColor(.textSecondary)
                    }
                }
            }
            .background(Color.brandSecondary.opacity(0.05))
            
            Button {
                viewModel.requestLocationPermission()
            } label: {
                Text("Enable Location")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 40)
                    .background(Color.brandPrimary)
                    .cornerRadius(AppConstants.UI.cornerRadiusSmall)
            }
        }
    }
    
    private var resolvedLocationCard: some View {
        locationCard {
            HStack {
                ZStack {
                    Circle().fill(Color.brandPrimary.opacity(0.1)).frame(width: 28, height: 28)
                    Image(systemName: AppIcons.mappin).foregroundColor(.brandPrimary).font(.system(size: 12))
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(viewModel.location)
                        .font(.system(size: 13, weight: .semibold))
                    Text(AppStrings.Create.locationApprox)
                        .font(.system(size: 11))
                        .foregroundColor(.textSecondary.opacity(0.7))
                }
                
                Spacer()
                
                Button("Change") { }
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.brandPrimary)
            }
        }
    }
    
    private var locationNoteArea: some View {
        HStack(alignment: .top, spacing: 6) {
            Image(systemName: "info.circle")
                .font(.system(size: 10))
            Text(AppStrings.Create.locationNote)
                .font(.system(size: 11))
        }
        .foregroundColor(.textSecondary.opacity(0.7))
    }
    
    private func locationCard<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        content()
            .padding(12)
            .background(Color.surfaceMain)
            .cornerRadius(AppConstants.UI.cornerRadiusMedium)
            .overlay(
                RoundedRectangle(cornerRadius: AppConstants.UI.cornerRadiusMedium)
                    .stroke(Color.appBorder.opacity(0.5), lineWidth: 1)
            )
    }
    
    private var capacitySelection: some View {
        HStack(spacing: 8) {
            ForEach(viewModel.capacities, id: \.self) { cap in
                capacityButton(cap: cap)
            }
        }
    }
    
    private func capacityButton(cap: Int) -> some View {
        let isSelected = viewModel.capacity == cap
        let label = cap == 8 ? "8+" : "\(cap)"
        
        return Button { viewModel.capacity = cap } label: {
            Text(label)
                .font(.system(size: 12, weight: .semibold))
                .frame(maxWidth: .infinity)
                .frame(height: 44)
                .background(isSelected ? Color.brandPrimary.opacity(0.12) : Color.surfaceMain)
                .foregroundColor(isSelected ? .brandPrimary : .textSecondary)
                .cornerRadius(AppConstants.UI.cornerRadiusSmall)
                .overlay(
                    RoundedRectangle(cornerRadius: AppConstants.UI.cornerRadiusSmall)
                        .stroke(isSelected ? Color.brandPrimary : Color.appBorder.opacity(0.6), lineWidth: isSelected ? 1.2 : 1)
                )
        }
    }
    
    private var joinModeSelection: some View {
        HStack(spacing: 12) {
            ForEach(viewModel.joinModes, id: \.self) { mode in
                joinModeButton(mode: mode)
            }
        }
    }
    
    private func joinModeButton(mode: String) -> some View {
        let isSelected = viewModel.joinMode == mode
        let icon = mode == "Anyone can join" ? "person.2.fill" : "person.badge.shield.check.fill"
        let subtitle = mode == "Anyone can join" ? "Open to everyone" : "I'll approve who joins"
        
        return Button { viewModel.joinMode = mode } label: {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Image(systemName: icon)
                        .font(.system(size: 14))
                    Spacer()
                }
                
                Text(mode)
                    .font(.system(size: 13, weight: .bold))
                Text(subtitle)
                    .font(.system(size: 11))
                    .foregroundColor(isSelected ? .brandPrimary.opacity(0.8) : .textSecondary)
            }
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(isSelected ? Color.brandPrimary.opacity(0.12) : Color.surfaceMain)
            .foregroundColor(isSelected ? .brandPrimary : .textSecondary)
            .cornerRadius(AppConstants.UI.cornerRadiusMedium)
            .overlay(
                RoundedRectangle(cornerRadius: AppConstants.UI.cornerRadiusMedium)
                    .stroke(isSelected ? Color.brandPrimary : Color.appBorder.opacity(0.6), lineWidth: isSelected ? 1.5 : 1)
            )
        }
    }
    
    private var hookSelection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                let hooks = ["Coffee on me", "Have coupons", "Free entry", "Bring a friend", "Custom"]
                ForEach(hooks, id: \.self) { hook in
                    hookButton(hook: hook)
                }
            }
        }
    }
    
    private func hookButton(hook: String) -> some View {
        let isSelected = viewModel.hook == hook
        return Button { viewModel.hook = hook } label: {
            Text(hook)
                .font(.system(size: 12, weight: .semibold))
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(isSelected ? Color.brandPrimary.opacity(0.12) : Color.surfaceMain)
                .foregroundColor(isSelected ? .brandPrimary : .textSecondary)
                .cornerRadius(AppConstants.UI.cornerRadiusSmall)
                .overlay(
                    RoundedRectangle(cornerRadius: AppConstants.UI.cornerRadiusSmall)
                        .stroke(isSelected ? Color.brandPrimary : Color.appBorder.opacity(0.6), lineWidth: 1)
                )
        }
    }
    
    private var vibeSelection: some View {
        let rows = [GridItem(.flexible()), GridItem(.flexible())]
        return ScrollView(.horizontal, showsIndicators: false) {
            LazyHGrid(rows: rows, spacing: 8) {
                ForEach(viewModel.vibes, id: \.self) { vibe in
                    vibeButton(vibe: vibe)
                }
            }
            .frame(height: 80)
        }
    }
    
    private func vibeButton(vibe: String) -> some View {
        let isSelected = viewModel.selectedVibe == vibe
        return Button { viewModel.selectedVibe = vibe } label: {
            Text(vibe)
                .font(.system(size: 12, weight: .semibold))
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(isSelected ? Color.brandPrimary.opacity(0.12) : Color.surfaceMain)
                .foregroundColor(isSelected ? .brandPrimary : .textSecondary)
                .cornerRadius(AppConstants.UI.cornerRadiusSmall)
                .overlay(
                    RoundedRectangle(cornerRadius: AppConstants.UI.cornerRadiusSmall)
                        .stroke(isSelected ? Color.brandPrimary : Color.appBorder.opacity(0.6), lineWidth: 1)
                )
        }
    }
    
    private var bottomStickyArea: some View {
        VStack(spacing: 0) {
            Spacer()
            
            // Gradient to blend scroll
            LinearGradient(
                colors: [Color.backgroundMain.opacity(0), Color.backgroundMain.opacity(0.95), Color.backgroundMain],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 40)
            
            VStack {
                createButton
                    .padding(.horizontal, AppConstants.Layout.standardPadding)
                    .padding(.bottom, 12)
            }
            .background(Color.backgroundMain)
        }
        .ignoresSafeArea(.all, edges: .bottom)
    }
    
    private var createButton: some View {
        Button {
            viewModel.createDrift()
        } label: {
            Text(AppStrings.Create.title)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 54)
                .background(viewModel.planTitle.isEmpty ? Color.brandPrimary.opacity(0.4) : Color.brandPrimary)
                .cornerRadius(AppConstants.UI.cornerRadiusMedium)
                .shadow(color: Color.brandPrimary.opacity(0.2), radius: 10, x: 0, y: 5)
        }
        .disabled(viewModel.planTitle.isEmpty)
    }
    
    private var loadingOverlay: some View {
        ZStack {
            Color.backgroundMain.ignoresSafeArea()
            VStack(spacing: 24) {
                loadingIcon
                
                loadingText
                
                ProgressView()
                    .tint(.brandPrimary)
            }
        }
    }
    
    private var loadingIcon: some View {
        ZStack {
            Circle()
                .fill(Color.brandPrimary.opacity(0.1))
                .frame(width: 100, height: 100)
            Image(systemName: activityIcon(for: viewModel.selectedActivity))
                .font(.system(size: 40))
                .foregroundColor(.brandPrimary)
        }
    }
    
    private var loadingText: some View {
        VStack(spacing: 8) {
            Text(AppStrings.Create.creating)
                .font(.system(size: 24, weight: .black))
            Text(AppStrings.Create.settingUp)
                .font(.system(size: 15))
                .foregroundColor(.textSecondary)
        }
    }
    
    private var successOverlay: some View {
        ZStack {
            Color.backgroundMain.ignoresSafeArea()
            
            successBackgroundDots
            
            VStack(spacing: 32) {
                Spacer()
                
                successCheckmark
                
                successHeader
                
                if let drift = viewModel.createdDrift {
                    successDriftCard(drift: drift)
                }
                
                Text(AppStrings.Create.redirectNote)
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(.textSecondary.opacity(0.5))
                
                Spacer()
                
                successManageButton
            }
        }
    }
    
    private var successBackgroundDots: some View {
        ZStack {
            ForEach(0..<12) { i in
                Circle()
                    .fill(Color.brandPrimary.opacity(0.2))
                    .frame(width: 4, height: 4)
                    .offset(x: 70 * cos(Double(i) * .pi / 6), y: 70 * sin(Double(i) * .pi / 6))
            }
        }
    }
    
    private var successCheckmark: some View {
        ZStack {
            Circle()
                .fill(Color.brandPrimary.opacity(0.1))
                .frame(width: 80, height: 80)
            Image(systemName: AppIcons.checkmark)
                .font(.system(size: 32, weight: .black))
                .foregroundColor(.brandPrimary)
        }
    }
    
    private var successHeader: some View {
        VStack(spacing: 8) {
            Text(AppStrings.Create.created)
                .font(.system(size: 24, weight: .black))
            Text(AppStrings.Create.createdSubtitle)
                .font(.system(size: 15))
                .foregroundColor(.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
    }
    
    private func successDriftCard(drift: Drift) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 16) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.brandPrimary.opacity(0.1))
                        .frame(width: 48, height: 48)
                    Image(systemName: activityIcon(for: viewModel.selectedActivity))
                        .font(.system(size: 20))
                        .foregroundColor(.brandPrimary)
                }
                VStack(alignment: .leading, spacing: 4) {
                    Text(drift.title)
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(.textPrimary)
                    Text("\(viewModel.selectedTime.lowercased()) • \(viewModel.location.components(separatedBy: ",").first ?? "") • \(viewModel.capacity) people")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.textSecondary.opacity(0.7))
                }
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.surfaceMain)
        .cornerRadius(AppConstants.UI.cornerRadiusMedium)
        .overlay(
            RoundedRectangle(cornerRadius: AppConstants.UI.cornerRadiusMedium)
                .stroke(Color.appBorder.opacity(0.5), lineWidth: 1)
        )
        .padding(.horizontal, 24)
    }
    
    private var successManageButton: some View {
        Button {
            dismiss()
        } label: {
            Text(AppStrings.Create.manageDrift)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(Color.brandPrimary)
                .cornerRadius(AppConstants.UI.cornerRadiusMedium)
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 24)
    }
    
    private func activityIcon(for activity: String) -> String {
        switch activity.lowercased() {
        case "coffee": return AppIcons.coffee
        case "walk": return AppIcons.walk
        case "food": return AppIcons.food
        case "movie": return AppIcons.movie
        case "study": return AppIcons.briefcase
        case "fitness": return AppIcons.fitness
        case "games": return AppIcons.games
        default: return AppIcons.plus
        }
    }
}
