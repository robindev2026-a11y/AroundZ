import Foundation
import Combine

final class NetworkInterceptor {
    static let shared = NetworkInterceptor()

    enum InterceptorError: LocalizedError {
        case offline
        case timeout
        
        var errorDescription: String? {
            switch self {
            case .offline: return "No internet connection. Please check your network and try again."
            case .timeout: return "The request timed out. Please try again."
            }
        }
    }

    /// Executes a given publisher with network validation and timeout protection.
    func execute<T>(_ publisher: AnyPublisher<T, Error>, timeout: TimeInterval = 15.0) -> AnyPublisher<T, Error> {
        guard NetworkManager.shared.isConnected else {
            return Fail(error: InterceptorError.offline)
                .receive(on: RunLoop.main)
                .eraseToAnyPublisher()
        }
        
        return publisher
            .timeout(.seconds(timeout), scheduler: RunLoop.main, customError: { InterceptorError.timeout })
            .receive(on: RunLoop.main)
            .eraseToAnyPublisher()
    }
}
