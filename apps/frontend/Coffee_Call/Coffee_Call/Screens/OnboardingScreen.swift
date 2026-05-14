import SwiftUI

// MARK: - Reusable Unsplash background
private struct UnsplashBackground: View {
    let url: String
    
    var body: some View {
        ZStack {
            CoffeeImageView(urlString: url)
                .ignoresSafeArea()
            
            // Subtle darken overlay for consistency with Figma
            Color.black.opacity(0.1)
                .ignoresSafeArea()
        }
    }
}

struct OnboardingScreen: View {
    @State private var currentPage = 0
    @State private var navigateToAuth = false
    
    var body: some View {
        ZStack {
            currentBackground

            TabView(selection: $currentPage) {
                Slide1View(currentPage: $currentPage)
                    .tag(0)
                Slide2View(currentPage: $currentPage)
                    .tag(1)
                Slide3View(currentPage: $currentPage)
                    .tag(2)
                Slide4View(currentPage: $currentPage)
                    .tag(3)
                Slide5View(currentPage: $currentPage, navigateToAuth: $navigateToAuth)
                    .tag(4)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
        }
        .navigationDestination(isPresented: $navigateToAuth) {
            PhoneAuthScreen()
        }
    }

    @ViewBuilder
    private var currentBackground: some View {
        switch currentPage {
        case 0:
            ZStack {
                UnsplashBackground(url: AppImages.Onboarding.heroURL)
                LinearGradient(
                    colors: [Color.darkOverlay.opacity(0.9), Color.darkOverlay.opacity(0.4), Color.clear],
                    startPoint: .top,
                    endPoint: .bottom
                )
            }
            .ignoresSafeArea()

        case 4:
            ZStack {
                UnsplashBackground(url: AppImages.Onboarding.readyURL)
                LinearGradient(
                    stops: [
                        .init(color: Color.black.opacity(0.05), location: 0),
                        .init(color: Color.black.opacity(0.25), location: 0.4),
                        .init(color: Color.black.opacity(0.78), location: 1.0)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            }
            .ignoresSafeArea()

        default:
            Color.backgroundMain
                .ignoresSafeArea()
        }
    }
}

// MARK: - Slide 1 (Landing)
struct Slide1View: View {
    @Binding var currentPage: Int
    @State private var animate = false
    
    var body: some View {
        ZStack {
            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    Spacer()
                    BetaBadge(title: AppStrings.betaTag, systemImage: AppIcons.sparkles)
                    Spacer()
                }
                .padding(.top, 96)
                
                Spacer()
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(AppStrings.Onboarding.slide1Title1)
                        .font(.system(size: 40, weight: .black, design: .default))
                        .foregroundColor(.white)
                        .lineSpacing(4)
                    Text(AppStrings.Onboarding.slide1Title2)
                        .font(.system(size: 40, weight: .black, design: .default))
                        .foregroundColor(.white)
                        .lineSpacing(4)
                    Text(AppStrings.Onboarding.slide1Title3)
                        .font(.system(size: 40, weight: .black, design: .default))
                        .foregroundColor(Color.brandPrimary)
                        .lineSpacing(4)
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 48)
                .opacity(animate ? 1 : 0)
                .offset(y: animate ? 0 : 30)
                .animation(.easeOut(duration: 0.6).delay(0.2), value: animate)
                
                VStack(spacing: 16) {
                    HStack {
                        GlassmorphicCard {
                            HStack(spacing: 16) {
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.brandPrimary)
                                    .frame(width: 40, height: 40)
                                    .overlay(
                                        Text("🌅")
                                            .font(.system(size: 24))
                                    )
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(AppStrings.Onboarding.nowNearby)
                                        .font(.system(size: 10, weight: .black))
                                        .foregroundColor(.white.opacity(0.6))
                                    Text(AppStrings.Onboarding.activity1Title)
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(.white)
                                }
                                Spacer()
                            }
                        }
                        .rotationEffect(.degrees(-2))
                        .opacity(animate ? 1 : 0)
                        .offset(x: animate ? 0 : -30)
                        .animation(.easeOut(duration: 0.6).delay(0.4), value: animate)
                        Spacer(minLength: 40)
                    }
                    
                    HStack {
                        Spacer(minLength: 40)
                        GlassmorphicCard {
                            HStack(spacing: 16) {
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.brandPurple)
                                    .frame(width: 40, height: 40)
                                    .overlay(
                                        Text("📸")
                                            .font(.system(size: 24))
                                    )
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(String(format: AppStrings.Onboarding.peopleJoined, 12))
                                        .font(.system(size: 10, weight: .black))
                                        .foregroundColor(.white.opacity(0.6))
                                    Text(AppStrings.Onboarding.activity2Title)
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(.white)
                                }
                                Spacer()
                            }
                        }
                        .rotationEffect(.degrees(2))
                        .opacity(animate ? 1 : 0)
                        .offset(x: animate ? 0 : 30)
                        .animation(.easeOut(duration: 0.6).delay(0.5), value: animate)
                    }
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 48)
                
                PrimaryButton(title: AppStrings.Onboarding.slide1CTA, height: 64, cornerRadius: 16, icon: AppIcons.arrowRight) {
                    withAnimation {
                        currentPage = 1
                    }
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 64)
                .opacity(animate ? 1 : 0)
                .animation(.easeOut(duration: 0.6).delay(0.6), value: animate)
            }
        }
        .onAppear {
            animate = true
        }
    }
}

// MARK: - Slide 2 (Discovery)
struct Slide2View: View {
    @Binding var currentPage: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            OnboardingProgressBar(activeIndex: 0, total: 4) // total is 4 onboarding screens + intro
                .padding(.top, 60)
                .padding(.horizontal, 24)
            
            VStack(alignment: .leading, spacing: 16) {
                Circle()
                    .fill(Color.white)
                    .frame(width: 48, height: 48)
                    .overlay(Image(systemName: AppIcons.bolt).foregroundColor(.brandPrimary).font(.system(size: 24)))
                    .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                    .padding(.bottom, 8)
                
                Text(AppStrings.Onboarding.slide2Title)
                    .font(.system(size: 32, weight: .black, design: .default))
                    .foregroundColor(.textPrimary)
                
                Text(AppStrings.Onboarding.slide2Subtitle)
                    .font(.body)
                    .foregroundColor(.textSecondary)
                    .lineSpacing(4)
            }
            .padding(.top, 40)
            .padding(.horizontal, 24)
            
            Spacer()
            
            // Grid of activity chips
            VStack(spacing: 16) {
                HStack(spacing: 16) {
                    ActivityChip(icon: AppIcons.coffee, title: "COFFEE CHAT", activeCount: 4)
                    ActivityChip(icon: "figure.walk", title: "URBAN WALK", activeCount: 7)
                }
                HStack(spacing: 16) {
                    ActivityChip(icon: "gamecontroller.fill", title: "GAME NIGHT", activeCount: 12)
                    ActivityChip(icon: "paintpalette.fill", title: "ART JAM", activeCount: 3)
                }
            }
            .padding(.horizontal, 24)
            
            Spacer()
            
            PrimaryButton(title: AppStrings.Onboarding.slide2CTA) {
                withAnimation {
                    currentPage = 2
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
        .background(Color.backgroundMain.ignoresSafeArea())
    }
}

// MARK: - Slide 3 (Safety)
struct Slide3View: View {
    @Binding var currentPage: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            OnboardingProgressBar(activeIndex: 1, total: 4)
                .padding(.top, 60)
                .padding(.horizontal, 24)
            
            VStack(alignment: .center, spacing: 16) {
                Circle()
                    .fill(Color.white)
                    .frame(width: 64, height: 64)
                    .overlay(Image(systemName: AppIcons.shield).foregroundColor(.brandPrimary).font(.system(size: 32)))
                    .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                    .padding(.bottom, 8)
                
                Text(AppStrings.Onboarding.slide3Title)
                    .font(.system(size: 32, weight: .black, design: .default))
                    .foregroundColor(.textPrimary)
                    .multilineTextAlignment(.center)
                
                Text(AppStrings.Onboarding.slide3Subtitle)
                    .font(.body)
                    .foregroundColor(.textSecondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
            }
            .padding(.top, 40)
            .padding(.horizontal, 24)
            .frame(maxWidth: .infinity)
            
            Spacer()
            
            VStack(spacing: 16) {
                SafetyFeatureRow(icon: AppIcons.privacyShield, text: AppStrings.Onboarding.safetyFeature1)
                SafetyFeatureRow(icon: "person.2", text: AppStrings.Onboarding.safetyFeature2)
                SafetyFeatureRow(icon: "heart.text.square", text: AppStrings.Onboarding.safetyFeature3)
            }
            .padding(.horizontal, 24)
            
            Spacer()
            
            PrimaryButton(title: AppStrings.Onboarding.slide3CTA) {
                withAnimation {
                    currentPage = 3
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
        .background(Color.backgroundMain.ignoresSafeArea())
    }
}

// MARK: - Slide 4 (Interests)
struct Slide4View: View {
    @Binding var currentPage: Int
    @State private var selectedInterests: Set<String> = []
    
    let interests = ["Creative", "Walks", "Gaming", "Study", "Food", "Startup", "Music", "Coffee"]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            OnboardingProgressBar(activeIndex: 2, total: 4)
                .padding(.top, 60)
                .padding(.horizontal, 24)
            
            VStack(alignment: .leading, spacing: 16) {
                Text(AppStrings.Onboarding.slide4Title)
                    .font(.system(size: 32, weight: .black, design: .default))
                    .foregroundColor(.textPrimary)
                
                Text(AppStrings.Onboarding.slide4Subtitle)
                    .font(.body)
                    .foregroundColor(.textSecondary)
            }
            .padding(.top, 40)
            .padding(.horizontal, 24)
            
            Spacer()
            
            ScrollView {
                VStack(spacing: 16) {
                    HStack(spacing: 16) {
                        InterestPill(title: "Creative", isSelected: selectedInterests.contains("Creative")) { toggle("Creative") }
                        InterestPill(title: "Walks", isSelected: selectedInterests.contains("Walks")) { toggle("Walks") }
                    }
                    HStack(spacing: 16) {
                        InterestPill(title: "Gaming", isSelected: selectedInterests.contains("Gaming")) { toggle("Gaming") }
                        InterestPill(title: "Study", isSelected: selectedInterests.contains("Study")) { toggle("Study") }
                    }
                    HStack(spacing: 16) {
                        InterestPill(title: "Food", isSelected: selectedInterests.contains("Food")) { toggle("Food") }
                        InterestPill(title: "Startup", isSelected: selectedInterests.contains("Startup")) { toggle("Startup") }
                    }
                    HStack(spacing: 16) {
                        InterestPill(title: "Music", isSelected: selectedInterests.contains("Music")) { toggle("Music") }
                        InterestPill(title: "Coffee", isSelected: selectedInterests.contains("Coffee")) { toggle("Coffee") }
                    }
                }
                .padding(.horizontal, 24)
            }
            
            Spacer()
            
            let remaining = max(0, 3 - selectedInterests.count)
            let isReady = remaining == 0
            
            Button(action: { 
                withAnimation {
                    currentPage = 4 
                }
            }) {
                Text(isReady ? AppStrings.Onboarding.readyToGo : String(format: AppStrings.Onboarding.selectMore, remaining))
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(isReady ? .white : .textSecondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(isReady ? Color.brandPrimary : Color.textSecondary.opacity(0.2))
                    .clipShape(Capsule())
            }
            .disabled(!isReady)
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
        .background(Color.backgroundMain.ignoresSafeArea())
    }
    
    private func toggle(_ interest: String) {
        if selectedInterests.contains(interest) {
            selectedInterests.remove(interest)
        } else {
            selectedInterests.insert(interest)
        }
    }
}

// MARK: - Slide 5 (Start Exploring)
struct Slide5View: View {
    @Binding var currentPage: Int
    @Binding var navigateToAuth: Bool
    
    var body: some View {
        ZStack {
            VStack(alignment: .center, spacing: 0) {
                Spacer()
                
                // Icon
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(Color.brandPrimary)
                    .frame(width: 88, height: 88)
                    .overlay(
                        Text("🎉")
                            .font(.system(size: 40))
                    )
                    .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
                    .padding(.bottom, 32)
                
                // Headings
                Text(AppStrings.Onboarding.slide5Title)
                    .font(.system(size: 32, weight: .black, design: .default))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 16)
                    .shadow(color: Color.black.opacity(0.4), radius: 4, x: 0, y: 2)
                
                Text(AppStrings.Onboarding.slide5Subtitle)
                    .font(.body)
                    .foregroundColor(.white.opacity(0.85))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                    .padding(.bottom, 32)
                
                // Avatars with CoffeeImageView
                HStack(spacing: -12) {
                    ForEach(AppImages.Onboarding.avatars, id: \.self) { avatarUrl in
                        CoffeeImageView(urlString: avatarUrl)
                            .frame(width: 44, height: 44)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.white, lineWidth: 2))
                    }
                    Circle()
                        .fill(Color.brandPurple.opacity(0.8))
                        .frame(width: 44, height: 44)
                        .overlay(
                            Text(AppStrings.Onboarding.socialProofCount)
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(.white)
                        )
                        .overlay(Circle().stroke(Color.white, lineWidth: 2))
                }
                .padding(.bottom, 16)
                
                Text(AppStrings.Onboarding.communityJoinNote)
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.white.opacity(0.8) )
                    .kerning(1.2)
                
                Spacer()
                
                // Button
                PrimaryButton(title: AppStrings.Onboarding.slide5CTA) {
                    navigateToAuth = true
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 16)
                
                Text(AppStrings.Onboarding.joinFreeNote)
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.white.opacity(0.55))
                    .kerning(1.0)
                    .padding(.bottom, 40)
            }
        }
    }
}

// MARK: - Subcomponents

struct OnboardingProgressBar: View {
    let activeIndex: Int
    let total: Int
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<total, id: \.self) { index in
                Rectangle()
                    .fill(index <= activeIndex ? Color.brandPrimary : Color.textSecondary.opacity(0.2))
                    .frame(height: 4)
                    .cornerRadius(2)
            }
        }
    }
}

struct ActivityChip: View {
    let icon: String
    let title: String
    let activeCount: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(.textPrimary)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.textPrimary)
                
                HStack(spacing: 4) {
                    Circle()
                        .fill(Color.statusSuccess)
                        .frame(width: 6, height: 6)
                    Text(String(format: AppStrings.Onboarding.activeCount, activeCount))
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.statusSuccess)
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(Color.surfaceMain)
                .overlay(
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .stroke(Color.appBorder, lineWidth: 1)
                )
        )
        .shadow(color: Color.textPrimary.opacity(0.04), radius: 12, x: 0, y: 4)
    }
}

struct SafetyFeatureRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .foregroundColor(.brandPrimary)
                .font(.system(size: 20))
                .frame(width: 24)
            
            Text(text)
                .font(.body)
                .fontWeight(.medium)
                .foregroundColor(.textPrimary)
            
            Spacer()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.surfaceMain)
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(Color.appBorder, lineWidth: 1)
                )
        )
        .shadow(color: Color.textPrimary.opacity(0.04), radius: 12, x: 0, y: 4)
    }
}

struct InterestPill: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.body)
                .fontWeight(.medium)
                .foregroundColor(isSelected ? .white : .textPrimary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(isSelected ? Color.brandPrimary : Color.surfaceMain)
                .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 30, style: .continuous)
                        .stroke(isSelected ? Color.clear : Color.appBorder, lineWidth: 1)
                )
                .shadow(color: Color.textPrimary.opacity(0.04), radius: 12, x: 0, y: 4)
        }
    }
}

// MARK: - Previews
struct OnboardingScreen_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingScreen()
    }
}
