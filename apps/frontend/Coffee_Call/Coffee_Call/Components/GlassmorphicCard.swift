import SwiftUI

struct GlassmorphicCard<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        content
            .padding()
            .background(.thinMaterial)
            .background(Color.white.opacity(0.15))
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
    }
}

struct GlassmorphicCard_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.coffeePrimary.edgesIgnoringSafeArea(.all)
            GlassmorphicCard {
                Text("Glassmorphism")
                    .foregroundColor(.white)
                    .padding()
            }
        }
    }
}
