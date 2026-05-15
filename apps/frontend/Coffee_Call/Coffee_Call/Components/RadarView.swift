import SwiftUI

// MARK: - Radar View
// Refined for Social Refresh: Feathered scan, soft rings, and atmospheric glow.
// Manual 5-second scan, static by default.

struct RadarView: View {
    let persons: [RadarPerson]
    let isScanning: Bool
    
    @State private var sweepRotation: Double = 0
    @State private var pulseScale: CGFloat = 1.0
    
    var body: some View {
        ZStack {
            // 1. Atmospheric Glow
            RadialGradient(
                gradient: Gradient(colors: [Color.brandPrimary.opacity(0.15), Color.clear]),
                center: .center,
                startRadius: 0,
                endRadius: 150
            )
            .scaleEffect(isScanning ? 1.2 : 1.0)
            .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: isScanning)
            
            // 2. Radar Rings (Thin & Soft)
            ForEach(1...4, id: \.self) { i in
                Circle()
                    .stroke(Color.brandPrimary.opacity(0.08), lineWidth: 0.5)
                    .frame(width: CGFloat(i) * 72)
            }
            
            // 3. Feathered Scan Wedge (Only when scanning)
            if isScanning {
                AngularGradient(
                    gradient: Gradient(stops: [
                        .init(color: .brandPrimary.opacity(0.4), location: 0.0),
                        .init(color: .brandPrimary.opacity(0.1), location: 0.2),
                        .init(color: .clear, location: 0.4)
                    ]),
                    center: .center,
                    angle: .degrees(sweepRotation)
                )
                .mask(Circle().frame(width: 340))
                .onAppear {
                    withAnimation(.linear(duration: 2).repeatForever(autoreverses: false)) {
                        sweepRotation = 360
                    }
                }
                .onDisappear {
                    sweepRotation = 0
                }
            }
            
            // 4. Center "You" Avatar
            centerAvatar
            
            // 5. Nearby People
            ForEach(persons) { person in
                RadarPersonAvatar(person: person)
                    .offset(
                        x: cos(person.angle * .pi / 180) * (person.distance * 150),
                        y: sin(person.angle * .pi / 180) * (person.distance * 150)
                    )
                    .opacity(isScanning ? 0.4 : 1.0)
                    .animation(.easeInOut(duration: 0.5), value: isScanning)
            }
        }
        .frame(maxWidth: .infinity)
    }
    
    private var centerAvatar: some View {
        ZStack {
            Circle()
                .fill(Color.brandPrimary.opacity(0.1))
                .frame(width: 56, height: 56)
            
            Circle()
                .fill(Color.surfaceMain)
                .frame(width: 48, height: 48)
                .shadow(color: Color.brandPrimary.opacity(0.1), radius: 8, x: 0, y: 4)
            
            Image(systemName: AppIcons.person)
                .foregroundColor(.brandPrimary.opacity(0.6))
                .font(.system(size: 20))
            
            VStack {
                Spacer()
                Text("You")
                    .font(.system(size: 9, weight: .bold))
                    .foregroundColor(.textSecondary)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color.surfaceMain)
                    .clipShape(Capsule())
                    .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
                    .offset(y: 6)
            }
            .frame(height: 48)
        }
    }
}

struct RadarPersonAvatar: View {
    let person: RadarPerson
    
    var body: some View {
        ZStack {
            Circle()
                .fill(Color.surfaceMain)
                .frame(width: 32, height: 32)
                .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
            
            if let imageUrl = person.imageUrl {
                // High-fidelity photo placeholder
                Circle()
                    .fill(person.color.opacity(0.2))
                    .frame(width: 28, height: 28)
                Text(person.initials)
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(person.color)
            } else {
                Text(person.initials)
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(person.color)
            }
        }
    }
}
