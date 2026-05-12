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
        .background(Color.coffeePrimaryDark.opacity(0.92))
        .overlay(
            Capsule().stroke(Color.white.opacity(0.14), lineWidth: 1)
        )
        .clipShape(Capsule())
        .shadow(color: Color.coffeePrimary.opacity(0.16), radius: 10, x: 0, y: 5)
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
