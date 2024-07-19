//
//  AppDelegate.swift
//  MyThreads
//
//  Created by Veysal Hasanbayli on 01.07.24.
//

import UIKit
import Firebase

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        LocalizationService.shared.getLanguage()
        let isUserLoggedIn = UserDefaults.standard.bool(forKey: "userLoggedIn")
        self.window = UIWindow(frame: UIScreen.main.bounds)
        let tabBar = TabBarController()
        let navVC = UINavigationController(rootViewController: InitialViewController())
        self.window?.rootViewController = isUserLoggedIn ? tabBar : navVC
        self.window?.makeKeyAndVisible()
        return true
    }

}

