// LocationViewModel.swift
import Foundation
import Combine

final class LocationViewModel: ObservableObject {
    @Published private(set) var locationString: String = ""
    private var cancellables = Set<AnyCancellable>()
    
    /// Requests location and returns a `Result<LocationModel, Error>`.
    func requestLocation(completion: @escaping (Result<LocationModel, Error>) -> Void) {
        LocationService.shared.fetchLocation { result in
            switch result {
            case .success(let model):
                let display = model.displayString
                DispatchQueue.main.async {
                    self.locationString = display
                    completion(.success(model))
                }
            case .failure(let err):
                DispatchQueue.main.async {
                    self.locationString = ""
                    completion(.failure(err))
                }
                print("Location error: \(err.localizedDescription)")
            }
        }
    }
}
