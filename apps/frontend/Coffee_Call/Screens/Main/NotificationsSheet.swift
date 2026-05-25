import SwiftUI

struct NotificationsSheet: View {
    @EnvironmentObject private var driftStore: GlobalDriftStore
    @Environment(\.dismiss) private var dismiss
    @Binding var navigationPath: [UUID]

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Header
                HStack {
                    Text("Notifications")
                        .font(.heading2)
                        .foregroundColor(.textPrimary)
                    Spacer()
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.textSecondary.opacity(0.8))
                    }
                }
                .padding()
                .padding(.top, 8)

                if driftStore.activeNotifications.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "bell.slash")
                            .font(.system(size: 40))
                            .foregroundColor(.textSecondary.opacity(0.5))
                        Text("No new notifications")
                            .font(.bodyStandard)
                            .foregroundColor(.textSecondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(.bottom, 50)
                } else {
                    ScrollView {
                        VStack(spacing: 12) {
                            ForEach(driftStore.activeNotifications) { notif in
                                Button {
                                    // Navigate to Manage Drift
                                    navigationPath.append(notif.driftId)
                                    dismiss()
                                } label: {
                                    HStack(spacing: 16) {
                                        ZStack {
                                            Circle()
                                                .fill(Color.brandPrimary.opacity(0.15))
                                                .frame(width: 48, height: 48)
                                            Image(systemName: "person.crop.circle.badge.plus")
                                                .font(.system(size: 20))
                                                .foregroundColor(.brandPrimary)
                                        }

                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(notif.title)
                                                .font(.bodyBold)
                                                .foregroundColor(.textPrimary)
                                            Text(notif.message)
                                                .font(.bodySmall)
                                                .foregroundColor(.textSecondary)
                                                .multilineTextAlignment(.leading)
                                        }
                                        Spacer()

                                        if !notif.isRead {
                                            Circle()
                                                .fill(Color.brandPrimary)
                                                .frame(width: 10, height: 10)
                                        }
                                    }
                                    .padding(12)
                                    .background(Color.surfaceMain)
                                    .cornerRadius(12)
                                    .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 2)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top, 4)
                        .padding(.bottom, 24)
                    }
                }
            }
            .background(Color.surfaceSecondary.ignoresSafeArea())
        }
    }
}
