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
    private var isFirebaseConfigured: Bool {
        FirebaseApp.app() != nil
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        // On fresh clones, `GoogleService-Info.plist` may be intentionally absent (it is project-secret).
        // Also note: this project currently copies the entire `App/` folder as a resource, so the plist
        // may live under the `App` subdirectory inside the bundle.
        if !isFirebaseConfigured {
            let plistPath =
                Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist") ??
                Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist", inDirectory: "App")

            if let plistPath, let options = FirebaseOptions(contentsOfFile: plistPath) {
                FirebaseApp.configure(options: options)
            }
        }
        
        #if targetEnvironment(simulator)
        // Firebase fictional phone numbers can be verified in the simulator without APNs or reCAPTCHA.
        if isFirebaseConfigured {
            Auth.auth().settings?.isAppVerificationDisabledForTesting = true
        }
        #endif
        
        return true
    }

    func application(_ application: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        if isFirebaseConfigured, Auth.auth().canHandle(url) {
            return true
        }
        return false
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        guard isFirebaseConfigured else { return }
        Auth.auth().setAPNSToken(deviceToken, type: .unknown)
    }

    func application(_ application: UIApplication, didReceiveRemoteNotification notification: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        if isFirebaseConfigured, Auth.auth().canHandleNotification(notification) {
            completionHandler(.noData)
            return
        }
        completionHandler(.newData)
    }
}

@main
struct Coffee_CallApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
