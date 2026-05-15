import SwiftUI
import UIKit

// MARK: - Navigation Gesture Fix
// Standard SwiftUI behavior disables the swipe-to-back gesture 
// when the default back button is hidden or replaced.
// This extension restores the gesture globally.

extension UINavigationController: UIGestureRecognizerDelegate {
    override open func viewDidLoad() {
        super.viewDidLoad()
        interactivePopGestureRecognizer?.delegate = self
    }

    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return viewControllers.count > 1
    }
}
