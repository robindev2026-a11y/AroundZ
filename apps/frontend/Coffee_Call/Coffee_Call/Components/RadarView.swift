import SwiftUI

struct RadarParticle: Identifiable {
    let id = UUID()
    let x: CGFloat
    let y: CGFloat
    let size: CGFloat
    let opacity: Double
    let color: Color
    
    // Animation offsets
    let driftX: CGFloat
    let driftY: CGFloat
}

struct RadarView: View {
    let persons: [RadarPerson]
    let isScanning: Bool
    let progress: CGFloat 
    let selectedPerson: RadarPerson?
    let onPersonTap: (RadarPerson) -> Void
    
    @State private var sweepRotation: Double = 0
    @State private var particles: [RadarParticle] = []
    @State private var twinklePhase: Double = 0
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                // MARK: - Atmospheric Layer
                
                // Background Glow Dots
                ForEach(particles) { particle in
                    Circle()
                        // Twinkle via opacity only (cheap). Avoid animating offsets + blur, which is costly.
                        .fill(particle.color.opacity(particle.opacity * (1.0 - progress) * (0.75 + 0.25 * sin(twinklePhase + Double(particle.id.uuidString.hashValue % 7)))))
                        .frame(width: particle.size, height: particle.size)
                        .scaleEffect(1.0 - (progress * 0.5))
                        .offset(x: particle.x * (1.0 + progress * 2.0), y: particle.y * (1.0 + progress * 2.0))
                        .scaleEffect(isScanning || selectedPerson != nil ? 1.4 : 1.0)
                }
                
                // Radial Gradient
                RadialGradient(
                    gradient: Gradient(colors: [
                        Color.brandPrimary.opacity(0.12 * (1.0 - progress)),
                        Color.brandPurple.opacity(0.04 * (1.0 - progress)),
                        Color.clear
                    ]),
                    center: .center,
                    startRadius: 0,
                    endRadius: 200
                )
                
                // MARK: - Rings
                
                ForEach(AppConstants.Radar.distances, id: \.self) { distance in
                    Circle()
                        .stroke(
                            Color.appBorder.opacity(0.3 * (1.0 - progress)),
                            style: StrokeStyle(lineWidth: 1, dash: [2, 4])
                        )
                        .frame(width: CGFloat(distance) * 420)
                        .scaleEffect(1.0 + (progress * 0.2))
                }
                
                // MARK: - Energy-Efficient Scanning Sweep
                
                if isScanning {
                    AngularGradient(
                        gradient: Gradient(stops: [
                            .init(color: .brandPrimary.opacity(0.25), location: 0.0),
                            .init(color: .brandPrimary.opacity(0.05), location: 0.1),
                            .init(color: .clear, location: 0.25)
                        ]),
                        center: .center,
                        angle: .degrees(sweepRotation)
                    )
                    .mask(Circle().frame(width: 400))
                    .opacity(1.0 - progress)
                    .onAppear {
                        // Start animation ONLY when isScanning becomes true
                        sweepRotation = 0
                        withAnimation(.linear(duration: 4).repeatForever(autoreverses: false)) {
                            sweepRotation = 360
                        }
                    }
                    .onDisappear {
                        // Stop animation and reset when scanning finishes
                        sweepRotation = 0
                    }
                }
                
                // MARK: - Center "You"
                
                VStack(spacing: 4) {
                    ZStack {
                        Circle()
                            .fill(Color.surfaceMain)
                            .frame(width: AppConstants.Radar.centerAvatarSize, height: AppConstants.Radar.centerAvatarSize)
                            .shadow(color: Color.black.opacity(0.06), radius: 10, x: 0, y: 5)
                            .overlay(Circle().stroke(Color.brandPrimary.opacity(0.2), lineWidth: 1))
                            .scaleEffect(1.0 - (progress * 0.2))
                        
                        AppIcons.personImage
                            .foregroundColor(.brandPrimary)
                            .font(.system(size: 28))
                    }
                    
                    Text(AppStrings.Tabs.profile)
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.textSecondary)
                        .opacity(1.0 - progress)
                }
                
                // MARK: - Nearby People
                
                ForEach(persons) { person in
                    let isSelected = selectedPerson?.id == person.id
                    
                    Button(action: { onPersonTap(person) }) {
                        ZStack {
                            if isSelected {
                                Circle()
                                    .fill(Color.brandPrimary.opacity(0.2))
                                    .frame(width: 64, height: 64)
                                    .blur(radius: 6)
                            }
                            
                            Circle()
                                .fill(Color.white)
                                .frame(width: AppConstants.Radar.personAvatarSize, height: AppConstants.Radar.personAvatarSize)
                                .shadow(color: Color.black.opacity(0.12), radius: 4, x: 0, y: 2)
                            
                            Text(person.initials)
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(person.color)
                        }
                    }
                    .pressScale(0.9)
                    .opacity(1.0 - progress)
                    .scaleEffect(1.0 - (progress * 0.3))
                    .offset(
                        x: cos(person.angle * .pi / 180) * (person.distance * 210) * (1.0 + progress * 0.5),
                        y: sin(person.angle * .pi / 180) * (person.distance * 210) * (1.0 + progress * 0.5)
                    )
                    .zIndex(isSelected ? 50 : 1)
                }
                
                // MARK: - Selected Person Dynamic Tooltip
                if let person = selectedPerson {
                    let bubbleX = cos(person.angle * .pi / 180) * (person.distance * 210)
                    let bubbleY = sin(person.angle * .pi / 180) * (person.distance * 210)
                    
                    let isBelow = bubbleY < -30
                    let tooltipY = isBelow ? bubbleY + 54 : bubbleY - 54
                    
                    let tooltipWidth: CGFloat = 190
                    let maxTooltipX = max((geo.size.width / 2) - (tooltipWidth / 2) - 16, 0)
                    let tooltipX = min(max(bubbleX, -maxTooltipX), maxTooltipX)
                    let arrowX = min(max(bubbleX - tooltipX, -70), 70)
                    
                    ActivityTooltipView(person: person, isBelow: isBelow, arrowX: arrowX)
                        .offset(x: tooltipX, y: tooltipY)
                        .transition(.asymmetric(insertion: .scale.combined(with: .opacity), removal: .opacity))
                        .zIndex(100)
                }
            }
            .frame(width: geo.size.width, height: geo.size.height)
            .onAppear {
                if particles.isEmpty {
                    generateParticles()
                }

                // Single shared twinkle driver (low energy).
                withAnimation(.linear(duration: 10).repeatForever(autoreverses: false)) {
                    twinklePhase = .pi * 2
                }
            }
        }
        .animation(.spring(response: 0.5, dampingFraction: 0.7), value: isScanning)
        .animation(.spring(response: 0.5, dampingFraction: 0.7), value: selectedPerson?.id)
    }
    
    private func generateParticles() {
        var newParticles: [RadarParticle] = []
        for i in 0..<12 {
            newParticles.append(RadarParticle(
                x: CGFloat.random(in: -160...160),
                y: CGFloat.random(in: -160...160),
                size: CGFloat.random(in: 4...8),
                opacity: i % 2 == 0 ? 0.3 : 0.2,
                color: i % 2 == 0 ? Color.brandPrimary : Color.brandPurple,
                driftX: 0,
                driftY: 0
            ))
        }
        self.particles = newParticles
    }
}

struct ActivityTooltipView: View {
    let person: RadarPerson
    let isBelow: Bool
    let arrowX: CGFloat
    
    var body: some View {
        VStack(spacing: 0) {
            if isBelow {
                // Triangle pointer on top pointing UP
                Image(systemName: "triangle.fill")
                    .resizable()
                    .frame(width: 12, height: 6)
                    .foregroundColor(.surfaceMain)
                    .offset(x: arrowX, y: 1)
                    .zIndex(10)
            }
            
            HStack(spacing: AppConstants.Layout.miniPadding * 2) {
                // Icon circle well (28x28)
                ZStack {
                    Circle()
                        .fill(person.color.opacity(0.12))
                        .frame(width: 28, height: 28)
                    
                    getIcon(for: person.interests.first ?? "")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(person.color)
                }
                
                VStack(alignment: .leading, spacing: 1) {
                    Text(person.interests.joined(separator: " & "))
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.textPrimary)
                        .lineLimit(1)
                    
                    Text(AppStrings.Discovery.anonymousSignal)
                        .font(.system(size: 9, weight: .medium))
                        .foregroundColor(.textSecondary)
                        .lineLimit(1)
                }
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .background(Color.surfaceMain)
            .cornerRadius(AppConstants.Layout.tooltipRadius)
            .overlay(
                RoundedRectangle(cornerRadius: AppConstants.Layout.tooltipRadius)
                    .stroke(Color.appBorder, lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
            
            if !isBelow {
                // Triangle pointer on bottom pointing DOWN
                Image(systemName: "triangle.fill")
                    .resizable()
                    .frame(width: 12, height: 6)
                    .foregroundColor(.surfaceMain)
                    .rotationEffect(.degrees(180))
                    .offset(x: arrowX, y: -1)
                    .zIndex(10)
            }
        }
        .frame(width: 190)
    }
    
    private func getIcon(for interest: String) -> Image {
        switch interest.lowercased() {
        case "walks", "walk":
            return AppIcons.walkImage
        case "coffee":
            return AppIcons.coffeeImage
        case "movies", "movie":
            return AppIcons.movieImage
        default:
            return AppIcons.sparklesImage
        }
    }
}

