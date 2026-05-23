//
//  Coffee_CallApp.swift
//  Coffee_Call
//
//  Created by Development on 12/05/26.
//

import SwiftUI
import UIKit
import FirebaseCore
import FirebaseAuth

final class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        if Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist") != nil {
            FirebaseApp.configure()
            print("Firebase configured successfully.")
        } else {
            print("GoogleService-Info.plist not found. Using offline mock mode.")
        }
        return true
    }

    // MARK: - Required for Firebase Phone Auth (APNs silent push)
    // Firebase uses silent APNs pushes to verify phone numbers on real devices.
    // Without this, OTP verification will hang or fail on physical hardware.
    func application(_ application: UIApplication,
                     didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        if Auth.auth().canHandleNotification(userInfo) {
            completionHandler(.noData)
            return
        }
        completionHandler(.noData)
    }

    // Required for reCAPTCHA fallback verification flow
    func application(_ app: UIApplication,
                     open url: URL,
                     options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        if Auth.auth().canHandle(url) {
            return true
        }
        return false
    }
}

@main
struct Coffee_CallApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    let persistenceController = PersistenceController.shared

    @StateObject private var networkManager = NetworkManager.shared
    @StateObject private var driftStore = GlobalDriftStore()
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(networkManager)
                .environmentObject(driftStore)
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
