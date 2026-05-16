import SwiftUI

struct InterestCard: View {
    let title: String
    let icon: String
    let count: Int
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            // Icon Well (Circular per spec)
            ZStack {
                Circle()
                    .fill(color.opacity(0.12))
                    .frame(width: 44, height: 44)
                
                Image(systemName: icon)
                    .font(.system(size: 22))
                    .foregroundColor(color)
            }
            
            VStack(spacing: 1) {
                Text(title)
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(.textPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                
                Text("\(count) nearby")
                    .font(.system(size: 9, weight: .bold))
                    .foregroundColor(.textSecondary.opacity(0.7))
            }
        }
        .frame(width: 79, height: 112) // Exact size target from DESIGN.md
        .background(Color.surfaceMain)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous)) // 22pt per spec
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(Color.appBorder.opacity(0.3), lineWidth: 0.5)
        )
        .shadow(color: Color.black.opacity(0.03), radius: 5, x: 0, y: 2)
    }
}
