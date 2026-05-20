import SwiftUI

struct PhoneAuthScreen: View {
    @EnvironmentObject var auth: AuthViewModel
    @Environment(\.presentationMode) var presentationMode

    @State private var phoneNumber: String = ""
    @State private var selectedCountry: CountryCode = CountryCode.defaultCountry
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
        (8...15).contains(fullPhoneDigits.count)
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
        VStack(alignment: .leading, spacing: 0) {
            Button(action: { presentationMode.wrappedValue.dismiss() }) {
                AppIcons.arrowLeftImage
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
            .padding(.bottom, 40)

            VStack(alignment: .leading, spacing: 12) {
                Text(AppStrings.Auth.phoneTitle)
                    .font(.system(size: 30, weight: .black, design: .default))
                    .foregroundColor(.textPrimary)

                Text(AppStrings.Auth.phoneSubtitle)
                    .font(.system(size: 18, weight: .medium, design: .default))
                    .foregroundColor(.textSecondary)
                    .lineSpacing(4)
            }
            .padding(.bottom, 48)

            VStack(alignment: .leading, spacing: 12) {
                Text(AppStrings.Auth.phoneLabel)
                    .font(.system(size: 12, weight: .black, design: .default))
                    .foregroundColor(.textSecondary)
                    .kerning(1.8)
                    .padding(.leading, 4)

                HStack(spacing: 14) {
                    Button(action: { showCountryPicker = true }) {
                        HStack(spacing: 8) {
                            Text(selectedCountry.flag)
                                .font(.system(size: 20))
                            Text(selectedCountry.dialCode)
                                .font(.system(size: 16, weight: .bold, design: .default))
                                .foregroundColor(.textPrimary)
                            AppIcons.chevronDownImage
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.textSecondary)
                        }
                        .frame(width: 110, height: 64)
                        .background(phoneFieldBackground)
                    }

                    TextField(AppStrings.Auth.phonePlaceholder, text: $phoneNumber)
                        .font(.system(size: 20, weight: .bold, design: .default))
                        .keyboardType(.numberPad)
                        .foregroundColor(.textPrimary)
                        .padding(.horizontal, 20)
                        .frame(height: 64)
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
                        .padding(.top, 4)
                }
            }

            Text("Standard SMS rates may apply. You'll receive a 6-digit code to verify your phone.")
                .font(.system(size: 14, weight: .medium, design: .default))
                .foregroundColor(.textSecondary.opacity(0.82))
                .lineSpacing(3)
                .padding(.top, 24)

            Spacer()

            Button(action: {
                auth.sendOTP(phoneNumber: fullPhoneNumber) { success in
                    if success {
                        otpPhoneNumber = fullPhoneNumber
                        navigateToOTP = true
                    }
                }
            }) {
                HStack(spacing: 12) {
                    if auth.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .textOnBrand))
                            .scaleEffect(0.9)
                    }
                    Text(auth.isLoading ? AppStrings.Auth.sending : AppStrings.Auth.phoneCTA)
                        .font(.system(size: 18, weight: .black, design: .default))
                }
                .foregroundColor(.textOnBrand)
                .frame(maxWidth: .infinity)
                .frame(height: 64)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(isPhoneValid ? Color.brandPrimary : Color.textSecondary.opacity(0.24))
                )
                .shadow(color: Color.brandPrimary.opacity(isPhoneValid ? 0.22 : 0), radius: 18, x: 0, y: 8)
            }
            .disabled(!isPhoneValid || auth.isLoading)
            .padding(.bottom, 12)

        }
        .padding(.horizontal, 32)
        .background(Color.backgroundMain.edgesIgnoringSafeArea(.all))
        .navigationBarHidden(true)
        .sheet(isPresented: $showCountryPicker) {
            CountryPickerView(selected: $selectedCountry)
        }
        .withDoneButton()
        .dismissKeyboardOnTap()
    }

    private var phoneFieldBackground: some View {
        RoundedRectangle(cornerRadius: 16, style: .continuous)
            .fill(Color.surfaceMain)
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(Color.appBorder, lineWidth: 1)
            )
            .shadow(color: Color.textPrimary.opacity(0.04), radius: 12, x: 0, y: 4)
    }
}

// MARK: - Country Code Model
struct CountryCode: Identifiable {
    let id = UUID()
    let name: String
    let flag: String
    let dialCode: String

    static let defaultCountry = CountryCode(name: "United States", flag: "🇺🇸", dialCode: "+1")

    static let all: [CountryCode] = [
        defaultCountry,
        CountryCode(name: "United Kingdom", flag: "🇬🇧", dialCode: "+44"),
        CountryCode(name: "India", flag: "🇮🇳", dialCode: "+91"),
        CountryCode(name: "Canada", flag: "🇨🇦", dialCode: "+1"),
        CountryCode(name: "Australia", flag: "🇦🇺", dialCode: "+61"),
        CountryCode(name: "Germany", flag: "🇩🇪", dialCode: "+49"),
        CountryCode(name: "France", flag: "🇫🇷", dialCode: "+33"),
        CountryCode(name: "Singapore", flag: "🇸🇬", dialCode: "+65"),
        CountryCode(name: "UAE", flag: "🇦🇪", dialCode: "+971"),
        CountryCode(name: "Japan", flag: "🇯🇵", dialCode: "+81"),
        CountryCode(name: "Brazil", flag: "🇧🇷", dialCode: "+55"),
        CountryCode(name: "Mexico", flag: "🇲🇽", dialCode: "+52"),
        CountryCode(name: "South Africa", flag: "🇿🇦", dialCode: "+27"),
        CountryCode(name: "Nigeria", flag: "🇳🇬", dialCode: "+234"),
        CountryCode(name: "Philippines", flag: "🇵🇭", dialCode: "+63"),
    ]
}

// MARK: - Country Picker Sheet
struct CountryPickerView: View {
    @Binding var selected: CountryCode
    @Environment(\.presentationMode) var presentationMode
    @State private var search: String = ""

    var filtered: [CountryCode] {
        if search.isEmpty { return CountryCode.all }
        return CountryCode.all.filter {
            $0.name.localizedCaseInsensitiveContains(search) ||
            $0.dialCode.contains(search)
        }
    }

    var body: some View {
        NavigationView {
            List(filtered) { country in
                Button(action: {
                    selected = country
                    presentationMode.wrappedValue.dismiss()
                }) {
                    HStack(spacing: 16) {
                        Text(country.flag).font(.system(size: 28))
                        VStack(alignment: .leading, spacing: 2) {
                            Text(country.name)
                                .font(.bodyStandard)
                                .foregroundColor(.textPrimary)
                            Text(country.dialCode)
                                .font(.captionText)
                                .foregroundColor(.textSecondary)
                        }
                        Spacer()
                        if selected.dialCode == country.dialCode && selected.name == country.name {
                            AppIcons.checkmarkImage
                                .foregroundColor(.brandPrimary)
                                .fontWeight(.semibold)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
            .searchable(text: $search, prompt: AppStrings.Auth.searchCountry)
            .navigationTitle(AppStrings.Auth.selectCountry)
            .navigationBarTitleDisplayMode(.inline)
        }
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
