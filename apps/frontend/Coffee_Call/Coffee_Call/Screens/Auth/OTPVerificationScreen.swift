import SwiftUI

struct OTPVerificationScreen: View {
    var phoneNumber: String
    @State private var otpCode: String = ""
    @Environment(\.presentationMode) var presentationMode
    
    var isCodeComplete: Bool {
        return otpCode.count == 6
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            HStack {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "arrow.left")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.coffeeTextPrimary)
                }
                Spacer()
            }
            .padding(.top, 16)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Enter your\nverification code")
                    .font(.heading1)
                    .foregroundColor(.coffeeTextPrimary)
                
                Text("Sent to \(phoneNumber)")
                    .font(.bodyStandard)
                    .foregroundColor(.coffeeTextSecondary)
            }
            .padding(.top, 16)
            
            TextField("000000", text: $otpCode)
                .font(.system(size: 40, weight: .bold, design: .rounded))
                .keyboardType(.numberPad)
                .foregroundColor(.coffeeTextPrimary)
                .padding(.vertical, 16)
            
            Divider()
                .background(Color.coffeeTextSecondary.opacity(0.3))
            
            Spacer()
            
            NavigationLink(destination: ProfileSetupScreen()) {
                Text("Verify")
                    .font(.buttonText)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(isCodeComplete ? Color.coffeePrimary : Color.coffeeTextSecondary.opacity(0.5))
                    .clipShape(Capsule())
            }
            .disabled(!isCodeComplete)
            .padding(.bottom, 40)
        }
        .padding(.horizontal, 24)
        .background(Color.coffeeSurface.edgesIgnoringSafeArea(.all))
        .navigationBarHidden(true)
    }
}

struct OTPVerificationScreen_Previews: PreviewProvider {
    static var previews: some View {
        OTPVerificationScreen(phoneNumber: "+1 555-555-5555")
    }
}
