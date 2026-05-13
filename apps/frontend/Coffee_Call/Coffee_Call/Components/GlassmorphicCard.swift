import SwiftUI

struct GlassmorphicCard<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        content
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(Color.surfaceMain.opacity(0.94))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .stroke(Color.appBorder.opacity(0.95), lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.05), radius: 16, x: 0, y: 10)
    }
}

struct GlassmorphicCard_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.coffeeBackground.edgesIgnoringSafeArea(.all)
            GlassmorphicCard {
                Text("Glassmorphism")
                    .foregroundColor(.coffeeTextPrimary)
                    .padding()
            }
        }
    }
}
