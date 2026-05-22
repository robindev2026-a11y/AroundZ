import SwiftUI

struct ProfileSetupScreen: View {
    @EnvironmentObject var auth: AuthViewModel
    @State private var firstName: String = ""
    @State private var navigateToPermissions = false
    @Environment(\.presentationMode) var presentationMode

    // Photo picker state
    @State private var pickedImage: UIImage? = nil
    @State private var photoPickerSource: PhotoPickerSource? = nil
    @State private var showSourceChoiceSheet = false

    var isReady: Bool {
        !firstName.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Back button
            Button(action: {
                presentationMode.wrappedValue.dismiss()
            }) {
                AppIcons.arrowLeftImage
                    .font(.system(size: AppConstants.Typography.sizeTitle, weight: .semibold))
                    .foregroundColor(.textPrimary)
                    .frame(width: 48, height: 48)
                    .background(
                        Circle()
                            .fill(Color.surfaceMain)
                            .overlay(Circle().stroke(Color.appBorder, lineWidth: 1))
                    )
                    .shadow(color: Color.textPrimary.opacity(AppConstants.UI.opacitySubtle), radius: 12, x: 0, y: 4)
            }
            .padding(.top, 40)
            .padding(.bottom, 32)

            Text(AppStrings.Auth.profileTitle)
                .font(.system(size: AppConstants.Typography.sizeDisplay - 2, weight: .black, design: .default))
                .foregroundColor(.textPrimary)
                .padding(.bottom, 36)

            // MARK: - Avatar
            VStack(spacing: AppConstants.Layout.standardPadding) {
                ZStack(alignment: .bottomTrailing) {
                    // Avatar preview / placeholder
                    Group {
                        if let pickedImage {
                            Image(uiImage: pickedImage)
                                .resizable()
                                .scaledToFill()
                        } else {
                            Color.surfaceSecondary
                                .overlay(
                                    AppIcons.cameraImage
                                        .font(.system(size: 38, weight: .medium))
                                        .foregroundColor(.textSecondary.opacity(AppConstants.UI.opacityNormal + 0.1))
                                )
                        }
                    }
                    .frame(width: 140, height: 140)
                    .clipShape(RoundedRectangle(cornerRadius: 48, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 48, style: .continuous)
                            .strokeBorder(
                                pickedImage == nil ? Color.appBorder : Color.brandPrimary.opacity(0.4),
                                style: StrokeStyle(lineWidth: 2, dash: pickedImage == nil ? [7] : [])
                            )
                    )

                    // Camera badge
                    Button(action: { showSourceChoiceSheet = true }) {
                        RoundedRectangle(cornerRadius: AppConstants.UI.cornerRadiusSmall, style: .continuous)
                            .fill(Color.brandPrimary)
                            .frame(width: 40, height: 40)
                            .overlay(
                                AppIcons.cameraImage
                                    .font(.system(size: AppConstants.Typography.sizeHeadline, weight: .bold))
                                    .foregroundColor(.textOnBrand)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: AppConstants.UI.cornerRadiusSmall, style: .continuous)
                                    .stroke(Color.surfaceMain, lineWidth: 4)
                            )
                            .shadow(color: Color.brandPrimary.opacity(0.24), radius: 12, x: 0, y: 6)
                    }
                    .offset(x: 2, y: 2)
                }

                // Source choice buttons
                HStack(spacing: AppConstants.Layout.elementSpacing) {
                    Button(action: { photoPickerSource = .camera }) {
                        Text(AppStrings.Auth.takePhoto)
                            .font(.system(size: AppConstants.Typography.sizeCaption + 1, weight: .bold))
                            .foregroundColor(.brandPrimary)
                            .padding(.vertical, 10)
                            .padding(.horizontal, 16)
                            .background(Color.brandPrimary.opacity(AppConstants.UI.opacityLight))
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    }

                    Button(action: { photoPickerSource = .library }) {
                        Text(AppStrings.Auth.chooseLibrary)
                            .font(.system(size: AppConstants.Typography.sizeCaption + 1, weight: .bold))
                            .foregroundColor(.brandPrimary)
                            .padding(.vertical, 10)
                            .padding(.horizontal, 16)
                            .background(Color.brandPrimary.opacity(AppConstants.UI.opacityLight))
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.bottom, 40)

            // MARK: - Name Input
            VStack(alignment: .leading, spacing: 8) {
                Text(AppStrings.Auth.displayNameLabel)
                    .font(.system(size: AppConstants.Typography.sizeTiny + 1, weight: .black, design: .default))
                    .foregroundColor(.textSecondary)
                    .kerning(1.8)

                TextField(AppStrings.Auth.displayNamePlaceholder, text: $firstName)
                    .font(.system(size: AppConstants.Typography.sizeHeadline, weight: .bold, design: .default))
                    .foregroundColor(.textPrimary)
                    .padding(.horizontal, 18)
                    .frame(height: 58)
                    .background(
                        RoundedRectangle(cornerRadius: AppConstants.UI.cornerRadiusSmall, style: .continuous)
                            .fill(Color.surfaceMain)
                            .overlay(
                                RoundedRectangle(cornerRadius: AppConstants.UI.cornerRadiusSmall, style: .continuous)
                                    .strokeBorder(Color.appBorder, lineWidth: 1)
                            )
                    )
                    .shadow(color: Color.textPrimary.opacity(AppConstants.UI.opacitySubtle), radius: 12, x: 0, y: 4)

                Text(AppStrings.Auth.displayNameSubtitle)
                    .font(.system(size: AppConstants.Typography.sizeTiny + 1))
                    .foregroundColor(.textSecondary)
                    .padding(.top, 4)
            }

            if let error = auth.errorMessage {
                Text(error)
                    .font(.system(size: AppConstants.Typography.sizeTiny + 1))
                    .foregroundColor(.statusError)
                    .padding(.top, 8)
            }

            Spacer()

            // MARK: - CTA
            Button(action: {
                auth.saveProfile(name: firstName, image: pickedImage) { success in
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
                        .font(.system(size: AppConstants.Typography.sizeHeadline, weight: .black, design: .default))
                }
                .foregroundColor(.textOnBrand)
                .frame(maxWidth: .infinity)
                .frame(height: 64)
                .background(
                    RoundedRectangle(cornerRadius: AppConstants.UI.cornerRadiusSmall, style: .continuous)
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
        .withDoneButton()
        .dismissKeyboardOnTap()
        .photoPicker(source: $photoPickerSource) { image in
            pickedImage = image
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
