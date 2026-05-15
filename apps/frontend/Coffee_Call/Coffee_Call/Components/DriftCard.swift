import SwiftUI

struct DriftCard: View {
    let drift: Drift
    let isFeatured: Bool
    let onJoin: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            HStack(alignment: .top, spacing: 16) {
                // Activity Icon
                ZStack {
                    Circle()
                        .fill(drift.category.color.opacity(AppConstants.UI.opacityLight * 1.5))
                        .frame(width: 56, height: 56)
                    
                    Image(systemName: drift.category.icon)
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundColor(drift.category.color)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        if isFeatured {
                            Text(AppStrings.Drifts.bestMatch)
                                .font(.system(size: 10, weight: .black))
                                .foregroundColor(.brandPurple)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.brandPurple.opacity(AppConstants.UI.opacityLight))
                                .cornerRadius(6)
                        }
                        
                        Spacer()
                        
                        Text(drift.status.rawValue)
                            .font(.system(size: 10, weight: .black))
                            .foregroundColor(drift.status.color)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(drift.status.color.opacity(AppConstants.UI.opacityLight))
                            .cornerRadius(6)
                    }
                    
                    Text(drift.title)
                        .font(.system(size: 20, weight: .black))
                        .foregroundColor(.textPrimary)
                    
                    Text(drift.location)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.textSecondary)
                    
                    Text("\(drift.time)  •  \(String(format: "%.1f", drift.distance)) km")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.textSecondary)
                }
            }
            
            // Hook / Offer
            if let hook = drift.hook {
                HStack(spacing: 12) {
                    Image(systemName: AppIcons.gift)
                        .font(.system(size: 20))
                        .foregroundColor(.brandSecondary)
                    
                    Text(hook)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.textPrimary)
                    
                    Spacer()
                    
                    if drift.category == .coffee {
                        Image(systemName: AppIcons.coffeeFill)
                            .font(.system(size: 24))
                            .foregroundColor(.brandSecondary.opacity(0.4))
                    }
                }
                .padding(16)
                .background(Color.brandSecondary.opacity(AppConstants.UI.opacitySubtle))
                .cornerRadius(AppConstants.UI.cornerRadiusMedium)
                .overlay(
                    RoundedRectangle(cornerRadius: AppConstants.UI.cornerRadiusMedium)
                        .stroke(Color.brandSecondary.opacity(AppConstants.UI.opacityLight), lineWidth: 1)
                )
            }
            
            HStack {
                // Participants
                HStack(spacing: -12) {
                    ForEach(0..<min(drift.participantInitials.count, 3), id: \.self) { index in
                        Text(drift.participantInitials[index])
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: 32, height: 32)
                            .background(Circle().fill(Color.brandPrimary))
                            .overlay(Circle().stroke(Color.white, lineWidth: 2))
                    }
                }
                
                HStack(spacing: 4) {
                    Text("\(drift.peopleGoing) \(AppStrings.Drifts.going)")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.textSecondary)
                    
                    if let spots = drift.spotsLeft {
                        Text("•")
                            .foregroundColor(.textSecondary)
                        Text("\(spots) \(AppStrings.Drifts.spotsLeft)")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(.brandSecondary)
                    }
                    
                    if let vibe = drift.vibeTags.first {
                        Text("•")
                            .foregroundColor(.textSecondary)
                        Text(vibe)
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(.textSecondary)
                    }
                }
                .padding(.leading, 8)
                
                Spacer()
                
                Button(action: onJoin) {
                    Text(AppStrings.Drifts.imIn)
                        .font(.system(size: 14, weight: .black))
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(Color.brandPrimary)
                        .clipShape(Capsule())
                }
                .pressScale(0.9)
            }
        }
        .padding(20)
        .background(Color.surfaceMain)
        .cornerRadius(AppConstants.UI.cornerRadiusLarge)
        .shadow(color: Color.black.opacity(AppConstants.UI.opacitySubtle), radius: AppConstants.UI.shadowRadius, x: 0, y: AppConstants.UI.shadowY)
    }
}
