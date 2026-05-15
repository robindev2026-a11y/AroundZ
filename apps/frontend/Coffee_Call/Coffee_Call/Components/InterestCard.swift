import SwiftUI

struct InterestCard: View {
    let title: String
    let icon: String
    let count: Int
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                // Reduced icon well
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .light))
                    .foregroundColor(isSelected ? .white : accentColor)
                    .frame(width: 38, height: 38)
                
                VStack(spacing: 1) {
                    Text(title)
                        .font(.system(size: AppConstants.Typography.sizeCaption, weight: .black))
                        .foregroundColor(isSelected ? .white : .textPrimary)
                    
                    Text("\(count) nearby")
                        .font(.system(size: AppConstants.Typography.sizeMicro, weight: .bold))
                        .foregroundColor(isSelected ? .white.opacity(0.8) : .textSecondary.opacity(0.6))
                }
            }
            .frame(width: AppConstants.Layout.interestCardWidth, height: AppConstants.Layout.interestCardHeight)
            .background(isSelected ? Color.brandPrimary : Color.surfaceMain)
            .clipShape(RoundedRectangle(cornerRadius: AppConstants.Layout.interestCardRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: AppConstants.Layout.interestCardRadius, style: .continuous)
                    .stroke(isSelected ? Color.clear : Color.appBorder.opacity(0.5), lineWidth: 1)
            )
        }
        .pressScale(0.95)
    }
    
    private var accentColor: Color {
        switch title.lowercased() {
        case "coffee", "walks": return .brandPrimary
        case "movies", "music": return .brandPurple
        case "food": return .brandSecondary
        default: return .brandPrimary
        }
    }
}
