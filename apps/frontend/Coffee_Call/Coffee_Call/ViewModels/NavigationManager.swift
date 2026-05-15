import SwiftUI

class NavigationManager: ObservableObject {
    @Published var isTabBarHidden: Bool = false
    
    static let shared = NavigationManager()
}
