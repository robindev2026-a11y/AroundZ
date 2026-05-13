import SwiftUI

struct ProfileSetupScreen: View {
    @EnvironmentObject var auth: AuthViewModel
    @State private var firstName: String = ""
    @State private var navigateToPermissions = false
    @Environment(\.presentationMode) var presentationMode

    var isReady: Bool {
        !firstName.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Back Button
            Button(action: {
                presentationMode.wrappedValue.dismiss()
            }) {
                Circle()
                    .fill(Color.textSecondary.opacity(0.05))
                    .frame(width: 40, height: 40)
                    .overlay(
                        Image(systemName: AppIcons.arrowLeft)
                            .foregroundColor(.textPrimary)
                    )
            }
            .padding(.top, 20)
            .padding(.bottom, 24)

            Text(AppStrings.Auth.profileTitle)
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(.textPrimary)
                .padding(.bottom, 40)

            // Avatar Section
            VStack(spacing: 24) {
                ZStack(alignment: .bottomTrailing) {
                    RoundedRectangle(cornerRadius: 36, style: .continuous)
                        .strokeBorder(Color.textSecondary.opacity(0.3), style: StrokeStyle(lineWidth: 1.5, dash: [6]))
                        .frame(width: 120, height: 120)
                        .background(
                            RoundedRectangle(cornerRadius: 36, style: .continuous)
                                .fill(Color.textOnBrand)
                        )
                        .overlay(
                            Image(systemName: AppIcons.camera)
                                .font(.system(size: 32))
                                .foregroundColor(.textSecondary.opacity(0.5))
                        )

                    Circle()
                        .fill(Color.brandPrimary)
                        .frame(width: 32, height: 32)
                        .overlay(
                            Image(systemName: AppIcons.camera)
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.textOnBrand)
                        )
                        .offset(x: 4, y: 4)
                        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                }

                HStack(spacing: 16) {
                    Button(action: {}) {
                        Text(AppStrings.Auth.takePhoto)
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.brandPrimary)
                            .padding(.vertical, 10)
                            .padding(.horizontal, 16)
                            .background(Color.brandPrimary.opacity(0.1))
                            .clipShape(Capsule())
                    }
                    
                    Button(action: {}) {
                        Text(AppStrings.Auth.chooseLibrary)
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.brandPrimary)
                            .padding(.vertical, 10)
                            .padding(.horizontal, 16)
                            .background(Color.brandPrimary.opacity(0.1))
                            .clipShape(Capsule())
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.bottom, 40)

            // Name Input Section
            VStack(alignment: .leading, spacing: 8) {
                Text(AppStrings.Auth.displayNameLabel)
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(.textSecondary)
                    .kerning(1.2)

                TextField(AppStrings.Auth.displayNamePlaceholder, text: $firstName)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.textPrimary)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .strokeBorder(Color.textSecondary.opacity(0.1), lineWidth: 1)
                            .background(RoundedRectangle(cornerRadius: 12).fill(Color.textSecondary.opacity(0.02)))
                    )

                Text(AppStrings.Auth.displayNameSubtitle)
                    .font(.system(size: 12))
                    .foregroundColor(.textSecondary)
                    .padding(.top, 4)
            }

            if let error = auth.errorMessage {
                Text(error)
                    .font(.system(size: 12))
                    .foregroundColor(.statusError)
                    .padding(.top, 8)
            }

            Spacer()

            // CTA
            Button(action: {
                auth.saveProfile(name: firstName) { success in
                    if success {
                        navigateToPermissions = true
                    }
                }
            }) {
                HStack(spacing: 12) {
                    if auth.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .textOnBrand))
                            .scaleEffect(0.9)
                    }
                    Text(auth.isLoading ? AppStrings.Auth.saving : AppStrings.Auth.profileCTA)
                        .font(.buttonText)
                        .foregroundColor(.textOnBrand)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(isReady ? Color.brandPrimary : Color.textSecondary.opacity(0.3))
                .clipShape(Capsule())
            }
            .disabled(!isReady || auth.isLoading)
            .padding(.bottom, 8)

            #if DEBUG
            Button(action: { navigateToPermissions = true }) {
                Text(AppStrings.Auth.skipProfileDebug)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.textSecondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.bottom, 32)
            #endif
        }
        .padding(.horizontal, 24)
        .background(Color.textOnBrand.edgesIgnoringSafeArea(.all)) // Clean white background for this screen
        .navigationBarHidden(true)
        .background(
            NavigationLink(
                destination: PermissionsScreen(),
                isActive: $navigateToPermissions,
                label: { EmptyView() }
            )
        )
    }
}

struct ProfileSetupScreen_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ProfileSetupScreen()
                .environmentObject(AuthViewModel())
        }
    }
}
