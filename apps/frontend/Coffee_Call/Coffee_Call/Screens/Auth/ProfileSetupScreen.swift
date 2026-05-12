import SwiftUI

struct ProfileSetupScreen: View {
    @EnvironmentObject var auth: AuthViewModel
    @State private var firstName: String = ""
    @State private var navigateToPermissions = false
    @Environment(\.presentationMode) var presentationMode

    var isReady: Bool {
        !firstName.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Back Button
            Button(action: {
                presentationMode.wrappedValue.dismiss()
            }) {
                Circle()
                    .fill(Color.coffeeTextSecondary.opacity(0.05))
                    .frame(width: 40, height: 40)
                    .overlay(
                        Image(systemName: "arrow.left")
                            .foregroundColor(.coffeeTextPrimary)
                    )
            }
            .padding(.top, 20)
            .padding(.bottom, 24)

            Text("Create your profile")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(.coffeeTextPrimary)
                .padding(.bottom, 40)

            // Avatar Section
            VStack(spacing: 24) {
                ZStack(alignment: .bottomTrailing) {
                    RoundedRectangle(cornerRadius: 36, style: .continuous)
                        .strokeBorder(Color.coffeeTextSecondary.opacity(0.3), style: StrokeStyle(lineWidth: 1.5, dash: [6]))
                        .frame(width: 120, height: 120)
                        .background(
                            RoundedRectangle(cornerRadius: 36, style: .continuous)
                                .fill(Color.white)
                        )
                        .overlay(
                            Image(systemName: "camera")
                                .font(.system(size: 32))
                                .foregroundColor(.coffeeTextSecondary.opacity(0.5))
                        )

                    Circle()
                        .fill(Color.blue)
                        .frame(width: 32, height: 32)
                        .overlay(
                            Image(systemName: "camera.fill")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.white)
                        )
                        .offset(x: 4, y: 4)
                        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                }

                HStack(spacing: 16) {
                    Button(action: {}) {
                        Text("Take Photo")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.blue)
                            .padding(.vertical, 10)
                            .padding(.horizontal, 16)
                            .background(Color.blue.opacity(0.1))
                            .clipShape(Capsule())
                    }
                    
                    Button(action: {}) {
                        Text("Choose Library")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.blue)
                            .padding(.vertical, 10)
                            .padding(.horizontal, 16)
                            .background(Color.blue.opacity(0.1))
                            .clipShape(Capsule())
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.bottom, 40)

            // Name Input Section
            VStack(alignment: .leading, spacing: 8) {
                Text("DISPLAY NAME")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(.coffeeTextSecondary)
                    .kerning(1.2)

                TextField("What should we call you?", text: $firstName)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.coffeeTextPrimary)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .strokeBorder(Color.coffeeTextSecondary.opacity(0.1), lineWidth: 1)
                            .background(RoundedRectangle(cornerRadius: 12).fill(Color.coffeeTextSecondary.opacity(0.02)))
                    )

                Text("This is how your friends will see you on CoffeeCall.")
                    .font(.system(size: 12))
                    .foregroundColor(.coffeeTextSecondary)
                    .padding(.top, 4)
            }

            if let error = auth.errorMessage {
                Text(error)
                    .font(.system(size: 12))
                    .foregroundColor(.coffeeError)
                    .padding(.top, 8)
            }

            Spacer()

            // CTA
            Button(action: {
                auth.saveProfile(name: firstName) { success in
                    if success {
                        navigateToPermissions = true
                    }
                }
            }) {
                HStack(spacing: 12) {
                    if auth.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(0.9)
                    }
                    Text(auth.isLoading ? "Saving..." : "Complete Profile")
                        .font(.buttonText)
                        .foregroundColor(.white)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(isReady ? Color(red: 0.58, green: 0.81, blue: 0.76) : Color.coffeeTextSecondary.opacity(0.3)) // Teal color matching design
                .clipShape(Capsule())
            }
            .disabled(!isReady || auth.isLoading)
            .padding(.bottom, 8)

            #if DEBUG
            Button(action: { navigateToPermissions = true }) {
                Text("⚡ Skip Profile (Debug)")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.coffeeTextSecondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.bottom, 32)
            #endif
        }
        .padding(.horizontal, 24)
        .background(Color.white.edgesIgnoringSafeArea(.all)) // Clean white background for this screen
        .navigationBarHidden(true)
        .background(
            NavigationLink(
                destination: PermissionsScreen(),
                isActive: $navigateToPermissions,
                label: { EmptyView() }
            )
        )
    }
}

struct ProfileSetupScreen_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ProfileSetupScreen()
                .environmentObject(AuthViewModel())
        }
    }
}
