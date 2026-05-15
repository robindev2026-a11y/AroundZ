import SwiftUI

struct CreateDriftButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 20) {
                // Leading Plus Icon
                Circle()
                    .fill(Color.white)
                    .frame(width: 48, height: 48)
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
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white.opacity(0.9))
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
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [.brandPrimary, .brandPrimaryDark]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .clipShape(Capsule())
            .shadow(color: Color.brandPrimary.opacity(0.35), radius: 20, x: 0, y: 10)
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
