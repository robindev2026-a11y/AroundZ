// NotificationPermissionService.swift
// Handles notification permission state and requests.

import Foundation
import UserNotifications
import SwiftUI
import Combine

public final class NotificationPermissionService: ObservableObject {
    // MARK: - Published properties
    @Published var notificationStatus: UNAuthorizationStatus = .notDetermined

    // MARK: - Singleton
    static let shared = NotificationPermissionService()

    private init() {
        checkNotificationStatus()
    }

    // MARK: - Public API
    func checkNotificationStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { [weak self] settings in
            DispatchQueue.main.async {
                self?.notificationStatus = settings.authorizationStatus
            }
        }
    }

    func requestNotificationPermission() {
        UNUserNotificationCenter.current().getNotificationSettings { [weak self] settings in
            DispatchQueue.main.async {
                if settings.authorizationStatus == .notDetermined {
                    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
                        DispatchQueue.main.async {
                            self?.checkNotificationStatus()
                        }
                    }
                } else if settings.authorizationStatus == .denied {
                    self?.openSettings()
                }
            }
        }
    }

    // MARK: - Private helpers
    private func openSettings() {
        guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else { return }
        if UIApplication.shared.canOpenURL(settingsUrl) {
            UIApplication.shared.open(settingsUrl, options: [:], completionHandler: nil)
        }
    }
}
