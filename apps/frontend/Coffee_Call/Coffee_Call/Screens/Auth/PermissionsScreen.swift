import SwiftUI

struct PermissionsScreen: View {
    @State private var locationRequested = false
    @State private var notificationsRequested = false
    @State private var navigateToReady = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            
            Text(AppStrings.Auth.permissionsTitle)
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(.textPrimary)
                .padding(.top, 40)
                .padding(.bottom, 12)
            
            Text(AppStrings.Auth.permissionsSubtitle)
                .font(.system(size: 16))
                .foregroundColor(.textSecondary)
                .lineSpacing(4)
                .padding(.bottom, 40)
            
            // Location Card
            VStack(alignment: .leading, spacing: 16) {
                HStack(alignment: .top, spacing: 16) {
                    Circle()
                        .fill(Color.brandPrimary.opacity(0.1))
                        .frame(width: 40, height: 40)
                        .overlay(
                            Image(systemName: AppIcons.location)
                                .foregroundColor(.brandPrimary)
                        )
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(AppStrings.Auth.locationTitle)
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.textPrimary)
                        
                        Text(AppStrings.Auth.locationDesc)
                            .font(.system(size: 13))
                            .foregroundColor(.textSecondary)
                            .lineSpacing(2)
                    }
                }
                
                Button(action: {
                    // MVP: Just simulate permission request
                    locationRequested = true
                }) {
                    Text(locationRequested ? AppStrings.Auth.locationGranted : AppStrings.Auth.locationCTA)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.textOnBrand)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(locationRequested ? Color.statusSuccess : Color.brandPrimary)
                        .clipShape(Capsule())
                }
                .disabled(locationRequested)
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color.textSecondary.opacity(0.03))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .strokeBorder(Color.textSecondary.opacity(0.1), lineWidth: 1)
                    )
            )
            .padding(.bottom, 24)
            
            // Notifications Card
            VStack(alignment: .leading, spacing: 16) {
                HStack(alignment: .top, spacing: 16) {
                    Circle()
                        .fill(Color.brandSecondary.opacity(0.1))
                        .frame(width: 40, height: 40)
                        .overlay(
                            Image(systemName: AppIcons.bell)
                                .foregroundColor(.brandSecondary)
                        )
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(AppStrings.Auth.notificationsTitle)
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.textPrimary)
                        
                        Text(AppStrings.Auth.notificationsDesc)
                            .font(.system(size: 13))
                            .foregroundColor(.textSecondary)
                            .lineSpacing(2)
                    }
                }
                
                Button(action: {
                    // MVP: Simulate permission request
                    notificationsRequested = true
                    
                    // Auto-navigate after second permission
                    if locationRequested {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            navigateToReady = true
                        }
                    }
                }) {
                    Text(notificationsRequested ? AppStrings.Auth.notificationsEnabled : AppStrings.Auth.notificationsCTA)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.textOnBrand)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(notificationsRequested ? Color.statusSuccess : Color.brandPrimary)
                        .clipShape(Capsule())
                }
                .disabled(notificationsRequested)
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color.textSecondary.opacity(0.03))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .strokeBorder(Color.textSecondary.opacity(0.1), lineWidth: 1)
                    )
            )
            
            Spacer()
            
            // Manual Continue button if auto-navigate fails or they skip
            if locationRequested || notificationsRequested {
                Button(action: { navigateToReady = true }) {
                    Text(AppStrings.Auth.readyCTA + " →")
                        .font(.buttonText)
                        .foregroundColor(.brandPrimary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                }
            }
            
            HStack(spacing: 6) {
                Spacer()
                Image(systemName: AppIcons.privacyShield)
                    .font(.system(size: 12))
                Text(AppStrings.Auth.privacyNote)
                    .font(.system(size: 10, weight: .bold))
                    .kerning(1.0)
                Spacer()
            }
            .foregroundColor(.textSecondary.opacity(0.6))
            .padding(.bottom, 32)
        }
        .padding(.horizontal, 24)
        .background(Color.textOnBrand.edgesIgnoringSafeArea(.all))
        .navigationBarHidden(true)
        .navigationDestination(isPresented: $navigateToReady) {
            ReadyScreen()
        }
    }
}

struct PermissionsScreen_Previews: PreviewProvider {
    static var previews: some View {
        PermissionsScreen()
    }
}
