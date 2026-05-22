import SwiftUI

// MARK: - Category Chip
// Matches the Figma filter chip: icon + label, pill shape,
// active = mint fill + shadow + scale-up, inactive = white surface + border.

struct CategoryChip: View {
    let title: String
    let isSelected: Bool
    var icon: String? = nil
    var count: Int? = nil
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 13, weight: .semibold))
                }
                
                HStack(spacing: 4) {
                    Text(title)
                        .font(.system(size: 14, weight: .bold, design: .default))
                    
                    if let count = count {
                        Text("\(count)")
                            .font(.system(size: 10, weight: .black))
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(isSelected ? Color.white.opacity(0.2) : Color.brandPrimary.opacity(0.1))
                            .clipShape(Capsule())
                    }
                }
            }
            .foregroundColor(isSelected ? .textOnBrand : .textPrimary)
            .padding(.horizontal, 18)
            .padding(.vertical, 10)
            .background(isSelected ? Color.brandPrimary : Color.surfaceMain)
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .stroke(isSelected ? Color.clear : Color.appBorder, lineWidth: 1)
            )
            .shadow(
                color: Color.brandPrimary.opacity(isSelected ? 0.28 : 0),
                radius: 10, x: 0, y: 4
            )
            .scaleEffect(isSelected ? 1.05 : 1.0)
            .animation(CoffeeAnimation.spring, value: isSelected)
        }
        .pressScale(0.92)
    }
}
