import SwiftUI

struct ContentView: View {
    @StateObject private var auth = AuthViewModel()
    @EnvironmentObject private var networkManager: NetworkManager

    var body: some View {
        VStack(spacing: 0) {
            if !networkManager.isConnected {
                HStack(spacing: 8) {
                    Image(systemName: "wifi.slash")
                        .font(.subheadline)
                    Text("No Network")
                        .font(.footnote)
                        .fontWeight(.semibold)
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .background(Color.red)
                .transition(.move(edge: .top).combined(with: .opacity))
            }
            
            Group {
                if auth.isAuthenticated {
                    MainTabView()
                } else if auth.isFirstLaunch {
                    // Very first time on this device — show the full onboarding slides.
                    NavigationStack {
                        OnboardingScreen()
                    }
                } else {
                    // Returning user who signed out — go straight to phone login.
                    NavigationStack {
                        PhoneAuthScreen()
                    }
                }
            }
        }
        .environmentObject(auth)
        .animation(.easeInOut, value: networkManager.isConnected)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(AuthViewModel())
            .environmentObject(NetworkManager.shared)
    }
}
