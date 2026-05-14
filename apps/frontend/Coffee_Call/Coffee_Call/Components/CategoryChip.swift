import SwiftUI

struct CategoryChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(isSelected ? .textOnBrand : .textPrimary)
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(isSelected ? Color.brandPrimary : Color.surfaceMain)
                .clipShape(Capsule())
                .overlay(
                    Capsule()
                        .stroke(isSelected ? Color.clear : Color.appBorder, lineWidth: 1)
                )
                .shadow(color: Color.brandPrimary.opacity(isSelected ? 0.22 : 0), radius: 12, x: 0, y: 4)
        }
    }
}
