import SwiftUI

struct EditProfileScreen: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel = ProfileViewModel()
    
    @State private var name: String = AppConstants.MockData.userName
    @State private var bio: String = AppConstants.MockData.userBio
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.backgroundMain.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: AppConstants.Layout.standardPadding) {
                        // Avatar Section
                        VStack(spacing: AppConstants.Layout.elementSpacing) {
                            ZStack(alignment: .bottomTrailing) {
                                Text(viewModel.initials)
                                    .font(.system(size: AppConstants.Typography.sizeDisplay, weight: .black))
                                    .foregroundColor(.brandPrimary)
                                    .frame(width: 100, height: 100)
                                    .background(Circle().fill(Color.brandPrimary.opacity(AppConstants.UI.opacityLight)))
                                
                                Button(action: {}) {
                                    ZStack {
                                        Circle()
                                            .fill(Color.brandPrimary)
                                            .frame(width: 32, height: 32)
                                        Image(systemName: AppIcons.camera)
                                            .font(.system(size: 14, weight: .bold))
                                            .foregroundColor(.white)
                                    }
                                    .overlay(Circle().stroke(Color.white, lineWidth: 3))
                                }
                            }
                            
                            Button(AppStrings.Profile.changePhoto) {}
                                .font(.system(size: AppConstants.Typography.sizeCaption, weight: .bold))
                                .foregroundColor(.brandPrimary)
                        }
                        .padding(.top, 20)
                        
                        // Form Fields
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
                                    .overlay(RoundedRectangle(cornerRadius: AppConstants.UI.cornerRadiusSmall).stroke(Color.appBorder, lineWidth: 1))
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
                                    .overlay(RoundedRectangle(cornerRadius: AppConstants.UI.cornerRadiusSmall).stroke(Color.appBorder, lineWidth: 1))
                            }
                        }
                    }
                    .padding(AppConstants.Layout.standardPadding)
                }
            }
            .navigationTitle(AppStrings.Profile.editProfile)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(content: {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(AppStrings.Common.cancel) {
                        dismiss()
                    }
                    .font(.system(size: AppConstants.Typography.sizeBody, weight: .medium))
                    .foregroundColor(.textPrimary)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(AppStrings.Common.save) {
                        // Save logic
                        dismiss()
                    }
                    .font(.system(size: AppConstants.Typography.sizeBody, weight: .black))
                    .foregroundColor(.brandPrimary)
                }
            })
        }
    }
}
