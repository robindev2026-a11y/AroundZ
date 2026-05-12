import SwiftUI

struct PhoneAuthScreen: View {
    @State private var phoneNumber: String = ""
    @Environment(\.presentationMode) var presentationMode
    
    var isPhoneValid: Bool {
        return phoneNumber.count >= 10
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            // Header
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
                Text("What's your\nphone number?")
                    .font(.heading1)
                    .foregroundColor(.coffeeTextPrimary)
                
                Text("We'll send you a code to verify your number so you can connect with people safely.")
                    .font(.bodyStandard)
                    .foregroundColor(.coffeeTextSecondary)
                    .lineSpacing(4)
            }
            .padding(.top, 16)
            
            // Phone Input
            HStack(spacing: 12) {
                Text("+1")
                    .font(.heading1)
                    .foregroundColor(.coffeeTextPrimary)
                
                TextField("555-555-5555", text: $phoneNumber)
                    .font(.heading1)
                    .keyboardType(.numberPad)
                    .foregroundColor(.coffeeTextPrimary)
            }
            .padding(.vertical, 16)
            
            Divider()
                .background(Color.coffeeTextSecondary.opacity(0.3))
            
            Spacer()
            
            NavigationLink(destination: OTPVerificationScreen(phoneNumber: "+1 \(phoneNumber)")) {
                Text("Send Code →")
                    .font(.buttonText)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(isPhoneValid ? Color.coffeePrimary : Color.coffeeTextSecondary.opacity(0.5))
                    .clipShape(Capsule())
            }
            .disabled(!isPhoneValid)
            .padding(.bottom, 40)
        }
        .padding(.horizontal, 24)
        .background(Color.coffeeSurface.edgesIgnoringSafeArea(.all))
        .navigationBarHidden(true)
    }
}

struct PhoneAuthScreen_Previews: PreviewProvider {
    static var previews: some View {
        PhoneAuthScreen()
    }
}
