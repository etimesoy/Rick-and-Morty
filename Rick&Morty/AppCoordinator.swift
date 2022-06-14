//
//  AppCoordinator.swift
//  Rick&Morty
//
//  Created by Руслан on 14.06.2022.
//

import UIKit

protocol Coordinator: AnyObject {
    func start() -> UIViewController
}

final class AppCoordinator: Coordinator {
    func start() -> UIViewController {
        let tabBarController = UITabBarController()
        
        tabBarController.viewControllers = [
            CharactersCoordinator().start(),
            UIViewController(),
            UIViewController()
        ]
        
        return tabBarController
    }
}
