import SwiftUI

struct CreateDriftSheet: View {
    enum Mode { case create, edit }

    private let mode: Mode
    private let existingDrift: Drift?
    private let onSave: (Drift) -> Void
    private let onCreateSucceeded: () -> Void

    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var driftStore: GlobalDriftStore
    @StateObject private var viewModel: CreateDriftViewModel
    @State private var showDiscardConfirmation = false
    @State private var showingMapPicker = false
    @State private var activeWhenPicker: WhenPickerKind?
    @State private var selectedDateAction = "Today"
    @State private var selectedTimeAction = "In 30 mins"

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

        if mode == .edit, let drift {
            _viewModel = StateObject(wrappedValue: viewModel ?? CreateDriftViewModel(editing: drift))
        } else {
            _viewModel = StateObject(wrappedValue: viewModel ?? CreateDriftViewModel())
        }
    }

    var body: some View {
        GeometryReader { proxy in
            let isTablet = proxy.size.width >= 700
            ZStack {
                Color(red: 0.96, green: 0.94, blue: 0.90).ignoresSafeArea()

                if isTablet {
                    tabletLayout
                        .frame(maxWidth: 980, maxHeight: 720)
                        .padding(28)
                } else {
                    phoneLayout
                }
            }
        }
        .sheet(isPresented: $showingMapPicker) {
            MapPickerSheet { address, lat, lng in
                viewModel.approximateLocation = address
                viewModel.selectedLatitude = lat
                viewModel.selectedLongitude = lng
            }
        }
        .sheet(item: $activeWhenPicker) { picker in
            WhenPickerSheet(date: $viewModel.scheduledDate, kind: picker)
                .presentationDetents([.medium])
        }
        .alert("Discard changes?", isPresented: $showDiscardConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Discard", role: .destructive) { dismiss() }
        } message: {
            Text("Your current Drift plan details will be lost.")
        }
    }

    private var phoneLayout: some View {
        VStack(spacing: 0) {
            phoneHeader

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 18) {
                    activitySection
                    planSection
                    vibeSection
                    whenSection
                    locationSection
                    gatheringSection
                    notesSection
                    Spacer(minLength: 92)
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)
            }
        }
        .safeAreaInset(edge: .bottom) {
            footer
        }
    }

    private var tabletLayout: some View {
        VStack(spacing: 0) {
            tabletHeader

            HStack(alignment: .top, spacing: 20) {
                VStack(spacing: 0) {
                    activitySection
                    Divider().padding(.vertical, 16)
                    planSection
                    Divider().padding(.vertical, 16)
                    vibeSection
                    Divider().padding(.vertical, 16)
                    whenSection
                }
                .frame(maxWidth: .infinity, alignment: .topLeading)

                VStack(spacing: 14) {
                    locationSection
                    gatheringSection
                    notesSection
                }
                .frame(width: 360, alignment: .top)
            }
            .padding(.horizontal, 24)
            .padding(.top, 10)

            Spacer(minLength: 14)
            footer
        }
        .background(Color.white.opacity(0.92))
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 22, style: .continuous).stroke(Color.appBorder, lineWidth: 1))
        .shadow(color: Color.black.opacity(0.14), radius: 28, y: 18)
    }

    private var phoneHeader: some View {
        VStack(spacing: 10) {
            Capsule()
                .fill(Color.appBorder)
                .frame(width: 42, height: 4)
                .padding(.top, 8)

            HStack {
                Button(action: closeTapped) {
                    Image(systemName: AppIcons.chevronDown)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.textPrimary)
                        .frame(width: 40, height: 40)
                }

                Spacer()

                VStack(spacing: 4) {
                    Text("NEW DRIFT")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.brandPrimaryDark)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.brandPrimary.opacity(0.12), in: Capsule())

                    Text(mode == .edit ? "Edit Moment" : "Host a Moment")
                        .font(.system(size: 22, weight: .black))
                        .foregroundColor(.textPrimary)

                    Text("Create a plan. Invite people. Make it happen.")
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(.textSecondary)
                }

                Spacer()

                Button(action: closeTapped) {
                    Image(systemName: AppIcons.close)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.textPrimary)
                        .frame(width: 40, height: 40)
                }
            }
            .padding(.horizontal, 12)
        }
        .padding(.bottom, 12)
        .background(.ultraThinMaterial)
        .overlay(alignment: .bottom) { Divider().opacity(0.8) }
    }

    private var tabletHeader: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 7) {
                Text("NEW DRIFT")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.brandPrimaryDark)
                    .padding(.horizontal, 9)
                    .padding(.vertical, 4)
                    .background(Color.brandPrimary.opacity(0.14), in: Capsule())

                Text(mode == .edit ? "Edit Moment" : "Host a Moment")
                    .font(.system(size: 26, weight: .black))
                    .foregroundColor(.textPrimary)

                Text("Create meaningful moments with people around you.")
                    .font(.system(size: 13))
                    .foregroundColor(.textSecondary)
            }

            Spacer()

            Button(action: closeTapped) {
                Image(systemName: AppIcons.close)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.textPrimary)
                    .frame(width: 42, height: 42)
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 24)
        .padding(.bottom, 4)
    }

    private var activitySection: some View {
        numberedSection("1. What are we doing?") {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(activityOptions, id: \.self) { activity in
                        activityTile(activity)
                    }
                }
                .padding(.vertical, 2)
            }
        }
    }

    private var planSection: some View {
        numberedSection("2. The plan") {
            VStack(alignment: .leading, spacing: 12) {
                labeledField(
                    title: "Drift title",
                    placeholder: "e.g. Coffee & conversations",
                    text: $viewModel.planTitle,
                    limit: viewModel.maxTitleCount,
                    height: 54
                )

                labeledField(
                    title: "Hook / Icebreaker",
                    placeholder: "e.g. Bringing my dog, hope that's okay!",
                    text: $viewModel.hookText,
                    limit: 120,
                    height: 58
                )
            }
        }
    }

    private var vibeSection: some View {
        numberedSection("3. Vibe") {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(VibeOption.allCases) { vibe in
                        Button { viewModel.selectedVibe = vibe } label: {
                            Text(vibe.title)
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(viewModel.selectedVibe == vibe ? .brandPrimaryDark : .textPrimary)
                                .padding(.horizontal, 14)
                                .frame(height: 30)
                                .background(viewModel.selectedVibe == vibe ? Color.brandPrimary.opacity(0.10) : Color.white)
                                .clipShape(Capsule())
                                .overlay(Capsule().stroke(viewModel.selectedVibe == vibe ? Color.brandPrimary : Color.appBorder, lineWidth: 1))
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }

    private var whenSection: some View {
        numberedSection("4. When") {
            VStack(alignment: .leading, spacing: 12) {
                Text("Date")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.textSecondary)
                HStack(spacing: 8) {
                    presetChip("Today", selected: selectedDateAction == "Today") {
                        selectedDateAction = "Today"
                        setDate(daysFromToday: 0)
                    }
                    presetChip("Tomorrow", selected: selectedDateAction == "Tomorrow") {
                        selectedDateAction = "Tomorrow"
                        setDate(daysFromToday: 1)
                    }
                    presetChip("Pick date", selected: selectedDateAction == "Pick date") {
                        selectedDateAction = "Pick date"
                        activeWhenPicker = .date
                    }
                }

                Text("Time")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.textSecondary)
                    .padding(.top, 2)
                HStack(spacing: 8) {
                    presetChip("In 30 mins", selected: selectedTimeAction == "In 30 mins") {
                        selectedTimeAction = "In 30 mins"
                        viewModel.scheduledDate = Date().addingTimeInterval(30 * 60)
                    }
                    presetChip("In 1 hour", selected: selectedTimeAction == "In 1 hour") {
                        selectedTimeAction = "In 1 hour"
                        viewModel.scheduledDate = Date().addingTimeInterval(60 * 60)
                    }
                    presetChip("Pick time", selected: selectedTimeAction == "Pick time") {
                        selectedTimeAction = "Pick time"
                        activeWhenPicker = .time
                    }
                }
            }
        }
    }

    private var locationSection: some View {
        numberedSection("5. Where") {
            Button(action: { showingMapPicker = true }) {
                VStack(spacing: 0) {
                    ZStack {
                        MapGrid()
                            .frame(height: 96)
                            .background(Color(red: 0.93, green: 0.92, blue: 0.88))
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

                        Image(systemName: AppIcons.mappinCircle)
                            .font(.system(size: 30, weight: .bold))
                            .foregroundColor(.brandPrimaryDark)
                    }

                    HStack(spacing: 12) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(viewModel.approximateLocation.isEmpty ? "Indiranagar, Bengaluru" : viewModel.approximateLocation)
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(.textPrimary)
                                .lineLimit(1)

                            Text(viewModel.selectedLatitude == nil ? "Near 100 Feet Road" : "Coordinates selected")
                                .font(.system(size: 11))
                                .foregroundColor(.textSecondary)

                            Text("Change area >")
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundColor(.brandPrimaryDark)
                        }

                        Spacer()
                        Image(systemName: AppIcons.chevronRight)
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(.textSecondary)
                    }
                    .padding(12)
                }
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous).stroke(Color.appBorder, lineWidth: 1))
            }
            .buttonStyle(.plain)
        }
    }

    private var gatheringSection: some View {
        numberedSection("6. Gathering") {
            VStack(spacing: 14) {
                HStack {
                    VStack(alignment: .leading, spacing: 3) {
                        Text("Spots")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(.textPrimary)
                        Text("How many can join?")
                            .font(.system(size: 11))
                            .foregroundColor(.textSecondary)
                    }
                    Spacer()
                    Stepper(value: $viewModel.selectedCapacityCount, in: 1...20) {
                        Text("\(viewModel.selectedCapacityCount)")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.textPrimary)
                    }
                    .fixedSize()
                }

                Toggle(isOn: $viewModel.isOpenToAllCapacity) {
                    VStack(alignment: .leading, spacing: 3) {
                        Text("Open to all")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(.textPrimary)
                        Text("Anyone can join without approval")
                            .font(.system(size: 11))
                            .foregroundColor(.textSecondary)
                    }
                }
                .tint(.brandPrimaryDark)

                VStack(alignment: .leading, spacing: 8) {
                    Text("Join mode")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.textSecondary)
                    HStack(spacing: 10) {
                        joinModeButton(.open, title: "Open Join", subtitle: "Instant", icon: AppIcons.participants)
                        joinModeButton(.approval, title: "Approval Required", subtitle: "Manual", icon: AppIcons.privacyShield)
                    }
                }
            }
        }
    }

    private var notesSection: some View {
        numberedSection("7. Notes (Optional)") {
            VStack(alignment: .leading, spacing: 8) {
                ZStack(alignment: .topLeading) {
                    if viewModel.notesText.isEmpty {
                        Text("Add anything else people should know...")
                            .font(.system(size: 12))
                            .foregroundColor(.textSecondary.opacity(0.75))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 13)
                    }

                    TextEditor(text: $viewModel.notesText)
                        .font(.system(size: 13))
                        .scrollContentBackground(.hidden)
                        .frame(minHeight: 64)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                }
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                .overlay(RoundedRectangle(cornerRadius: 10, style: .continuous).stroke(Color.appBorder, lineWidth: 1))

                HStack {
                    suggestionChip("What to bring", icon: "bag")
                    suggestionChip("Parking info", icon: "parkingsign")
                    suggestionChip("Group vibe", icon: "face.smiling")
                }
            }
        }
    }

    private func numberedSection<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.system(size: 13, weight: .black))
                .foregroundColor(.textPrimary)

            content()
        }
        .padding(.vertical, 14)
        .padding(.horizontal, 14)
        .background(Color.white.opacity(0.74))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous).stroke(Color.appBorder.opacity(0.9), lineWidth: 1))
    }

    private func activityTile(_ activity: ActivityType) -> some View {
        let selected = viewModel.selectedActivity == activity
        return Button { viewModel.setActivity(activity) } label: {
            VStack(spacing: 8) {
                Image(systemName: activity.iconName)
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundColor(selected ? activity.tint : activity.tint.opacity(0.9))
                    .frame(height: 22)

                Text(activity.title)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.textPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .frame(width: 62, height: 64)
            .background(selected ? activity.tint.opacity(0.09) : Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 12, style: .continuous).stroke(selected ? activity.tint : Color.appBorder, lineWidth: selected ? 1.4 : 1))
        }
        .buttonStyle(.plain)
    }

    private func labeledField(title: String, placeholder: String, text: Binding<String>, limit: Int, height: CGFloat) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(title)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.textPrimary)
                if title == "Drift title" {
                    Text("*").foregroundColor(.statusError)
                }
                Spacer()
                Text("\(min(text.wrappedValue.count, limit))/\(limit)")
                    .font(.system(size: 11))
                    .foregroundColor(.textSecondary)
            }

            TextField(placeholder, text: Binding(
                get: { text.wrappedValue },
                set: { text.wrappedValue = String($0.prefix(limit)) }
            ))
            .font(.system(size: 13))
            .padding(.horizontal, 12)
            .frame(height: height)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 10, style: .continuous).stroke(Color.appBorder, lineWidth: 1))
        }
    }

    private func presetChip(_ label: String, selected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(label)
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(selected ? .brandPrimaryDark : .textPrimary)
                .padding(.horizontal, 12)
                .frame(height: 32)
                .background(selected ? Color.brandPrimary.opacity(0.10) : Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                .overlay(RoundedRectangle(cornerRadius: 8, style: .continuous).stroke(selected ? Color.brandPrimary : Color.appBorder, lineWidth: 1))
        }
        .buttonStyle(.plain)
    }

    private func joinModeButton(_ mode: JoinMode, title: String, subtitle: String, icon: String) -> some View {
        let selected = viewModel.selectedJoinMode == mode
        return Button { viewModel.setJoinMode(mode) } label: {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(selected ? .brandPrimaryDark : .textSecondary)
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.textPrimary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.75)
                    Text(subtitle)
                        .font(.system(size: 10))
                        .foregroundColor(.textSecondary)
                }
                Spacer(minLength: 0)
            }
            .padding(.horizontal, 10)
            .frame(height: 52)
            .background(selected ? Color.brandPrimary.opacity(0.10) : Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 10, style: .continuous).stroke(selected ? Color.brandPrimary : Color.appBorder, lineWidth: 1))
        }
        .buttonStyle(.plain)
    }

    private func suggestionChip(_ label: String, icon: String) -> some View {
        HStack(spacing: 5) {
            Image(systemName: icon)
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(.brandPrimaryDark)
            Text(label)
                .font(.system(size: 10, weight: .semibold))
                .foregroundColor(.textPrimary)
        }
        .padding(.horizontal, 9)
        .frame(height: 26)
        .background(Color.backgroundMain.opacity(0.55), in: Capsule())
        .overlay(Capsule().stroke(Color.appBorder, lineWidth: 1))
    }

    private var footer: some View {
        VStack(spacing: 8) {
            Button(action: postTapped) {
                HStack(spacing: 8) {
                    if viewModel.isCreating {
                        ProgressView().tint(.white)
                    } else {
                        Image(systemName: AppIcons.plus)
                            .font(.system(size: 15, weight: .bold))
                    }
                    Text(viewModel.isCreating ? "Creating Drift" : "Create Drift")
                        .font(.system(size: 15, weight: .bold))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .background(Color.brandPrimaryDark)
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                .shadow(color: Color.brandPrimaryDark.opacity(0.22), radius: 8, y: 3)
            }
            .disabled(!viewModel.canPost)
            .opacity(viewModel.canPost ? 1 : 0.55)

            HStack(spacing: 5) {
                Image(systemName: AppIcons.lock)
                    .font(.system(size: 10, weight: .bold))
                Text("You can review everything before it goes live.")
                    .font(.system(size: 10))
            }
            .foregroundColor(.textSecondary)
        }
        .padding(.horizontal, 16)
        .padding(.top, 10)
        .padding(.bottom, 8)
        .background(Color.white.opacity(0.92))
        .overlay(alignment: .top) { Divider().opacity(0.6) }
    }

    private var activityOptions: [ActivityType] {
        ActivityType.allCases.filter { $0 != .custom }.prefix(7).map { $0 }
    }

    private func closeTapped() {
        if viewModel.hasUnsavedChanges {
            showDiscardConfirmation = true
        } else {
            dismiss()
        }
    }

    private func postTapped() {
        switch mode {
        case .create:
            viewModel.create { drift in
                driftStore.addOrUpdate(drift)
                onCreateSucceeded()
                dismiss()
            }
        case .edit:
            guard let existingDrift else { return }
            viewModel.update(original: existingDrift) { drift in
                onSave(drift)
                driftStore.addOrUpdate(drift)
                dismiss()
            }
        }
    }

    private func setDate(daysFromToday days: Int) {
        let calendar = Calendar.current
        let currentTime = calendar.dateComponents([.hour, .minute], from: viewModel.scheduledDate)
        var base = calendar.date(byAdding: .day, value: days, to: Date()) ?? Date()
        base = calendar.startOfDay(for: base)
        viewModel.scheduledDate = calendar.date(bySettingHour: currentTime.hour ?? 9, minute: currentTime.minute ?? 0, second: 0, of: base) ?? base
    }

}

private enum WhenPickerKind: String, Identifiable {
    case date
    case time

    var id: String { rawValue }
}

private struct WhenPickerSheet: View {
    @Binding var date: Date
    let kind: WhenPickerKind
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 14) {
            HStack {
                Text(kind == .date ? "Select date" : "Select time")
                    .font(.system(size: 17, weight: .bold))
                    .foregroundColor(.textPrimary)
                Spacer()
                Button("Done") { dismiss() }
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.brandPrimaryDark)
            }
            .padding(.horizontal, 20)
            .padding(.top, 18)

            if kind == .date {
                DatePicker("", selection: $date, in: Date()..., displayedComponents: .date)
                    .datePickerStyle(.graphical)
                    .labelsHidden()
                    .tint(.brandPrimaryDark)
                    .padding(.horizontal, 16)
            } else {
                DatePicker("", selection: $date, displayedComponents: .hourAndMinute)
                    .datePickerStyle(.wheel)
                    .labelsHidden()
                    .tint(.brandPrimaryDark)
            }

            Spacer(minLength: 0)
        }
        .background(Color.backgroundMain.ignoresSafeArea())
    }
}

private struct MapGrid: View {
    var body: some View {
        Canvas { context, size in
            let lineColor = Color.brandPrimary.opacity(0.12)
            for x in stride(from: 0, through: size.width, by: 22) {
                var path = Path()
                path.move(to: CGPoint(x: x, y: 0))
                path.addLine(to: CGPoint(x: x, y: size.height))
                context.stroke(path, with: .color(lineColor), lineWidth: 1)
            }
            for y in stride(from: 0, through: size.height, by: 22) {
                var path = Path()
                path.move(to: CGPoint(x: 0, y: y))
                path.addLine(to: CGPoint(x: size.width, y: y))
                context.stroke(path, with: .color(lineColor), lineWidth: 1)
            }
            let center = CGPoint(x: size.width / 2, y: size.height / 2)
            for radius in [22.0, 42.0, 62.0] {
                let rect = CGRect(x: center.x - radius, y: center.y - radius, width: radius * 2, height: radius * 2)
                context.stroke(Path(ellipseIn: rect), with: .color(Color.brandPrimary.opacity(0.20)), lineWidth: 1)
            }
        }
    }
}
