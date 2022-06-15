//
//  CharactersCoordinator.swift
//  Rick&Morty
//
//  Created by Руслан on 14.06.2022.
//

import UIKit

final class CharactersCoordinator: Coordinator {
    func start() -> UIViewController {
        let vc = CharactersViewController(viewModel: CharactersViewModel(networkManager: NetworkManager()))
        return UINavigationController(rootViewController: vc)
    }
}
