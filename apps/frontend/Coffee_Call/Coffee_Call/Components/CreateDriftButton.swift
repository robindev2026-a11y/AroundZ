import SwiftUI

struct CreateDriftButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                // Compact Plus Icon
                Circle()
                    .fill(Color.white.opacity(0.15))
                    .frame(width: 32, height: 32)
                    .overlay(
                        Image(systemName: AppIcons.plus)
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                    )
                
                VStack(alignment: .leading, spacing: 1) {
                    Text(AppStrings.Discovery.createDrift)
                        .font(.system(size: 17, weight: .black))
                        .foregroundColor(.white)
                    
                    Text(AppStrings.Discovery.createDriftSubtitle)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.white.opacity(0.8))
                }
                
                Spacer()
                
                Image(systemName: AppIcons.arrowRight)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white.opacity(0.6))
            }
            .padding(.horizontal, 20)
            .frame(maxWidth: .infinity)
            .frame(height: AppConstants.Layout.createDriftButtonHeight)
            .background(Color.brandPrimary)
            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
            .shadow(color: Color.brandPrimary.opacity(0.12), radius: 10, x: 0, y: 5)
        }
        .pressScale(0.97)
    }
}
