import SwiftUI

// MARK: - Reusable Unsplash background
private struct UnsplashBackground: View {
    let url: String
    var body: some View {
        GeometryReader { geo in
            AsyncImage(url: URL(string: url)) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(
                            width: geo.size.width,
                            height: geo.size.height + geo.safeAreaInsets.top + geo.safeAreaInsets.bottom
                        )
                        .clipped()
                case .failure, .empty:
                    LinearGradient(
                        colors: [Color.textPrimary, Color.textSecondary],
                        startPoint: .top, endPoint: .bottom
                    )
                    .frame(
                        width: geo.size.width,
                        height: geo.size.height + geo.safeAreaInsets.top + geo.safeAreaInsets.bottom
                    )
                @unknown default:
                    Color.textPrimary
                }
            }
            .offset(y: -geo.safeAreaInsets.top)
        }
        .ignoresSafeArea()
    }
}

struct OnboardingScreen: View {
    @State private var currentPage = 0
    
    var body: some View {
        TabView(selection: $currentPage) {
            Slide1View(currentPage: $currentPage)
                .tag(0)
            Slide2View(currentPage: $currentPage)
                .tag(1)
            Slide3View(currentPage: $currentPage)
                .tag(2)
            Slide4View(currentPage: $currentPage)
                .tag(3)
            Slide5View(currentPage: $currentPage)
                .tag(4)
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
        .edgesIgnoringSafeArea(.all)
    }
}

// MARK: - Slide 1 (Landing)
struct Slide1View: View {
    @Binding var currentPage: Int
    
    var body: some View {
        ZStack {
            // Unsplash: exact image from Figma onboarding hero screen
            UnsplashBackground(url: AppImages.Onboarding.heroURL)
            
            // Overlay so text is always readable
            LinearGradient(
                colors: [Color.black.opacity(0.2), Color.black.opacity(0.65)],
                startPoint: .top,
                endPoint: .bottom
            )
            .edgesIgnoringSafeArea(.all)
            
            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    Spacer()
                    PillBadge(title: AppStrings.betaTag, systemImage: AppIcons.sparkles)
                    Spacer()
                }
                .padding(.top, 60)
                
                Spacer()
                
                VStack(alignment: .leading, spacing: 8) {
                    Text(AppStrings.Onboarding.slide1Title1)
                        .font(.heading1)
                        .foregroundColor(.textOnBrand)
                    Text(AppStrings.Onboarding.slide1Title2)
                        .font(.heading1)
                        .foregroundColor(.textOnBrand)
                    Text(AppStrings.Onboarding.slide1Title3)
                        .font(.heading1)
                        .foregroundColor(.brandPrimary)
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
                
                PrimaryButton(title: "Let's Go →") {
                    currentPage = 1
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
        }
    }
}

// MARK: - Slide 2 (Discovery)
struct Slide2View: View {
    @Binding var currentPage: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            OnboardingProgressBar(activeIndex: 0, total: 3)
                .padding(.top, 60)
                .padding(.horizontal, 24)
            
            VStack(alignment: .leading, spacing: 16) {
                Circle()
                    .fill(Color.textOnBrand)
                    .frame(width: 48, height: 48)
                    .overlay(Image(systemName: "bolt.fill").foregroundColor(.brandPrimary).font(.system(size: 24)))
                    .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                    .padding(.bottom, 8)
                
                Text("Discover what's\nhappening nearby.")
                    .font(.heading1)
                    .foregroundColor(.textPrimary)
                
                Text("Coffee chats, walks, gaming, and spontaneous social moments.")
                    .font(.bodyStandard)
                    .foregroundColor(.textSecondary)
                    .lineSpacing(4)
            }
            .padding(.top, 40)
            .padding(.horizontal, 24)
            
            Spacer()
            
            // Grid of activity chips
            VStack(spacing: 16) {
                HStack(spacing: 16) {
                    ActivityChip(icon: "cup.and.saucer.fill", title: "COFFEE CHAT", activeCount: 4)
                    ActivityChip(icon: "figure.walk", title: "URBAN WALK", activeCount: 7)
                }
                HStack(spacing: 16) {
                    ActivityChip(icon: "gamecontroller.fill", title: "GAME NIGHT", activeCount: 12)
                    ActivityChip(icon: "paintpalette.fill", title: "ART JAM", activeCount: 3)
                }
            }
            .padding(.horizontal, 24)
            
            Spacer()
            
            PrimaryButton(title: "Next →") {
                currentPage = 2
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
        .background(Color.surfaceMain.edgesIgnoringSafeArea(.all))
    }
}

// MARK: - Slide 3 (Safety)
struct Slide3View: View {
    @Binding var currentPage: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            OnboardingProgressBar(activeIndex: 1, total: 3)
                .padding(.top, 60)
                .padding(.horizontal, 24)
            
            VStack(alignment: .center, spacing: 16) {
                Circle()
                    .fill(Color.textOnBrand)
                    .frame(width: 64, height: 64)
                    .overlay(Image(systemName: "checkmark.shield.fill").foregroundColor(.brandPrimary).font(.system(size: 32)))
                    .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                    .padding(.bottom, 8)
                
                Text("Safe, friendly,\nand verified.")
                    .font(.heading1)
                    .foregroundColor(.textPrimary)
                    .multilineTextAlignment(.center)
                
                Text("We prioritize trust and real connections through verified profiles and community vibes.")
                    .font(.bodyStandard)
                    .foregroundColor(.textSecondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
            }
            .padding(.top, 40)
            .padding(.horizontal, 24)
            .frame(maxWidth: .infinity)
            
            Spacer()
            
            VStack(spacing: 16) {
                SafetyFeatureRow(icon: "checkmark.shield", text: "Verified Community")
                SafetyFeatureRow(icon: "person.2", text: "Shared Mutual Friends")
                SafetyFeatureRow(icon: "heart.text.square", text: "Vibe-Checked Meetups")
            }
            .padding(.horizontal, 24)
            
            Spacer()
            
            PrimaryButton(title: "Sounds Good →") {
                currentPage = 3
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
        .background(Color.surfaceMain.edgesIgnoringSafeArea(.all))
    }
}

// MARK: - Slide 4 (Interests)
struct Slide4View: View {
    @Binding var currentPage: Int
    @State private var selectedInterests: Set<String> = []
    
    let interests = ["Creative", "Walks", "Gaming", "Study", "Food", "Startup", "Music", "Coffee"]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            OnboardingProgressBar(activeIndex: 2, total: 3)
                .padding(.top, 60)
                .padding(.horizontal, 24)
            
            VStack(alignment: .leading, spacing: 16) {
                Text("What are you into today?")
                    .font(.heading1)
                    .foregroundColor(.textPrimary)
                
                Text("Select at least 3 to find your vibe.")
                    .font(.bodyStandard)
                    .foregroundColor(.textSecondary)
            }
            .padding(.top, 40)
            .padding(.horizontal, 24)
            
            Spacer()
            
            // Simple Grid alternative for iOS 14+ compatibility without LazyVGrid issues
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
            
            Button(action: { currentPage = 4 }) {
                Text(isReady ? "Let's Go" : "Select \(remaining) more")
                    .font(.buttonText)
                    .foregroundColor(isReady ? .white : .coffeeTextSecondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(isReady ? Color.coffeePrimary : Color.coffeeTextSecondary.opacity(0.2))
                    .clipShape(Capsule())
            }
            .disabled(!isReady)
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
        .background(Color.coffeeSurface.edgesIgnoringSafeArea(.all))
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
    
    var body: some View {
        ZStack {
            // Unsplash: exact image from Figma Start Exploring screen (Slide 5)
            UnsplashBackground(url: "https://images.unsplash.com/photo-1735335568593-6b9f50ec909d?auto=format&fit=crop&w=1000&q=80")
            
            // Gradient overlay — fades from subtle at top to dark at bottom for readability
            LinearGradient(
                stops: [
                    .init(color: Color.black.opacity(0.05), location: 0),
                    .init(color: Color.black.opacity(0.25), location: 0.4),
                    .init(color: Color.black.opacity(0.78), location: 1.0)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .edgesIgnoringSafeArea(.all)
            
            VStack(alignment: .center, spacing: 0) {
                Spacer()
                
                // Icon
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(Color.coffeePrimary)
                    .frame(width: 88, height: 88)
                    .overlay(
                        Text("🎉")
                            .font(.system(size: 40))
                    )
                    .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
                    .padding(.bottom, 32)
                
                // Headings
                Text("You're ready to\njoin the moment.")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 16)
                    .shadow(color: Color.black.opacity(0.4), radius: 4, x: 0, y: 2)
                
                Text("48 meetups happening in your\ncity right now.")
                    .font(.bodyStandard)
                    .foregroundColor(.white.opacity(0.85))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                    .padding(.bottom, 32)
                
                // Avatars with real Unsplash faces
                HStack(spacing: -12) {
                    ForEach([
                        "https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=80&q=80",
                        "https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=80&q=80",
                        "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=80&q=80",
                        "https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=80&q=80"
                    ], id: \.self) { avatarUrl in
                        AsyncImage(url: URL(string: avatarUrl)) { phase in
                            if case .success(let img) = phase {
                                img.resizable().scaledToFill()
                            } else {
                                Circle().fill(Color.gray.opacity(0.5))
                            }
                        }
                        .frame(width: 44, height: 44)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.white, lineWidth: 2))
                    }
                    Circle()
                        .fill(Color.purple.opacity(0.8))
                        .frame(width: 44, height: 44)
                        .overlay(
                            Text("+1.2k")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(.white)
                        )
                        .overlay(Circle().stroke(Color.white, lineWidth: 2))
                }
                .padding(.bottom, 16)
                
                Text("JOIN RILEY AND 1,204 OTHERS NEARBY")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.white.opacity(0.8))
                    .kerning(1.2)
                
                Spacer()
                
                // Button
                NavigationLink(destination: PhoneAuthScreen()) {
                    Text(AppStrings.Onboarding.slide5CTA)
                        .font(.buttonText)
                        .foregroundColor(.textOnBrand)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.brandPrimary)
                        .clipShape(Capsule())
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 16)
                
                Text("NO CREDIT CARD REQUIRED • JOIN FOR FREE")
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
                    .font(.captionText)
                    .foregroundColor(.textPrimary)
                
                HStack(spacing: 4) {
                    Circle()
                        .fill(Color.statusSuccess)
                        .frame(width: 6, height: 6)
                    Text("\(activeCount) ACTIVE")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.statusSuccess)
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.textOnBrand)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
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
                .font(.bodyStandard)
                .fontWeight(.medium)
                .foregroundColor(.textPrimary)
            
            Spacer()
        }
        .padding()
        .background(Color.textOnBrand)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

struct InterestPill: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.bodyStandard)
                .fontWeight(.medium)
                .foregroundColor(isSelected ? .textOnBrand : .textPrimary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(isSelected ? Color.brandPrimary : Color.textOnBrand)
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        }
    }
}

// MARK: - Previews
struct OnboardingScreen_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingScreen()
    }
}
