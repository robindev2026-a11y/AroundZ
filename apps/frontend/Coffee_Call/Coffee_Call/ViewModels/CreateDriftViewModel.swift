import SwiftUI
import Combine

class CreateDriftViewModel: ObservableObject {
    enum LocationState {
        case resolving
        case permissionMissing
        case resolved
    }
    
    @Published var selectedActivity: String = "Coffee"
    @Published var planTitle: String = ""
    @Published var selectedTime: String = "Now"
    @Published var location: String = "Detecting your location..."
    @Published var locationState: LocationState = .resolving
    @Published var capacity: Int = 3
    @Published var joinMode: String = "Anyone can join"
    
    // Optional
    @Published var hook: String = ""
    @Published var selectedVibe: String?
    @Published var notes: String = ""
    
    @Published var isCreating: Bool = false
    @Published var isSuccess: Bool = false
    @Published var createdDrift: Drift?
    
    let activities = ["Coffee", "Walk", "Food", "Movie", "Study", "Fitness", "Games", "Custom"]
    let times = ["Now", "In 30 mins", "Tonight", "Tomorrow", "Custom"]
    let vibes = ["Relaxed", "Productive", "Fun", "Deep chat", "Quick meet", "Active"]
    let hooks = ["Coffee on me", "Have coupons", "Free entry", "Bring a friend", "Custom"]
    let capacities = [1, 3, 5, 8]
    let joinModes = ["Anyone can join", "Approve requests"]
    
    var isDirty: Bool {
        !planTitle.isEmpty || !hook.isEmpty || !notes.isEmpty || selectedVibe != nil
    }
    
    init() {
        simulateLocationResolving()
    }
    
    func simulateLocationResolving() {
        locationState = .resolving
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.location = "Indiranagar, Bengaluru"
            self.locationState = .resolved
        }
    }
    
    func requestLocationPermission() {
        // Mock permission request
        simulateLocationResolving()
    }
    
    func createDrift() {
        guard !planTitle.isEmpty else { return }
        
        isCreating = true
        
        // Mock creation delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.isCreating = false
            self.isSuccess = true
            // Mock created drift
            self.createdDrift = Drift(
                title: self.planTitle,
                description: self.notes,
                location: self.location,
                meetingPoint: "",
                time: self.selectedTime,
                endTime: "",
                date: "Today",
                distance: 0.2,
                status: .open,
                category: .coffee,
                hook: self.hook,
                host: Host(name: "You", role: "Host", imageUrl: nil, isVerified: true),
                peopleGoing: 1,
                spotsLeft: self.capacity - 1,
                capacity: self.capacity,
                vibeTags: [self.selectedVibe].compactMap { $0 },
                whatToBring: [],
                notes: self.notes,
                participantInitials: ["Y"],
                imageUrl: nil
            )
        }
    }
}
