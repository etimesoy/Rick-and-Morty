//
//  CharactersCoordinator.swift
//  Rick&Morty
//
//  Created by Руслан on 14.06.2022.
//

import UIKit

final class CharactersCoordinator: Coordinator {
    func start() -> UIViewController {
        return CharactersVC(viewModel: CharactersViewModel())
    }
}
