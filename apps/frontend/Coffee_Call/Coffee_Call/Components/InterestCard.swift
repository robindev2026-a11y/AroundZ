import SwiftUI

struct InterestCard: View {
    let title: String
    let icon: String
    let count: Int
    let color: Color
    
    var body: some View {
        VStack(spacing: AppConstants.Layout.subElementSpacing + 2) {
            
            // Reusable Icon Circle
            IconCircle(
                icon: icon,
                size: AppConstants.Layout.sheetHandleWidth, // 44pt
                color: color,
                iconSize: 22
            )
            
            VStack(spacing: 1) {
                Text(title)
                    .font(.system(size: AppConstants.Typography.sizeCaption - 1, weight: .bold))
                    .foregroundColor(.textPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                
                Text("\(count) \(AppStrings.Discovery.nearby)")
                    .font(.system(size: AppConstants.Typography.sizeMicro, weight: .bold))
                    .foregroundColor(.textSecondary.opacity(0.7))
            }
        }
        .frame(
            width: AppConstants.Layout.interestCardWidth,
            height: AppConstants.Layout.interestCardHeight
        )
        .background(Color.surfaceMain)
        .clipShape(RoundedRectangle(cornerRadius: AppConstants.Layout.interestCardRadius, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: AppConstants.Layout.interestCardRadius, style: .continuous)
                .stroke(Color.appBorder.opacity(0.3), lineWidth: 0.5)
        )
        .shadow(color: Color.black.opacity(0.03), radius: 5, x: 0, y: 2)
    }
}
