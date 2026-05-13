import SwiftUI

// MARK: - CoffeeCall Animation System
// All animations used in the app must come from here.
// Never hardcode animation values inline — reference these tokens.

enum CoffeeAnimation {

    // MARK: - Spring Presets
    /// Default spring for most UI transitions (tab switches, chip selection)
    static let spring = Animation.spring(response: 0.35, dampingFraction: 0.72)

    /// Snappier spring for button press feedback
    static let springSnap = Animation.spring(response: 0.2, dampingFraction: 0.65)

    /// Gentle spring for card entrance / list items
    static let springGentle = Animation.spring(response: 0.55, dampingFraction: 0.8)

    // MARK: - Ease Presets
    /// Standard easeOut for screen transitions / fade-ins
    static let easeOut = Animation.easeOut(duration: 0.28)

    /// Slow fade for background overlays
    static let easeOutSlow = Animation.easeOut(duration: 0.45)

    // MARK: - Durations
    static let shortDuration: Double = 0.2
    static let standardDuration: Double = 0.3
    static let longDuration: Double = 0.5
}

// MARK: - Button Press Scale Modifier
/// Replicates the subtle scale-down on press seen in the Figma design
struct PressScaleModifier: ViewModifier {
    var scale: CGFloat = 0.96

    @State private var isPressed = false

    func body(content: Content) -> some View {
        content
            .scaleEffect(isPressed ? scale : 1.0)
            .animation(CoffeeAnimation.springSnap, value: isPressed)
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in isPressed = true }
                    .onEnded   { _ in isPressed = false }
            )
    }
}

// MARK: - Slide-Up Entrance Modifier
/// Slide up + fade in — used on screen load and card entrance
struct SlideUpEntranceModifier: ViewModifier {
    var delay: Double = 0
    @State private var appeared = false

    func body(content: Content) -> some View {
        content
            .opacity(appeared ? 1 : 0)
            .offset(y: appeared ? 0 : 24)
            .onAppear {
                withAnimation(CoffeeAnimation.springGentle.delay(delay)) {
                    appeared = true
                }
            }
    }
}

// MARK: - Fade-In Modifier
struct FadeInModifier: ViewModifier {
    var delay: Double = 0
    @State private var appeared = false

    func body(content: Content) -> some View {
        content
            .opacity(appeared ? 1 : 0)
            .onAppear {
                withAnimation(CoffeeAnimation.easeOut.delay(delay)) {
                    appeared = true
                }
            }
    }
}

// MARK: - View Extensions (clean call-site API)
extension View {
    /// Scale down on press — Figma button feedback
    func pressScale(_ scale: CGFloat = 0.96) -> some View {
        modifier(PressScaleModifier(scale: scale))
    }

    /// Slide up and fade in on appear
    func slideUpEntrance(delay: Double = 0) -> some View {
        modifier(SlideUpEntranceModifier(delay: delay))
    }

    /// Fade in on appear
    func fadeIn(delay: Double = 0) -> some View {
        modifier(FadeInModifier(delay: delay))
    }
}
