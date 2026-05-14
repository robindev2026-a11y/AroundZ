import SwiftUI

struct PrimaryButton: View {
    let title: String
    var height: CGFloat = 56
    var cornerRadius: CGFloat = 16
    var icon: String? = nil
    var isDisabled: Bool = false
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Text(title)
                    .font(.buttonText)
                
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .bold))
                }
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: height)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(isDisabled ? Color.textSecondary.opacity(0.24) : Color.brandPrimary)
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(Color.textOnBrand.opacity(isDisabled ? 0.08 : 0.12), lineWidth: 1)
            )
            .contentShape(Rectangle()) // Fix for tap area
            .shadow(color: Color.brandPrimary.opacity(isDisabled ? 0.0 : 0.22), radius: 14, x: 0, y: 8)
        }
        .disabled(isDisabled)
    }
}

struct PrimaryButton_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            PrimaryButton(title: "Find Meetups Nearby", action: {})
            PrimaryButton(title: "Disabled", isDisabled: true, action: {})
        }
        .padding()
        .background(Color.backgroundMain)
    }
}
