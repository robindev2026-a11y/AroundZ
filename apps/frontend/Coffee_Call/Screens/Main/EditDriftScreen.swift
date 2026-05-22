// EditDriftScreen.swift
// Screen for editing a Drift's details
// Implements navigation push from ManageDriftScreen

import SwiftUI

struct EditDriftScreen: View {
    @ObservedObject var viewModel: ManageDriftViewModel
    @Environment(\.dismiss) private var dismiss
    
    // Editable fields bound to local state
    @State private var title: String = ""
    @State private var description: String = ""
    @State private var location: String = ""
    @State private var meetingPoint: String = ""
    @State private var date: String = ""
    @State private var time: String = ""
    @State private var endTime: String = ""
    @State private var capacity: String = ""
    
    var body: some View {
        VStack(spacing: AppConstants.Layout.standardPadding) {
            // Header
            HStack {
                Text(AppStrings.Manage.edit)
                    .font(.system(size: AppConstants.Typography.sizeDisplay, weight: .black))
                    .foregroundColor(.textPrimary)
                Spacer()
            }
            .padding(.top, 20)
            
            // Form fields
            Form {
                Section(header: Text(AppStrings.Manage.EditFields.title)) {
                    TextField(AppStrings.Manage.EditFields.title, text: $title)
                        .disabled(!viewModel.canEdit)
                }
                Section(header: Text(AppStrings.Manage.EditFields.description)) {
                    TextField(AppStrings.Manage.EditFields.description, text: $description)
                        .disabled(!viewModel.canEdit)
                }
                Section(header: Text(AppStrings.Manage.EditFields.location)) {
                    TextField(AppStrings.Manage.EditFields.location, text: $location)
                        .disabled(!viewModel.canEdit)
                }
                Section(header: Text(AppStrings.Manage.EditFields.meetingPoint)) {
                    TextField(AppStrings.Manage.EditFields.meetingPoint, text: $meetingPoint)
                        .disabled(!viewModel.canEdit)
                }
                Section(header: Text(AppStrings.Manage.EditFields.date)) {
                    TextField(AppStrings.Manage.EditFields.date, text: $date)
                        .disabled(!viewModel.canEdit)
                }
                Section(header: Text(AppStrings.Manage.EditFields.time)) {
                    TextField(AppStrings.Manage.EditFields.time, text: $time)
                        .disabled(!viewModel.canEdit)
                }
                Section(header: Text(AppStrings.Manage.EditFields.endTime)) {
                    TextField(AppStrings.Manage.EditFields.endTime, text: $endTime)
                        .disabled(!viewModel.canEdit)
                }
                Section(header: Text(AppStrings.Manage.EditFields.capacity)) {
                    TextField(AppStrings.Manage.EditFields.capacity, text: $capacity)
                        .keyboardType(.numberPad)
                        .disabled(!viewModel.canEdit)
                }
            }
            .background(Color.surfaceMain)
            .cornerRadius(AppConstants.UI.cornerRadiusMedium)
            
            // Action buttons
            HStack(spacing: AppConstants.Layout.elementSpacing) {
                Button(action: { dismiss() }) {
                    Text(AppStrings.Common.cancel)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.surfaceSecondary)
                        .foregroundColor(.textPrimary)
                        .cornerRadius(AppConstants.UI.cornerRadiusSmall)
                }
                Button(action: saveChanges) {
                    Text(AppStrings.Common.save)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(viewModel.canEdit ? Color.brandPrimary : Color.brandPrimary.opacity(0.5))
                        .foregroundColor(.white)
                        .cornerRadius(AppConstants.UI.cornerRadiusSmall)
                }
                .disabled(!viewModel.canEdit)
            }
            .padding(.horizontal, AppConstants.Layout.standardPadding)
        }
        .padding(.horizontal, AppConstants.Layout.standardPadding)
        .asCoffeePage(.sub, title: "")
        .onAppear(perform: populateFields)
        .navigationBarHidden(true)
    }
    
    private func populateFields() {
        let drift = viewModel.drift
        title = drift.title
        description = drift.description
        location = drift.location
        meetingPoint = drift.meetingPoint
        date = drift.date
        time = drift.time
        endTime = drift.endTime
        capacity = String(drift.capacity)
    }
    
    private func saveChanges() {
        guard viewModel.canEdit else { return }
        // Construct a new Drift instance with updated mutable fields
        let capacityValue = Int(capacity) ?? viewModel.drift.capacity
        let updated = Drift(
            id: viewModel.drift.id,
            title: title,
            description: description,
            location: location,
            meetingPoint: meetingPoint,
            time: time,
            endTime: endTime,
            date: date,
            distance: viewModel.drift.distance,
            status: viewModel.drift.status,
            category: viewModel.drift.category,
            hook: viewModel.drift.hook,
            host: viewModel.drift.host,
            peopleGoing: viewModel.drift.peopleGoing,
            spotsLeft: viewModel.drift.spotsLeft,
            capacity: capacityValue,
            vibeTags: viewModel.drift.vibeTags,
            whatToBring: viewModel.drift.whatToBring,
            notes: viewModel.drift.notes,
            participantInitials: viewModel.drift.participantInitials,
            imageUrl: viewModel.drift.imageUrl,
            pendingRequests: viewModel.drift.pendingRequests,
            isMine: viewModel.drift.isMine,
            lastMessage: viewModel.drift.lastMessage,
            lastMessageTime: viewModel.drift.lastMessageTime,
            unreadCount: viewModel.drift.unreadCount,
            latitude: viewModel.drift.latitude,
            longitude: viewModel.drift.longitude
        )
        viewModel.editDrift(updated: updated)
        dismiss()
    }
}

// MARK: - Preview
struct EditDriftScreen_Previews: PreviewProvider {
    static var previews: some View {
        let sampleDrift = Drift(
            title: "Coffee Drift",
            description: "Spontaneous coffee meetup.",
            location: "Panampilly Nagar, Kochi",
            meetingPoint: "Near Main Entrance",
            time: "6:30 PM",
            endTime: "7:30 PM",
            date: "Today",
            distance: 1.2,
            status: .open,
            category: .coffee,
            hook: nil,
            host: Host(name: "Arjun", role: "Hosting", imageUrl: "host_arjun", isVerified: true),
            peopleGoing: 3,
            spotsLeft: 2,
            capacity: 5,
            vibeTags: ["Casual"],
            whatToBring: ["Good mood"],
            notes: "Just chat.",
            participantInitials: [],
            imageUrl: "drift_coffee",
            isMine: true
        )
        EditDriftScreen(viewModel: ManageDriftViewModel(drift: sampleDrift))
    }
}
