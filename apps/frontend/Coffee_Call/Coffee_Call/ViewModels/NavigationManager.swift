import SwiftUI

class NavigationManager: ObservableObject {
    @Published private var tabBarHiddenSources: Set<String> = []
    @Published var activeInterestFilter: String? = nil
    
    static let shared = NavigationManager()
    
    var isTabBarHidden: Bool {
        !tabBarHiddenSources.isEmpty
    }
    
    func setTabBarHidden(_ isHidden: Bool, source: String) {
        if isHidden {
            tabBarHiddenSources.insert(source)
        } else {
            tabBarHiddenSources.remove(source)
        }
    }
    
    func resetTabBarVisibility() {
        tabBarHiddenSources.removeAll()
    }
}
