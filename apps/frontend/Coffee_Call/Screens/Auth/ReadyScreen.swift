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
                        AppIcons.checkmarkImage
                            .font(.system(size: 40, weight: .bold))
                            .foregroundColor(.textOnBrand)
                    )
                    .shadow(color: Color.brandPrimary.opacity(0.28), radius: 20, x: 0, y: 10)
                
                AppIcons.sparklesImage
                    .font(.system(size: 24))
                    .foregroundColor(Color.brandSecondary.opacity(0.8))
                    .offset(x: 16, y: -16)
            }
            .padding(.bottom, 32)
            
            Text(AppStrings.Auth.readyTitle)
                .font(.system(size: 32, weight: .black, design: .default))
                .foregroundColor(.textPrimary)
                .padding(.bottom, 16)
            
            Text(AppStrings.Auth.readySubtitle)
                .font(.system(size: 16, weight: .medium, design: .default))
                .foregroundColor(.textSecondary)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
                .padding(.horizontal, 32)
                .padding(.bottom, 48)
            
            // Tip Card
            VStack(spacing: 12) {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.brandPrimary.opacity(0.12))
                    .frame(width: 48, height: 48)
                    .overlay(
                        AppIcons.coffeeImage
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
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(Color.surfaceMain)
                    .overlay(
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .stroke(Color.appBorder, lineWidth: 1)
                    )
                    .shadow(color: Color.textPrimary.opacity(0.05), radius: 20, x: 0, y: 10)
            )
            .padding(.horizontal, 32)
            
            Spacer()
            
            PrimaryButton(title: AppStrings.Auth.readyCTA, height: 64, cornerRadius: 16, icon: AppIcons.arrowRight) {
                auth.completeOnboarding()
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
        .background(Color.backgroundMain.edgesIgnoringSafeArea(.all))
        .navigationBarHidden(true)
    }
}

struct ReadyScreen_Previews: PreviewProvider {
    static var previews: some View {
        ReadyScreen()
            .environmentObject(AuthViewModel())
    }
}
