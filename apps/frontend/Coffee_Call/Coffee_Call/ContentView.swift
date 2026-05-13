import SwiftUI

struct ContentView: View {
    @StateObject private var auth = AuthViewModel()

    var body: some View {
        Group {
            if auth.isAuthenticated {
                // TODO: Replace with HomeScreen when built
                Text("Welcome! You're signed in.")
                    .font(.heading1)
                    .foregroundColor(.textPrimary)
            } else {
                NavigationView {
                    OnboardingScreen()
                }
                .navigationViewStyle(.stack)
            }
        }
        .environmentObject(auth)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
