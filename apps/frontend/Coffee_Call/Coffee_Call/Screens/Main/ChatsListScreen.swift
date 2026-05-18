import SwiftUI

struct ChatsListScreen: View {
    @StateObject private var viewModel = ChatsViewModel()
    @State private var selectedFilter: ChatFilter = .active
    @State private var viewMode: ViewMode = .bubbles
    
    enum ViewMode {
        case bubbles
        case list
    }
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: AppConstants.Layout.elementSpacing) {
                // 1. Status Filter Chips Row
                statusChipsRow
                    .padding(.top, AppConstants.Layout.subElementSpacing)
                
                // 2. Main Content Mode Selector
                let chats = viewModel.filteredChats(for: selectedFilter)
                
                if chats.isEmpty {
                    emptyStateView
                        .padding(.top, AppConstants.Layout.sectionSpacing)
                } else {
                    switch viewMode {
                    case .bubbles:
                        bubbleFieldView(chats: chats)
                            .scrollDisabled(true)
                    case .list:
                        compactListView(chats: chats)
                    }
                }
            }
            .asCoffeeMainPage(
                title: viewModel.title,
                subtitle: viewModel.subtitle ?? AppStrings.Chat.subtitle
            ) {
                // Shared Floating Glass Header Right Action: View Toggle Button
                CoffeeHeaderButton(
                    icon: viewMode == .bubbles ? "list.bullet" : "bubble.left.and.bubble.right",
                    iconSize: 18
                ) {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
                        viewMode = (viewMode == .bubbles) ? .list : .bubbles
                    }
                }
            }
            .navigationDestination(for: Drift.self) { drift in
                DriftChatScreen(viewModel: DriftChatViewModel(drift: drift))
            }
        }
    }
    
    // MARK: - Status Filter Row
    private var statusChipsRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: AppConstants.Layout.subElementSpacing) {
                ForEach(ChatFilter.allCases) { filter in
                    Button(action: {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                            selectedFilter = filter
                        }
                    }) {
                        Text(filter.title)
                            .font(.bodySmall)
                            .foregroundColor(selectedFilter == filter ? .brandPrimary : .textSecondary)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(
                                Capsule()
                                    .fill(selectedFilter == filter ? Color.brandPrimary.opacity(0.12) : Color.surfaceMain)
                            )
                            .overlay(
                                Capsule()
                                    .stroke(selectedFilter == filter ? Color.brandPrimary.opacity(0.3) : Color.appBorder, lineWidth: 1)
                            )
                    }
                    .pressScale(0.95)
                }
            }
            .padding(.horizontal, AppConstants.Layout.standardPadding)
        }
    }
    
    // MARK: - Bubble Field View Mode
    private func bubbleFieldView(chats: [Drift]) -> some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let height = geometry.size.height > 0 ? geometry.size.height : 500
            

            let sparkles: [SparkleInfo] = [
                SparkleInfo(x: 0.15, y: 0.18, size: 4.0, color: Color.brandSecondary.opacity(0.3)),
                SparkleInfo(x: 0.85, y: 0.12, size: 5.0, color: Color.brandPrimary.opacity(0.3)),
                SparkleInfo(x: 0.35, y: 0.28, size: 3.0, color: Color.brandPurple.opacity(0.3)),
                SparkleInfo(x: 0.58, y: 0.22, size: 6.0, color: Color.brandPrimary.opacity(0.2)),
                SparkleInfo(x: 0.12, y: 0.45, size: 5.0, color: Color.brandPurple.opacity(0.3)),
                SparkleInfo(x: 0.88, y: 0.52, size: 4.0, color: Color.brandSecondary.opacity(0.3)),
                SparkleInfo(x: 0.42, y: 0.38, size: 4.0, color: Color.brandSecondary.opacity(0.2)),
                SparkleInfo(x: 0.65, y: 0.55, size: 5.0, color: Color.brandPurple.opacity(0.3)),
                SparkleInfo(x: 0.18, y: 0.72, size: 6.0, color: Color.brandSecondary.opacity(0.3)),
                SparkleInfo(x: 0.48, y: 0.78, size: 4.0, color: Color.brandPrimary.opacity(0.3)),
                SparkleInfo(x: 0.82, y: 0.84, size: 5.0, color: Color.brandPrimary.opacity(0.3)),
                SparkleInfo(x: 0.32, y: 0.92, size: 3.0, color: Color.brandPurple.opacity(0.3))
            ]
            
            ZStack {
                // Background Sparkles
                ForEach(sparkles) { s in
                    Circle()
                        .fill(s.color)
                        .frame(width: s.size, height: s.size)
                        .position(x: width * s.x, y: height * s.y)
                }
                
                // Subtle Ambient Indicators under the bubbles (Starting soon / New activity keys)
                VStack {
                    Spacer()
                    HStack(spacing: 16) {
                        HStack(spacing: 8) {
                            Circle()
                                .stroke(Color.brandPrimary, lineWidth: 2)
                                .frame(width: 10, height: 10)
                            Text(AppStrings.Chat.startingSoon)
                                .font(.micro)
                                .foregroundColor(.textSecondary)
                        }
                        
                        Rectangle()
                            .fill(Color.appBorder)
                            .frame(width: 1, height: 12)
                        
                        HStack(spacing: 8) {
                            Circle()
                                .fill(Color.statusSuccess)
                                .frame(width: 8, height: 8)
                            Text(AppStrings.Chat.newActivity)
                                .font(.micro)
                                .foregroundColor(.textSecondary)
                        }
                    }
                    .padding(.bottom, 24)
                }
                .frame(maxWidth: .infinity)
                
                // Laying out bubbles with distinct scatter offsets based on screen width/height
                ForEach(Array(chats.enumerated()), id: \.element.id) { index, drift in
                    let bubbleSize = sizeForIndex(index)
                    let coords = positionForIndex(index, width: width, height: height)
                    
                    NavigationLink(value: drift) {
                        BubbleView(drift: drift, size: bubbleSize)
                    }
                    .buttonStyle(.plain)
                    .position(x: coords.x, y: coords.y)
                    .modifier(BubbleFloatModifier(delay: Double(index) * 0.25))
                }
            }
        }
        .frame(maxHeight: .infinity)
    }
    
    // MARK: - Compact Rooms List View Mode
    private func compactListView(chats: [Drift]) -> some View {
        ScrollView {
            VStack(spacing: 12) {
                ForEach(chats) { drift in
                    NavigationLink(value: drift) {
                        CompactChatRow(drift: drift)
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal, AppConstants.Layout.standardPadding)
                }
            }
            .padding(.vertical, 12)
        }
    }
    
    // MARK: - Helper sizing and coordinates scatter mapped to approved mockup layout
    private func sizeForIndex(_ index: Int) -> CGFloat {
        switch index {
        case 0: return 118 // Coffee after work (Large, unread, starting soon)
        case 1: return 96  // Street Food Walk (Medium/Large, unread)
        case 2: return 118 // Movie plan (Large, starting soon)
        case 3: return 118 // Morning walk (Large, unread, starting soon)
        case 4: return 84  // Books & chai (Medium, unread)
        case 5: return 84  // Workout buddy (Medium)
        case 6: return 84  // Chai Time (Medium)
        case 7: return 84  // Food (Medium, unread)
        case 8: return 72  // Coffee (Small)
        case 9: return 84  // Walks (Medium)
        case 10: return 84 // Movies (Medium)
        default: return 72
        }
    }
    
    private func positionForIndex(_ index: Int, width: CGFloat, height: CGFloat) -> CGPoint {
        // High density coordinates ensuring beautiful spacing exactly matching approved visual mockup
        switch index {
        case 0: return CGPoint(x: width * 0.76, y: height * 0.24) // Coffee after work (Large, top-right)
        case 1: return CGPoint(x: width * 0.50, y: height * 0.48) // Street Food Walk (Medium, center)
        case 2: return CGPoint(x: width * 0.28, y: height * 0.68) // Movie plan (Large, bottom-left)
        case 3: return CGPoint(x: width * 0.68, y: height * 0.88) // Morning walk (Large, bottom-right)
        case 4: return CGPoint(x: width * 0.54, y: height * 0.70) // Books & chai (Medium, bottom-center)
        case 5: return CGPoint(x: width * 0.30, y: height * 0.88) // Workout buddy (Medium, bottom-left)
        case 6: return CGPoint(x: width * 0.78, y: height * 0.70) // Chai Time (Medium, bottom-right)
        case 7: return CGPoint(x: width * 0.24, y: height * 0.20) // Food (Medium, top-left)
        case 8: return CGPoint(x: width * 0.48, y: height * 0.22) // Coffee (Small, top-center)
        case 9: return CGPoint(x: width * 0.25, y: height * 0.40) // Walks (Medium, middle-left)
        case 10: return CGPoint(x: width * 0.77, y: height * 0.48) // Movies (Medium, middle-right)
        default: return CGPoint(x: width * 0.5, y: height * 0.5)
        }
    }
    
    // MARK: - Empty State
    private var emptyStateView: some View {
        VStack(spacing: AppConstants.Layout.elementSpacing) {
            ZStack {
                Circle()
                    .fill(Color.brandPrimary.opacity(0.05))
                    .frame(width: 100, height: 100)
                Image(systemName: "bubble.left.and.bubble.right.fill")
                    .font(.system(size: 36))
                    .foregroundColor(.brandPrimary)
            }
            
            VStack(spacing: AppConstants.Layout.subElementSpacing - 2) {
                Text(AppStrings.Chat.emptyTitle)
                    .font(.heading2)
                    .foregroundColor(.textPrimary)
                Text(AppStrings.Chat.emptySubtitle)
                    .font(.bodyStandard)
                    .foregroundColor(.textSecondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, AppConstants.Layout.elementSpacing)
            
            Button(action: {
                // Return to Discover Screen tab index or Nearby Drifts (handled by Parent Router)
            }) {
                Text(AppStrings.Chat.exploreCTA)
                    .font(.buttonText)
                    .foregroundColor(.white)
                    .padding(.horizontal, 32)
                    .frame(height: 56)
                    .background(Color.brandPrimary)
                    .cornerRadius(28)
                    .shadow(color: Color.brandPrimary.opacity(0.2), radius: 8, x: 0, y: 4)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(AppConstants.Layout.sectionSpacing)
        .background(Color.surfaceMain)
        .cornerRadius(AppConstants.UI.cornerRadiusLarge)
        .overlay(
            RoundedRectangle(cornerRadius: AppConstants.UI.cornerRadiusLarge)
                .stroke(Color.appBorder, lineWidth: 1)
        )
        .padding(.horizontal, AppConstants.Layout.standardPadding)
    }
}

struct SparkleInfo: Identifiable {
    let id = UUID()
    let x: CGFloat
    let y: CGFloat
    let size: CGFloat
    let color: Color
}


// MARK: - Reusable Custom Bubble View
struct BubbleView: View {
    let drift: Drift
    let size: CGFloat
    
    @State private var pulseScale: CGFloat = 1.0
    
    var bubbleLabel: String {
        // High fidelity label matching bubble mockup
        if drift.title == "Movie plan" {
            return "Movie Night"
        } else if drift.title == "Books & chai" {
            return "Books"
        } else if drift.title == "Workout buddy" {
            return "Workout"
        }
        return drift.title
    }
    
    var bubbleTime: String {
        drift.time
            .replacingOccurrences(of: " • ", with: " ")
            .replacingOccurrences(of: " PM", with: "")
            .replacingOccurrences(of: " AM", with: "")
    }
    
    var body: some View {
        ZStack {
            // Glow ring / Halo if starting soon
            if drift.status == .startingSoon {
                Circle()
                    .stroke(drift.category.color.opacity(0.25), lineWidth: 3)
                    .blur(radius: 3)
                    .frame(width: size + 10, height: size + 10)
            }
            
            // Main Glass Bubble Surface
            Circle()
                .fill(Color.surfaceMain.opacity(0.7))
                .frame(width: size, height: size)
                .overlay(
                    Circle()
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.85),
                                    Color.white.opacity(0.0)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1.5
                        )
                )
                .shadow(color: drift.category.color.opacity(0.15), radius: 10, x: 0, y: 5)
            
            // Inner Glow / category accent ring
            Circle()
                .stroke(drift.category.color.opacity(0.12), lineWidth: 5)
                .padding(3)
            
            // Content
            VStack(spacing: 3) {
                Image(systemName: drift.category.icon)
                    .font(.system(size: size > 90 ? 24 : 18, weight: .bold))
                    .foregroundColor(drift.category.color)
                
                if size >= 80 {
                    Text(bubbleLabel)
                        .font(.system(size: size > 90 ? 11 : 9, weight: .bold))
                        .foregroundColor(.textPrimary)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                        .padding(.horizontal, 6)
                }
                
                if size > 90 && drift.status == .startingSoon {
                    Text(bubbleTime)
                        .font(.system(size: 9, weight: .bold))
                        .foregroundColor(.brandPrimary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(Color.brandPrimary.opacity(0.1))
                        .cornerRadius(6)
                        .padding(.top, 1)
                }
            }
            
            // Unread Pulse Dot / Activity Badge at upper-right (simple mint dot in mockup)
            if drift.unreadCount > 0 {
                Circle()
                    .fill(Color.statusSuccess)
                    .frame(width: 10, height: 10)
                    .scaleEffect(pulseScale)
                    .offset(x: size / 2.8, y: -size / 2.8)
                    .onAppear {
                        withAnimation(
                            Animation.easeInOut(duration: 1.2)
                                .repeatForever(autoreverses: true)
                        ) {
                            pulseScale = 1.2
                        }
                    }
            }
        }
        .contextMenu {
            Button {} label: {
                Label("Open Room", systemImage: AppIcons.chatGroup)
            }
            Button {} label: {
                Label("Info", systemImage: AppIcons.infoCircle)
            }
            Button {} label: {
                Label("Mute", systemImage: AppIcons.bellFill)
            }
        }
    }
}

// MARK: - Reusable Custom Bubble Float Modifier
struct BubbleFloatModifier: ViewModifier {
    let delay: Double
    @State private var offset = CGSize.zero
    
    func body(content: Content) -> some View {
        content
            .offset(offset)
            .onAppear {
                withAnimation(
                    Animation.easeInOut(duration: Double.random(in: 3.5...5.0))
                        .repeatForever(autoreverses: true)
                        .delay(delay)
                ) {
                    offset = CGSize(
                        width: CGFloat.random(in: -5...5),
                        height: CGFloat.random(in: -8...8)
                    )
                }
            }
    }
}

// MARK: - Reusable Compact Row View
struct CompactChatRow: View {
    let drift: Drift
    
    var body: some View {
        HStack(spacing: 12) {
            // Icon well (38x38 circle)
            ZStack {
                Circle()
                    .fill(drift.category.color.opacity(0.12))
                    .frame(width: 38, height: 38)
                
                Image(systemName: drift.category.icon)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(drift.category.color)
            }
            
            VStack(alignment: .leading, spacing: 3) {
                HStack(alignment: .firstTextBaseline) {
                    Text(drift.title)
                        .font(.bodySmall)
                        .foregroundColor(.textPrimary)
                        .lineLimit(1)
                    
                    Spacer()
                    
                    Text(drift.lastMessageTime ?? "")
                        .font(.metadata)
                        .foregroundColor(.textSecondary)
                }
                
                HStack(spacing: 8) {
                    Text(drift.lastMessage ?? "Start coordinating!")
                        .font(.captionText)
                        .foregroundColor(drift.unreadCount > 0 ? .textPrimary : .textSecondary)
                        .lineLimit(1)
                    
                    Spacer()
                    
                    if drift.unreadCount > 0 {
                        ZStack {
                            Circle()
                                .fill(Color.statusSuccess)
                                .frame(width: 18, height: 18)
                            
                            if drift.unreadCount > 1 {
                                Text("\(drift.unreadCount)")
                                    .font(.system(size: 9, weight: .black))
                                    .foregroundColor(.white)
                            }
                        }
                    }
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .frame(height: 60)
        .background(Color.surfaceMain)
        .cornerRadius(18)
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(Color.appBorder, lineWidth: 1)
        )
        .pressScale(0.98)
    }
}

#Preview {
    ChatsListScreen()
}
