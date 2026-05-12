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
                    Image(systemName: "arrow.left")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.coffeeTextPrimary)
                }
                Spacer()
            }
            .padding(.top, 16)

            // Title
            VStack(alignment: .leading, spacing: 8) {
                Text("Enter verification\ncode")
                    .font(.heading1)
                    .foregroundColor(.coffeeTextPrimary)

                Text("Sent to \(phoneNumber)")
                    .font(.bodyStandard)
                    .foregroundColor(.coffeeTextSecondary)
            }
            .padding(.top, 16)

            // OTP boxes
            HStack(spacing: 12) {
                ForEach(0..<6, id: \.self) { index in
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.white)
                            .frame(width: 46, height: 56)
                            .shadow(color: Color.black.opacity(0.06), radius: 4, x: 0, y: 2)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .strokeBorder(
                                        index < otpCode.count ? Color.coffeePrimary : Color.clear,
                                        lineWidth: 2
                                    )
                            )

                        if index < otpCode.count {
                            let charIndex = otpCode.index(otpCode.startIndex, offsetBy: index)
                            Text(String(otpCode[charIndex]))
                                .font(.system(size: 22, weight: .bold, design: .rounded))
                                .foregroundColor(.coffeeTextPrimary)
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
                    .foregroundColor(.coffeeError)
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
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(0.9)
                    }
                    Text(auth.isLoading ? "Verifying..." : "Verify →")
                        .font(.buttonText)
                        .foregroundColor(.white)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(isCodeComplete ? Color.coffeePrimary : Color.coffeeTextSecondary.opacity(0.3))
                .clipShape(Capsule())
            }
            .disabled(!isCodeComplete || auth.isLoading)
            .padding(.bottom, 8)

            #if DEBUG
            Button(action: { navigateToProfile = true }) {
                Text("⚡ Skip Verify (Debug)")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.coffeeTextSecondary)
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
        .background(Color.coffeeSurface.edgesIgnoringSafeArea(.all))
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
