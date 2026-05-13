import SwiftUI
import FirebaseAuth

struct PhoneAuthScreen: View {
    @EnvironmentObject var auth: AuthViewModel
    @Environment(\.presentationMode) var presentationMode

    @State private var phoneNumber: String = ""
    @State private var selectedCountry: CountryCode = CountryCode.all[0]
    @State private var showCountryPicker = false
    @State private var navigateToOTP = false

    var fullPhoneNumber: String {
        "\(selectedCountry.dialCode)\(phoneNumber)"
    }

    var isPhoneValid: Bool {
        phoneNumber.count >= 7
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {

            // Back Button
            HStack {
                Button(action: { presentationMode.wrappedValue.dismiss() }) {
                    Image(systemName: AppIcons.arrowLeft)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.textPrimary)
                }
                Spacer()
            }
            .padding(.top, 16)

            // Title
            VStack(alignment: .leading, spacing: 8) {
                Text(AppStrings.Auth.phoneTitle)
                    .font(.heading1)
                    .foregroundColor(.textPrimary)
                
                Text(AppStrings.Auth.phoneSubtitle)
                    .font(.bodyStandard)
                    .foregroundColor(.textSecondary)
                    .lineSpacing(4)
            }
            .padding(.top, 16)

            // Phone Input Row
            VStack(spacing: 0) {
                HStack(spacing: 12) {
                    // Country Code Picker Button
                    Button(action: { showCountryPicker = true }) {
                        HStack(spacing: 6) {
                            Text(selectedCountry.flag)
                                .font(.system(size: 22))
                            Text(selectedCountry.dialCode)
                                .font(.bodyStandard)
                                .fontWeight(.semibold)
                                .foregroundColor(.textPrimary)
                            Image(systemName: "chevron.down")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(.textSecondary)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 14)
                        .background(Color.textOnBrand)
                        .cornerRadius(12)
                        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
                    }

                    // Number Input
                    TextField(AppStrings.Auth.phonePlaceholder, text: $phoneNumber)
                        .font(.bodyStandard)
                        .keyboardType(.numberPad)
                        .foregroundColor(.textPrimary)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 14)
                        .background(Color.textOnBrand)
                        .cornerRadius(12)
                        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
                        .frame(maxWidth: .infinity)
                }

                // Inline error
                if let error = auth.errorMessage {
                    Text(error)
                        .font(.captionText)
                        .foregroundColor(.statusError)
                        .padding(.top, 8)
                }
            }

            Spacer()

            // CTA Button
            Button(action: {
                auth.sendOTP(phoneNumber: fullPhoneNumber) { success in
                    if success && !auth.isAuthenticated {
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
                        .font(.buttonText)
                        .foregroundColor(.textOnBrand)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(isPhoneValid ? Color.brandPrimary : Color.textSecondary.opacity(0.3))
                .clipShape(Capsule())
            }
            .disabled(!isPhoneValid || auth.isLoading)
            .padding(.bottom, 8)

            #if DEBUG
            Button(action: { navigateToOTP = true }) {
                Text(AppStrings.Auth.skipDebug)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.textSecondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.bottom, 32)
            #endif

        }
        .navigationDestination(isPresented: $navigateToOTP) {
            OTPVerificationScreen(phoneNumber: fullPhoneNumber)
        }
        .padding(.horizontal, 24)
        .background(Color.surfaceMain.edgesIgnoringSafeArea(.all))
        .navigationBarHidden(true)
        .sheet(isPresented: $showCountryPicker) {
            CountryPickerView(selected: $selectedCountry)
        }
    }
}

// MARK: - Country Code Model
struct CountryCode: Identifiable {
    let id = UUID()
    let name: String
    let flag: String
    let dialCode: String

    static let all: [CountryCode] = [
        CountryCode(name: "India", flag: "🇮🇳", dialCode: "+91"),
        CountryCode(name: "United States", flag: "🇺🇸", dialCode: "+1"),
        CountryCode(name: "United Kingdom", flag: "🇬🇧", dialCode: "+44"),
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
                            Image(systemName: AppIcons.checkmark)
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
