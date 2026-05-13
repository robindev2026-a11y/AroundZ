import SwiftUI

struct LocationPermissionScreen: View {
    var body: some View {
        VStack(alignment: .center, spacing: 24) {
            Spacer()
            
            Circle()
                .fill(Color.textOnBrand)
                .frame(width: 80, height: 80)
                .overlay(
                    Image(systemName: AppIcons.location)
                        .foregroundColor(.brandPrimary)
                        .font(.system(size: 32))
                )
                .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
            
            Text(AppStrings.Auth.locationTitle)
                .font(.heading1)
                .foregroundColor(.textPrimary)
                .multilineTextAlignment(.center)
            
            Text(AppStrings.Auth.locationRadiusDesc)
                .font(.bodyStandard)
                .foregroundColor(.textSecondary)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
                .padding(.horizontal, 16)
            
            Spacer()
            
            VStack(spacing: 16) {
                PrimaryButton(title: AppStrings.Auth.locationSimpleCTA) {
                    print("Requesting Location Permissions")
                }
                
                Button(action: {
                    print("Skipping Location")
                }) {
                    Text(AppStrings.Auth.locationSkip)
                        .font(.buttonText)
                        .foregroundColor(.textSecondary)
                }
                .padding(.vertical, 8)
            }
            .padding(.bottom, 40)
        }
        .padding(.horizontal, 24)
        .background(Color.surfaceMain.edgesIgnoringSafeArea(.all))
        .navigationBarHidden(true)
    }
}

struct LocationPermissionScreen_Previews: PreviewProvider {
    static var previews: some View {
        LocationPermissionScreen()
    }
}
