import SwiftUI

struct LocationPermissionScreen: View {
    var body: some View {
        VStack(alignment: .center, spacing: 24) {
            Spacer()
            
            Circle()
                .fill(Color.white)
                .frame(width: 80, height: 80)
                .overlay(
                    Image(systemName: "location.fill")
                        .foregroundColor(.coffeePrimary)
                        .font(.system(size: 32))
                )
                .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
            
            Text("Enable Location")
                .font(.heading1)
                .foregroundColor(.coffeeTextPrimary)
                .multilineTextAlignment(.center)
            
            Text("CoffeeCall uses your location to match you with nearby people and activities within a 10km radius.")
                .font(.bodyStandard)
                .foregroundColor(.coffeeTextSecondary)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
                .padding(.horizontal, 16)
            
            Spacer()
            
            VStack(spacing: 16) {
                PrimaryButton(title: "Allow Location") {
                    print("Requesting Location Permissions")
                }
                
                Button(action: {
                    print("Skipping Location")
                }) {
                    Text("Skip for now")
                        .font(.buttonText)
                        .foregroundColor(.coffeeTextSecondary)
                }
                .padding(.vertical, 8)
            }
            .padding(.bottom, 40)
        }
        .padding(.horizontal, 24)
        .background(Color.coffeeSurface.edgesIgnoringSafeArea(.all))
        .navigationBarHidden(true)
    }
}

struct LocationPermissionScreen_Previews: PreviewProvider {
    static var previews: some View {
        LocationPermissionScreen()
    }
}
