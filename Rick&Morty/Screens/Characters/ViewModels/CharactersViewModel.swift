//
//  CharactersViewModel.swift
//  Rick&Morty
//
//  Created by Руслан on 14.06.2022.
//

import RxSwift
import UIKit

protocol CharactersViewModelProtocol: AnyObject {
    var characterCellViewModels: BehaviorSubject<[CharacterCellViewModel]> { get }
    var nextCharacterCellViewModels: BehaviorSubject<[CharacterCellViewModel]> { get }
    
    func filterCellViewModels(searchString: String?, status: Status?, gender: Gender?)
    func getNextCellViewModels()
    
//    func addFilterOption(searchString: String?, status: Status?, gender: Gender?)
//    func clearFilterOptions()
}

extension CharactersViewModelProtocol {
    func filterCellViewModels(searchString: String? = nil, status: Status? = nil, gender: Gender? = nil) {
        filterCellViewModels(searchString: searchString, status: status, gender: gender)
    }
    
    func getCellViewModels() { filterCellViewModels() }
}

final class CharactersViewModel: CharactersViewModelProtocol {
    let characterCellViewModels = BehaviorSubject<[CharacterCellViewModel]>(value: [])
    let nextCharacterCellViewModels = BehaviorSubject<[CharacterCellViewModel]>(value: [])
    
    private let networkManager: NetworkManagerProtocol
    
    init(networkManager: NetworkManagerProtocol) {
        self.networkManager = networkManager
        getCellViewModels()
    }
    
    func filterCellViewModels(searchString: String?, status: Status?, gender: Gender?) {
        Task {
            let characters = await networkManager.getCharacters(
                name: searchString?.lowercased(), status: status, gender: gender
            )
            characterCellViewModels.onNext(characters.map(CharacterCellViewModel.init))
        }
    }
    
    func getNextCellViewModels() {
        Task {
            let characters = await networkManager.getNextCharacters()
            if let characters = characters {
                nextCharacterCellViewModels.onNext(characters.map(CharacterCellViewModel.init))
            } else {
                nextCharacterCellViewModels.onCompleted()
            }
        }
    }
}
