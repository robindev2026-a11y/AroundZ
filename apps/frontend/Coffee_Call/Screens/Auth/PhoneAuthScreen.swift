import SwiftUI
import Coffee_Call

struct PhoneAuthScreen: View {
    @EnvironmentObject var auth: AuthViewModel
    @Environment(\.presentationMode) var presentationMode

    @State private var phoneNumber: String = ""
    @State private var selectedCountry: Coffee_Call.CountryCode = Coffee_Call.CountryCode.defaultCountry
    @State private var showCountryPicker = false
    @State private var navigateToOTP = false
    @State private var otpPhoneNumber: String = ""

    private var phoneDigits: String {
        phoneNumber.filter(\.isNumber)
    }

    private var fullPhoneDigits: String {
        selectedCountry.dialCode.filter(\.isNumber) + phoneDigits
    }

    private var fullPhoneNumber: String {
        "\(selectedCountry.dialCode)\(phoneDigits)"
    }

    private var isPhoneValid: Bool {
        (AppConstants.Auth.minPhoneDigits...AppConstants.Auth.maxPhoneDigits).contains(fullPhoneDigits.count)
    }

    var body: some View {
        if navigateToOTP {
            OTPVerificationScreen(phoneNumber: otpPhoneNumber) {
                navigateToOTP = false
                otpPhoneNumber = ""
                auth.clearError()
            }
        } else {
            phoneEntryView
        }
    }
    
    private var phoneEntryView: some View {
        VStack(alignment: .leading, spacing: .zero) {
            Button(action: { presentationMode.wrappedValue.dismiss() }) {
                AppIcons.arrowLeftImage
                    .font(.captionText)
                    .foregroundColor(.textPrimary)
                    .frame(width: AppConstants.Auth.backButtonSize, height: AppConstants.Auth.backButtonSize)
                    .background(
                        Circle()
                            .fill(Color.surfaceMain)
                            .overlay(Circle().stroke(Color.appBorder, lineWidth: AppConstants.Auth.borderWidth))
                    )
                    .shadow(color: Color.textPrimary.opacity(AppConstants.UI.opacitySubtle), radius: AppConstants.Auth.backButtonShadowRadius, x: 0, y: AppConstants.Auth.backButtonShadowY)
            }
            .padding(.top, AppConstants.Auth.topSpacing)
            .padding(.bottom, AppConstants.Auth.topSpacing)

            VStack(alignment: .leading, spacing: AppConstants.Auth.sectionSpacing) {
                Text(AppStrings.Auth.phoneTitle)
                    .font(.heading1)
                    .foregroundColor(.textPrimary)

                Text(AppStrings.Auth.phoneSubtitle)
                    .font(.bodyStandard)
                    .foregroundColor(.textSecondary)
                    .lineSpacing(AppConstants.Auth.titleLineSpacing)
            }
            .padding(.bottom, AppConstants.Auth.titleBottomSpacing)

            VStack(alignment: .leading, spacing: AppConstants.Auth.sectionSpacing) {
                Text(AppStrings.Auth.phoneLabel)
                    .font(.metadata)
                    .foregroundColor(.textSecondary)
                    .kerning(AppConstants.Auth.labelKerning)
                    .padding(.leading, AppConstants.Layout.miniPadding)

                HStack(spacing: AppConstants.Auth.countryFieldSpacing) {
                    Button(action: { showCountryPicker = true }) {
                        HStack(spacing: AppConstants.Layout.subElementSpacing) {
                            Text(selectedCountry.flag)
                                .font(.system(size: AppConstants.Auth.countryFlagSize))
                            Text(selectedCountry.dialCode)
                                .font(.system(size: AppConstants.Auth.countryCodeFontSize, weight: .bold, design: .default))
                                .foregroundColor(.textPrimary)
                            AppIcons.chevronDownImage
                                .font(.system(size: AppConstants.Auth.countryChevronSize, weight: .bold))
                                .foregroundColor(.textSecondary)
                        }
                        .frame(width: AppConstants.Auth.countryFieldWidth, height: AppConstants.Auth.fieldHeight)
                        .background(phoneFieldBackground)
                    }

                    TextField(AppStrings.Auth.phonePlaceholder, text: $phoneNumber)
                        .font(.system(size: AppConstants.Auth.phoneFontSize, weight: .bold, design: .default))
                        .keyboardType(.numberPad)
                        .foregroundColor(.textPrimary)
                        .padding(.horizontal, AppConstants.Layout.elementSpacing + AppConstants.Layout.subElementSpacing)
                        .frame(height: AppConstants.Auth.fieldHeight)
                        .frame(maxWidth: .infinity)
                        .background(phoneFieldBackground)
                        .onChange(of: phoneNumber) { _ in
                            auth.clearError()
                        }
                }

                if let error = auth.errorMessage {
                    Text(error)
                        .font(.captionText)
                        .foregroundColor(.statusError)
                        .padding(.top, AppConstants.Layout.miniPadding)
                }
            }

            Text(AppStrings.Auth.smsHelper)
                .font(.system(size: AppConstants.Auth.smsHelperFontSize, weight: .medium, design: .default))
                .foregroundColor(.textSecondary.opacity(AppConstants.Auth.secondaryTextOpacity))
                .lineSpacing(AppConstants.Auth.helperLineSpacing)
                .padding(.top, AppConstants.Auth.helperTopSpacing)

            Spacer()

            Button(action: {
                auth.sendOTP(phoneNumber: fullPhoneNumber) { success in
                    if success {
                        otpPhoneNumber = fullPhoneNumber
                        navigateToOTP = true
                    }
                }
            }) {
                HStack(spacing: AppConstants.Auth.sectionSpacing) {
                    if auth.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .textOnBrand))
                            .scaleEffect(AppConstants.Auth.loadingScale)
                    }
                    Text(auth.isLoading ? AppStrings.Auth.sending : AppStrings.Auth.phoneCTA)
                        .font(.buttonText)
                }
                .foregroundColor(.textOnBrand)
                .frame(maxWidth: .infinity)
                .frame(height: AppConstants.Auth.fieldHeight)
                .background(
                    RoundedRectangle(cornerRadius: AppConstants.Auth.fieldCornerRadius, style: .continuous)
                        .fill(isPhoneValid ? Color.brandPrimary : Color.textSecondary.opacity(AppConstants.Auth.disabledButtonOpacity))
                )
                .shadow(color: Color.brandPrimary.opacity(isPhoneValid ? AppConstants.Auth.brandShadowOpacity : 0), radius: AppConstants.Auth.phoneButtonShadowRadius, x: 0, y: AppConstants.Auth.phoneButtonShadowY)
            }
            .disabled(!isPhoneValid || auth.isLoading)
            .padding(.bottom, AppConstants.Auth.authButtonBottomSpacing)

        }
        .padding(.horizontal, AppConstants.Auth.screenHorizontalPadding)
        .background(Color.backgroundMain.edgesIgnoringSafeArea(.all))
        .navigationBarHidden(true)
        .sheet(isPresented: $showCountryPicker) {
            CountryPickerView(selected: $selectedCountry)
        }
        .withDoneButton()
        .dismissKeyboardOnTap()
    }

    private var phoneFieldBackground: some View {
                RoundedRectangle(cornerRadius: AppConstants.Auth.fieldCornerRadius, style: .continuous)
                    .fill(Color.surfaceMain)
                    .overlay(
                        RoundedRectangle(cornerRadius: AppConstants.Auth.fieldCornerRadius, style: .continuous)
                    .stroke(Color.appBorder, lineWidth: AppConstants.Auth.borderWidth)
                    )
            .shadow(color: Color.textPrimary.opacity(AppConstants.UI.opacitySubtle), radius: AppConstants.Auth.fieldShadowRadius, x: 0, y: AppConstants.Auth.fieldShadowY)
    }
}

struct PhoneAuthScreen_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            PhoneAuthScreen()
                .environmentObject(AuthViewModel())
        }
    }
}
