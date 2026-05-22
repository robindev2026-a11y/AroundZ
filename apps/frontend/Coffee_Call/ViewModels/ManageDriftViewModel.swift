import SwiftUI
import Combine
	
class ManageDriftViewModel: ObservableObject {
    @Published var drift: Drift
    @Published var isLoading = false
    @Published var didDelete = false
    @Published var showErrorAlert = false
    @Published var errorAlertMessage = ""
    
    var canEdit: Bool { drift.isMine && drift.status != .ended }
    
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
        
        // Populate sample pending requests for non‑Firebase debug builds
        let isFirebaseEnabled = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist") != nil
        if !isFirebaseEnabled && self.drift.pendingRequests.isEmpty {
            self.drift.pendingRequests = [
                JoinRequest(userName: "Sneha R.", userInitials: "SR", userRole: "Loves evening walks and good conversations.", message: "I'm looking for a chill walk!", timestamp: "10 mins ago"),
                JoinRequest(userName: "Karthik M.", userInitials: "KM", userRole: "Looking forward to joining!", message: "I live nearby!", timestamp: "25 mins ago")
            ]
        }
    }
    
    private func presentError(_ message: String) {
        errorAlertMessage = message
        showErrorAlert = true
    }
    
    // MARK: - Join Requests
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
    
    // MARK: - Drift Actions
    func closeDrift() {
        guard drift.status != .ended else { return }
        isLoading = true
        driftsService.updateDriftStatus(driftId: drift.id, status: .ended)
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: { [weak self] completionResult in
                self?.isLoading = false
                if case .failure(let error) = completionResult {
                    print("Error closing drift: \(error)")
                    self?.presentError("Failed to close drift: \(error.localizedDescription)")
                }
            }, receiveValue: { [weak self] in
                guard let self else { return }
                withAnimation { drift.status = .ended }
            })
            .store(in: &cancellables)
    }
    
    func editDrift(updated: Drift) {
        isLoading = true
        driftsService.updateDrift(updated)
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: { [weak self] completionResult in
                self?.isLoading = false
                if case .failure(let error) = completionResult {
                    print("Error editing drift: \(error)")
                    self?.presentError("Failed to save changes: \(error.localizedDescription)")
                }
            }, receiveValue: { [weak self] in
                guard let self else { return }
                withAnimation { drift = updated }
            })
            .store(in: &cancellables)
    }
    
    func deleteDrift() {
        isLoading = true
        driftsService.deleteDrift(driftId: drift.id)
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: { [weak self] completionResult in
                self?.isLoading = false
                if case .failure(let error) = completionResult {
                    print("Error deleting drift: \(error)")
                    self?.presentError("Failed to delete drift: \(error.localizedDescription)")
                }
            }, receiveValue: { })
            .store(in: &cancellables)
        
        // For non-transactional delete calls, success arrives via completion (finished) and we set didDelete there.
        // Some publishers send a value before finishing; handle that as success as well.
        driftsService.deleteDrift(driftId: drift.id)
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: { [weak self] completionResult in
                if case .finished = completionResult {
                    self?.didDelete = true
                }
            }, receiveValue: { [weak self] in
                self?.didDelete = true
            })
            .store(in: &cancellables)
    }

    
    func shareDrift() {
        let inviteText = AppStrings.Drifts.Detail.inviteText(
            title: drift.title,
            date: drift.date,
            time: drift.time,
            location: drift.location
        )
        UIApplication.shareText(inviteText)
    }
}
