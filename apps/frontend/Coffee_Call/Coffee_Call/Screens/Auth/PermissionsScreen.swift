import SwiftUI

struct PermissionsScreen: View {
    @State private var locationRequested = false
    @State private var notificationsRequested = false
    @State private var navigateToReady = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            
            Text("Almost there")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(.coffeeTextPrimary)
                .padding(.top, 40)
                .padding(.bottom, 12)
            
            Text("CoffeeCall works best when we can find\nactivities and keep you updated.")
                .font(.system(size: 16))
                .foregroundColor(.coffeeTextSecondary)
                .lineSpacing(4)
                .padding(.bottom, 40)
            
            // Location Card
            VStack(alignment: .leading, spacing: 16) {
                HStack(alignment: .top, spacing: 16) {
                    Circle()
                        .fill(Color.blue.opacity(0.1))
                        .frame(width: 40, height: 40)
                        .overlay(
                            Image(systemName: "location.fill")
                                .foregroundColor(.blue)
                        )
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Location Services")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.coffeeTextPrimary)
                        
                        Text("We use your location to show you spontaneous activities happening right around you.")
                            .font(.system(size: 13))
                            .foregroundColor(.coffeeTextSecondary)
                            .lineSpacing(2)
                    }
                }
                
                Button(action: {
                    // MVP: Just simulate permission request
                    locationRequested = true
                }) {
                    Text(locationRequested ? "Location Granted" : "Allow Location Access")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(locationRequested ? Color.coffeeSuccess : Color(red: 0.36, green: 0.71, blue: 0.64)) // Teal matching design
                        .clipShape(Capsule())
                }
                .disabled(locationRequested)
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color.coffeeTextSecondary.opacity(0.03))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .strokeBorder(Color.coffeeTextSecondary.opacity(0.1), lineWidth: 1)
                    )
            )
            .padding(.bottom, 24)
            
            // Notifications Card
            VStack(alignment: .leading, spacing: 16) {
                HStack(alignment: .top, spacing: 16) {
                    Circle()
                        .fill(Color.orange.opacity(0.1))
                        .frame(width: 40, height: 40)
                        .overlay(
                            Image(systemName: "bell.fill")
                                .foregroundColor(.orange)
                        )
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Real-time Updates")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.coffeeTextPrimary)
                        
                        Text("Get notified instantly when someone joins your activity or starts something nearby.")
                            .font(.system(size: 13))
                            .foregroundColor(.coffeeTextSecondary)
                            .lineSpacing(2)
                    }
                }
                
                Button(action: {
                    // MVP: Simulate permission request
                    notificationsRequested = true
                    
                    // Auto-navigate after second permission
                    if locationRequested {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            navigateToReady = true
                        }
                    }
                }) {
                    Text(notificationsRequested ? "Notifications Enabled" : "Enable Notifications")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(notificationsRequested ? Color.coffeeSuccess : Color(red: 0.36, green: 0.71, blue: 0.64))
                        .clipShape(Capsule())
                }
                .disabled(notificationsRequested)
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color.coffeeTextSecondary.opacity(0.03))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .strokeBorder(Color.coffeeTextSecondary.opacity(0.1), lineWidth: 1)
                    )
            )
            
            Spacer()
            
            // Manual Continue button if auto-navigate fails or they skip
            if locationRequested || notificationsRequested {
                NavigationLink(destination: ReadyScreen()) {
                    Text("Continue →")
                        .font(.buttonText)
                        .foregroundColor(.coffeePrimary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                }
            }
            
            HStack(spacing: 6) {
                Spacer()
                Image(systemName: "checkmark.shield")
                    .font(.system(size: 12))
                Text("YOUR PRIVACY IS OUR PRIORITY")
                    .font(.system(size: 10, weight: .bold))
                    .kerning(1.0)
                Spacer()
            }
            .foregroundColor(.coffeeTextSecondary.opacity(0.6))
            .padding(.bottom, 32)
        }
        .padding(.horizontal, 24)
        .background(Color.white.edgesIgnoringSafeArea(.all))
        .navigationBarHidden(true)
        .background(
            NavigationLink(
                destination: ReadyScreen(),
                isActive: $navigateToReady,
                label: { EmptyView() }
            )
        )
    }
}

struct PermissionsScreen_Previews: PreviewProvider {
    static var previews: some View {
        PermissionsScreen()
    }
}
