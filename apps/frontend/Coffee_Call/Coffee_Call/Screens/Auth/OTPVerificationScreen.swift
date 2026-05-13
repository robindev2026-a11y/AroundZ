import SwiftUI

struct OTPVerificationScreen: View {
    @EnvironmentObject var auth: AuthViewModel
    @Environment(\.presentationMode) var presentationMode

    var phoneNumber: String

    @State private var otpCode: String = ""
    @State private var navigateToProfile = false

    var isCodeComplete: Bool { otpCode.count == 6 }

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
                Text(AppStrings.Auth.otpTitle)
                    .font(.heading1)
                    .foregroundColor(.textPrimary)
                
                Text("\(AppStrings.Auth.sentTo) \(phoneNumber)")
                    .font(.bodyStandard)
                    .foregroundColor(.textSecondary)
            }
            .padding(.top, 16)

            // OTP boxes
            HStack(spacing: 12) {
                ForEach(0..<6, id: \.self) { index in
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.textOnBrand)
                            .frame(width: 46, height: 56)
                            .shadow(color: Color.black.opacity(0.06), radius: 4, x: 0, y: 2)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .strokeBorder(
                                        index < otpCode.count ? Color.brandPrimary : Color.clear,
                                        lineWidth: 2
                                    )
                            )

                        if index < otpCode.count {
                            let charIndex = otpCode.index(otpCode.startIndex, offsetBy: index)
                            Text(String(otpCode[charIndex]))
                                .font(.system(size: 22, weight: .bold, design: .rounded))
                                .foregroundColor(.textPrimary)
                        }
                    }
                }
            }

            // Hidden text field capturing real input
            TextField("", text: $otpCode)
                .keyboardType(.numberPad)
                .frame(width: 1, height: 1)
                .opacity(0.01)
                .onChange(of: otpCode) { newValue in
                    // Clamp to 6 digits only
                    let digits = newValue.filter { $0.isNumber }
                    if digits.count > 6 {
                        otpCode = String(digits.prefix(6))
                    } else {
                        otpCode = digits
                    }
                }

            // Inline error
            if let error = auth.errorMessage {
                Text(error)
                    .font(.captionText)
                    .foregroundColor(.statusError)
            }

            Spacer()

            // Verify CTA
            Button(action: {
                auth.verifyOTP(code: otpCode) { success in
                    if success { navigateToProfile = true }
                }
            }) {
                HStack(spacing: 12) {
                    if auth.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .textOnBrand))
                            .scaleEffect(0.9)
                    }
                    Text(auth.isLoading ? AppStrings.Auth.verifying : AppStrings.Auth.otpCTA)
                        .font(.buttonText)
                        .foregroundColor(.textOnBrand)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(isCodeComplete ? Color.brandPrimary : Color.textSecondary.opacity(0.3))
                .clipShape(Capsule())
            }
            .disabled(!isCodeComplete || auth.isLoading)
            .padding(.bottom, 8)

            #if DEBUG
            Button(action: { navigateToProfile = true }) {
                Text(AppStrings.Auth.skipVerifyDebug)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.textSecondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.bottom, 32)
            #endif

        }
        .background(
            NavigationLink(
                destination: ProfileSetupScreen(),
                isActive: $navigateToProfile
            ) { EmptyView() }
        )
        .padding(.horizontal, 24)
        .background(Color.surfaceMain.edgesIgnoringSafeArea(.all))
        .navigationBarHidden(true)
    }
}

struct OTPVerificationScreen_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            OTPVerificationScreen(phoneNumber: "+91 98765 43210")
                .environmentObject(AuthViewModel())
        }
    }
}
