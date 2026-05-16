import SwiftUI

struct RadarView: View {
    let persons: [RadarPerson]
    let isScanning: Bool
    let selectedPerson: RadarPerson?
    let onPersonTap: (RadarPerson) -> Void
    
    @State private var sweepRotation: Double = 0
    
    var body: some View {
        ZStack {
            // Atmospheric Glow
            RadialGradient(
                gradient: Gradient(colors: [Color.brandPrimary.opacity(0.12), Color.brandPurple.opacity(0.04), Color.clear]),
                center: .center,
                startRadius: 0,
                endRadius: 220
            )
            
            // Rings with Distance Labels
            ForEach(AppConstants.Radar.distances, id: \.self) { distance in
                ZStack {
                    Circle()
                        .stroke(Color.appBorder.opacity(0.4), style: StrokeStyle(lineWidth: 1, dash: [2, 4]))
                        .frame(width: CGFloat(distance) * 360)
                    
                    Text("\(String(format: "%.1f", distance)) mi")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundColor(Color.brandPrimary.opacity(0.5))
                        .padding(.horizontal, 4)
                        .background(Color.backgroundMain)
                        .offset(y: -CGFloat(distance) * 180)
                }
            }
            
            // Scanning Wedge
            if isScanning {
                AngularGradient(
                    gradient: Gradient(stops: [
                        .init(color: .brandPrimary.opacity(0.3), location: 0.0),
                        .init(color: .brandPrimary.opacity(0.1), location: 0.2),
                        .init(color: .clear, location: 0.4)
                    ]),
                    center: .center,
                    angle: .degrees(sweepRotation)
                )
                .mask(Circle().frame(width: 340))
                .onAppear {
                    withAnimation(.linear(duration: 2.5).repeatForever(autoreverses: false)) {
                        sweepRotation = 360
                    }
                }
            }
            
            // Center "You"
            VStack(spacing: 4) {
                ZStack {
                    Circle()
                        .fill(Color.surfaceMain)
                        .frame(width: AppConstants.Radar.centerAvatarSize, height: AppConstants.Radar.centerAvatarSize)
                        .shadow(color: Color.black.opacity(0.06), radius: 10, x: 0, y: 5)
                    
                    Image(systemName: AppIcons.person)
                        .foregroundColor(.brandPrimary)
                        .font(.system(size: 28))
                }
                Text(AppStrings.Tabs.profile)
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(.textSecondary)
            }
            
            // Nearby People
            ForEach(persons) { person in
                let isSelected = selectedPerson?.id == person.id
                
                Button(action: { onPersonTap(person) }) {
                    ZStack {
                        // Selection Glow
                        if isSelected {
                            Circle()
                                .fill(Color.brandPrimary.opacity(0.2))
                                .frame(width: 64, height: 64)
                                .blur(radius: 4)
                        }
                        
                        Circle()
                            .fill(Color.white)
                            .frame(width: AppConstants.Radar.personAvatarSize, height: AppConstants.Radar.personAvatarSize)
                            .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                        
                        Text(person.initials)
                            .font(.system(size: 11, weight: .black))
                            .foregroundColor(person.color)
                    }
                }
                .pressScale(0.9)
                .offset(
                    x: cos(person.angle * .pi / 180) * (person.distance * 180),
                    y: sin(person.angle * .pi / 180) * (person.distance * 180)
                )
                .overlay(
                    Group {
                        if isSelected {
                            ActivityTooltipView(person: person)
                                .offset(
                                    x: cos(person.angle * .pi / 180) * (person.distance * 180),
                                    y: sin(person.angle * .pi / 180) * (person.distance * 180) - 50
                                )
                        }
                    }
                )
            }
        }
    }
}

struct ActivityTooltipView: View {
    let person: RadarPerson
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 8) {
                // Score Placeholder (Future)
                Text("98")
                    .font(.system(size: 10, weight: .black))
                    .foregroundColor(.brandPrimary)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 3)
                    .background(Color.brandPrimary.opacity(0.1))
                    .clipShape(Capsule())
                
                VStack(alignment: .leading, spacing: 0) {
                    HStack(spacing: 6) {
                        Text(person.interests.joined(separator: " & "))
                            .font(.system(size: AppConstants.Typography.sizeCaption, weight: .black))
                            .foregroundColor(.textPrimary)
                        
                        HStack(spacing: 4) {
                            ForEach(person.interests, id: \.self) { interest in
                                Image(systemName: getIcon(for: interest))
                                    .font(.system(size: 9))
                                    .foregroundColor(.brandPrimary)
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .background(Color.surfaceMain)
            .clipShape(RoundedRectangle(cornerRadius: AppConstants.Layout.tooltipRadius, style: .continuous))
            .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 4)
            .overlay(
                RoundedRectangle(cornerRadius: AppConstants.Layout.tooltipRadius, style: .continuous)
                    .stroke(Color.appBorder.opacity(0.2), lineWidth: 0.5)
            )
            
            // Triangle pointer
            Image(systemName: "triangle.fill")
                .resizable()
                .frame(width: 10, height: 5)
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

// MARK: - Interactive Preview
#Preview("Radar View") {
    PreviewWrapper()
}

private struct PreviewWrapper: View {
    @State private var selectedPerson: RadarPerson? = nil
    
    private let persons = [
        RadarPerson(
            initials: "LM",
            name: "Liam",
            color: .brandPrimary,
            distance: 0.7,
            angle: 110,
            hasPresence: true,
            interests: ["Coffee", "Walks"]
        ),
        RadarPerson(
            initials: "DK",
            name: "David",
            color: .brandSecondary,
            distance: 0.4,
            angle: 195,
            hasPresence: true,
            interests: ["Food", "Gaming"]
        ),
        RadarPerson(
            initials: "NP",
            name: "Neha",
            color: .brandPrimary,
            distance: 0.8,
            angle: 250,
            hasPresence: true,
            interests: ["Movies", "Music"]
        )
    ]
    
    var body: some View {
        ZStack {
            Color.backgroundMain
                .ignoresSafeArea()
            
            RadarView(
                persons: persons,
                isScanning: true,
                selectedPerson: selectedPerson,
                onPersonTap: { person in
                    withAnimation(.spring()) {
                        if selectedPerson?.id == person.id {
                            selectedPerson = nil
                        } else {
                            selectedPerson = person
                        }
                    }
                }
            )
        }
    }
}
