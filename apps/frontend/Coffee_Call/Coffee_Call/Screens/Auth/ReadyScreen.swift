import SwiftUI

struct ReadyScreen: View {
    @EnvironmentObject var auth: AuthViewModel
    
    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            
            Spacer()
            
            // Icon
            ZStack(alignment: .topTrailing) {
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .fill(Color.blue)
                    .frame(width: 96, height: 96)
                    .overlay(
                        Image(systemName: "checkmark")
                            .font(.system(size: 40, weight: .bold))
                            .foregroundColor(.white)
                    )
                    .shadow(color: Color.blue.opacity(0.3), radius: 15, x: 0, y: 8)
                
                Image(systemName: "sparkles")
                    .font(.system(size: 24))
                    .foregroundColor(Color.orange.opacity(0.8))
                    .offset(x: 16, y: -16)
            }
            .padding(.bottom, 32)
            
            Text("You're ready!")
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundColor(.coffeeTextPrimary)
                .padding(.bottom, 16)
            
            Text("Your profile is complete and\nwe've found activities near you.")
                .font(.system(size: 16))
                .foregroundColor(.coffeeTextSecondary)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
                .padding(.horizontal, 32)
                .padding(.bottom, 48)
            
            // Tip Card
            VStack(spacing: 12) {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.blue.opacity(0.1))
                    .frame(width: 48, height: 48)
                    .overlay(
                        Image(systemName: "cup.and.saucer")
                            .font(.system(size: 20))
                            .foregroundColor(.blue)
                    )
                    .padding(.bottom, 4)
                
                Text("First Activity Tip")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.coffeeTextPrimary)
                
                Text("Don't be shy! Most people on\nCoffeeCall are just as eager to meet\nsomeone new.")
                    .font(.system(size: 13))
                    .foregroundColor(.coffeeTextSecondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
            }
            .padding(32)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.04), radius: 20, x: 0, y: 10)
            )
            .padding(.horizontal, 32)
            
            Spacer()
            
            // CTA
            Button(action: {
                auth.completeOnboarding()
            }) {
                HStack {
                    Text("Start Exploring")
                    Image(systemName: "arrow.right")
                }
                .font(.buttonText)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color(red: 0.36, green: 0.71, blue: 0.64)) // Teal matching design
                .clipShape(Capsule())
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
        .background(Color.coffeeTextSecondary.opacity(0.02).edgesIgnoringSafeArea(.all)) // Very slight off-white
        .navigationBarHidden(true)
    }
}

struct ReadyScreen_Previews: PreviewProvider {
    static var previews: some View {
        ReadyScreen()
            .environmentObject(AuthViewModel())
    }
}
