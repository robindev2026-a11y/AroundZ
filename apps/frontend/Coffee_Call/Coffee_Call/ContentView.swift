import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationView {
            OnboardingScreen()
        }
        .navigationViewStyle(.stack)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
