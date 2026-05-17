import SwiftUI

/// A premium, reusable glassmorphic bottom sheet with built-in spring-loaded drag gestures and snapping physics.
struct CoffeeBottomSheet<Content: View>: View {
    
    // MARK: - Bindings & Properties
    
    @Binding var sheetOffset: CGFloat
    @Binding var dragOffset: CGFloat // Exposed for reactive sibling animations
    let geo: GeometryProxy
    @ViewBuilder let content: () -> Content
    
    private var currentSheetOffset: CGFloat {
        max(
            AppConstants.Layout.sheetExpandedOffset,
            min(AppConstants.Layout.sheetCollapsedOffset, sheetOffset + dragOffset)
        )
    }
    
    // MARK: - Body
    
    var body: some View {
        VStack(spacing: 0) {
            
            // 1. The Standardized Drag Handle Capsule
            Capsule()
                .fill(Color.textSecondary.opacity(AppConstants.UI.opacityMuted))
                .frame(width: AppConstants.Layout.sheetHandleWidth, height: AppConstants.Layout.sheetHandleHeight)
                .padding(.top, AppConstants.Layout.sheetHandleTopPadding)
                .padding(.bottom, AppConstants.Layout.sheetHandleBottomPadding)
            
            // 2. The Custom Page Content
            content()
        }
        .frame(width: geo.size.width, height: geo.size.height)
        .background(
            RoundedRectangle(cornerRadius: AppConstants.Layout.sheetRadius, style: .continuous)
                .fill(.ultraThinMaterial)
                .shadow(color: .black.opacity(0.08), radius: 18, x: 0, y: -8)
        )
        .offset(y: currentSheetOffset)
        // 3. Fully Encapsulated Drag Gesture & Velocity Snapping Math!
        .simultaneousGesture(
            DragGesture(minimumDistance: 5)
                .onChanged { value in
                    dragOffset = value.translation.height
                }
                .onEnded { value in
                    let translation = value.translation.height
                    let velocity = value.predictedEndTranslation.height - translation
                    
                    withAnimation(.spring(response: 0.38, dampingFraction: 0.85)) {
                        if translation < -AppConstants.Layout.sheetSnapThreshold || velocity < -100 {
                            sheetOffset = AppConstants.Layout.sheetExpandedOffset
                        } else if translation > AppConstants.Layout.sheetSnapThreshold || velocity > 100 {
                            sheetOffset = AppConstants.Layout.sheetCollapsedOffset
                        } else {
                            // Mid-point snapping logic
                            let midPoint = (AppConstants.Layout.sheetCollapsedOffset + AppConstants.Layout.sheetExpandedOffset) / 2
                            if currentSheetOffset < midPoint {
                                sheetOffset = AppConstants.Layout.sheetExpandedOffset
                            } else {
                                sheetOffset = AppConstants.Layout.sheetCollapsedOffset
                            }
                        }
                        dragOffset = 0
                    }
                }
        )
        .ignoresSafeArea(edges: .bottom)
    }
}
