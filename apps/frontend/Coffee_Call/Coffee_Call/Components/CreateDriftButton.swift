import SwiftUI

final class CreateDriftViewModel: ObservableObject {
    enum ActivityType: String, CaseIterable, Identifiable {
        case coffee
        case walk
        case food
        case movie
        case study
        case fitness
        case games
        case music
        case sports
        case drinks
        case custom

        var id: String { rawValue }

        var title: String {
            switch self {
            case .coffee: AppStrings.Create.Activity.coffee
            case .walk: AppStrings.Create.Activity.walk
            case .food: AppStrings.Create.Activity.food
            case .movie: AppStrings.Create.Activity.movie
            case .study: AppStrings.Create.Activity.study
            case .fitness: AppStrings.Create.Activity.fitness
            case .games: AppStrings.Create.Activity.games
            case .music: AppStrings.Create.Activity.music
            case .sports: AppStrings.Create.Activity.sports
            case .drinks: AppStrings.Create.Activity.drinks
            case .custom: AppStrings.Create.Activity.custom
            }
        }

        var icon: String {
            switch self {
            case .coffee: AppIcons.coffee
            case .walk: AppIcons.walk
            case .food: AppIcons.food
            case .movie: AppIcons.movie
            case .study: AppIcons.study
            case .fitness: AppIcons.fitness
            case .games: AppIcons.games
            case .music: AppIcons.music
            case .sports: AppIcons.sports
            case .drinks: AppIcons.drinks
            case .custom: AppIcons.custom
            }
        }

        var tint: Color {
            switch self {
            case .coffee, .walk, .fitness:
                return .brandPrimary
            case .food, .drinks:
                return .brandSecondary
            case .movie, .music, .games, .sports:
                return .brandPurple
            case .study, .custom:
                return .textPrimary
            }
        }
    }

    enum TimeOption: String, CaseIterable, Identifiable {
        case now
        case in30Mins
        case tonight
        case tomorrow
        case custom

        var id: String { rawValue }

        var title: String {
            switch self {
            case .now: AppStrings.Create.Time.now
            case .in30Mins: AppStrings.Create.Time.in30Mins
            case .tonight: AppStrings.Create.Time.tonight
            case .tomorrow: AppStrings.Create.Time.tomorrow
            case .custom: AppStrings.Create.Time.custom
            }
        }

        var icon: String {
            switch self {
            case .now: AppIcons.bolt
            case .in30Mins: AppIcons.clock
            case .tonight: AppIcons.moon
            case .tomorrow: AppIcons.calendar
            case .custom: AppIcons.ellipsis
            }
        }
    }

    enum CapacityOption: String, CaseIterable, Identifiable {
        case one
        case three
        case five
        case eightPlus

        var id: String { rawValue }

        var title: String {
            switch self {
            case .one: AppStrings.Create.Capacity.one
            case .three: AppStrings.Create.Capacity.three
            case .five: AppStrings.Create.Capacity.five
            case .eightPlus: AppStrings.Create.Capacity.eightPlus
            }
        }

        var value: Int {
            switch self {
            case .one: return 1
            case .three: return 3
            case .five: return 5
            case .eightPlus: return 8
            }
        }
    }

    enum VibeOption: String, CaseIterable, Identifiable {
        case casual
        case chill
        case friendly
        case focused
        case adventurous
        case social

        var id: String { rawValue }

        var title: String {
            switch self {
            case .casual: AppStrings.Create.Vibe.casual
            case .chill: AppStrings.Create.Vibe.chill
            case .friendly: AppStrings.Create.Vibe.friendly
            case .focused: AppStrings.Create.Vibe.focused
            case .adventurous: AppStrings.Create.Vibe.adventurous
            case .social: AppStrings.Create.Vibe.social
            }
        }
    }

    enum JoinMode: String, CaseIterable, Identifiable {
        case open
        case approval

        var id: String { rawValue }

        var title: String {
            switch self {
            case .open: AppStrings.Create.joinModeOpen
            case .approval: AppStrings.Create.joinModeApproval
            }
        }

        var subtitle: String {
            switch self {
            case .open: AppStrings.Create.joinModeOpenSubtitle
            case .approval: AppStrings.Create.joinModeApprovalSubtitle
            }
        }

        var icon: String {
            switch self {
            case .open: AppIcons.participants
            case .approval: AppIcons.lock
            }
        }
    }

    @Published var selectedActivity: ActivityType = .coffee
    @Published var planTitle: String = ""
    @Published var scheduledDate: Date
    @Published var selectedCapacity: CapacityOption = .three
    @Published var selectedJoinMode: JoinMode = .open
    @Published var approximateLocation: String = AppStrings.Create.sampleLocation
    @Published var customActivityText: String = ""
    @Published var hookText: String = ""
    @Published var selectedVibe: VibeOption? = nil
    @Published var notesText: String = ""
    @Published var optionalDetailsExpanded: Bool = false
    @Published var isCreating: Bool = false

    let maxTitleCount = 60
    private let initialScheduledDate: Date

    init() {
        let now = Date()
        initialScheduledDate = now
        _scheduledDate = Published(initialValue: now)
    }

    var titleCount: Int {
        min(planTitle.count, maxTitleCount)
    }

    var canPost: Bool {
        !planTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        && selectedVibe != nil
        && (selectedActivity != .custom || !customActivityText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        && !isCreating
    }

    var hasUnsavedChanges: Bool {
        selectedActivity != .coffee
        || !planTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        || scheduledDate != initialScheduledDate
        || selectedCapacity != .three
        || selectedJoinMode != .open
        || !customActivityText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        || !hookText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        || selectedVibe != nil
        || !notesText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        || optionalDetailsExpanded
    }

    func setActivity(_ activity: ActivityType) {
        selectedActivity = activity
    }

    func setCapacity(_ option: CapacityOption) {
        selectedCapacity = option
    }

    func setJoinMode(_ mode: JoinMode) {
        selectedJoinMode = mode
    }

    func create(completion: @escaping (Drift) -> Void) {
        guard canPost else { return }
        isCreating = true

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self else { return }
            self.isCreating = false
            completion(self.buildDrift())
        }
    }

    func buildDrift() -> Drift {
        let capacityValue = selectedCapacity.value
        let vibeTags = selectedVibe.map { [$0.title] } ?? []
        let host = Host(
            name: AppConstants.MockData.userName,
            role: AppStrings.Create.hostRole,
            imageUrl: nil,
            isVerified: true
        )

        return Drift(
            title: planTitle.trimmingCharacters(in: .whitespacesAndNewlines),
            description: driftDescription,
            location: approximateLocation,
            meetingPoint: AppStrings.Create.locationCardNote,
            time: Self.timeFormatter.string(from: scheduledDate),
            endTime: Self.endTimeFormatter.string(from: scheduledDate.addingTimeInterval(60 * 60)),
            date: Self.dateFormatter.string(from: scheduledDate),
            distance: 1.2,
            status: .open,
            category: categoryForSelectedActivity,
            hook: cleanedText(hookText),
            host: host,
            peopleGoing: 1,
            spotsLeft: max(capacityValue - 1, 0),
            capacity: capacityValue,
            vibeTags: vibeTags,
            whatToBring: [],
            notes: cleanedText(notesText),
            participantInitials: [AppConstants.MockData.userInitials],
            imageUrl: nil,
            isMine: true
        )
    }

    private var driftDescription: String {
        let parts = [hookText, customActivityText, notesText].compactMap { cleanedText($0) }
        return parts.isEmpty ? planTitle.trimmingCharacters(in: .whitespacesAndNewlines) : parts.joined(separator: " • ")
    }

    private var categoryForSelectedActivity: DriftCategory {
        switch selectedActivity {
        case .coffee: return .coffee
        case .walk: return .walk
        case .food: return .food
        case .movie: return .movie
        case .study: return .study
        case .fitness: return .yoga
        case .games: return .gaming
        case .music: return .music
        case .sports: return .event
        case .drinks: return .event
        case .custom: return .event
        }
    }

    private func cleanedText(_ value: String) -> String? {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()

    private static let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter
    }()

    private static let endTimeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter
    }()
}

struct CreateDriftSheet: View {
    @Environment(\.dismiss) private var dismiss
    @FocusState private var focusedField: FocusField?
    @StateObject private var viewModel: CreateDriftViewModel
    @State private var showDiscardConfirmation = false
    @State private var showSuccessState = false

    private let onCreateSucceeded: () -> Void

    init(
        viewModel: CreateDriftViewModel = CreateDriftViewModel(),
        onCreateSucceeded: @escaping () -> Void = {}
    ) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.onCreateSucceeded = onCreateSucceeded
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            Color.backgroundMain.ignoresSafeArea()

            VStack(spacing: 0) {
                sheetHandle

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: AppConstants.Layout.sectionSpacing) {
                        header
                        activitySection
                        planTitleSection
                        dateTimeSection
                        locationCapacitySection
                        joinModeSection
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
        .interactiveDismissDisabled(true)
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
                Text(AppStrings.Create.title)
                    .font(.heading1)
                    .foregroundColor(.textPrimary)

                Text(AppStrings.Create.subtitle)
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
                ForEach(Array(CreateDriftViewModel.ActivityType.allCases.dropLast()), id: \.id) { activity in
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

            if viewModel.selectedActivity == .custom {
                InlineTextFieldRow(
                    title: AppStrings.Create.customActivityTitle,
                    placeholder: AppStrings.Create.customActivityPlaceholder,
                    text: $viewModel.customActivityText,
                    isRequired: true,
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
        HStack(alignment: .top, spacing: AppConstants.Layout.elementSpacing) {
            ApproximateLocationCard(location: viewModel.approximateLocation)
                .frame(maxWidth: .infinity)

            CapacityScrollCard(
                selectedCapacity: viewModel.selectedCapacity,
                onSelect: { option in
                    withAnimation(CoffeeAnimation.spring) {
                        viewModel.setCapacity(option)
                    }
                }
            )
            .frame(maxWidth: .infinity)
        }
    }

    private var joinModeSection: some View {
        VStack(alignment: .leading, spacing: AppConstants.Layout.elementSpacing) {
            requiredSectionTitle(AppStrings.Create.joinModeTitle)

            LazyVGrid(columns: joinModeColumns, spacing: AppConstants.Layout.elementSpacing) {
                ForEach(CreateDriftViewModel.JoinMode.allCases) { mode in
                    JoinModeCard(
                        mode: mode,
                        isSelected: viewModel.selectedJoinMode == mode
                    ) {
                        withAnimation(CoffeeAnimation.spring) {
                            viewModel.setJoinMode(mode)
                        }
                    }
                }
            }
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
                        focusField: .hook,
                        focusedField: $focusedField
                    )

                    VibeMenuRow(selectedVibe: $viewModel.selectedVibe)

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
            if showSuccessState {
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
        if viewModel.isCreating {
            return AppStrings.Create.postingAction
        }

        if showSuccessState {
            return AppStrings.Create.created
        }

        return AppStrings.Create.postAction
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
        Array(repeating: GridItem(.flexible(), spacing: AppConstants.Layout.elementSpacing), count: 5)
    }

    private func closeTapped() {
        if viewModel.hasUnsavedChanges || viewModel.isCreating {
            showDiscardConfirmation = true
            return
        }

        dismiss()
    }

    private func postTapped() {
        guard viewModel.canPost else { return }

        viewModel.create { drift in
            CreatedDriftStore.shared.add(drift)
            showSuccessState = true
            onCreateSucceeded()

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.85) {
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

    private var joinModeColumns: [GridItem] {
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
    let activity: CreateDriftViewModel.ActivityType
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 10) {
                Image(systemName: activity.icon)
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
    let option: CreateDriftViewModel.TimeOption
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

private struct CapacityScrollCard: View {
    let selectedCapacity: CreateDriftViewModel.CapacityOption
    let onSelect: (CreateDriftViewModel.CapacityOption) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: AppConstants.Layout.elementSpacing) {
            HStack(spacing: 4) {
                Text(AppStrings.Create.capacityTitle)
                Text(AppStrings.Create.requiredMarker)
                    .foregroundColor(.brandSecondary)
            }
                .font(.bodyBold)
                .foregroundColor(.textPrimary)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: AppConstants.Layout.subElementSpacing) {
                    ForEach(CreateDriftViewModel.CapacityOption.allCases) { option in
                        Button(action: { onSelect(option) }) {
                            Text(option.title)
                                .font(.bodyBold)
                                .foregroundColor(selectedCapacity == option ? .brandPrimary : .textPrimary)
                                .frame(width: 56, height: AppConstants.Layout.createSheetChipHeight)
                                .background(selectedCapacity == option ? Color.brandPrimary.opacity(0.12) : Color.surfaceMain)
                                .overlay(
                                    RoundedRectangle(cornerRadius: AppConstants.UI.cornerRadiusSmall, style: .continuous)
                                        .stroke(selectedCapacity == option ? Color.brandPrimary.opacity(0.35) : Color.appBorder, lineWidth: 1)
                                )
                                .clipShape(RoundedRectangle(cornerRadius: AppConstants.UI.cornerRadiusSmall, style: .continuous))
                        }
                        .pressScale(0.96)
                    }
                }
            }
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
    @Binding var selectedVibe: CreateDriftViewModel.VibeOption?

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
                ForEach(CreateDriftViewModel.VibeOption.allCases) { vibe in
                    Button(vibe.title) {
                        selectedVibe = vibe
                    }
                }
            } label: {
                HStack(spacing: AppConstants.Layout.subElementSpacing) {
                    Text(selectedVibe?.title ?? AppStrings.Create.vibeSelectionPlaceholder)
                        .font(.bodyStandard)
                        .foregroundColor(selectedVibe == nil ? .textSecondary : .textPrimary)
                        .lineLimit(1)

                    Spacer(minLength: 0)

                    AppIcons.chevronDownImage
                        .font(.captionText)
                        .foregroundColor(.textSecondary)
                }
                .padding(.horizontal, AppConstants.Layout.elementSpacing)
                .padding(.vertical, AppConstants.Layout.subElementSpacing)
                .frame(maxWidth: .infinity, minHeight: 48, alignment: .leading)
                .background(Color.backgroundMain)
                .overlay(
                    RoundedRectangle(cornerRadius: AppConstants.UI.cornerRadiusMedium, style: .continuous)
                        .stroke(Color.appBorder, lineWidth: 1)
                )
                .clipShape(RoundedRectangle(cornerRadius: AppConstants.UI.cornerRadiusMedium, style: .continuous))
            }
        }
    }
}

private struct JoinModeCard: View {
    let mode: CreateDriftViewModel.JoinMode
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(alignment: .center, spacing: AppConstants.Layout.subElementSpacing) {
                ZStack {
                    Circle()
                        .fill(isSelected ? Color.brandPrimary.opacity(0.12) : Color.surfaceSecondary)
                        .frame(width: 40, height: 40)

                    Image(systemName: mode.icon)
                        .font(.captionText)
                        .foregroundColor(isSelected ? .brandPrimary : .textSecondary)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(mode.title)
                        .font(.bodyBold)
                        .foregroundColor(.textPrimary)

                    Text(mode.subtitle)
                        .font(.metadata)
                        .foregroundColor(.textSecondary)
                        .lineLimit(2)
                }

                Spacer(minLength: 0)
            }
            .padding(AppConstants.Layout.elementSpacing)
            .frame(maxWidth: .infinity)
            .frame(minHeight: AppConstants.Layout.createSheetJoinModeHeight)
            .background(isSelected ? Color.brandPrimary.opacity(0.06) : Color.surfaceMain)
            .overlay(
                RoundedRectangle(cornerRadius: AppConstants.UI.cornerRadiusMedium, style: .continuous)
                    .stroke(isSelected ? Color.brandPrimary.opacity(0.35) : Color.appBorder, lineWidth: 1)
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
