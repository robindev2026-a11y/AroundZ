import SwiftUI

struct ProfileSetupScreen: View {
    @State private var firstName: String = ""
    
    var isReady: Bool {
        return !firstName.trimmingCharacters(in: .whitespaces).isEmpty
    }
    
    var body: some View {
        VStack(alignment: .center, spacing: 32) {
            Text("Set up your profile")
                .font(.heading1)
                .foregroundColor(.coffeeTextPrimary)
                .padding(.top, 60)
            
            // Photo Upload Placeholder
            ZStack(alignment: .bottomTrailing) {
                Circle()
                    .fill(Color.coffeeTextSecondary.opacity(0.1))
                    .frame(width: 120, height: 120)
                    .overlay(
                        Image(systemName: "person.crop.circle.fill")
                            .font(.system(size: 120))
                            .foregroundColor(.coffeeTextSecondary.opacity(0.3))
                    )
                
                Circle()
                    .fill(Color.coffeePrimary)
                    .frame(width: 36, height: 36)
                    .overlay(
                        Image(systemName: "camera.fill")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                    )
                    .offset(x: -8, y: -8)
            }
            .padding(.vertical, 24)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("FIRST NAME")
                    .font(.captionText)
                    .foregroundColor(.coffeeTextSecondary)
                
                TextField("e.g. Alex", text: $firstName)
                    .font(.heading1)
                    .foregroundColor(.coffeeTextPrimary)
                
                Divider()
                    .background(Color.coffeeTextSecondary.opacity(0.3))
            }
            
            Spacer()
            
            NavigationLink(destination: LocationPermissionScreen()) {
                Text("Continue →")
                    .font(.buttonText)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(isReady ? Color.coffeePrimary : Color.coffeeTextSecondary.opacity(0.5))
                    .clipShape(Capsule())
            }
            .disabled(!isReady)
            .padding(.bottom, 40)
        }
        .padding(.horizontal, 24)
        .background(Color.coffeeSurface.edgesIgnoringSafeArea(.all))
        .navigationBarHidden(true)
    }
}

struct ProfileSetupScreen_Previews: PreviewProvider {
    static var previews: some View {
        ProfileSetupScreen()
    }
}
