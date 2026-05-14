import SwiftUI

// MARK: - Availability-Gated SwiftUI Modifiers
//
// These wrappers keep call-sites clean and future-proof.
// Each wrapper is a no-op on the current SDK and activates automatically
// once the project is built against the required Xcode / SDK version.
//
// Activation guide:
//   iOS 16.4+ APIs → uncomment when building with Xcode 14.3+
//   iOS 17+  APIs  → uncomment when building with Xcode 15+
//
// Never add raw `if #available` blocks inside screens — add a helper here.

extension View {

    // -------------------------------------------------------------------------
    // MARK: iOS 16.4+ — Sheet corner radius   (requires Xcode 14.3+)
    // -------------------------------------------------------------------------
    /// Rounds the detent sheet corners.
    /// Uncomment the body when building with Xcode 14.3+ (iOS 16.4 SDK).
    @ViewBuilder
    func coffeeSheetCornerRadius(_ radius: CGFloat) -> some View {
        // if #available(iOS 16.4, *) { self.presentationCornerRadius(radius) } else { self }
        self
    }

    // -------------------------------------------------------------------------
    // MARK: iOS 16.4+ — Sheet drag indicator   (requires Xcode 14.3+)
    // -------------------------------------------------------------------------
    /// Shows/hides the sheet drag indicator.
    /// visibility: SwiftUI.Visibility (.visible / .hidden / .automatic)
    /// Uncomment the body when building with Xcode 14.3+ (iOS 16.4 SDK).
    @ViewBuilder
    func coffeeSheetDragIndicator(_ visibility: Visibility) -> some View {
        // if #available(iOS 16.4, *) { self.presentationDragIndicator(visibility) } else { self }
        self
    }

    // -------------------------------------------------------------------------
    // MARK: iOS 16.4+ — Scroll bounce   (requires Xcode 14.3+)
    // -------------------------------------------------------------------------
    /// Disables over-scroll bounce when content fits the scroll view.
    /// Uncomment the body when building with Xcode 14.3+ (iOS 16.4 SDK).
    @ViewBuilder
    func coffeeScrollBounceBehaviorBasedOnSize() -> some View {
        // if #available(iOS 16.4, *) { self.scrollBounceBehavior(.basedOnSize) } else { self }
        self
    }

    // -------------------------------------------------------------------------
    // MARK: iOS 17+ — Scroll target layout   (requires Xcode 15+)
    // -------------------------------------------------------------------------
    /// Marks a layout as a scroll-target container for snapped scrolling.
    /// Pair with .scrollTargetBehavior(.viewAligned) on the parent ScrollView.
    /// Uncomment the body when building with Xcode 15+ (iOS 17 SDK).
    @ViewBuilder
    func coffeeScrollTargetLayout() -> some View {
        // if #available(iOS 17, *) { self.scrollTargetLayout() } else { self }
        self
    }

    // -------------------------------------------------------------------------
    // MARK: iOS 17+ — Impact haptic   (requires Xcode 15+)
    // -------------------------------------------------------------------------
    /// Plays a light impact haptic when `trigger` changes.
    /// Uncomment the body when building with Xcode 15+ (iOS 17 SDK).
    @ViewBuilder
    func coffeeImpactFeedback<T: Equatable>(trigger: T) -> some View {
        // if #available(iOS 17, *) { self.sensoryFeedback(.impact(weight: .light), trigger: trigger) } else { self }
        self
    }

    // -------------------------------------------------------------------------
    // MARK: iOS 17+ — Selection haptic   (requires Xcode 15+)
    // -------------------------------------------------------------------------
    /// Plays a selection haptic when `trigger` changes.
    /// Uncomment the body when building with Xcode 15+ (iOS 17 SDK).
    @ViewBuilder
    func coffeeSelectionFeedback<T: Equatable>(trigger: T) -> some View {
        // if #available(iOS 17, *) { self.sensoryFeedback(.selection, trigger: trigger) } else { self }
        self
    }

    // -------------------------------------------------------------------------
    // MARK: iOS 17+ — Symbol bounce effect   (requires Xcode 15+)
    // -------------------------------------------------------------------------
    /// Bounces the SF Symbol when `trigger` changes.
    /// Uncomment the body when building with Xcode 15+ (iOS 17 SDK).
    @ViewBuilder
    func coffeeBounceSymbol<T: Equatable>(trigger: T) -> some View {
        // if #available(iOS 17, *) { self.symbolEffect(.bounce, value: trigger) } else { self }
        self
    }

    // -------------------------------------------------------------------------
    // MARK: iOS 17+ — Numeric content transition   (requires Xcode 15+)
    // -------------------------------------------------------------------------
    /// Cross-fades number/text changes in Text views.
    /// Uncomment the body when building with Xcode 15+ (iOS 17 SDK).
    @ViewBuilder
    func coffeeNumericContentTransition() -> some View {
        // if #available(iOS 17, *) { self.contentTransition(.numericText()) } else { self }
        self
    }
}
