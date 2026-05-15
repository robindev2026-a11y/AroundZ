import SwiftUI

struct RadarView: View {
    let persons: [RadarPerson]
    let maxDistance: Double = 1.0 // Maximum distance shown on radar
    
    var body: some View {
        GeometryReader { geo in
            let center = CGPoint(x: geo.size.width / 2, y: geo.size.height / 2)
            let radius = min(geo.size.width, geo.size.height) / 2
            
            ZStack {
                // Background Rings
                ForEach(AppConstants.Radar.distances, id: \.self) { distance in
                    let ringRadius = (distance / AppConstants.Radar.maxDistance) * radius
                    Circle()
                        .stroke(
                            RadialGradient(
                                gradient: Gradient(colors: [Color.brandPrimary.opacity(0.1), Color.clear]),
                                center: .center,
                                startRadius: ringRadius - 1,
                                endRadius: ringRadius + 1
                            ),
                            lineWidth: 2
                        )
                        .overlay(
                            Circle()
                                .stroke(Color.appBorder.opacity(AppConstants.Radar.ringOpacity), lineWidth: AppConstants.Radar.ringLineWidth)
                        )
                        .frame(width: ringRadius * 2, height: ringRadius * 2)
                }
                
                // Center (You)
                VStack(spacing: 8) {
                    ZStack {
                        Circle()
                            .fill(Color.brandPrimary.opacity(0.1))
                            .frame(width: AppConstants.Radar.centerGlowSize, height: AppConstants.Radar.centerGlowSize)
                            .blur(radius: 10)
                        
                        Image("user_profile") // Assuming this asset exists or using a placeholder
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: AppConstants.Radar.centerAvatarSize, height: AppConstants.Radar.centerAvatarSize)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.white, lineWidth: 3))
                            .background(Circle().fill(Color.surfaceMain))
                            .shadow(color: Color.brandPrimary.opacity(0.2), radius: 15, x: 0, y: 8)
                    }
                    
                    Text("You")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.textPrimary)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 6)
                        .background(Color.surfaceMain)
                        .clipShape(Capsule())
                        .shadow(color: Color.textPrimary.opacity(0.05), radius: 5, x: 0, y: 2)
                }
                .offset(y: -5) // Visual centering adjustment
                
                // Nearby People
                ForEach(persons) { person in
                    let personRadius = (person.distance / maxDistance) * radius
                    let xOffset = personRadius * cos(person.angle * .pi / 180)
                    let yOffset = personRadius * sin(person.angle * .pi / 180)
                    
                    RadarPersonAvatar(person: person)
                        .offset(x: xOffset, y: yOffset)
                        .transition(.scale.combined(with: .opacity))
                }
            }
            .position(center)
        }
        .aspectRatio(1, contentMode: .fit)
    }
}

// MARK: - Person Avatar
private struct RadarPersonAvatar: View {
    let person: RadarPerson
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            Text(person.initials)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.textPrimary)
                .frame(width: 44, height: 44)
                .background(person.color.opacity(0.2))
                .clipShape(Circle())
                .overlay(
                    Circle()
                        .stroke(Color.surfaceMain, lineWidth: 2)
                )
                .background(
                    Circle()
                        .fill(Color.surfaceMain)
                        .shadow(color: Color.textPrimary.opacity(0.06), radius: 8, x: 0, y: 4)
                )
            
            if person.hasPresence {
                Circle()
                    .fill(Color.brandPrimary)
                    .frame(width: 10, height: 10)
                    .overlay(Circle().stroke(Color.surfaceMain, lineWidth: 1.5))
                    .offset(x: -2, y: 2)
            }
        }
    }
}

// MARK: - Previews
struct RadarView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.backgroundMain.ignoresSafeArea()
            RadarView(persons: [
                RadarPerson(initials: "AL", color: .brandPrimary, distance: 0.2, angle: 45, hasPresence: true),
                RadarPerson(initials: "RI", color: .brandPurple, distance: 0.5, angle: 120, hasPresence: true),
                RadarPerson(initials: "PR", color: .brandSecondary, distance: 0.7, angle: -30, hasPresence: false),
                RadarPerson(initials: "MA", color: .brandPrimary, distance: 0.4, angle: 210, hasPresence: true),
                RadarPerson(initials: "SA", color: .brandPurple, distance: 0.9, angle: 300, hasPresence: true)
            ])
            .padding(40)
        }
    }
}
