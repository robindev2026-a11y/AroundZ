import SwiftUI
import Combine

class ManageDriftViewModel: ObservableObject {
    @Published var drift: Drift
    @Published var isLoading = false
    
    init(drift: Drift) {
        self.drift = drift
        
        // Mocking some pending requests if none exist
        if self.drift.pendingRequests.isEmpty {
            self.drift.pendingRequests = [
                JoinRequest(userName: "Sneha R.", userInitials: "SR", userRole: "Loves evening walks and good conversations.", message: "I'm looking for a chill walk!", timestamp: "10 mins ago"),
                JoinRequest(userName: "Karthik M.", userInitials: "KM", userRole: "Looking forward to joining!", message: "I live nearby!", timestamp: "25 mins ago")
            ]
        }
    }
    
    func acceptRequest(_ request: JoinRequest) {
        withAnimation {
            drift.pendingRequests.removeAll { $0.id == request.id }
            // Add to participant initials (mock)
            drift.participantInitials.append(request.userInitials)
        }
    }
    
    func rejectRequest(_ request: JoinRequest) {
        withAnimation {
            drift.pendingRequests.removeAll { $0.id == request.id }
        }
    }
    
    func closeDrift() {
        // Logic to close the drift
    }
    
    func deleteDrift() {
        // Logic to delete the drift
    }
    
    func editDrift() {
        // Navigation to edit
    }
    
    func shareDrift() {
        // Share sheet
    }
}
