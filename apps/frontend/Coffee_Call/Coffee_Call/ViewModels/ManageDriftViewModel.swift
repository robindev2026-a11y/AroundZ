import SwiftUI
import Combine

class ManageDriftViewModel: ObservableObject {
    @Published var drift: Drift
    @Published var isLoading = false
    
    private let driftsService: DriftsServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    
    init(drift: Drift, driftsService: DriftsServiceProtocol? = nil) {
        self.drift = drift
        if let driftsService = driftsService {
            self.driftsService = driftsService
        } else {
            let isFirebaseEnabled = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist") != nil
            self.driftsService = isFirebaseEnabled ? FirebaseDriftsService() : MockDriftsService()
        }
        
        let isFirebaseEnabled = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist") != nil
        if !isFirebaseEnabled && self.drift.pendingRequests.isEmpty {
            self.drift.pendingRequests = [
                JoinRequest(userName: "Sneha R.", userInitials: "SR", userRole: "Loves evening walks and good conversations.", message: "I'm looking for a chill walk!", timestamp: "10 mins ago"),
                JoinRequest(userName: "Karthik M.", userInitials: "KM", userRole: "Looking forward to joining!", message: "I live nearby!", timestamp: "25 mins ago")
            ]
        }
    }
    
    func acceptRequest(_ request: JoinRequest) {
        isLoading = true
        driftsService.acceptJoinRequest(driftId: drift.id, request: request)
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: { [weak self] completionResult in
                self?.isLoading = false
                if case .failure(let error) = completionResult {
                    print("Error accepting join request: \(error)")
                }
            }, receiveValue: { [weak self] in
                guard let self = self else { return }
                withAnimation {
                    self.drift.pendingRequests.removeAll { $0.id == request.id }
                    if !self.drift.participantInitials.contains(request.userInitials) {
                        self.drift.participantInitials.append(request.userInitials)
                    }
                    self.drift.peopleGoing += 1
                    if let spots = self.drift.spotsLeft {
                        self.drift.spotsLeft = max(spots - 1, 0)
                    }
                }
            })
            .store(in: &cancellables)
    }
    
    func rejectRequest(_ request: JoinRequest) {
        isLoading = true
        driftsService.rejectJoinRequest(driftId: drift.id, requestId: request.id)
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: { [weak self] completionResult in
                self?.isLoading = false
                if case .failure(let error) = completionResult {
                    print("Error rejecting join request: \(error)")
                }
            }, receiveValue: { [weak self] in
                guard let self = self else { return }
                withAnimation {
                    self.drift.pendingRequests.removeAll { $0.id == request.id }
                }
            })
            .store(in: &cancellables)
    }
    
    func closeDrift() {
        isLoading = true
        driftsService.updateDriftStatus(driftId: drift.id, status: .ended)
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: { [weak self] completionResult in
                self?.isLoading = false
                if case .failure(let error) = completionResult {
                    print("Error closing drift: \(error)")
                }
            }, receiveValue: { [weak self] in
                guard let self = self else { return }
                withAnimation {
                    self.drift.status = .ended
                }
            })
            .store(in: &cancellables)
    }
    
    func deleteDrift() {
        // Logic to delete the drift
    }
    
    func editDrift() {
        // Navigation to edit
    }
    
    func shareDrift() {
        let inviteText = "Hey! Join me for '\(drift.title)' on \(drift.date) at \(drift.time) at \(drift.location). Let's catch up! Download CoffeeCall to join."
        UIApplication.shareText(inviteText)
    }
}
