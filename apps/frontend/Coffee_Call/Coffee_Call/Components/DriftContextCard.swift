import SwiftUI

/// A high-fidelity card that provides ambient context for the Discovery/Around screen.
/// Designed for the Social Refresh: glassmorphic, warm surfaces, and mint accents.
struct DriftContextCard: View {
    let title: String
    let subtitle: String
    let actionLabel: String
    let action: () -> Void
    
    var body: some View {
        HStack(spacing: 14) {
            // 1. Context Icon (Soft Circle)
            ZStack {
                Circle()
                    .fill(Color.brandPrimary.opacity(0.12))
                    .frame(width: 44, height: 44)
                
                Image(systemName: AppIcons.participants)
                    .foregroundColor(.brandPrimary)
                    .font(.system(size: 18, weight: .semibold))
            }
            
            // 2. Textual Context
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 13, weight: .black))
                    .foregroundColor(.textPrimary)
                    .textCase(.uppercase)
                
                Text(subtitle)
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(.textSecondary.opacity(0.6))
                    .lineLimit(1)
            }
            
            Spacer()
            
            // 3. Conversion Action (See Nearby)
            Button(action: action) {
                HStack(spacing: 4) {
                    Text(actionLabel)
                        .font(.system(size: 11, weight: .black))
                    
                    Image(systemName: AppIcons.chevronRight)
                        .font(.system(size: 10, weight: .black))
                }
                .foregroundColor(.brandPrimary)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color.brandPrimary.opacity(0.08))
                .clipShape(Capsule())
            }
            .pressScale(0.92)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 12)
        .background(
            ZStack {
                Color.surfaceMain
                
                // Subtle glassmorphic inner stroke
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .stroke(Color.white.opacity(0.6), lineWidth: 1)
            }
        )
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .shadow(color: Color.textPrimary.opacity(0.04), radius: 10, x: 0, y: 5)
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(Color.appBorder.opacity(0.3), lineWidth: 0.5)
        )
    }
}

// MARK: - Preview
struct DriftContextCard_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.backgroundMain.ignoresSafeArea()
            DriftContextCard(
                title: "Around you",
                subtitle: "5 people are looking for company",
                actionLabel: "SEE NEARBY",
                action: {}
            )
            .padding()
        }
    }
}
