import SwiftUI

struct PillBadge: View {
    let title: String
    let systemImage: String
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: systemImage)
                .font(.system(size: 10, weight: .bold))
            Text(title)
                .font(.system(size: 10, weight: .bold))
        }
        .foregroundColor(.white)
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(.ultraThinMaterial)
        .background(Color.white.opacity(0.2))
        .clipShape(Capsule())
    }
}

struct PillBadge_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.coffeePrimaryDark.edgesIgnoringSafeArea(.all)
            PillBadge(title: "BETA", systemImage: "sparkles")
        }
    }
}
