import SwiftUI

class NavigationManager: ObservableObject {
    @Published private var tabBarHiddenSources: Set<String> = []
    @Published var activeInterestFilter: String? = nil
    @Published var isTabBarHidden: Bool = false
    
    static let shared = NavigationManager()
    
    func setTabBarHidden(_ isHidden: Bool, source: String) {
        DispatchQueue.main.async {
            if isHidden {
                self.tabBarHiddenSources.insert(source)
            } else {
                self.tabBarHiddenSources.remove(source)
            }
            self.isTabBarHidden = !self.tabBarHiddenSources.isEmpty
        }
    }
    
    func resetTabBarVisibility() {
        DispatchQueue.main.async {
            self.tabBarHiddenSources.removeAll()
            self.isTabBarHidden = false
        }
    }
}
