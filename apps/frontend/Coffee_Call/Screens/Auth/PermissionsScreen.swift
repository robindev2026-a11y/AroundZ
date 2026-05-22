import SwiftUI
import UserNotifications
import CoreLocation
import Coffee_Call
struct PermissionsScreen: View {
    @StateObject private var locationService = LocationService.shared
    @StateObject private var notificationService = NotificationPermissionService.shared
    @State private var navigateToReady = false
    
    private var locationDetermined: Bool {
        locationService.locationStatus != .notDetermined
    }
    
    private var locationGranted: Bool {
        locationService.locationStatus == CLAuthorizationStatus.authorizedWhenInUse ||
        locationService.locationStatus == CLAuthorizationStatus.authorizedAlways
    }
    
    private var locationDenied: Bool {
        locationService.locationStatus == .denied || locationService.locationStatus == .restricted
    }
    
    private var notificationsDetermined: Bool {
        notificationService.notificationStatus != .notDetermined
    }
    
    private var notificationsGranted: Bool {
        notificationService.notificationStatus == .authorized ||
        notificationService.notificationStatus == .provisional ||
        notificationService.notificationStatus == .ephemeral
    }
    
    private var notificationsDenied: Bool {
        notificationService.notificationStatus == .denied
    }
    
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
                            AppIcons.locationImage
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
                    locationService.requestPermission()
                }) {
                    HStack(spacing: 6) {
                        if locationGranted {
                            AppIcons.checkmarkImage
                        } else if locationDenied {
                            AppIcons.infoCircleImage
                        }
                        
                        Text(locationText)
                    }
                    .font(.system(size: 14, weight: .bold, design: .default))
                    .foregroundColor(locationForegroundColor)
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .background(locationBackgroundColor)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                }
                .disabled(locationGranted)
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
                            AppIcons.bellImage
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
                    notificationService.requestNotificationPermission()
                }) {
                    HStack(spacing: 6) {
                        if notificationsGranted {
                            AppIcons.checkmarkImage
                        } else if notificationsDenied {
                            AppIcons.infoCircleImage
                        }
                        
                        Text(notificationsText)
                    }
                    .font(.system(size: 14, weight: .bold, design: .default))
                    .foregroundColor(notificationsForegroundColor)
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .background(notificationsBackgroundColor)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                }
                .disabled(notificationsGranted)
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
            
            if locationDetermined && notificationsDetermined {
                Button(action: { navigateToReady = true }) {
                    HStack(spacing: 8) {
                        Text("All Set! Let's Go")
                        AppIcons.arrowRightImage
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
                AppIcons.privacyShieldImage
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
        .onChange(of: locationDetermined) { newValue in
            if newValue && notificationsDetermined {
                triggerAutoNavigation()
            }
        }
        .onChange(of: notificationsDetermined) { newValue in
            if newValue && locationDetermined {
                triggerAutoNavigation()
            }
        }
    }
    
    private func triggerAutoNavigation() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            navigateToReady = true
        }
    }
    
    // MARK: - UI Configuration Helpers
    
    private var locationText: String {
        if locationGranted {
            return AppStrings.Auth.locationGranted
        } else if locationDenied {
            return "Location Denied (Enable in Settings)"
        } else {
            return AppStrings.Auth.locationCTA
        }
    }
    
    private var locationForegroundColor: Color {
        if locationGranted {
            return .statusSuccess
        } else if locationDenied {
            return .brandSecondary
        } else {
            return .textOnBrand
        }
    }
    
    private var locationBackgroundColor: Color {
        if locationGranted {
            return Color.statusSuccess.opacity(0.1)
        } else if locationDenied {
            return Color.brandSecondary.opacity(0.1)
        } else {
            return Color.brandPrimary
        }
    }
    
    private var notificationsText: String {
        if notificationsGranted {
            return AppStrings.Auth.notificationsEnabled
        } else if notificationsDenied {
            return "Notifications Denied (Enable in Settings)"
        } else {
            return AppStrings.Auth.notificationsCTA
        }
    }
    
    private var notificationsForegroundColor: Color {
        if notificationsGranted {
            return .statusSuccess
        } else if notificationsDenied {
            return .brandSecondary
        } else {
            return .textOnBrand
        }
    }
    
    private var notificationsBackgroundColor: Color {
        if notificationsGranted {
            return Color.statusSuccess.opacity(0.1)
        } else if notificationsDenied {
            return Color.brandSecondary.opacity(0.1)
        } else {
            return Color.brandPrimary
        }
    }
}

struct PermissionsScreen_Previews: PreviewProvider {
    static var previews: some View {
        PermissionsScreen()
    }
}

