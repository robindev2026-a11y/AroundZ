import SwiftUI

struct PermissionsScreen: View {
    @State private var locationRequested = false
    @State private var notificationsRequested = false
    @State private var navigateToReady = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(AppStrings.Auth.permissionsTitle)
                .font(.system(size: 30, weight: .black, design: .default))
                .foregroundColor(.textPrimary)
                .padding(.top, 52)
                .padding(.bottom, 12)
            
            Text(AppStrings.Auth.permissionsSubtitle)
                .font(.system(size: 16, weight: .medium, design: .default))
                .foregroundColor(.textSecondary)
                .lineSpacing(4)
                .padding(.bottom, 40)
            
            VStack(alignment: .leading, spacing: 16) {
                HStack(alignment: .top, spacing: 16) {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(Color.brandPrimary.opacity(0.1))
                        .frame(width: 48, height: 48)
                        .overlay(
                            Image(systemName: AppIcons.location)
                                .font(.system(size: 22, weight: .semibold))
                                .foregroundColor(.brandPrimary)
                        )
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(AppStrings.Auth.locationTitle)
                            .font(.system(size: 17, weight: .bold, design: .default))
                            .foregroundColor(.textPrimary)
                        
                        Text(AppStrings.Auth.locationDesc)
                            .font(.system(size: 13, weight: .medium, design: .default))
                            .foregroundColor(.textSecondary)
                            .lineSpacing(2)
                    }
                }
                
                Button(action: {
                    locationRequested = true
                    if notificationsRequested {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            navigateToReady = true
                        }
                    }
                }) {
                    HStack(spacing: 6) {
                        if locationRequested {
                            Image(systemName: AppIcons.checkmark)
                        }
                        Text(locationRequested ? AppStrings.Auth.locationGranted : AppStrings.Auth.locationCTA)
                    }
                    .font(.system(size: 14, weight: .bold, design: .default))
                    .foregroundColor(locationRequested ? .statusSuccess : .textOnBrand)
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .background(locationRequested ? Color.statusSuccess.opacity(0.1) : Color.brandPrimary)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                }
                .disabled(locationRequested)
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(Color.surfaceMain)
                    .overlay(
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .strokeBorder(Color.appBorder, lineWidth: 1)
                    )
            )
            .shadow(color: Color.textPrimary.opacity(0.04), radius: 12, x: 0, y: 4)
            .padding(.bottom, 24)
            
            VStack(alignment: .leading, spacing: 16) {
                HStack(alignment: .top, spacing: 16) {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(Color.brandSecondary.opacity(0.1))
                        .frame(width: 48, height: 48)
                        .overlay(
                            Image(systemName: AppIcons.bell)
                                .font(.system(size: 22, weight: .semibold))
                                .foregroundColor(.brandSecondary)
                        )
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(AppStrings.Auth.notificationsTitle)
                            .font(.system(size: 17, weight: .bold, design: .default))
                            .foregroundColor(.textPrimary)
                        
                        Text(AppStrings.Auth.notificationsDesc)
                            .font(.system(size: 13, weight: .medium, design: .default))
                            .foregroundColor(.textSecondary)
                            .lineSpacing(2)
                    }
                }
                
                Button(action: {
                    notificationsRequested = true
                    if locationRequested {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            navigateToReady = true
                        }
                    }
                }) {
                    HStack(spacing: 6) {
                        if notificationsRequested {
                            Image(systemName: AppIcons.checkmark)
                        }
                        Text(notificationsRequested ? AppStrings.Auth.notificationsEnabled : AppStrings.Auth.notificationsCTA)
                    }
                    .font(.system(size: 14, weight: .bold, design: .default))
                    .foregroundColor(notificationsRequested ? .statusSuccess : .textOnBrand)
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .background(notificationsRequested ? Color.statusSuccess.opacity(0.1) : Color.brandPrimary)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                }
                .disabled(notificationsRequested)
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(Color.surfaceMain)
                    .overlay(
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .strokeBorder(Color.appBorder, lineWidth: 1)
                    )
            )
            .shadow(color: Color.textPrimary.opacity(0.04), radius: 12, x: 0, y: 4)
            
            Spacer()
            
            if locationRequested && notificationsRequested {
                Button(action: { navigateToReady = true }) {
                    HStack(spacing: 8) {
                        Text("All Set! Let's Go")
                        Image(systemName: AppIcons.arrowRight)
                            .font(.system(size: 16, weight: .bold))
                    }
                    .font(.system(size: 17, weight: .black, design: .default))
                    .foregroundColor(.textOnBrand)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(Color.brandPrimary)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .shadow(color: Color.brandPrimary.opacity(0.22), radius: 16, x: 0, y: 8)
                }
                .padding(.bottom, 20)
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
        .padding(.horizontal, 32)
        .background(Color.backgroundMain.edgesIgnoringSafeArea(.all))
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
