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
                    Image(systemName: "arrow.left")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.coffeeTextPrimary)
                }
                Spacer()
            }
            .padding(.top, 16)

            // Title
            VStack(alignment: .leading, spacing: 8) {
                Text("What's your\nphone number?")
                    .font(.heading1)
                    .foregroundColor(.coffeeTextPrimary)

                Text("We'll send a one-time code to verify your number.")
                    .font(.bodyStandard)
                    .foregroundColor(.coffeeTextSecondary)
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
                                .foregroundColor(.coffeeTextPrimary)
                            Image(systemName: "chevron.down")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(.coffeeTextSecondary)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 14)
                        .background(Color.white)
                        .cornerRadius(12)
                        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
                    }

                    // Number Input
                    TextField("Phone number", text: $phoneNumber)
                        .font(.bodyStandard)
                        .keyboardType(.numberPad)
                        .foregroundColor(.coffeeTextPrimary)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 14)
                        .background(Color.white)
                        .cornerRadius(12)
                        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
                        .frame(maxWidth: .infinity)
                }

                // Inline error
                if let error = auth.errorMessage {
                    Text(error)
                        .font(.captionText)
                        .foregroundColor(.coffeeError)
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
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(0.9)
                    }
                    Text(auth.isLoading ? "Sending..." : "Send Code →")
                        .font(.buttonText)
                        .foregroundColor(.white)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(isPhoneValid ? Color.coffeePrimary : Color.coffeeTextSecondary.opacity(0.3))
                .clipShape(Capsule())
            }
            .disabled(!isPhoneValid || auth.isLoading)
            .padding(.bottom, 8)

            #if DEBUG
            Button(action: { navigateToOTP = true }) {
                Text("⚡ Skip OTP (Debug)")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.coffeeTextSecondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.bottom, 32)
            #endif

        }
        .background(
            NavigationLink(
                destination: OTPVerificationScreen(phoneNumber: fullPhoneNumber),
                isActive: $navigateToOTP
            ) { EmptyView() }
        )
        .padding(.horizontal, 24)
        .background(Color.coffeeSurface.edgesIgnoringSafeArea(.all))
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
                                .foregroundColor(.coffeeTextPrimary)
                            Text(country.dialCode)
                                .font(.captionText)
                                .foregroundColor(.coffeeTextSecondary)
                        }
                        Spacer()
                        if selected.dialCode == country.dialCode && selected.name == country.name {
                            Image(systemName: "checkmark")
                                .foregroundColor(.coffeePrimary)
                                .fontWeight(.semibold)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
            .searchable(text: $search, prompt: "Search country")
            .navigationTitle("Select Country")
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
