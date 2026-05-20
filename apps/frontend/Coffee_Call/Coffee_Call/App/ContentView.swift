import SwiftUI

struct ContentView: View {
    @StateObject private var auth = AuthViewModel()

    var body: some View {
        NavigationStack {
            OnboardingScreen()
                .environmentObject(auth)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
