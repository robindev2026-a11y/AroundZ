import SwiftUI

struct EditProfileScreen: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: ProfileViewModel

    @State private var name: String = ""
    @State private var bio: String = ""

    // Photo picker state
    @State private var pickedImage: UIImage? = nil
    @State private var photoPickerSource: PhotoPickerSource? = nil
    @State private var showSourceChoice = false
    @State private var isPhotoRemoved = false

    init(viewModel: ProfileViewModel) {
        self.viewModel = viewModel
        _name = State(initialValue: viewModel.name)
        _bio = State(initialValue: viewModel.bio)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.backgroundMain.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: AppConstants.Layout.standardPadding) {

                        // MARK: - Avatar Section
                        VStack(spacing: AppConstants.Layout.elementSpacing) {
                            ZStack(alignment: .bottomTrailing) {
                                // Avatar preview or initials fallback
                                Group {
                                    if isPhotoRemoved {
                                        Text(viewModel.initials)
                                            .font(.system(size: AppConstants.Typography.sizeDisplay, weight: .black))
                                            .foregroundColor(.brandPrimary)
                                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                                            .background(Color.brandPrimary.opacity(AppConstants.UI.opacityLight))
                                    } else if let pickedImage {
                                        Image(uiImage: pickedImage)
                                            .resizable()
                                            .scaledToFill()
                                    } else if let existingImage = viewModel.profileImage {
                                        Image(uiImage: existingImage)
                                            .resizable()
                                            .scaledToFill()
                                    } else {
                                        Text(viewModel.initials)
                                            .font(.system(size: AppConstants.Typography.sizeDisplay, weight: .black))
                                            .foregroundColor(.brandPrimary)
                                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                                            .background(Color.brandPrimary.opacity(AppConstants.UI.opacityLight))
                                    }
                                }
                                .frame(width: 100, height: 100)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(Color.brandPrimary.opacity(0.2), lineWidth: 1.5))

                                // Camera badge
                                Button(action: { showSourceChoice = true }) {
                                    ZStack {
                                        Circle()
                                            .fill(Color.brandPrimary)
                                            .frame(width: 32, height: 32)
                                        AppIcons.cameraImage
                                            .font(.system(size: 14, weight: .bold))
                                            .foregroundColor(.white)
                                    }
                                    .overlay(Circle().stroke(Color.white, lineWidth: 3))
                                }
                            }

                            Button(AppStrings.Profile.changePhoto) {
                                showSourceChoice = true
                            }
                            .font(.system(size: AppConstants.Typography.sizeCaption, weight: .bold))
                            .foregroundColor(.brandPrimary)
                        }
                        .padding(.top, 20)

                        // MARK: - Form Fields
                        VStack(alignment: .leading, spacing: AppConstants.Layout.sectionSpacing) {
                            VStack(alignment: .leading, spacing: 8) {
                                Text(AppStrings.Auth.displayNameLabel)
                                    .font(.system(size: AppConstants.Typography.sizeTiny, weight: .black))
                                    .foregroundColor(.textSecondary)
                                    .kerning(1.2)

                                TextField("", text: $name)
                                    .font(.system(size: AppConstants.Typography.sizeBody, weight: .bold))
                                    .padding()
                                    .background(Color.surfaceMain)
                                    .cornerRadius(AppConstants.UI.cornerRadiusSmall)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: AppConstants.UI.cornerRadiusSmall)
                                            .stroke(Color.appBorder, lineWidth: 1)
                                    )
                            }

                            VStack(alignment: .leading, spacing: 8) {
                                Text(AppStrings.Profile.bioLabel)
                                    .font(.system(size: AppConstants.Typography.sizeTiny, weight: .black))
                                    .foregroundColor(.textSecondary)
                                    .kerning(1.2)

                                TextEditor(text: $bio)
                                    .font(.system(size: AppConstants.Typography.sizeBody, weight: .medium))
                                    .frame(height: 120)
                                    .padding(8)
                                    .background(Color.surfaceMain)
                                    .cornerRadius(AppConstants.UI.cornerRadiusSmall)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: AppConstants.UI.cornerRadiusSmall)
                                            .stroke(Color.appBorder, lineWidth: 1)
                                    )
                            }
                        }
                    }
                    .padding(AppConstants.Layout.standardPadding)
                }
            }
            .navigationTitle(AppStrings.Profile.editProfile)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(AppStrings.Common.cancel) {
                        dismiss()
                    }
                    .font(.system(size: AppConstants.Typography.sizeBody, weight: .medium))
                    .foregroundColor(.textPrimary)
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(AppStrings.Common.save) {
                        viewModel.updateProfile(name: name, bio: bio, image: pickedImage, removePhoto: isPhotoRemoved)
                        dismiss()
                    }
                    .font(.system(size: AppConstants.Typography.sizeBody, weight: .black))
                    .foregroundColor(.brandPrimary)
                }
            }
            .withDoneButton()
            .dismissKeyboardOnTap()
            // Source choice confirmation dialog
            .confirmationDialog("Change Profile Photo", isPresented: $showSourceChoice, titleVisibility: .visible) {
                Button("Take Photo") { photoPickerSource = .camera }
                Button("Choose from Library") { photoPickerSource = .library }
                if pickedImage != nil || (viewModel.profileImage != nil && !isPhotoRemoved) {
                    Button("Remove Photo", role: .destructive) {
                        pickedImage = nil
                        isPhotoRemoved = true
                    }
                }
                Button("Cancel", role: .cancel) {}
            }
            // Attach the unified picker modifier
            .photoPicker(source: $photoPickerSource) { image in
                pickedImage = image
                isPhotoRemoved = false
            }
        }
    }
}
