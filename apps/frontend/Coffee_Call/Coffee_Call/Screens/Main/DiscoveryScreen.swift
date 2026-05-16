import SwiftUI

struct DiscoveryScreen: View {
    @StateObject private var viewModel = DiscoveryViewModel()
    @Binding var selectedTab: Int
    
    @State private var scrollOffset: CGFloat = 0
    @State private var selectedPerson: RadarPerson? = nil
    
    // 4 Column x 2 Row Grid per DESIGN.md
    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]
    
    var body: some View {
        ZStack(alignment: .top) {
            // 1. Base Background
            Color.backgroundMain.ignoresSafeArea()
                .onTapGesture {
                    withAnimation { selectedPerson = nil }
                }
            
            // 2. Fixed/Parallax Radar (Layer 1)
            VStack {
                RadarView(
                    persons: viewModel.radarPeople,
                    isScanning: viewModel.isScanning,
                    selectedPerson: selectedPerson,
                    onPersonTap: { person in
                        withAnimation(CoffeeAnimation.spring) {
                            if selectedPerson?.id == person.id {
                                selectedPerson = nil
                            } else {
                                selectedPerson = person
                            }
                        }
                    }
                )
                .padding(.top, 160)
                .scaleEffect(max(0.9, 1.0 - (scrollOffset / 1000)))
                .opacity(max(0.0, 1.0 - (scrollOffset / 300)))
                .blur(radius: min(10, scrollOffset / 40))
                
                Spacer()
            }
            .ignoresSafeArea()
            
            // 3. Scrollable Foreground Content (Layer 2)
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    // Larger Transparent Window to keep Radar "On Front" initially
                    Color.clear
                        .frame(height: 520)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            withAnimation { selectedPerson = nil }
                        }
                    
                    // The "Content Card" that slides OVER the radar (Stack Effect)
                    VStack(spacing: 24) {
                        // 2. Drift Context Card (88pt height per DESIGN.md)
                        HStack(spacing: 16) {
                            ZStack {
                                Circle()
                                    .fill(Color.brandPrimary.opacity(0.1))
                                    .frame(width: 52, height: 52)
                                Image(systemName: "person.2.fill")
                                    .foregroundColor(.brandPrimary)
                                    .font(.system(size: 18))
                            }
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(viewModel.contextTitle)
                                    .font(.system(size: 14, weight: .black))
                                    .foregroundColor(.textPrimary)
                                Text(viewModel.contextBody)
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundColor(.textSecondary)
                            }
                            
                            Spacer()
                            
                            Button(action: {
                                withAnimation(CoffeeAnimation.spring) {
                                    selectedTab = 1
                                }
                            }) {
                                Text(viewModel.contextCTA)
                                    .font(.system(size: 10, weight: .black))
                                    .foregroundColor(Color.brandPrimary)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                                    .background(Color.brandPrimary.opacity(0.1))
                                    .clipShape(Capsule())
                            }
                        }
                        .frame(height: 88)
                        .padding(.horizontal, 16)
                        .background(Color.surfaceMain)
                        .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 26, style: .continuous)
                                .stroke(Color.appBorder.opacity(0.3), lineWidth: 1)
                        )
                        .padding(.horizontal, 20)
                        
                        // 3. Interests Grid (Section Title + 4x2 Grid)
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Your interests nearby")
                                .font(.system(size: 18, weight: .black))
                                .foregroundColor(.textPrimary)
                                .padding(.horizontal, 20)
                            
                            LazyVGrid(columns: columns, spacing: 14) {
                                ForEach(viewModel.interestCategories) { category in
                                    InterestCard(
                                        title: category.label,
                                        icon: category.icon,
                                        count: category.count,
                                        color: category.color ?? .brandPrimary
                                    )
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                        
                        Spacer(minLength: 160)
                    }
                    .padding(.top, 24)
                    .background(
                        ZStack {
                            Color.backgroundMain
                            
                            // Definition shadow for the "Card Stack" edge
                            Rectangle()
                                .fill(LinearGradient(colors: [.black.opacity(0.08), .clear], startPoint: .top, endPoint: .bottom))
                                .frame(height: 12)
                                .offset(y: -12)
                        }
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 34, style: .continuous))
                    .onTapGesture {
                        withAnimation { selectedPerson = nil }
                    }
                }
                .background(GeometryReader { geo in
                    Color.clear.preference(key: ScrollOffsetPreferenceKey.self, value: geo.frame(in: .named("discoveryScroll")).minY)
                })
            }
            .coordinateSpace(name: "discoveryScroll")
            .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
                let newOffset = -value
                if abs(newOffset - scrollOffset) > 10 && selectedPerson != nil {
                    withAnimation { selectedPerson = nil }
                }
                scrollOffset = newOffset
            }
            
            // 4. Fixed Top UI: Floating Glass Header (82pt height per DESIGN.md)
            VStack {
                HStack(alignment: .center) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(viewModel.title)
                            .font(.system(size: 24, weight: .black))
                            .foregroundColor(.textPrimary)
                        Text(viewModel.subtitle)
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.textSecondary)
                    }
                    
                    Spacer()
                    
                    // Notification Button (56x56 per DESIGN.md)
                    Button(action: {}) {
                        ZStack {
                            Circle()
                                .fill(Color.surfaceMain)
                                .frame(width: 56, height: 56)
                                .overlay(Circle().stroke(Color.appBorder.opacity(0.3), lineWidth: 0.5))
                                .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 4)
                            
                            Image(systemName: "bell")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.textPrimary)
                            
                            Circle()
                                .fill(Color.brandPrimary)
                                .frame(width: 18, height: 18)
                                .overlay(Text("3").font(.system(size: 9, weight: .black)).foregroundColor(.white))
                                .offset(x: 12, y: -12)
                        }
                    }
                }
                .padding(.horizontal, 20)
                .frame(height: 82)
                .background(
                    RoundedRectangle(cornerRadius: 30, style: .continuous)
                        .fill(.ultraThinMaterial)
                        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
                )
                .padding(.horizontal, 20)
                .padding(.top, 10)
                
                Spacer()
                
                // 5. Floating Refresh Button (58x58 per DESIGN.md)
                HStack {
                    Spacer()
                    Button(action: { viewModel.refreshNearby() }) {
                        ZStack {
                            Circle()
                                .fill(.ultraThinMaterial)
                                .frame(width: 58, height: 58)
                                .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
                                .overlay(Circle().stroke(Color.white.opacity(0.5), lineWidth: 0.5))
                            
                            Image(systemName: "arrow.clockwise")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.brandPrimary)
                                .rotationEffect(.degrees(viewModel.isScanning ? 360 : 0))
                                .animation(viewModel.isScanning ? .linear(duration: 1).repeatForever(autoreverses: false) : .default, value: viewModel.isScanning)
                        }
                    }
                    .padding(.trailing, 20)
                    .padding(.bottom, 120)
                    .opacity(scrollOffset > 100 ? 0 : 1)
                    .animation(.easeInOut, value: scrollOffset)
                }
            }
            .ignoresSafeArea(edges: .top)
        }
    }
}

// Preference Key for Scroll Tracking
struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

#Preview {
    DiscoveryScreen(selectedTab: .constant(0))
}
