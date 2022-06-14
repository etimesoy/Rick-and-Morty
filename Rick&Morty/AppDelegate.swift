//
//  AppDelegate.swift
//  RickAndMorty
//
//  Created by Руслан on 14.06.2022.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        let appCoordinator = AppCoordinator()
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = appCoordinator.start()
        window?.makeKeyAndVisible()
        
        return true
    }
}
