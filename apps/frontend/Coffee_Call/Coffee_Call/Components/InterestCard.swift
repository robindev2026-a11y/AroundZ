import SwiftUI

// MARK: - Interest Card
// Matches the vertical card from the "Around" screen image:
// Icon top, Title center, Count bottom.

struct InterestCard: View {
    let title: String
    let icon: String
    let count: Int
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                // Icon
                Image(systemName: icon)
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(isSelected ? .white : categoryColor)
                
                VStack(spacing: 4) {
                    Text(title)
                        .font(.system(size: 16, weight: .black))
                        .foregroundColor(isSelected ? .white : .textPrimary)
                    
                    Text("\(count) nearby")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(isSelected ? .white.opacity(0.8) : .textSecondary)
                }
            }
            .frame(width: AppConstants.Layout.interestCardWidth, height: AppConstants.Layout.interestCardHeight)
            .background(isSelected ? Color.brandPrimary : Color.surfaceMain)
            .clipShape(RoundedRectangle(cornerRadius: AppConstants.Layout.interestCardRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: AppConstants.Layout.interestCardRadius, style: .continuous)
                    .stroke(isSelected ? Color.clear : Color.appBorder, lineWidth: 1)
            )
            .shadow(
                color: isSelected ? Color.brandPrimary.opacity(0.25) : Color.textPrimary.opacity(0.04),
                radius: 12, x: 0, y: 6
            )
        }
        .pressScale(0.94)
    }
    
    private var categoryColor: Color {
        switch title.lowercased() {
        case "coffee": return .brandPrimary
        case "walk":   return .brandPrimaryDark
        case "movie":  return .brandPurple
        case "food":   return .brandSecondary
        default:       return .brandPrimary
        }
    }
}

struct InterestCard_Previews: PreviewProvider {
    static var previews: some View {
        HStack(spacing: 16) {
            InterestCard(title: "Coffee", icon: "cup.and.saucer", count: 3, isSelected: true, action: {})
            InterestCard(title: "Walk", icon: "figure.walk", count: 4, isSelected: false, action: {})
        }
        .padding()
        .background(Color.backgroundMain)
    }
}
