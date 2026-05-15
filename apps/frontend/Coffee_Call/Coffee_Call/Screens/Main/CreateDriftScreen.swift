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
                        Group {
                            // 1. What's the plan? (Activity)
                            sectionHeader(title: AppStrings.Create.step1)
                            activityGrid
                            
                            // 2. Plan title
                            sectionHeader(title: AppStrings.Create.step2)
                            TextField(AppStrings.Create.titlePlaceholder, text: $viewModel.planTitle)
                                .font(.bodyStandard)
                                .padding(AppConstants.Layout.elementSpacing)
                                .background(Color.surfaceSecondary)
                                .cornerRadius(AppConstants.UI.cornerRadiusSmall)
                            
                            // 3. When?
                            sectionHeader(title: AppStrings.Create.step3)
                            timeSelection
                            
                            // 4. Where?
                            sectionHeader(title: AppStrings.Create.step4)
                            locationCard
                        }
                        
                        Group {
                            // 5. Capacity
                            sectionHeader(title: AppStrings.Create.step5)
                            capacitySelection
                            
                            // 6. Join mode
                            sectionHeader(title: AppStrings.Create.step6)
                            joinModeSelection
                            
                            // Optional Section
                            optionalSection
                            
                            Spacer(minLength: AppConstants.Layout.screenBottomSpacer)
                        }
                    }
                    .padding(AppConstants.Layout.standardPadding)
                }
                
                // Sticky Bottom CTA
                bottomCTA
            }
            .background(Color.backgroundMain.ignoresSafeArea())
            .navigationTitle(AppStrings.Create.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        if !viewModel.planTitle.isEmpty {
                            showDiscardAlert = true
                        } else {
                            dismiss()
                        }
                    } label: {
                        Image(systemName: AppIcons.close)
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(.textSecondary)
                            .padding(7)
                            .background(Color.surfaceSecondary)
                            .clipShape(Circle())
                    }
                }
            }
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
            .font(.heading2)
            .foregroundColor(.textPrimary)
    }
    
    private var activityGrid: some View {
        let columns = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]
        return LazyVGrid(columns: columns, spacing: 10) {
            ForEach(viewModel.activities, id: \.self) { activity in
                let isSelected = viewModel.selectedActivity == activity
                Button { viewModel.selectedActivity = activity } label: {
                    VStack(spacing: 6) {
                        Image(systemName: activityIcon(for: activity))
                            .font(.system(size: 18))
                        Text(activity)
                            .font(.micro)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 64)
                    .background(isSelected ? Color.brandPrimary.opacity(0.1) : Color.surfaceMain)
                    .foregroundColor(isSelected ? .brandPrimary : .textSecondary)
                    .cornerRadius(AppConstants.UI.cornerRadiusSmall)
                    .overlay(
                        RoundedRectangle(cornerRadius: AppConstants.UI.cornerRadiusSmall)
                            .stroke(isSelected ? Color.brandPrimary : Color.appBorder, lineWidth: 1.2)
                    )
                }
            }
        }
    }
    
    private var timeSelection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(viewModel.times, id: \.self) { time in
                    let isSelected = viewModel.selectedTime == time
                    Button { viewModel.selectedTime = time } label: {
                        Text(time)
                            .font(.bodySmall)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(isSelected ? Color.brandPrimary.opacity(0.1) : Color.surfaceMain)
                            .foregroundColor(isSelected ? .brandPrimary : .textSecondary)
                            .cornerRadius(AppConstants.UI.cornerRadiusTiny * 1.5)
                            .overlay(RoundedRectangle(cornerRadius: AppConstants.UI.cornerRadiusTiny * 1.5).stroke(isSelected ? Color.brandPrimary : Color.appBorder, lineWidth: 1))
                    }
                }
            }
        }
    }
    
    private var locationCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                ZStack {
                    Circle().fill(Color.brandPrimary.opacity(0.1)).frame(width: 28, height: 28)
                    Image(systemName: AppIcons.mappin).foregroundColor(.brandPrimary).font(.system(size: 12))
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(viewModel.location)
                        .font(.bodySmall)
                    Text(AppStrings.Create.locationApprox)
                        .font(.micro)
                        .foregroundColor(.textSecondary)
                }
                
                Spacer()
                
                Button("Change") { }
                    .font(.micro)
                    .foregroundColor(.brandPrimary)
            }
            .padding(10)
            .background(Color.surfaceMain)
            .cornerRadius(AppConstants.UI.cornerRadiusSmall)
            .overlay(RoundedRectangle(cornerRadius: AppConstants.UI.cornerRadiusSmall).stroke(Color.appBorder, lineWidth: 1))
        }
    }
    
    private var capacitySelection: some View {
        HStack(spacing: 10) {
            ForEach(viewModel.capacities, id: \.self) { cap in
                let isSelected = viewModel.capacity == cap
                let label = cap == 8 ? "8+" : "\(cap)"
                Button { viewModel.capacity = cap } label: {
                    Text(label)
                        .font(.bodyStandard)
                        .frame(maxWidth: .infinity)
                        .frame(height: 38)
                        .background(isSelected ? Color.brandPrimary.opacity(0.1) : Color.surfaceMain)
                        .foregroundColor(isSelected ? .brandPrimary : .textSecondary)
                        .cornerRadius(AppConstants.UI.cornerRadiusTiny * 1.5)
                        .overlay(RoundedRectangle(cornerRadius: AppConstants.UI.cornerRadiusTiny * 1.5).stroke(isSelected ? Color.brandPrimary : Color.appBorder, lineWidth: 1))
                }
            }
        }
    }
    
    private var joinModeSelection: some View {
        HStack(spacing: 10) {
            ForEach(viewModel.joinModes, id: \.self) { mode in
                let isSelected = viewModel.joinMode == mode
                Button { viewModel.joinMode = mode } label: {
                    VStack(alignment: .leading, spacing: 3) {
                        Text(mode)
                            .font(.bodySmall)
                        Text(mode == "Anyone can join" ? "Open to everyone" : "I'll approve who joins")
                            .font(.micro)
                            .foregroundColor(isSelected ? .brandPrimary.opacity(0.8) : .textSecondary)
                    }
                    .padding(10)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(isSelected ? Color.brandPrimary.opacity(0.1) : Color.surfaceMain)
                    .foregroundColor(isSelected ? .brandPrimary : .textSecondary)
                    .cornerRadius(AppConstants.UI.cornerRadiusSmall)
                    .overlay(RoundedRectangle(cornerRadius: AppConstants.UI.cornerRadiusSmall).stroke(isSelected ? Color.brandPrimary : Color.appBorder, lineWidth: 1))
                }
            }
        }
    }
    
    private var optionalSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Optional Details")
                .font(.bodySmall)
                .foregroundColor(.textSecondary)
                .padding(.top, 12)
            
            VStack(alignment: .leading, spacing: 6) {
                Text("Hook (Optional)")
                    .font(.micro)
                    .foregroundColor(.textSecondary)
                TextField("e.g. Coffee on me", text: $viewModel.hook)
                    .padding(10)
                    .background(Color.surfaceSecondary)
                    .cornerRadius(AppConstants.UI.cornerRadiusSmall)
            }
            
            VStack(alignment: .leading, spacing: 6) {
                Text("Notes (Optional)")
                    .font(.micro)
                    .foregroundColor(.textSecondary)
                TextField("Additional info...", text: $viewModel.notes, axis: .vertical)
                    .lineLimit(2...4)
                    .padding(10)
                    .background(Color.surfaceSecondary)
                    .cornerRadius(AppConstants.UI.cornerRadiusSmall)
            }
        }
    }
    
    private var bottomCTA: some View {
        VStack {
            Spacer()
            Button {
                viewModel.createDrift()
            } label: {
                HStack {
                    Text(AppStrings.Create.title)
                        .font(.buttonText)
                    Spacer()
                    Image(systemName: AppIcons.chevronRight)
                        .font(.bodyBold)
                }
                .padding(.horizontal, 20)
                .frame(maxWidth: .infinity)
                .frame(height: AppConstants.Layout.createDriftButtonHeight)
                .background(viewModel.planTitle.isEmpty ? Color.textSecondary.opacity(0.3) : Color.brandPrimary)
                .foregroundColor(.white)
                .cornerRadius(AppConstants.UI.cornerRadiusSmall * 1.2)
                .shadow(color: Color.brandPrimary.opacity(0.2), radius: 8, x: 0, y: 4)
            }
            .disabled(viewModel.planTitle.isEmpty)
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
        .background(
            LinearGradient(colors: [Color.backgroundMain.opacity(0), Color.backgroundMain], startPoint: .top, endPoint: .bottom)
                .frame(height: 100)
        )
    }
    
    private var loadingOverlay: some View {
        ZStack {
            Color.backgroundMain.ignoresSafeArea()
            VStack(spacing: 24) {
                ZStack {
                    Circle()
                        .fill(Color.brandPrimary.opacity(0.1))
                        .frame(width: 100, height: 100)
                    Image(systemName: "wand.and.stars")
                        .font(.system(size: 40))
                        .foregroundColor(.brandPrimary)
                }
                
                VStack(spacing: 8) {
                    Text(AppStrings.Create.creating)
                        .font(.heading1)
                    Text(AppStrings.Create.settingUp)
                        .font(.bodyStandard)
                        .foregroundColor(.textSecondary)
                }
                
                ProgressView()
                    .tint(.brandPrimary)
            }
        }
    }
    
    private var successOverlay: some View {
        ZStack {
            Color.backgroundMain.ignoresSafeArea()
            VStack(spacing: 24) {
                ZStack {
                    Circle()
                        .fill(Color.brandPrimary.opacity(0.1))
                        .frame(width: 80, height: 80)
                    Image(systemName: AppIcons.checkmark)
                        .font(.system(size: 32, weight: .black))
                        .foregroundColor(.brandPrimary)
                }
                
                VStack(spacing: 6) {
                    Text(AppStrings.Create.created)
                        .font(.heading1)
                    Text(AppStrings.Create.createdSubtitle)
                        .font(.bodyStandard)
                        .foregroundColor(.textSecondary)
                }
                
                if let drift = viewModel.createdDrift {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack(spacing: 12) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color.brandPrimary.opacity(0.08))
                                    .frame(width: 40, height: 40)
                                Image(systemName: AppIcons.calendar)
                                    .font(.system(size: 18))
                                    .foregroundColor(.brandPrimary)
                            }
                            VStack(alignment: .leading, spacing: 2) {
                                Text(drift.title)
                                    .font(.bodyBold)
                                Text("\(drift.time) • \(drift.location) • \(drift.capacity) people")
                                    .font(.metadata)
                                    .foregroundColor(.textSecondary.opacity(0.7))
                            }
                        }
                    }
                    .padding(16)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.surfaceMain)
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                    .overlay(RoundedRectangle(cornerRadius: 20, style: .continuous).stroke(Color.appBorder.opacity(0.4), lineWidth: 1))
                    .padding(.horizontal, 20)
                }
                
                Text(AppStrings.Create.redirectNote)
                    .font(.metadata)
                    .foregroundColor(.textSecondary.opacity(0.6))
                
                Spacer()
                
                Button {
                    dismiss()
                } label: {
                    HStack {
                        Text(AppStrings.Create.manageDrift)
                            .font(.buttonText)
                        Spacer()
                        Image(systemName: AppIcons.chevronRight)
                            .font(.bodyBold)
                    }
                    .padding(.horizontal, 20)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(Color.brandPrimary)
                    .foregroundColor(.white)
                    .cornerRadius(AppConstants.UI.cornerRadiusSmall * 1.2)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
            .padding(.top, 60)
        }
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

// MARK: - Preview
struct CreateDriftScreen_Previews: PreviewProvider {
    static var previews: some View {
    CreateDriftScreen()
    }
}
