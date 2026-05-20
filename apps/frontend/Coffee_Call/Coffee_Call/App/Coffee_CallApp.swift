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

