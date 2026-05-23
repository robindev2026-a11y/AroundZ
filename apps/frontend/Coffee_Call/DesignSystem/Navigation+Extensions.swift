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

// MARK: - Native Share Sheet Helper
extension UIApplication {
    static func shareText(_ text: String) {
        guard let windowScene = (shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene)
                ?? (shared.connectedScenes.first as? UIWindowScene) else {
            return
        }

        let rootVC = windowScene.windows.first(where: { $0.isKeyWindow })?.rootViewController
            ?? windowScene.windows.first?.rootViewController

        guard let rootVC else {
            return
        }
        
        var topVC = rootVC
        while let presented = topVC.presentedViewController {
            topVC = presented
        }
        
        let activityVC = UIActivityViewController(activityItems: [text], applicationActivities: nil)
        
        if let popover = activityVC.popoverPresentationController {
            popover.sourceView = topVC.view
            popover.sourceRect = CGRect(x: topVC.view.bounds.midX, y: topVC.view.bounds.midY, width: 0, height: 0)
            popover.permittedArrowDirections = []
        }
        
        topVC.present(activityVC, animated: true)
    }
}

// MARK: - Lazy Navigation Wrapper
struct LazyView<Content: View>: View {
    private let build: () -> Content
    
    init(_ build: @autoclosure @escaping () -> Content) {
        self.build = build
    }
    
    var body: Content {
        build()
    }
}
