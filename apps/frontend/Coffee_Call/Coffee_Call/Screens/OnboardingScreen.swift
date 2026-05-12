import SwiftUI

struct OnboardingScreen: View {
    var body: some View {
        ZStack {
            // Background Image Placeholder
            LinearGradient(
                colors: [Color.coffeeTextPrimary, Color.coffeeTextSecondary],
                startPoint: .top,
                endPoint: .bottom
            )
            .edgesIgnoringSafeArea(.all)
            
            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    Spacer()
                    PillBadge(title: "COFFEECALL BETA", systemImage: "sparkles")
                    Spacer()
                }
                .padding(.top, 20)
                
                Spacer()
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Meet people")
                        .font(.heading1)
                        .foregroundColor(.white)
                    Text("nearby in")
                        .font(.heading1)
                        .foregroundColor(.white)
                    Text("real life.")
                        .font(.heading1)
                        .foregroundColor(.coffeePrimary)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 32)
                
                VStack(spacing: 16) {
                    HStack {
                        GlassmorphicCard {
                            HStack(spacing: 16) {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.orange.opacity(0.8))
                                    .frame(width: 40, height: 40)
                                    .overlay(Image(systemName: "sun.max.fill").foregroundColor(.white))
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("NOW NEARBY")
                                        .font(.captionText)
                                        .foregroundColor(.white.opacity(0.8))
                                    Text("Sunset Walk + Convo")
                                        .font(.bodySmall)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.white)
                                }
                                Spacer()
                            }
                        }
                        Spacer(minLength: 40)
                    }
                    
                    HStack {
                        Spacer(minLength: 40)
                        GlassmorphicCard {
                            HStack(spacing: 16) {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.purple.opacity(0.8))
                                    .frame(width: 40, height: 40)
                                    .overlay(Image(systemName: "camera.fill").foregroundColor(.white))
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("12 PEOPLE JOINED")
                                        .font(.captionText)
                                        .foregroundColor(.white.opacity(0.8))
                                    Text("Photo Session at Park")
                                        .font(.bodySmall)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.white)
                                }
                                Spacer()
                            }
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 48)
                
                PrimaryButton(title: "Let's Go") {
                    print("Transition to Auth Flow")
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 32)
            }
        }
    }
}

struct OnboardingScreen_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingScreen()
    }
}
