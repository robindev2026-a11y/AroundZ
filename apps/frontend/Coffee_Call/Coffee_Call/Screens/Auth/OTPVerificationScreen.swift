import SwiftUI

struct OTPVerificationScreen: View {
    @EnvironmentObject var auth: AuthViewModel
    @Environment(\.presentationMode) var presentationMode

    var phoneNumber: String
    var onBack: (() -> Void)? = nil

    @State private var otpCode: String = ""
    @State private var navigateToProfile = false
    @FocusState private var isOTPFocused: Bool

    var isCodeComplete: Bool { otpCode.count == 6 }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button(action: {
                if let onBack {
                    onBack()
                } else {
                    presentationMode.wrappedValue.dismiss()
                }
            }) {
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
                Text(AppStrings.Auth.otpTitle)
                    .font(.system(size: 30, weight: .black, design: .default))
                    .foregroundColor(.textPrimary)
                
                Text("\(AppStrings.Auth.sentTo) \(phoneNumber)")
                    .font(.system(size: 16, weight: .medium, design: .default))
                    .foregroundColor(.textSecondary)
                    .lineSpacing(3)
            }
            .padding(.bottom, 44)

            HStack(spacing: 8) {
                ForEach(0..<6, id: \.self) { index in
                    ZStack {
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(Color.surfaceMain)
                            .frame(height: 62)
                            .shadow(color: Color.textPrimary.opacity(0.04), radius: 12, x: 0, y: 4)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .strokeBorder(
                                        index < otpCode.count ? Color.brandPrimary : Color.appBorder,
                                        lineWidth: index < otpCode.count ? 2 : 1
                                    )
                            )

                        if index < otpCode.count {
                            let charIndex = otpCode.index(otpCode.startIndex, offsetBy: index)
                            Text(String(otpCode[charIndex]))
                                .font(.system(size: 22, weight: .bold, design: .default))
                                .foregroundColor(.textPrimary)
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .contentShape(Rectangle())
            .onTapGesture {
                isOTPFocused = true
            }
            .padding(.bottom, 24)

            TextField("", text: $otpCode)
                .keyboardType(.numberPad)
                .frame(width: 1, height: 1)
                .opacity(0.01)
                .focused($isOTPFocused)
                .onChange(of: otpCode) { newValue in
                    auth.clearError()
                    let digits = newValue.filter { $0.isNumber }
                    if digits.count > 6 {
                        otpCode = String(digits.prefix(6))
                    } else {
                        otpCode = digits
                    }
                }
                .onAppear {
                    isOTPFocused = true
                }

            HStack {
                Spacer()
                Button(action: {
                    auth.sendOTP(phoneNumber: phoneNumber) { success in
                        if success {
                            otpCode = ""
                            isOTPFocused = true
                        }
                    }
                }) {
                    Text(auth.isLoading ? AppStrings.Auth.sending : AppStrings.Auth.resendCode)
                        .font(.system(size: 13, weight: .bold, design: .default))
                        .foregroundColor(.brandPrimary)
                }
                .disabled(auth.isLoading)
                Spacer()
            }
            .padding(.vertical, 10)
            .background(
                Capsule()
                    .fill(Color.surfaceSecondary)
            )
            .padding(.horizontal, 36)

            if let error = auth.errorMessage {
                Text(error)
                    .font(.captionText)
                    .foregroundColor(.statusError)
                    .padding(.top, 16)
            }

            Spacer()

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
                        .font(.system(size: 18, weight: .black, design: .default))
                }
                .foregroundColor(.textOnBrand)
                .frame(maxWidth: .infinity)
                .frame(height: 64)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(isCodeComplete ? Color.brandPrimary : Color.textSecondary.opacity(0.24))
                )
                .shadow(color: Color.brandPrimary.opacity(isCodeComplete ? 0.22 : 0), radius: 18, x: 0, y: 8)
            }
            .disabled(!isCodeComplete || auth.isLoading)
            .padding(.bottom, 12)

        }
        .navigationDestination(isPresented: $navigateToProfile) {
            ProfileSetupScreen()
        }
        .padding(.horizontal, 32)
        .background(Color.backgroundMain.edgesIgnoringSafeArea(.all))
        .navigationBarHidden(true)
        .withDoneButton()
        .dismissKeyboardOnTap()
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
