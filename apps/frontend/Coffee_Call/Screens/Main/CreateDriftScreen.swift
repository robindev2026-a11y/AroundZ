import SwiftUI
import Combine
import FirebaseCore
import FirebaseAuth


struct CreateDriftSheet: View {
    enum Mode { case create, edit }
    private let mode: Mode
    private let existingDrift: Drift?
    private let onSave: (Drift) -> Void
    private let onCreateSucceeded: () -> Void
    @Environment(\.dismiss) private var dismiss
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @FocusState private var focusedField: FocusField?
    @StateObject private var viewModel: CreateDriftViewModel
    @State private var showDiscardConfirmation = false
    @State private var showSuccessState = false
    @State private var showHookTooltip = false

    init(
        mode: Mode = .create,
        drift: Drift? = nil,
        viewModel: CreateDriftViewModel? = nil,
        onSave: @escaping (Drift) -> Void = { _ in },
        onCreateSucceeded: @escaping () -> Void = {}
    ) {
        self.mode = mode
        self.existingDrift = drift
        self.onSave = onSave
        self.onCreateSucceeded = onCreateSucceeded

        if mode == .edit, let drift = drift {
            _viewModel = StateObject(wrappedValue: viewModel ?? CreateDriftViewModel(editing: drift))
        } else {
            _viewModel = StateObject(wrappedValue: viewModel ?? CreateDriftViewModel())
        }
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            Color.backgroundMain.ignoresSafeArea()

            glassBackdrop

            VStack(spacing: 0) {
                if mode == .create {
                    sheetHandle
                }
                header
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: AppConstants.Layout.sectionSpacing) {
                        activitySection
                        planTitleSection
                        dateTimeSection
                        locationCapacitySection
                        joinModeSection
                        VibeMenuRow(selectedVibe: $viewModel.selectedVibe)
                        optionalDetailsSection
                        privacySection
                    }
                    .padding(.horizontal, AppConstants.Layout.standardPadding)
                    .padding(.top, AppConstants.Layout.subElementSpacing)
                    .padding(.bottom, AppConstants.Layout.createSheetFooterHeight + AppConstants.Layout.createSheetFooterSpacing + AppConstants.Layout.screenBottomSpacer)
                }
            }

            stickyFooter
        }
        .interactiveDismissDisabled(mode == .create)
        .onChange(of: viewModel.selectedActivity) { newValue in
            if newValue == .custom {
                focusedField = .customActivity
            } else if focusedField == .customActivity {
                focusedField = nil
            }
        }
        .alert(AppStrings.Create.discardTitle, isPresented: $showDiscardConfirmation) {
            Button(AppStrings.Create.continueEditing, role: .cancel) { }
            Button(AppStrings.Create.discardAction, role: .destructive) {
                dismiss()
            }
        } message: {
            Text(AppStrings.Create.discardMessage)
        }
        .alert("Error", isPresented: $viewModel.showErrorAlert) {
            Button(AppStrings.Common.ok, role: .cancel) { }
        } message: {
            Text(viewModel.errorAlertMessage)
        }
    }

    private var glassBackdrop: some View {
        ZStack {
            Circle()
                .fill(Color.brandPrimary.opacity(0.14))
                .frame(width: 420, height: 420)
                .blur(radius: 72)
                .offset(x: -160, y: -320)

            Circle()
                .fill(Color.brandPrimary.opacity(0.08))
                .frame(width: 320, height: 320)
                .blur(radius: 56)
                .offset(x: 170, y: 220)

            RoundedRectangle(cornerRadius: AppConstants.Layout.createSheetRadius, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(
                    LinearGradient(
                        colors: [
                            Color.brandPrimary.opacity(0.10),
                            Color.surfaceMain.opacity(0.76),
                            Color.backgroundMain.opacity(0.58)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: AppConstants.Layout.createSheetRadius, style: .continuous)
                        .stroke(Color.brandPrimary.opacity(0.16), lineWidth: 1)
                )
                .shadow(color: Color.brandPrimary.opacity(0.08), radius: 24, x: 0, y: 12)
        }
        .ignoresSafeArea()
        .allowsHitTesting(false)
    }

    private var sheetHandle: some View {
        Capsule()
            .fill(Color.appBorder)
            .frame(width: AppConstants.Layout.sheetHandleWidth, height: AppConstants.Layout.sheetHandleHeight)
            .padding(.top, AppConstants.Layout.sheetHandleTopPadding)
            .padding(.bottom, AppConstants.Layout.sheetHandleBottomPadding)
    }

    private var header: some View {
        HStack(alignment: .top, spacing: AppConstants.Layout.elementSpacing) {
            VStack(alignment: .leading, spacing: AppConstants.Layout.miniPadding) {
                Text(mode == .edit ? AppStrings.Manage.editTitle : AppStrings.Create.title)
                    .font(.heading1)
                    .foregroundColor(.textPrimary)

                Text(mode == .edit ? AppStrings.Manage.editSubtitle : AppStrings.Create.subtitle)
                    .font(.bodyStandard)
                    .foregroundColor(.textSecondary)
            }

            Spacer(minLength: 0)

            Button(action: closeTapped) {
                ZStack {
                    Circle()
                        .fill(Color.surfaceMain)
                        .frame(width: AppConstants.Layout.minTouchTarget + 10, height: AppConstants.Layout.minTouchTarget + 10)
                        .overlay(
                            Circle()
                                .stroke(Color.appBorder, lineWidth: 1)
                        )

                    AppIcons.closeImage
                        .font(.bodyBold)
                        .foregroundColor(.textPrimary)
                }
            }
            .pressScale(0.92)
        }
        .padding(.horizontal, AppConstants.Layout.standardPadding)
        .padding(.bottom, AppConstants.Layout.elementSpacing)
    }

    private var activitySection: some View {
        VStack(alignment: .leading, spacing: AppConstants.Layout.elementSpacing) {
            HStack(alignment: .firstTextBaseline) {
                VStack(alignment: .leading, spacing: 4) {
                    requiredSectionTitle(AppStrings.Create.activityTitle)

                    Text(AppStrings.Create.activitySubtitle)
                        .font(.bodyStandard)
                        .foregroundColor(.textSecondary)
                }

                Spacer(minLength: 0)

                Button(action: {
                    withAnimation(CoffeeAnimation.spring) {
                        viewModel.setActivity(.custom)
                    }
                }) {
                    HStack(spacing: 6) {
                        AppIcons.editImage
                            .font(.captionText)
                        Text(AppStrings.Create.customActivity)
                            .font(.captionText)
                    }
                    .foregroundColor(viewModel.selectedActivity == .custom ? .brandPrimary : .textPrimary)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(viewModel.selectedActivity == .custom ? Color.brandPrimary.opacity(0.12) : Color.surfaceMain)
                    .overlay(
                        Capsule()
                            .stroke(viewModel.selectedActivity == .custom ? Color.brandPrimary.opacity(0.35) : Color.appBorder, lineWidth: 1)
                    )
                    .clipShape(Capsule())
                }
                .pressScale(0.96)
            }

            LazyVGrid(columns: activityColumns, spacing: AppConstants.Layout.elementSpacing) {
                ForEach(visibleActivityItems, id: \.id) { activity in
                    ActivityTypeCard(
                        activity: activity,
                        isSelected: viewModel.selectedActivity == activity
                    ) {
                        withAnimation(CoffeeAnimation.spring) {
                            viewModel.setActivity(activity)
                        }
                    }
                }
            }

            if activityItems.count > AppConstants.Create.activityGridCollapsedCount {
                Button(action: {
                    viewModel.toggleActivityGridExpansion()
                }) {
                    HStack(spacing: 6) {
                        Text(viewModel.isActivityGridExpanded ? AppStrings.Create.viewLessActivities : AppStrings.Create.viewMoreActivities)
                            .font(.bodyBold)
                        AppIcons.chevronDownImage
                            .font(.captionText)
                            .rotationEffect(.degrees(viewModel.isActivityGridExpanded ? 180 : 0))
                    }
                    .foregroundColor(.brandPrimary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color.surfaceMain)
                    .overlay(
                        RoundedRectangle(cornerRadius: AppConstants.UI.cornerRadiusMedium, style: .continuous)
                            .stroke(Color.appBorder, lineWidth: 1)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: AppConstants.UI.cornerRadiusMedium, style: .continuous))
                }
                .pressScale(0.97)
            }

            if viewModel.selectedActivity == .custom {
                InlineTextFieldRow(
                    title: AppStrings.Create.customActivityTitle,
                    placeholder: AppStrings.Create.customActivityPlaceholder,
                    text: $viewModel.customActivityText,
                    isRequired: true,
                    tooltipTitle: nil,
                    tooltipMessage: nil,
                    showTooltip: .constant(false),
                    focusField: .customActivity,
                    focusedField: $focusedField
                )
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
    }

    private var planTitleSection: some View {
        VStack(alignment: .leading, spacing: AppConstants.Layout.elementSpacing) {
            requiredSectionTitle(AppStrings.Create.planTitlePrompt)

            TitleField(
                text: $viewModel.planTitle,
                focusedField: $focusedField,
                count: viewModel.titleCount,
                maxCount: viewModel.maxTitleCount
            )
        }
    }

    private var dateTimeSection: some View {
        VStack(alignment: .leading, spacing: AppConstants.Layout.elementSpacing) {
            requiredSectionTitle(AppStrings.Create.timeTitle)

            Text(AppStrings.Create.timeSubtitle)
                .font(.bodyStandard)
                .foregroundColor(.textSecondary)

            HStack(spacing: AppConstants.Layout.elementSpacing) {
                DatePicker(
                    "",
                    selection: $viewModel.scheduledDate,
                    displayedComponents: [.date]
                )
                .datePickerStyle(.compact)
                .labelsHidden()
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, AppConstants.Layout.elementSpacing)
                .padding(.vertical, AppConstants.Layout.subElementSpacing)
                .background(Color.surfaceMain)
                .overlay(
                    RoundedRectangle(cornerRadius: AppConstants.UI.cornerRadiusMedium, style: .continuous)
                        .stroke(Color.appBorder, lineWidth: 1)
                )
                .clipShape(RoundedRectangle(cornerRadius: AppConstants.UI.cornerRadiusMedium, style: .continuous))

                DatePicker(
                    "",
                    selection: $viewModel.scheduledDate,
                    displayedComponents: [.hourAndMinute]
                )
                .datePickerStyle(.compact)
                .labelsHidden()
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, AppConstants.Layout.elementSpacing)
                .padding(.vertical, AppConstants.Layout.subElementSpacing)
                .background(Color.surfaceMain)
                .overlay(
                    RoundedRectangle(cornerRadius: AppConstants.UI.cornerRadiusMedium, style: .continuous)
                        .stroke(Color.appBorder, lineWidth: 1)
                )
                .clipShape(RoundedRectangle(cornerRadius: AppConstants.UI.cornerRadiusMedium, style: .continuous))
            }

            HStack(spacing: AppConstants.Layout.elementSpacing) {
                dateTimeCaption(AppStrings.Create.dateLabel)
                dateTimeCaption(AppStrings.Create.timeLabel)
            }
        }
    }

    private var locationCapacitySection: some View {
        Group {
            if horizontalSizeClass == .regular {
                LazyVGrid(columns: locationCapacityColumns, spacing: AppConstants.Layout.elementSpacing) {
                    ApproximateLocationCard(location: viewModel.approximateLocation)
                    CapacityChipScrollCard(
                        selectedCapacityCount: viewModel.selectedCapacityCount,
                        isOpenToAllCapacity: viewModel.isOpenToAllCapacity,
                        onCapacityChange: { viewModel.setCapacityCount($0) },
                        onOpenToAllChange: { viewModel.setOpenToAllCapacity($0) }
                    )
                }
            } else {
                VStack(spacing: AppConstants.Layout.elementSpacing) {
                    ApproximateLocationCard(location: viewModel.approximateLocation)
                    CapacityChipScrollCard(
                        selectedCapacityCount: viewModel.selectedCapacityCount,
                        isOpenToAllCapacity: viewModel.isOpenToAllCapacity,
                        onCapacityChange: { viewModel.setCapacityCount($0) },
                        onOpenToAllChange: { viewModel.setOpenToAllCapacity($0) }
                    )
                }
            }
        }
    }

    private var joinModeSection: some View {
        VStack(alignment: .leading, spacing: AppConstants.Layout.elementSpacing) {
            requiredSectionTitle(AppStrings.Create.joinModeTitle)

            JoinModeToggleCard(
                selectedMode: viewModel.selectedJoinMode,
                onSelect: { mode in
                    withAnimation(CoffeeAnimation.spring) {
                        viewModel.setJoinMode(mode)
                    }
                }
            )
        }
    }

    private var optionalDetailsSection: some View {
        VStack(alignment: .leading, spacing: AppConstants.Layout.elementSpacing) {
            Button(action: {
                withAnimation(CoffeeAnimation.springGentle) {
                    viewModel.optionalDetailsExpanded.toggle()
                }
            }) {
                HStack(alignment: .top, spacing: AppConstants.Layout.miniPadding) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(AppStrings.Create.optionalDetails)
                            .font(.bodyBold)
                            .foregroundColor(.textPrimary)

                        Text(AppStrings.Create.optionalDetailsSubtitle)
                            .font(.bodyStandard)
                            .foregroundColor(.textSecondary)
                    }

                    Spacer(minLength: 0)

                    AppIcons.chevronDownImage
                        .font(.captionText)
                        .foregroundColor(.textSecondary)
                        .rotationEffect(.degrees(viewModel.optionalDetailsExpanded ? 180 : 0))
                }
                .padding(.horizontal, AppConstants.Layout.elementSpacing)
                .padding(.vertical, AppConstants.Layout.elementSpacing)
                .background(Color.surfaceMain)
                .overlay(
                    RoundedRectangle(cornerRadius: AppConstants.UI.cornerRadiusMedium, style: .continuous)
                        .stroke(Color.appBorder, lineWidth: 1)
                )
                .clipShape(RoundedRectangle(cornerRadius: AppConstants.UI.cornerRadiusMedium, style: .continuous))
            }
            .pressScale(0.98)

            if viewModel.optionalDetailsExpanded {
                VStack(spacing: AppConstants.Layout.elementSpacing) {
                    InlineTextFieldRow(
                        title: AppStrings.Create.hookTitle,
                        placeholder: AppStrings.Create.hookPlaceholder,
                        text: $viewModel.hookText,
                        isRequired: false,
                        tooltipTitle: AppStrings.Create.hookTooltipTitle,
                        tooltipMessage: AppStrings.Create.hookTooltipMessage,
                        showTooltip: $showHookTooltip,
                        focusField: .hook,
                        focusedField: $focusedField
                    )

                    NotesFieldRow(
                        title: AppStrings.Create.notesTitle,
                        placeholder: AppStrings.Create.notesPlaceholder,
                        text: $viewModel.notesText,
                        focusedField: $focusedField
                    )
                }
                .padding(.horizontal, AppConstants.Layout.elementSpacing)
                .padding(.vertical, AppConstants.Layout.elementSpacing)
                .background(Color.surfaceMain)
                .overlay(
                    RoundedRectangle(cornerRadius: AppConstants.UI.cornerRadiusMedium, style: .continuous)
                        .stroke(Color.appBorder, lineWidth: 1)
                )
                .clipShape(RoundedRectangle(cornerRadius: AppConstants.UI.cornerRadiusMedium, style: .continuous))
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
    }

    private var privacySection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .top, spacing: 8) {
                AppIcons.shieldVerifiedImage
                    .font(.captionText)
                    .foregroundColor(.brandPrimary)
                    .padding(.top, 1)

                VStack(alignment: .leading, spacing: 4) {
                    Text(AppStrings.Create.privacyLinePrimary)
                        .font(.metadata)
                        .foregroundColor(.textSecondary)
                        .multilineTextAlignment(.leading)

                    Text(AppStrings.Create.privacyLineSecondary)
                        .font(.metadata)
                        .foregroundColor(.textSecondary)
                }
            }
        }
    }

    private var stickyFooter: some View {
        VStack(spacing: AppConstants.Layout.createSheetFooterSpacing) {
            if mode == .create, showSuccessState {
                successBanner
            }

            Button(action: postTapped) {
                HStack(spacing: AppConstants.Layout.subElementSpacing) {
                    if viewModel.isCreating {
                        ProgressView()
                            .tint(viewModel.canPost ? .textOnBrand : .textSecondary)
                    } else if showSuccessState {
                        AppIcons.checkCircleFillImage
                            .font(.bodyBold)
                    } else if mode == .edit {
                        AppIcons.checkmarkImage
                            .font(.bodyBold)
                    } else {
                        AppIcons.paperplaneFillImage
                            .font(.bodyBold)
                    }

                    Text(footerTitle)
                        .font(.buttonText)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .foregroundColor(viewModel.canPost || showSuccessState ? .textOnBrand : .textSecondary)
                .background(
                    RoundedRectangle(cornerRadius: AppConstants.UI.cornerRadiusLarge, style: .continuous)
                        .fill(footerBackground)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: AppConstants.UI.cornerRadiusLarge, style: .continuous)
                        .stroke(Color.white.opacity(0.12), lineWidth: 1)
                )
            }
            .disabled(!viewModel.canPost)
            .pressScale(0.97)

            Text(AppStrings.Create.footerNote)
                .font(.metadata)
                .foregroundColor(.textSecondary)
        }
        .padding(.horizontal, AppConstants.Layout.standardPadding)
        .padding(.top, 12)
        .padding(.bottom, 12)
        .background(
            Color.backgroundMain
                .ignoresSafeArea(edges: .bottom)
        )
    }

    private var successBanner: some View {
        HStack(spacing: AppConstants.Layout.subElementSpacing) {
            AppIcons.checkCircleFillImage
                .font(.bodyBold)
                .foregroundColor(.brandPrimary)

            VStack(alignment: .leading, spacing: 2) {
                Text(AppStrings.Create.successTitle)
                    .font(.bodyBold)
                    .foregroundColor(.textPrimary)

                Text(AppStrings.Create.successSubtitle)
                    .font(.metadata)
                    .foregroundColor(.textSecondary)
            }

            Spacer(minLength: 0)
        }
        .padding(.horizontal, AppConstants.Layout.elementSpacing)
        .padding(.vertical, AppConstants.Layout.subElementSpacing)
        .background(Color.surfaceMain)
        .overlay(
            RoundedRectangle(cornerRadius: AppConstants.UI.cornerRadiusMedium, style: .continuous)
                .stroke(Color.brandPrimary.opacity(0.24), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: AppConstants.UI.cornerRadiusMedium, style: .continuous))
    }

    private var footerTitle: String {
        switch mode {
        case .create:
            if viewModel.isCreating {
                return AppStrings.Create.postingAction
            }

            if showSuccessState {
                return AppStrings.Create.created
            }

            return AppStrings.Create.postAction
        case .edit:
            if viewModel.isCreating {
                return AppStrings.Manage.savingAction
            }

            return AppStrings.Common.save
        }
    }

    private var footerBackground: LinearGradient {
        if viewModel.canPost {
            return LinearGradient(
                colors: [.brandPrimary, .brandPrimaryDark],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }

        return LinearGradient(
            colors: [.surfaceSecondary, .surfaceSecondary],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    private var activityColumns: [GridItem] {
        Array(repeating: GridItem(.flexible(), spacing: AppConstants.Layout.elementSpacing), count: 3)
    }

    private var activityItems: [ActivityType] {
        Array(ActivityType.allCases.dropLast())
    }

    private var visibleActivityItems: [ActivityType] {
        if viewModel.isActivityGridExpanded {
            return activityItems
        }

        return Array(activityItems.prefix(AppConstants.Create.activityGridCollapsedCount))
    }

    private func closeTapped() {
        if mode == .create {
            if viewModel.hasUnsavedChanges || viewModel.isCreating {
                showDiscardConfirmation = true
                return
            }

            dismiss()
            return
        }

        guard !viewModel.isCreating else { return }
        dismiss()
    }

    private func postTapped() {
        guard viewModel.canPost else { return }

        if mode == .create {
            viewModel.create { drift in
                CreatedDriftStore.shared.add(drift)
                showSuccessState = true
                onCreateSucceeded()

                DispatchQueue.main.asyncAfter(deadline: .now() + 0.85) {
                    dismiss()
                }
            }
        } else if mode == .edit, let existing = existingDrift {
            viewModel.update(original: existing) { updated in
                CreatedDriftStore.shared.add(updated)
                NotificationCenter.default.post(name: NSNotification.Name("DriftUpdated"), object: nil, userInfo: ["drift": updated])
                onSave(updated)
                dismiss()
            }
        }
    }

    enum FocusField {
        case title
        case customActivity
        case hook
        case notes
    }

    private func requiredSectionTitle(_ title: String) -> some View {
        HStack(spacing: 4) {
            Text(title)
            Text(AppStrings.Create.requiredMarker)
                .foregroundColor(.brandSecondary)
        }
        .font(.heading2)
        .foregroundColor(.textPrimary)
    }

    private func dateTimeCaption(_ title: String) -> some View {
        HStack(spacing: 4) {
            Text(title)
            Text(AppStrings.Create.requiredMarker)
                .foregroundColor(.brandSecondary)
        }
        .font(.metadata)
        .foregroundColor(.textSecondary)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var locationCapacityColumns: [GridItem] {
        [GridItem(.flexible(), spacing: AppConstants.Layout.elementSpacing), GridItem(.flexible(), spacing: AppConstants.Layout.elementSpacing)]
    }
}

private struct TitleField: View {
    @Binding var text: String
    @FocusState.Binding var focusedField: CreateDriftSheet.FocusField?
    let count: Int
    let maxCount: Int

    var body: some View {
        let displayedCount = min(count, maxCount)

        HStack(spacing: AppConstants.Layout.elementSpacing) {
            ZStack(alignment: .leading) {
                TextField("", text: $text)
                    .font(.bodyStandard)
                    .foregroundColor(.textPrimary)
                    .focused($focusedField, equals: .title)
                    .textInputAutocapitalization(.sentences)
                    .autocorrectionDisabled(false)
                    .frame(maxWidth: .infinity, alignment: .leading)

                if text.isEmpty {
                    Text(AppStrings.Create.titlePlaceholder)
                        .font(.bodyStandard)
                        .foregroundColor(.textSecondary)
                        .allowsHitTesting(false)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Text(String(format: AppStrings.Create.titleCounterFormat, displayedCount))
                .font(.metadata)
                .foregroundColor(.textSecondary)
        }
        .padding(.horizontal, AppConstants.Layout.elementSpacing)
        .padding(.vertical, AppConstants.Layout.subElementSpacing + 2)
        .background(Color.surfaceMain)
        .overlay(
            RoundedRectangle(cornerRadius: AppConstants.UI.cornerRadiusMedium, style: .continuous)
                .stroke(Color.appBorder, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: AppConstants.UI.cornerRadiusMedium, style: .continuous))
    }
}

private struct ActivityTypeCard: View {
    let activity: ActivityType
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 10) {
                Image(systemName: activity.iconName)
                    .font(.system(size: 21, weight: .regular))
                    .foregroundColor(isSelected ? activity.tint : .textPrimary)
                    .frame(height: 24)

                Text(activity.title)
                    .font(.bodyStandard)
                    .foregroundColor(.textPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .frame(maxWidth: .infinity)
            .frame(minHeight: AppConstants.Layout.createSheetCardMinHeight + 28)
            .padding(.vertical, AppConstants.Layout.subElementSpacing)
            .background(isSelected ? activity.tint.opacity(0.06) : Color.surfaceMain)
            .overlay(
                RoundedRectangle(cornerRadius: AppConstants.UI.cornerRadiusSmall, style: .continuous)
                    .stroke(isSelected ? activity.tint.opacity(0.38) : Color.appBorder, lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: AppConstants.UI.cornerRadiusSmall, style: .continuous))
        }
        .pressScale(0.96)
    }
}

private struct TimeChip: View {
    let option: TimeOption
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: option.icon)
                    .font(.captionText)
                Text(option.title)
                    .font(.captionText)
            }
            .foregroundColor(isSelected ? .brandPrimary : .textPrimary)
            .frame(maxWidth: .infinity)
            .frame(height: AppConstants.Layout.createSheetChipHeight)
            .padding(.horizontal, 6)
            .background(isSelected ? Color.brandPrimary.opacity(0.12) : Color.surfaceMain)
            .overlay(
                RoundedRectangle(cornerRadius: AppConstants.UI.cornerRadiusSmall, style: .continuous)
                    .stroke(isSelected ? Color.brandPrimary.opacity(0.35) : Color.appBorder, lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: AppConstants.UI.cornerRadiusSmall, style: .continuous))
        }
        .pressScale(0.96)
    }
}

private struct ApproximateLocationCard: View {
    let location: String

    var body: some View {
        VStack(alignment: .leading, spacing: AppConstants.Layout.subElementSpacing) {
            HStack(spacing: 4) {
                Text(AppStrings.Create.locationTitle)
                Text(AppStrings.Create.requiredMarker)
                    .foregroundColor(.brandSecondary)
            }
            .font(.bodyBold)
            .foregroundColor(.textPrimary)

            HStack(alignment: .center, spacing: 8) {
                ZStack {
                    Circle()
                        .fill(Color.brandPrimary.opacity(0.12))
                        .frame(width: 36, height: 36)

                    AppIcons.mappinCircleImage
                        .font(.bodyBold)
                        .foregroundColor(.brandPrimary)
                }

                Text(location)
                    .font(.bodyBold)
                    .foregroundColor(.textPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)

                Spacer(minLength: 0)
            }

            Text(AppStrings.Create.locationApprox)
                .font(.bodyStandard)
                .foregroundColor(.textSecondary)

            Text(AppStrings.Create.locationCardNote)
                .font(.metadata)
                .foregroundColor(.textSecondary)
                .lineLimit(2)
        }
        .padding(AppConstants.Layout.elementSpacing)
        .frame(minHeight: AppConstants.Layout.createSheetLocationCardHeight)
        .background(Color.surfaceMain)
        .overlay(
            RoundedRectangle(cornerRadius: AppConstants.UI.cornerRadiusMedium, style: .continuous)
                .stroke(Color.appBorder, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: AppConstants.UI.cornerRadiusMedium, style: .continuous))
    }
}

private struct CapacityChipScrollCard: View {
    let selectedCapacityCount: Int
    let isOpenToAllCapacity: Bool
    let onCapacityChange: (Int) -> Void
    let onOpenToAllChange: (Bool) -> Void

    private let capacityOptions = Array(1...50)

    var body: some View {
        VStack(alignment: .leading, spacing: AppConstants.Layout.elementSpacing) {
            HStack(spacing: 4) {
                Text(AppStrings.Create.capacityTitle)
                Text(AppStrings.Create.requiredMarker)
                    .foregroundColor(.brandSecondary)
            }
            .font(.bodyBold)
            .foregroundColor(.textPrimary)

            Toggle(isOn: Binding(
                get: { isOpenToAllCapacity },
                set: { onOpenToAllChange($0) }
            )) {
                HStack(spacing: 8) {
                    ZStack {
                        Circle()
                            .fill(isOpenToAllCapacity ? Color.brandPrimary.opacity(0.12) : Color.surfaceSecondary)
                            .frame(width: 36, height: 36)

                        AppIcons.ellipsisImage
                            .font(.captionText)
                            .foregroundColor(isOpenToAllCapacity ? .brandPrimary : .textSecondary)
                            .rotationEffect(.degrees(isOpenToAllCapacity ? 180 : 0))
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text(AppStrings.Create.openToAll)
                            .font(.bodyBold)
                            .foregroundColor(.textPrimary)
                        Text(AppStrings.Create.openToAllSubtitle)
                            .font(.metadata)
                            .foregroundColor(.textSecondary)
                    }
                }
            }
            .toggleStyle(SwitchToggleStyle(tint: .brandPrimary))
            .animation(.spring(response: 0.28, dampingFraction: 0.78), value: isOpenToAllCapacity)

            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: AppConstants.Layout.subElementSpacing) {
                    ForEach(capacityOptions, id: \.self) { value in
                        Button {
                            guard !isOpenToAllCapacity else { return }
                            withAnimation(CoffeeAnimation.spring) {
                                onCapacityChange(value)
                            }
                        } label: {
                            Text("\(value)")
                                .font(.bodyBold)
                                .foregroundColor(selectedCapacityCount == value ? .brandPrimary : .textPrimary)
                                .frame(width: 52, height: 44)
                                .background(selectedCapacityCount == value ? Color.brandPrimary.opacity(0.12) : Color.surfaceMain)
                                .overlay(
                                    RoundedRectangle(cornerRadius: AppConstants.UI.cornerRadiusSmall, style: .continuous)
                                        .stroke(selectedCapacityCount == value ? Color.brandPrimary.opacity(0.35) : Color.appBorder, lineWidth: 1)
                                )
                                .clipShape(RoundedRectangle(cornerRadius: AppConstants.UI.cornerRadiusSmall, style: .continuous))
                        }
                        .disabled(isOpenToAllCapacity)
                        .pressScale(0.96)
                    }
                }
                .padding(.vertical, 2)
            }
            .disabled(isOpenToAllCapacity)
            .opacity(isOpenToAllCapacity ? 0.45 : 1)
            .animation(.spring(response: 0.28, dampingFraction: 0.78), value: isOpenToAllCapacity)
        }
        .padding(AppConstants.Layout.elementSpacing)
        .frame(minHeight: AppConstants.Layout.createSheetLocationCardHeight)
        .background(Color.surfaceMain)
        .overlay(
            RoundedRectangle(cornerRadius: AppConstants.UI.cornerRadiusMedium, style: .continuous)
                .stroke(Color.appBorder, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: AppConstants.UI.cornerRadiusMedium, style: .continuous))
    }
}

private struct VibeMenuRow: View {
    @Binding var selectedVibe: VibeOption?

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 4) {
                Text(AppStrings.Create.vibeTitle)
                Text(AppStrings.Create.requiredMarker)
                    .foregroundColor(.brandSecondary)
            }
            .font(.bodyBold)
            .foregroundColor(.textPrimary)

            Menu {
                ForEach(VibeOption.allCases) { vibe in
                    Button {
                        withAnimation(CoffeeAnimation.spring) {
                            selectedVibe = vibe
                        }
                    } label: {
                        HStack(spacing: AppConstants.Layout.subElementSpacing) {
                            ZStack {
                                Circle()
                                    .fill(vibe.tint.opacity(0.14))
                                    .frame(width: 26, height: 26)

                                Image(systemName: vibe.icon)
                                    .font(.captionText)
                                    .foregroundColor(vibe.tint)
                            }
                            Text(vibe.title)
                                .foregroundColor(vibe.tint)
                        }
                    }
                }
            } label: {
                HStack(spacing: AppConstants.Layout.subElementSpacing) {
                    if let selectedVibe {
                        ZStack {
                            Circle()
                                .fill(selectedVibe.tint.opacity(0.14))
                                .frame(width: 28, height: 28)

                            Image(systemName: selectedVibe.icon)
                                .font(.captionText)
                                .foregroundColor(selectedVibe.tint)
                        }
                    }

                    Text(selectedVibe?.title ?? AppStrings.Create.vibeSelectionPlaceholder)
                        .font(.bodyStandard)
                        .foregroundColor(selectedVibe == nil ? .textSecondary : (selectedVibe?.tint ?? .textPrimary))
                        .lineLimit(1)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    Spacer(minLength: 0)

                    AppIcons.chevronDownImage
                        .font(.captionText)
                        .foregroundColor(.textSecondary)
                }
                .padding(.horizontal, AppConstants.Layout.elementSpacing)
                .padding(.vertical, AppConstants.Layout.subElementSpacing)
                .frame(maxWidth: .infinity, minHeight: 48, alignment: .leading)
                .background(
                    LinearGradient(
                        colors: [
                            (selectedVibe?.tint ?? Color.surfaceSecondary).opacity(selectedVibe == nil ? 1 : 0.14),
                            Color.surfaceMain
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: AppConstants.UI.cornerRadiusMedium, style: .continuous)
                        .stroke(selectedVibe?.tint.opacity(0.32) ?? Color.appBorder, lineWidth: 1)
                )
                .clipShape(RoundedRectangle(cornerRadius: AppConstants.UI.cornerRadiusMedium, style: .continuous))
            }
        }
    }
}

private struct JoinModeToggleCard: View {
    let selectedMode: JoinMode
    let onSelect: (JoinMode) -> Void

    var body: some View {
        HStack(spacing: AppConstants.Layout.elementSpacing) {
            joinModeOption(
                mode: .open,
                title: AppStrings.Create.joinModeOpen,
                subtitle: AppStrings.Create.joinModeOpenSubtitle,
                icon: AppIcons.participants,
                tint: Color.brandPrimary
            )

            joinModeOption(
                mode: .approval,
                title: AppStrings.Create.joinModeApproval,
                subtitle: AppStrings.Create.joinModeApprovalSubtitle,
                icon: AppIcons.lock,
                tint: Color.brandPurple
            )
        }
    }

    private func joinModeOption(
        mode: JoinMode,
        title: String,
        subtitle: String,
        icon: String,
        tint: Color
    ) -> some View {
        Button {
            onSelect(mode)
        } label: {
            HStack(alignment: .center, spacing: AppConstants.Layout.subElementSpacing) {
                ZStack {
                    Circle()
                        .fill((selectedMode == mode ? tint : Color.surfaceSecondary).opacity(selectedMode == mode ? 0.16 : 1))
                        .frame(width: 40, height: 40)

                    Image(systemName: icon)
                        .font(.captionText)
                        .foregroundColor(selectedMode == mode ? tint : .textSecondary)
                        .rotationEffect(.degrees(selectedMode == mode ? 0 : -10))
                        .scaleEffect(selectedMode == mode ? 1.04 : 0.96)
                        .animation(.spring(response: 0.3, dampingFraction: 0.75), value: selectedMode == mode)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.bodyBold)
                        .foregroundColor(.textPrimary)

                    Text(subtitle)
                        .font(.metadata)
                        .foregroundColor(.textSecondary)
                        .lineLimit(2)
                }

                Spacer(minLength: 0)
            }
            .padding(AppConstants.Layout.elementSpacing)
            .frame(maxWidth: .infinity)
            .frame(minHeight: AppConstants.Layout.createSheetJoinModeHeight)
            .background(selectedMode == mode ? tint.opacity(0.08) : Color.surfaceMain)
            .overlay(
                RoundedRectangle(cornerRadius: AppConstants.UI.cornerRadiusMedium, style: .continuous)
                    .stroke(selectedMode == mode ? tint.opacity(0.35) : Color.appBorder, lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: AppConstants.UI.cornerRadiusMedium, style: .continuous))
        }
        .pressScale(0.96)
    }
}

private struct InlineTextFieldRow: View {
    let title: String
    let placeholder: String
    @Binding var text: String
    let isRequired: Bool
    let tooltipTitle: String?
    let tooltipMessage: String?
    @Binding var showTooltip: Bool
    let focusField: CreateDriftSheet.FocusField
    @FocusState.Binding var focusedField: CreateDriftSheet.FocusField?

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 4) {
                Text(title)
                if isRequired {
                    Text(AppStrings.Create.requiredMarker)
                        .foregroundColor(.brandSecondary)
                }

                if let tooltipTitle, let tooltipMessage {
                    Button {
                        withAnimation(CoffeeAnimation.springGentle) {
                            showTooltip.toggle()
                        }
                    } label: {
                        AppIcons.infoCircleImage
                            .font(.captionText)
                            .foregroundColor(.textSecondary)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(tooltipTitle)
                    .popover(isPresented: $showTooltip, attachmentAnchor: .rect(.bounds), arrowEdge: .bottom) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(tooltipTitle)
                                .font(.bodyBold)
                                .foregroundColor(.textPrimary)
                            Text(tooltipMessage)
                                .font(.bodyStandard)
                                .foregroundColor(.textSecondary)
                        }
                        .padding(AppConstants.Layout.elementSpacing)
                        .frame(maxWidth: 240, alignment: .leading)
                    }
                }
            }
            .font(.bodyBold)
            .foregroundColor(.textPrimary)

            TextField("", text: $text)
                .font(.bodyStandard)
                .foregroundColor(.textPrimary)
                .focused($focusedField, equals: focusField)
                .textInputAutocapitalization(.sentences)
                .autocorrectionDisabled(false)
                .overlay(alignment: .leading) {
                    if text.isEmpty {
                        Text(placeholder)
                            .font(.bodyStandard)
                            .foregroundColor(.textSecondary)
                            .allowsHitTesting(false)
                    }
                }
        }
    }
}

private struct NotesFieldRow: View {
    let title: String
    let placeholder: String
    @Binding var text: String
    @FocusState.Binding var focusedField: CreateDriftSheet.FocusField?

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.bodyBold)
                .foregroundColor(.textPrimary)

            ZStack(alignment: .topLeading) {
                if text.isEmpty {
                    Text(placeholder)
                        .font(.bodyStandard)
                        .foregroundColor(.textSecondary)
                        .padding(.horizontal, 4)
                        .padding(.vertical, 8)
                        .allowsHitTesting(false)
                }

                TextEditor(text: $text)
                    .font(.bodyStandard)
                    .foregroundColor(.textPrimary)
                    .focused($focusedField, equals: .notes)
                    .frame(minHeight: 80)
                    .scrollContentBackground(.hidden)
                    .background(Color.clear)
            }
        }
    }
}

struct CreateDriftSheet_Previews: PreviewProvider {
    static var previews: some View {
        CreateDriftSheet()
            .presentationDetents([.large])
    }
}
