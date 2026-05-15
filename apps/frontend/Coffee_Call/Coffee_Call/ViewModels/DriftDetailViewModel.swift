import SwiftUI
import Combine

class DriftDetailViewModel: ObservableObject {
    @Published var drift: Drift
    @Published var joinStatus: JoinStatus = .notJoined
    
    enum JoinStatus {
        case notJoined
        case requested
        case joined
        case full
        case ended
    }
    
    init(drift: Drift) {
        self.drift = drift
        
        // Initial status logic
        if drift.spotsLeft == 0 {
            self.joinStatus = .full
        } else {
            self.joinStatus = .notJoined
        }
    }
    
    func joinDrift() {
        withAnimation(.spring()) {
            // Logic for requesting or joining directly
            // For now, let's say it's an instant join for the demo
            self.joinStatus = .joined
        }
    }
    
    func requestToJoin() {
        withAnimation(.spring()) {
            self.joinStatus = .requested
        }
    }
    
    func saveDrift() {
        print("Saving drift...")
    }
    
    func shareDrift() {
        print("Sharing drift...")
    }
    
    func setReminder() {
        print("Setting reminder...")
    }
}
