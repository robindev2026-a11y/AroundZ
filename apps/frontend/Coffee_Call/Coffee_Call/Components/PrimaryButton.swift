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
                .background(isDisabled ? Color.coffeeTextSecondary.opacity(0.5) : Color.coffeePrimary)
                .clipShape(Capsule())
        }
        .disabled(isDisabled)
    }
}

struct PrimaryButton_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            PrimaryButton(title: "Let's Go", action: {})
            PrimaryButton(title: "Disabled", action: {}, isDisabled: true)
        }
        .padding()
        .background(Color.coffeeBackground)
    }
}
