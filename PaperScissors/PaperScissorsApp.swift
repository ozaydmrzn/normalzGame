//
//  PaperScissorsApp.swift
//  PaperScissors
//
//  Created by Ozay Demirezen on 27/8/24.
//

import SwiftUI
import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        return true
    }
}
@main
struct PaperScissorsApp: App {
    // register app delegate for Firebase setup
        @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
        
        var body: some Scene {
            WindowGroup {
                NavigationView {
                    ContentView()
                }
            }
        }
    }
