// RadarService.swift
// Centralized service for radar visibility state and Firestore sync.

import Foundation
import FirebaseCore
import FirebaseAuth
import FirebaseFirestore
import SwiftUI
import Combine

/// RadarService manages the on/off state of the radar UI element.
///
/// It stores the flag in `UserDefaults` for persistence between launches and
/// syncs the value to Firestore so the preference is shared across a user's
/// devices. The class is a lightweight `ObservableObject` that can be observed
/// directly from SwiftUI views (e.g. `DiscoveryScreen`).
final class RadarService: ObservableObject {
    // MARK: - Public Published Properties
    /// The current radar visibility flag. `true` means the radar is active and
    /// location updates are allowed to be published to other users.
    @Published var isRadarVisible: Bool

    // MARK: - Singleton Instance
    static let shared = RadarService()

    // MARK: - Private State
    private var hasSyncedRadarVisibilityPreference = false
    private var isRadarVisibilitySyncInFlight = false
    private let radarVisibilityKey = "CoffeeCall.isRadarVisible"

    // MARK: - Init
    private init() {
        // Load persisted radar visibility, defaulting to `true` for a fresh install.
        self.isRadarVisible = UserDefaults.standard.object(forKey: radarVisibilityKey) as? Bool ?? true
    }

    // MARK: - Public API
    /// Toggle the radar visibility flag.
    func toggleRadarVisibility() {
        setRadarVisibility(!isRadarVisible)
    }

    /// Explicitly set the radar visibility flag.
    /// - Parameter isVisible: Desired visibility state.
    func setRadarVisibility(_ isVisible: Bool) {
        guard isRadarVisible != isVisible else { return }
        isRadarVisible = isVisible
        UserDefaults.standard.set(isVisible, forKey: radarVisibilityKey)
        // Reset the sync flag so a new write will be attempted.
        hasSyncedRadarVisibilityPreference = false
        syncRadarVisibility(isVisible)
    }

    /// Ensure the current radar preference is persisted to Firestore.
    /// Call this on app launch (e.g. from an `onAppear`) to keep the server in
    /// sync with the locally stored flag.
    func syncRadarVisibilityPreference() {
        guard !hasSyncedRadarVisibilityPreference, !isRadarVisibilitySyncInFlight else { return }
        syncRadarVisibility(isRadarVisible)
    }

    // MARK: - Private Helpers
    private func syncRadarVisibility(_ isVisible: Bool) {
        // Only attempt a Firestore write when the app is configured with Firebase.
        let isFirebaseEnabled = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist") != nil
        guard isFirebaseEnabled, let uid = Auth.auth().currentUser?.uid else { return }
        isRadarVisibilitySyncInFlight = true
        Firestore.firestore().collection("users").document(uid).setData(
            [
                "isRadarVisible": isVisible,
                "radarVisibilityUpdatedAt": FieldValue.serverTimestamp()
            ],
            merge: true) { [weak self] error in
                DispatchQueue.main.async {
                    self?.isRadarVisibilitySyncInFlight = false
                    if let _ = error {
                        self?.hasSyncedRadarVisibilityPreference = false
                    } else {
                        self?.hasSyncedRadarVisibilityPreference = true
                    }
                }
            }
    }
}
