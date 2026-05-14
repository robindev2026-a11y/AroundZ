import SwiftUI

// MARK: - Category Chip
// Matches the Figma filter chip: icon + label, pill shape,
// active = mint fill + shadow + scale-up, inactive = white surface + border.

struct CategoryChip: View {
    let title: String
    let isSelected: Bool
    var icon: String? = nil       // SF symbol name
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 13, weight: .semibold))
                }
                Text(title)
                    .font(.system(size: 14, weight: .bold, design: .default))
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
