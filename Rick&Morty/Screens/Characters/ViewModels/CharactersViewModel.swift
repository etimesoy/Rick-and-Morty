//
//  CharactersViewModel.swift
//  Rick&Morty
//
//  Created by Руслан on 14.06.2022.
//

import RxSwift
import UIKit

enum CharacterFilterOption: Hashable {
    case search(String)
    case status(Status)
    case gender(Gender)
    case favorites(Bool)
    
    static func == (lhs: CharacterFilterOption, rhs: CharacterFilterOption) -> Bool {
        switch (lhs, rhs) {
        case (.search(_), .search(_)): return true
        case (.status(_), .status(_)): return true
        case (.gender(_), .gender(_)): return true
        case (.favorites(_), .favorites(_)): return true
        default: return false
        }
    }
}

protocol CharactersViewModelProtocol: AnyObject {
    var characterCellViewModels: BehaviorSubject<[CharacterCellViewModel]> { get }
    var nextCharacterCellViewModels: BehaviorSubject<[CharacterCellViewModel]> { get }
    
    func getNextCellViewModels()
    
    func addFilterOption(_ option: CharacterFilterOption)
    func clearFilterOptions()
    
    func getCharacter(id: Int) -> Single<Character>
}

final class CharactersViewModel: CharactersViewModelProtocol {
    let characterCellViewModels = BehaviorSubject<[CharacterCellViewModel]>(value: [])
    let nextCharacterCellViewModels = BehaviorSubject<[CharacterCellViewModel]>(value: [])
    
    private let networkManager: NetworkManagerProtocol
    
    private let firebaseManager: FirebaseManagerProtocol
    
    private var filterOptions: Set<CharacterFilterOption> = [.favorites(false)]
    
    init(networkManager: NetworkManagerProtocol, firebaseManager: FirebaseManagerProtocol) {
        self.networkManager = networkManager
        self.firebaseManager = firebaseManager
        getCellViewModels()
    }
    
    private func getCellViewModels() {
        Task {
            var (searchString, status, gender, favorites): (String?, Status?, Gender?, Bool?)
            filterOptions.forEach { option in
                switch option {
                case .search(let value): searchString = value
                case .status(let value): status = value
                case .gender(let value): gender = value
                case .favorites(let value): favorites = value
                }
            }
            let name = searchString?.trimmingCharacters(in: .whitespaces).lowercased()
            var characters = await networkManager.getCharacters(
                name: name, status: status, gender: gender
            ).map(CharacterCellViewModel.init)
            
            if let favorites = favorites, favorites {
                firebaseManager.getFavoriteCharacterIds { [weak self] favoriteCharacterIds in
                    characters = characters.filter {
                        favoriteCharacterIds.contains($0.id)
                    }
                    self?.characterCellViewModels.onNext(characters)
                }
            } else {
                characterCellViewModels.onNext(characters)
            }
        }
    }
    
    func addFilterOption(_ option: CharacterFilterOption) {
        filterOptions = filterOptions.filter { $0 != option }
        filterOptions.insert(option)
        getCellViewModels()
    }
    
    func clearFilterOptions() {
        filterOptions.removeAll()
        getCellViewModels()
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
    
    func getCharacter(id: Int) -> Single<Character> {
        return Single<Character>.create { single in
            Task { [weak self] in
                guard let `self` = self else { return }
                do {
                    let character = try await self.networkManager.getCharacter(id: id)
                    single(.success(character))
                } catch {
                    single(.failure(error))
                }
            }
            return Disposables.create()
        }
    }
}
