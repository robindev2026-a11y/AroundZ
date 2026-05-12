import SwiftUI

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
                .padding(.top, 60)
                
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
                
                PrimaryButton(title: "Let's Go →") {
                    withAnimation {
                        currentPage = 1
                    }
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
                    .fill(Color.white)
                    .frame(width: 48, height: 48)
                    .overlay(Image(systemName: "bolt.fill").foregroundColor(.coffeePrimary).font(.system(size: 24)))
                    .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                    .padding(.bottom, 8)
                
                Text("Discover what's\nhappening nearby.")
                    .font(.heading1)
                    .foregroundColor(.coffeeTextPrimary)
                
                Text("Coffee chats, walks, gaming, and spontaneous social moments.")
                    .font(.bodyStandard)
                    .foregroundColor(.coffeeTextSecondary)
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
                withAnimation {
                    currentPage = 2
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
        .background(Color.coffeeSurface.edgesIgnoringSafeArea(.all))
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
                    .fill(Color.white)
                    .frame(width: 64, height: 64)
                    .overlay(Image(systemName: "checkmark.shield.fill").foregroundColor(.coffeePrimary).font(.system(size: 32)))
                    .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                    .padding(.bottom, 8)
                
                Text("Safe, friendly,\nand verified.")
                    .font(.heading1)
                    .foregroundColor(.coffeeTextPrimary)
                    .multilineTextAlignment(.center)
                
                Text("We prioritize trust and real connections through verified profiles and community vibes.")
                    .font(.bodyStandard)
                    .foregroundColor(.coffeeTextSecondary)
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
                withAnimation {
                    currentPage = 3
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
        .background(Color.coffeeSurface.edgesIgnoringSafeArea(.all))
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
                    .foregroundColor(.coffeeTextPrimary)
                
                Text("Select at least 3 to find your vibe.")
                    .font(.bodyStandard)
                    .foregroundColor(.coffeeTextSecondary)
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
            
            NavigationLink(destination: PhoneAuthScreen()) {
                Text(isReady ? "Let's Go" : "Select \\(remaining) more")
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

// MARK: - Subcomponents

struct OnboardingProgressBar: View {
    let activeIndex: Int
    let total: Int
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<total, id: \.self) { index in
                Rectangle()
                    .fill(index <= activeIndex ? Color.coffeePrimary : Color.coffeeTextSecondary.opacity(0.2))
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
                .foregroundColor(.coffeeTextPrimary)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.captionText)
                    .foregroundColor(.coffeeTextPrimary)
                
                HStack(spacing: 4) {
                    Circle()
                        .fill(Color.coffeeSuccess)
                        .frame(width: 6, height: 6)
                    Text("\\(activeCount) ACTIVE")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.coffeeSuccess)
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
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
                .foregroundColor(.coffeePrimary)
                .font(.system(size: 20))
                .frame(width: 24)
            
            Text(text)
                .font(.bodyStandard)
                .fontWeight(.medium)
                .foregroundColor(.coffeeTextPrimary)
            
            Spacer()
        }
        .padding()
        .background(Color.white)
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
                .foregroundColor(isSelected ? .white : .coffeeTextPrimary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(isSelected ? Color.coffeePrimary : Color.white)
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
