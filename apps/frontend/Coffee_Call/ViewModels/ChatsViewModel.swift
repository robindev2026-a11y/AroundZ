import SwiftUI
import Combine

// MARK: - Chat Service Dependency Injection
protocol ChatServiceProtocol {
    func getChats() -> [Drift]
    /// Called by the service whenever Firestore data changes.
    /// The ViewModel sets this closure to refresh its published state.
    var onUpdate: (([Drift]) -> Void)? { get set }
}

enum ChatFilter: String, CaseIterable, Identifiable {
    case active
    case joined
    case hosted
    case expired
    
    var id: String { self.rawValue }
    
    var title: String {
        switch self {
        case .active: return AppStrings.Chat.active
        case .joined: return AppStrings.Chat.joined
        case .hosted: return AppStrings.Chat.hosted
        case .expired: return AppStrings.Chat.expired
        }
    }
}

class ChatsViewModel: ObservableObject {
    var title: String { AppStrings.Chat.title }
    var subtitle: String? { AppStrings.Chat.subtitle }

    @Published var allChats: [Drift] = []

    private var chatService: ChatServiceProtocol

    init(chatService: ChatServiceProtocol? = nil) {
        self.chatService = chatService ?? FirebaseChatService()
        // Subscribe to live Firestore updates so UI refreshes when data arrives.
        self.chatService.onUpdate = { [weak self] updated in
            DispatchQueue.main.async { self?.allChats = updated }
        }
        loadChats()
    }

    func loadChats() {
        // getChats() returns cached/mock data immediately as a placeholder.
        // Real data arrives later via onUpdate when the Firestore listener fires.
        self.allChats = chatService.getChats()
    }
    
    func filteredChats(for filter: ChatFilter) -> [Drift] {
        switch filter {
        case .active:
            return allChats.filter { $0.status != .ended }
        case .joined:
            return allChats.filter { !$0.isMine && $0.status != .ended }
        case .hosted:
            return allChats.filter { $0.isMine && $0.status != .ended }
        case .expired:
            return allChats.filter { $0.status == .ended }
        }
    }
}


