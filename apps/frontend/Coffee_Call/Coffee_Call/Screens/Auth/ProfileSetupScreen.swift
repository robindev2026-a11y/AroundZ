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
            Button(action: {
                presentationMode.wrappedValue.dismiss()
            }) {
                Image(systemName: AppIcons.arrowLeft)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.textPrimary)
                    .frame(width: 48, height: 48)
                    .background(
                        Circle()
                            .fill(Color.surfaceMain)
                            .overlay(Circle().stroke(Color.appBorder, lineWidth: 1))
                    )
                    .shadow(color: Color.textPrimary.opacity(0.04), radius: 12, x: 0, y: 4)
            }
            .padding(.top, 40)
            .padding(.bottom, 32)

            Text(AppStrings.Auth.profileTitle)
                .font(.system(size: 30, weight: .black, design: .default))
                .foregroundColor(.textPrimary)
                .padding(.bottom, 36)

            VStack(spacing: 24) {
                ZStack(alignment: .bottomTrailing) {
                    RoundedRectangle(cornerRadius: 48, style: .continuous)
                        .fill(Color.surfaceSecondary)
                        .frame(width: 140, height: 140)
                        .overlay(
                            RoundedRectangle(cornerRadius: 48, style: .continuous)
                                .strokeBorder(Color.appBorder, style: StrokeStyle(lineWidth: 2, dash: [7]))
                        )
                        .background(
                            RoundedRectangle(cornerRadius: 48, style: .continuous)
                                .fill(Color.surfaceMain)
                        )
                        .overlay(
                            Image(systemName: AppIcons.camera)
                                .font(.system(size: 38, weight: .medium))
                                .foregroundColor(.textSecondary.opacity(0.5))
                        )

                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(Color.brandPrimary)
                        .frame(width: 40, height: 40)
                        .overlay(
                            Image(systemName: AppIcons.camera)
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.textOnBrand)
                        )
                        .offset(x: 2, y: 2)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .stroke(Color.surfaceMain, lineWidth: 4)
                        )
                        .shadow(color: Color.brandPrimary.opacity(0.24), radius: 12, x: 0, y: 6)
                }

                HStack(spacing: 16) {
                    Button(action: {}) {
                        Text(AppStrings.Auth.takePhoto)
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.brandPrimary)
                            .padding(.vertical, 10)
                            .padding(.horizontal, 16)
                            .background(Color.brandPrimary.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    }
                    
                    Button(action: {}) {
                        Text(AppStrings.Auth.chooseLibrary)
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.brandPrimary)
                            .padding(.vertical, 10)
                            .padding(.horizontal, 16)
                            .background(Color.brandPrimary.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.bottom, 40)

            // Name Input Section
            VStack(alignment: .leading, spacing: 8) {
                Text(AppStrings.Auth.displayNameLabel)
                    .font(.system(size: 12, weight: .black, design: .default))
                    .foregroundColor(.textSecondary)
                    .kerning(1.8)

                TextField(AppStrings.Auth.displayNamePlaceholder, text: $firstName)
                    .font(.system(size: 18, weight: .bold, design: .default))
                    .foregroundColor(.textPrimary)
                    .padding(.horizontal, 18)
                    .frame(height: 58)
                    .background(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(Color.surfaceMain)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .strokeBorder(Color.appBorder, lineWidth: 1)
                            )
                    )
                    .shadow(color: Color.textPrimary.opacity(0.04), radius: 12, x: 0, y: 4)

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
                        .font(.system(size: 18, weight: .black, design: .default))
                }
                .foregroundColor(.textOnBrand)
                .frame(maxWidth: .infinity)
                .frame(height: 64)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(isReady ? Color.brandPrimary : Color.textSecondary.opacity(0.24))
                )
                .shadow(color: Color.brandPrimary.opacity(isReady ? 0.22 : 0), radius: 18, x: 0, y: 8)
            }
            .disabled(!isReady || auth.isLoading)
            .padding(.bottom, 12)

        }
        .padding(.horizontal, 32)
        .background(Color.backgroundMain.edgesIgnoringSafeArea(.all))
        .navigationBarHidden(true)
        .navigationDestination(isPresented: $navigateToPermissions) {
            PermissionsScreen()
        }
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
