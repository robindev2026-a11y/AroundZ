import SwiftUI

struct ReadyScreen: View {
    @EnvironmentObject var auth: AuthViewModel
    
    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            
            Spacer()
            
            // Icon
            ZStack(alignment: .topTrailing) {
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .fill(Color.brandPrimary)
                    .frame(width: 96, height: 96)
                    .overlay(
                        Image(systemName: AppIcons.checkmark)
                            .font(.system(size: 40, weight: .bold))
                            .foregroundColor(.textOnBrand)
                    )
                    .shadow(color: Color.brandPrimary.opacity(0.3), radius: 15, x: 0, y: 8)
                
                Image(systemName: AppIcons.sparkles)
                    .font(.system(size: 24))
                    .foregroundColor(Color.brandSecondary.opacity(0.8))
                    .offset(x: 16, y: -16)
            }
            .padding(.bottom, 32)
            
            Text(AppStrings.Auth.readyTitle)
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundColor(.textPrimary)
                .padding(.bottom, 16)
            
            Text(AppStrings.Auth.readySubtitle)
                .font(.system(size: 16))
                .foregroundColor(.textSecondary)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
                .padding(.horizontal, 32)
                .padding(.bottom, 48)
            
            // Tip Card
            VStack(spacing: 12) {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.brandPrimary.opacity(0.1))
                    .frame(width: 48, height: 48)
                    .overlay(
                        Image(systemName: AppIcons.coffee)
                            .font(.system(size: 20))
                            .foregroundColor(.brandPrimary)
                    )
                    .padding(.bottom, 4)
                
                Text(AppStrings.Auth.tipTitle)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.textPrimary)
                
                Text(AppStrings.Auth.tipDesc)
                    .font(.system(size: 13))
                    .foregroundColor(.textSecondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
            }
            .padding(32)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(Color.textOnBrand)
                    .shadow(color: Color.black.opacity(0.04), radius: 20, x: 0, y: 10)
            )
            .padding(.horizontal, 32)
            
            Spacer()
            
            // CTA
            Button(action: {
                auth.completeOnboarding()
            }) {
                HStack {
                    Text(AppStrings.Auth.readyCTA)
                    Image(systemName: AppIcons.arrowRight)
                }
                .font(.buttonText)
                .foregroundColor(.textOnBrand)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color.brandPrimary)
                .clipShape(Capsule())
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
        .background(Color.textSecondary.opacity(0.02).edgesIgnoringSafeArea(.all)) // Very slight off-white
        .navigationBarHidden(true)
    }
}

struct ReadyScreen_Previews: PreviewProvider {
    static var previews: some View {
        ReadyScreen()
            .environmentObject(AuthViewModel())
    }
}
