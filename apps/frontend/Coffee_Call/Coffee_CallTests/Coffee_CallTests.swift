//
//  Coffee_CallTests.swift
//  Coffee_CallTests
//
//  Created by Development on 12/05/26.
//

import XCTest
import Combine
@testable import Coffee_Call

final class Coffee_CallTests: XCTestCase {

    override func setUpWithError() throws {
        NavigationManager.shared.resetTabBarVisibility()
        NavigationManager.shared.activeInterestFilter = nil
    }

    override func tearDownWithError() throws {
        NavigationManager.shared.resetTabBarVisibility()
        NavigationManager.shared.activeInterestFilter = nil
    }

    func testMockDiscoveryServiceDataLoading() throws {
        let service = MockDiscoveryService()
        let categories = service.fetchInterestCategories()
        let radarPeople = service.fetchRadarPeople()
        
        XCTAssertEqual(categories.count, 8)
        XCTAssertEqual(radarPeople.count, 5)
        
        // Validate ISSUE-005: Retention of name and presence/interests support in model
        let firstPerson = try XCTUnwrap(radarPeople.first)
        XCTAssertEqual(firstPerson.initials, "LM")
        XCTAssertEqual(firstPerson.name, "Liam M.")
        XCTAssertFalse(firstPerson.interests.isEmpty)
    }

    func testDiscoveryViewModelDependencyInjection() throws {
        struct StubDiscoveryService: DiscoveryServiceProtocol {
            func fetchInterestCategories() -> [InterestCategory] {
                [InterestCategory(id: "TestInterest", label: "Test", icon: "sparkles", count: 1)]
            }
            func fetchRadarPeople() -> [RadarPerson] {
                [RadarPerson(initials: "TP", name: "Test Person", color: .red, distance: 0.5, angle: 90, hasPresence: true, interests: ["Test"])]
            }
        }
        
        let stubService = StubDiscoveryService()
        let viewModel = DiscoveryViewModel(service: stubService)
        
        XCTAssertEqual(viewModel.interestCategories.count, 1)
        XCTAssertEqual(viewModel.interestCategories.first?.id, "TestInterest")
        XCTAssertEqual(viewModel.radarPeople.count, 1)
        XCTAssertEqual(viewModel.radarPeople.first?.initials, "TP")
        XCTAssertEqual(viewModel.radarPeople.first?.name, "Test Person")
    }

    // MARK: - Batch B Tests (ISSUE-024)

    func testMockDriftsServiceDataLoading() throws {
        let service = MockDriftsService()
        var loadedDrifts: [Drift] = []
        let expectation = self.expectation(description: "Loading mock drifts")
        
        let cancellable = service.fetchDrifts()
            .sink(receiveCompletion: { _ in }, receiveValue: { drifts in
                loadedDrifts = drifts
                expectation.fulfill()
            })
            
        waitForExpectations(timeout: 1.0)
        cancellable.cancel()
        
        XCTAssertEqual(loadedDrifts.count, 4)
        XCTAssertTrue(loadedDrifts.contains(where: { $0.title == "Coffee Drift" }))
    }
    
    func testDriftsViewModelDependencyInjection() throws {
        struct StubDriftsService: DriftsServiceProtocol {
            func fetchDrifts() -> AnyPublisher<[Drift], Error> {
                let mockHost = Host(name: "Test Host", role: "Test", imageUrl: nil, isVerified: false)
                let drift = Drift(
                    title: "Test Stub Drift",
                    description: "Desc",
                    location: "Loc",
                    meetingPoint: "Meet",
                    time: "10:00 AM",
                    endTime: "11:00 AM",
                    date: "Today",
                    distance: 0.5,
                    status: .open,
                    category: .gaming,
                    hook: nil,
                    host: mockHost,
                    peopleGoing: 1,
                    spotsLeft: 3,
                    capacity: 4,
                    vibeTags: [],
                    whatToBring: [],
                    notes: nil,
                    participantInitials: [],
                    imageUrl: nil,
                    isMine: false
                )
                return Just([drift])
                    .setFailureType(to: Error.self)
                    .eraseToAnyPublisher()
            }
        }
        
        let stubService = StubDriftsService()
        let viewModel = DriftsViewModel(driftsService: stubService)
        
        XCTAssertEqual(viewModel.drifts.count, 1)
        XCTAssertEqual(viewModel.drifts.first?.title, "Test Stub Drift")
        XCTAssertEqual(viewModel.drifts.first?.category, .gaming)
    }
    
    func testDriftsViewModelFilteringAndSearch() throws {
        let viewModel = DriftsViewModel(driftsService: MockDriftsService())
        
        // Default mode is discover, all time states, category nil
        XCTAssertEqual(viewModel.selectedMode, .discover)
        XCTAssertEqual(viewModel.selectedTimeState, .all)
        XCTAssertNil(viewModel.selectedCategory)
        
        // Discover mode contains mock drifts with isMine = false (3 items)
        XCTAssertEqual(viewModel.filteredDrifts.count, 3)
        
        // Clear category and switch mode to mine
        viewModel.selectedCategory = nil
        viewModel.selectedMode = .mine
        XCTAssertEqual(viewModel.filteredDrifts.count, 1) // Only Coffee Drift (isMine = true)
        
        // Search filter matching description
        viewModel.isSearchActive = true
        viewModel.debouncedSearchQuery = "Spontaneous"
        XCTAssertEqual(viewModel.filteredDrifts.count, 1) // matches Coffee Drift
        
        // Search filter not matching description
        viewModel.debouncedSearchQuery = "xyz123"
        XCTAssertEqual(viewModel.filteredDrifts.count, 0)
    }
    
    func testDiscoveryToDriftsHandoffPlumbing() throws {
        // Setup initial handoff state
        NavigationManager.shared.activeInterestFilter = "Walks"
        
        let viewModel = DriftsViewModel(driftsService: MockDriftsService())
        
        // The handoff sink runs on init when activeInterestFilter is set.
        // It sets selectedMode to .discover and selectedCategory to .walk,
        // then resets activeInterestFilter to nil immediately.
        XCTAssertEqual(viewModel.selectedMode, .discover)
        XCTAssertEqual(viewModel.selectedCategory, .walk)
        
        // Wait briefly for main thread queue run loop
        let expectation = self.expectation(description: "Handoff reset expectation")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertNil(NavigationManager.shared.activeInterestFilter)
            expectation.fulfill()
        }
        waitForExpectations(timeout: 0.5)
    }
    
    // MARK: - Batch C Tests
    
    func testDriftDetailViewModelStartsRequestedForNonHostUntilAccepted() throws {
        let viewModel = DriftDetailViewModel(drift: makeDrift())
        
        XCTAssertFalse(viewModel.canAccessChat)
        
        viewModel.requestToJoin()
        
        XCTAssertEqual(viewModel.joinStatus, .requested)
        XCTAssertFalse(viewModel.canAccessChat)
    }
    
    func testDriftDetailViewModelStartsJoinedForHostedDrift() throws {
        let viewModel = DriftDetailViewModel(drift: makeDrift(isMine: true))
        
        XCTAssertEqual(viewModel.joinStatus, .joined)
        XCTAssertTrue(viewModel.canAccessChat)
    }
    
    func testDriftChatViewModelLoadsInjectedThreadData() throws {
        struct StubThreadService: DriftChatThreadServiceProtocol {
            func loadThread(for drift: Drift) -> DriftChatThreadContext {
                DriftChatThreadContext(
                    systemMessages: [
                        SystemMessage(
                            content: "Request accepted",
                            icon: AppIcons.verified,
                            timestamp: Date()
                        )
                    ],
                    messages: [
                        ChatMessage(
                            senderId: "host",
                            senderName: "Host",
                            senderInitials: "HO",
                            content: "Welcome in",
                            timestamp: Date(),
                            isSelf: false,
                            status: .sent
                        )
                    ],
                    participants: [
                        ParticipantInfo(
                            initials: "HO",
                            name: "Host",
                            color: .brandPrimary,
                            isHost: true,
                            isMe: false
                        )
                    ]
                )
            }
        }
        
        let viewModel = DriftChatViewModel(
            drift: makeDrift(),
            threadService: StubThreadService()
        )
        
        XCTAssertEqual(viewModel.systemMessages.count, 1)
        XCTAssertEqual(viewModel.messages.count, 1)
        XCTAssertEqual(viewModel.participants.count, 1)
        XCTAssertEqual(viewModel.messages.first?.content, "Welcome in")
    }
    
    func testDriftChatViewModelTrimsOutgoingMessages() throws {
        let viewModel = DriftChatViewModel(
            drift: makeDrift(),
            threadService: MockDriftChatThreadService()
        )
        let originalCount = viewModel.messages.count
        
        viewModel.messageText = "  See you there  "
        viewModel.sendMessage()
        
        XCTAssertEqual(viewModel.messages.count, originalCount + 1)
        XCTAssertEqual(viewModel.messages.last?.content, "See you there")
        XCTAssertEqual(viewModel.messageText, "")
    }
    
    func testNavigationManagerKeepsTabBarHiddenUntilLastScreenReleasesIt() throws {
        let navigationManager = NavigationManager.shared
        
        navigationManager.setTabBarHidden(true, source: "detail")
        navigationManager.setTabBarHidden(true, source: "chat")
        XCTAssertTrue(navigationManager.isTabBarHidden)
        
        navigationManager.setTabBarHidden(false, source: "detail")
        XCTAssertTrue(navigationManager.isTabBarHidden)
        
        navigationManager.setTabBarHidden(false, source: "chat")
        XCTAssertFalse(navigationManager.isTabBarHidden)
    }
    
    private func makeDrift(isMine: Bool = false) -> Drift {
        Drift(
            title: "Coffee Drift",
            description: "Spontaneous coffee meetup.",
            location: "Panampilly Nagar",
            meetingPoint: "Main Entrance",
            time: "Today • 6:30 PM",
            endTime: "7:30 PM",
            date: "Today",
            distance: 0.5,
            status: .open,
            category: .coffee,
            hook: nil,
            host: Host(name: "Arjun", role: "Hosting", imageUrl: nil, isVerified: true),
            peopleGoing: 3,
            spotsLeft: 2,
            capacity: 5,
            vibeTags: ["Casual"],
            whatToBring: ["Good mood"],
            notes: "Meet near the entrance.",
            participantInitials: ["AR", "MY", "YU"],
            imageUrl: nil,
            isMine: isMine
        )
    }

    func testHostContextCardEnrichedTrustMetrics() throws {
        let drift = makeDrift()
        let viewModel = DriftDetailViewModel(drift: drift)
        
        let host = viewModel.drift.host
        XCTAssertEqual(host.hostedCount, 4)
        XCTAssertEqual(host.joinedCount, 12)
        XCTAssertEqual(host.completedCount, 16)
        XCTAssertTrue(host.verified)
        XCTAssertEqual(host.interests, ["Walks", "Coffee", "Movies"])
        XCTAssertEqual(host.pastDrifts, ["Walk in Indiranagar", "Coffee chat"])
        XCTAssertEqual(host.otherActiveDrifts.count, 2)
        
        let firstOtherActive = try XCTUnwrap(host.otherActiveDrifts.first)
        XCTAssertEqual(firstOtherActive.title, "Walk in Indiranagar")
        XCTAssertEqual(firstOtherActive.category, .walk)
    }

    func testWhoIsComingParticipantDataResolvesCorrectly() throws {
        let drift = makeDrift()
        let viewModel = DriftDetailViewModel(drift: drift)
        
        XCTAssertEqual(viewModel.participants.count, 4)
        
        let firstParticipant = try XCTUnwrap(viewModel.participants.first)
        XCTAssertEqual(firstParticipant.name, "Liam")
        XCTAssertEqual(firstParticipant.initials, "LJ")
        XCTAssertEqual(firstParticipant.interests, ["Walks", "Coffee", "Music"])
        XCTAssertEqual(firstParticipant.joinTimeDescription, "Joined today 2:14 PM")
    }
    
    func testTactileDriftsFiltersAndTimeframes() throws {
        let viewModel = DriftsViewModel(driftsService: MockDriftsService())
        
        // 1. Verify default values of Tactile Filter properties
        XCTAssertEqual(viewModel.selectedDistanceRadius, 10.0)
        XCTAssertTrue(viewModel.selectedCategories.isEmpty)
        XCTAssertEqual(viewModel.selectedTimeframe, "All")
        
        // 2. Test Distance Radius Filter (Should filter out drifts with distance > radius)
        viewModel.selectedDistanceRadius = 2.0
        // Evening Walk: 1.8 km (discover)
        // Movie Drift: 2.1 km (discover) - filtered out since 2.1 > 2.0
        // Dinner & Chats: 2.4 km (discover) - filtered out since 2.4 > 2.0
        // So only Evening Walk should match in discover mode!
        XCTAssertEqual(viewModel.filteredDrifts.count, 1)
        XCTAssertEqual(viewModel.filteredDrifts.first?.title, "Evening Walk")
        
        // 3. Test Category Selection Filter (Set of category strings)
        viewModel.selectedDistanceRadius = 10.0
        viewModel.selectedCategories = ["Movies"]
        XCTAssertEqual(viewModel.filteredDrifts.count, 1)
        XCTAssertEqual(viewModel.filteredDrifts.first?.title, "Movie Drift")
        
        // 4. Test Timeframe Filter
        viewModel.selectedCategories = []
        viewModel.selectedTimeframe = "Today"
        // All mock drifts are scheduled for "Today", so all 3 discover drifts should match
        XCTAssertEqual(viewModel.filteredDrifts.count, 3)
        
        // Let's set timeframe to "Tomorrow" (none in mock data are Tomorrow)
        viewModel.selectedTimeframe = "Tomorrow"
        XCTAssertEqual(viewModel.filteredDrifts.count, 0)
    }
    
    func testBookmarkTogglingAndPersistence() throws {
        // 1. Reset state
        BookmarkManager.shared.savedDrifts = []
        BookmarkManager.shared.saveBookmarks()
        
        let drift = makeDrift()
        
        // 2. Initial state verification
        XCTAssertFalse(BookmarkManager.shared.isBookmarked(drift))
        XCTAssertEqual(BookmarkManager.shared.savedDrifts.count, 0)
        
        // 3. Toggle Bookmark (Add)
        BookmarkManager.shared.toggleBookmark(drift)
        
        XCTAssertTrue(BookmarkManager.shared.isBookmarked(drift))
        XCTAssertEqual(BookmarkManager.shared.savedDrifts.count, 1)
        XCTAssertEqual(BookmarkManager.shared.savedDrifts.first?.title, drift.title)
        
        // 4. Persistence verification (Simulate reload from UserDefaults)
        BookmarkManager.shared.savedDrifts = []
        BookmarkManager.shared.loadBookmarks()
        
        XCTAssertTrue(BookmarkManager.shared.isBookmarked(drift))
        XCTAssertEqual(BookmarkManager.shared.savedDrifts.count, 1)
        XCTAssertEqual(BookmarkManager.shared.savedDrifts.first?.title, drift.title)
        
        // 5. Toggle Bookmark (Remove)
        BookmarkManager.shared.toggleBookmark(drift)
        
        XCTAssertFalse(BookmarkManager.shared.isBookmarked(drift))
        XCTAssertEqual(BookmarkManager.shared.savedDrifts.count, 0)
        
        // 6. Reload from UserDefaults verification (Should be empty)
        BookmarkManager.shared.loadBookmarks()
        XCTAssertEqual(BookmarkManager.shared.savedDrifts.count, 0)
    }
}
