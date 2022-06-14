//
//  CharactersViewModel.swift
//  Rick&Morty
//
//  Created by Руслан on 14.06.2022.
//

import RxSwift

protocol CharactersViewModelProtocol: AnyObject {
    var characterCellViewModels: PublishSubject<[Character]> { get }
}

final class CharactersViewModel: CharactersViewModelProtocol {
    let characterCellViewModels = PublishSubject<[Character]>()
    
    private let networkManager: NetworkManagerProtocol
    
    init(networkManager: NetworkManagerProtocol) {
        self.networkManager = networkManager
        Task {
            let characters = await networkManager.getCharacters()
            characterCellViewModels.onNext(characters)
        }
    }
}
