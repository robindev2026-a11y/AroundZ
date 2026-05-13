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
                .cornerRadius(20)
                .shadow(color: Color.black.opacity(isSelected ? 0.1 : 0.02), radius: 5, x: 0, y: 2)
        }
    }
}
