import SwiftUI

struct BetaBadge: View {
    let title: String
    let systemImage: String
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: systemImage)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.brandPrimary)
            Text(title)
                .font(.system(size: 10, weight: .black))
                .foregroundColor(.white)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            ZStack {
                // Glass background: white with low opacity
                Color.white.opacity(0.1)
                // Blur effect via ultra-thin material
                Rectangle().fill(.ultraThinMaterial)
            }
            .cornerRadius(999)
        )
        .overlay(
            Capsule()
                .strokeBorder(Color.white.opacity(0.2), lineWidth: 1)
        )
    }
}

struct BetaBadge_Previews: PreviewProvider {
    static var previews: some View {
        BetaBadge(title: "COFFEECALL BETA", systemImage: "sparkles")
            .previewLayout(.sizeThatFits)
    }
}
