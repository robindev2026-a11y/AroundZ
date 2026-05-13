import SwiftUI

struct PrimaryButton: View {
    let title: String
    let action: () -> Void
    var isDisabled: Bool = false
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.buttonText)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(isDisabled ? Color.textSecondary.opacity(0.35) : Color.brandPrimaryDark)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(Color.textOnBrand.opacity(isDisabled ? 0.08 : 0.12), lineWidth: 1)
                )
                .shadow(color: Color.brandPrimary.opacity(isDisabled ? 0.0 : 0.22), radius: 14, x: 0, y: 8)
        }
        .disabled(isDisabled)
    }
}

struct PrimaryButton_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            PrimaryButton(title: "Find Meetups Nearby", action: {})
            PrimaryButton(title: "Disabled", action: {}, isDisabled: true)
        }
        .padding()
        .background(Color.coffeeBackground)
    }
}
