import Foundation
import Network
import Combine

/// Central network connectivity monitor used across the app.
///
/// The manager observes the device's internet connection using `NWPathMonitor`.
/// It publishes a `Bool` flag via `@Published var isConnected` which UI can observe
/// to present offline warnings or prevent network operations.
final class NetworkManager: ObservableObject {
    static let shared = NetworkManager()

    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkMonitorQueue")

    @Published var isConnected: Bool = true
    private var cancellables = Set<AnyCancellable>()

    private init() {
        monitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                self?.isConnected = path.status == .satisfied
            }
        }
        monitor.start(queue: queue)
    }

    /// Stop monitoring – call when the app terminates if needed.
    func stop() {
        monitor.cancel()
    }
}
