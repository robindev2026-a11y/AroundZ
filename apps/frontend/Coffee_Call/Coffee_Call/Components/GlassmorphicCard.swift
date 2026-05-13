import SwiftUI

struct GlassmorphicCard<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        content
            .padding(16)
            .background(
                ZStack {
                    // Frosted glass: white with 15% opacity + material blur
                    Color.white.opacity(0.15)
                    Rectangle().fill(.ultraThinMaterial)
                }
                .cornerRadius(12)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(Color.white.opacity(0.2), lineWidth: 1)
            )
            // No shadow per design
    }
}

struct GlassmorphicCard_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.backgroundMain.edgesIgnoringSafeArea(.all)
            GlassmorphicCard {
                Text("Glassmorphism")
                    .foregroundColor(.textPrimary)
                    .padding()
            }
        }
    }
}
