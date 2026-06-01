import SwiftUI
import FirebaseAuth

struct DriftCard: View {
    let drift: Drift
    let isFeatured: Bool
    let onJoin: () -> Void

    private var isJoined: Bool {
        if Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist") != nil {
            guard let currentUid = Auth.auth().currentUser?.uid else { return false }
            return drift.participantIds?.contains(currentUid) == true
        }

        let userInitStr = (UserDefaults.standard.string(forKey: "profile_initials") ?? AppConstants.MockData.userInitials)
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .uppercased()
        guard !userInitStr.isEmpty else { return false }

        return drift.participantInitials.contains {
            $0.trimmingCharacters(in: .whitespacesAndNewlines).uppercased() == userInitStr
        }
    }

    private var buttonText: String {
        if drift.isMine {
            return "Hosting"
        } else if isJoined {
            return "Joined"
        } else {
            return AppStrings.Drifts.imIn
        }
    }

    private var buttonColor: Color {
        if drift.isMine {
            return .brandPurple
        } else if isJoined {
            return .brandSecondary
        } else {
            return .brandPrimary
        }
    }

    var body: some View {
        VStack(spacing: AppConstants.Layout.elementSpacing) {
            HStack(alignment: .top, spacing: AppConstants.Layout.elementSpacing) {
                // Activity Icon Well (Reduced)
                ZStack {
                    Circle()
                        .fill(drift.category.color.opacity(AppConstants.UI.opacityLight * 1.5))
                        .frame(width: 48, height: 48)
                    
                    Image(systemName: drift.category.icon)
                        .font(.system(size: AppConstants.Typography.sizeHeadline, weight: .semibold))
                        .foregroundColor(drift.category.color)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        if isFeatured {
                            Text(AppStrings.Drifts.bestMatch)
                                .font(.system(size: AppConstants.Typography.sizeMicro, weight: .black))
                                .foregroundColor(.brandPurple)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 3)
                                .background(Color.brandPurple.opacity(AppConstants.UI.opacityLight))
                                .cornerRadius(AppConstants.UI.cornerRadiusTiny)
                        }
                        
                        Spacer()
                        
                        Text(drift.status.rawValue)
                            .font(.system(size: AppConstants.Typography.sizeMicro, weight: .black))
                            .foregroundColor(drift.status.color)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 3)
                            .background(drift.status.color.opacity(AppConstants.UI.opacityLight))
                            .cornerRadius(AppConstants.UI.cornerRadiusTiny)
                    }
                    
                    Text(drift.title)
                        .font(.system(size: AppConstants.Typography.sizeTitle, weight: .black))
                        .foregroundColor(.textPrimary)
                        .lineLimit(1)
                    
                    Text(drift.location)
                        .font(.system(size: AppConstants.Typography.sizeCaption, weight: .medium))
                        .foregroundColor(.textSecondary)
                        .lineLimit(1)
                    
                    Text("\(drift.time)  •  \(String(format: "%.1f", drift.distance)) km")
                        .font(.system(size: AppConstants.Typography.sizeCaption, weight: .bold))
                        .foregroundColor(.textSecondary)
                }
            }
            
            // Hook / Offer
            if let hook = drift.hook, !hook.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                HStack(spacing: 8) {
                    AppIcons.giftImage
                        .font(.system(size: AppConstants.Typography.sizeHeadline))
                        .foregroundColor(.brandSecondary)
                    
                    Text(hook)
                        .font(.system(size: AppConstants.Typography.sizeCaption, weight: .semibold))
                        .foregroundColor(.textPrimary)
                        .lineLimit(1)
                    
                    Spacer()
                    
                    if drift.category == .coffee {
                        AppIcons.coffeeFillImage
                            .font(.system(size: AppConstants.Typography.sizeHeadline + 2))
                            .foregroundColor(.brandSecondary.opacity(0.4))
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(Color.brandSecondary.opacity(AppConstants.UI.opacitySubtle))
                .cornerRadius(AppConstants.UI.cornerRadiusSmall)
            }
            
            // Footer Section
            HStack(spacing: 0) {
                // Participants (Reduced size)
                HStack(spacing: -8) {
                    ForEach(Array(drift.participantInitials.prefix(3).enumerated()), id: \.offset) { index, initial in
                        Text(initial)
                            .font(.system(size: AppConstants.Typography.sizeMicro, weight: .black))
                            .foregroundColor(.white)
                            .frame(width: 28, height: 28)
                            .background(Circle().fill(Color.brandPrimary))
                            .overlay(Circle().stroke(Color.white, lineWidth: 1.5))
                    }
                }
                
                // Metadata (Fixed wrapping)
                HStack(spacing: 4) {
                    Text("\(drift.peopleGoing)\(String(AppStrings.Drifts.going.prefix(1)))") // e.g. "3g"
                        .font(.system(size: AppConstants.Typography.sizeCaption, weight: .bold))
                    
                    if let spots = drift.spotsLeft {
                        Text("•")
                        Text("\(spots)\(String(AppStrings.Drifts.spotsLeft.prefix(1)))")
                            .foregroundColor(.brandSecondary)
                    }
                    
                    if let vibe = drift.vibeTags.first {
                        Text("•")
                        Text(vibe)
                    }
                }
                .font(.system(size: AppConstants.Typography.sizeCaption, weight: .bold))
                .foregroundColor(.textSecondary)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
                .padding(.leading, 8)
                
                Spacer()
                
                // Join Button
                Button(action: onJoin) {
                    Text(buttonText)
                        .font(.system(size: AppConstants.Typography.sizeCaption, weight: .black))
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(buttonColor)
                        .clipShape(Capsule())
                }
                .pressScale(0.9)
            }
        }
        .padding(AppConstants.Layout.elementSpacing)
        .background(Color.surfaceMain)
        .cornerRadius(AppConstants.UI.cornerRadiusMedium)
        .shadow(color: Color.textPrimary.opacity(0.06), radius: 10, x: 0, y: 5)
    }
}
