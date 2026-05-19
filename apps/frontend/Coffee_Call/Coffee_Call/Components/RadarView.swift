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
                    
                    ZStack {
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
                                    .font(.system(size: 11, weight: .black))
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
                        
                        if isSelected {
                            ActivityTooltipView(person: person)
                                .transition(.asymmetric(insertion: .scale.combined(with: .opacity), removal: .opacity))
                                .offset(
                                    x: cos(person.angle * .pi / 180) * (person.distance * 210),
                                    y: sin(person.angle * .pi / 180) * (person.distance * 210) - 75
                                )
                                .zIndex(100)
                        }
                    }
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
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                // Avatar Mini
                ZStack {
                    Circle()
                        .fill(person.color.opacity(0.1))
                        .frame(width: 32, height: 32)
                    
                    Text(person.initials)
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(person.color)
                }
                
                VStack(alignment: .leading, spacing: 1) {
                    HStack(spacing: 4) {
                        Text(person.interests.joined(separator: " & "))
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(.textPrimary)
                        
                        Image(systemName: getIcon(for: person.interests.first ?? ""))
                            .font(.system(size: 9))
                            .foregroundColor(.brandPrimary)
                    }
                    
                    Text(AppStrings.Discovery.anonymousSignal)
                        .font(.system(size: 9, weight: .medium))
                        .foregroundColor(.textSecondary)
                }
                
                Button(action: {}) {
                    Text(AppStrings.Discovery.startDrift)
                        .font(.system(size: 10, weight: .black))
                        .foregroundColor(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Color.brandPrimary)
                        .clipShape(Capsule())
                }
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .background(Color.surfaceMain)
            .clipShape(RoundedRectangle(cornerRadius: AppConstants.Layout.tooltipRadius, style: .continuous))
            .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
            
            // Triangle pointer
            Image(systemName: "triangle.fill")
                .resizable()
                .frame(width: 12, height: 6)
                .foregroundColor(.surfaceMain)
                .rotationEffect(.degrees(180))
                .offset(y: -1)
        }
    }
    
    func getIcon(for interest: String) -> String {
        switch interest {
        case "Coffee": return AppIcons.coffeeFill
        case "Walks": return AppIcons.walk
        case "Food": return AppIcons.food
        case "Movies": return AppIcons.movie
        default: return AppIcons.sparkles
        }
    }
}
