import SwiftUI

struct CreateDriftButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 20) {
                // Leading Plus Icon
                Circle()
                    .fill(Color.white)
                    .frame(width: 40, height: 40)
                    .overlay(
                        Image(systemName: AppIcons.plus)
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.brandPrimary)
                    )
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(AppStrings.Discovery.createDrift)
                        .font(.system(size: 20, weight: .black))
                        .foregroundColor(.white)
                    
                    Text(AppStrings.Discovery.createDriftSubtitle)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.white.opacity(0.85))
                }
                
                Spacer()
                
                // Trailing Chevron
                Image(systemName: AppIcons.chevronRight)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white.opacity(0.6))
            }
            .padding(.horizontal, 16)
            .frame(maxWidth: .infinity)
            .frame(height: AppConstants.Layout.createDriftButtonHeight)
            .background(Color.brandPrimary)
            .clipShape(RoundedRectangle(cornerRadius: AppConstants.UI.cornerRadiusLarge, style: .continuous))
            .shadow(color: Color.brandPrimary.opacity(0.15), radius: 10, x: 0, y: 5)
        }
        .pressScale(0.96)
    }
}

struct CreateDriftButton_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.backgroundMain.ignoresSafeArea()
            CreateDriftButton(action: {})
                .padding(24)
        }
    }
}
