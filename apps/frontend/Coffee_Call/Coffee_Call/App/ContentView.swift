import SwiftUI

struct ContentView: View {
    @StateObject private var auth = AuthViewModel()

    var body: some View {
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
        .environmentObject(auth)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(AuthViewModel())
    }
}
