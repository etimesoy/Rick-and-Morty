//
//  DetailViewModel.swift
//  Rick&Morty
//
//  Created by Руслан on 17.06.2022.
//

import Foundation
import RxSwift

protocol DetailViewModelProtocol: AnyObject {
    var character: Character { get set }
    var isFavoriteSubject: PublishSubject<Bool> { get }
}

final class DetailViewModel: DetailViewModelProtocol {
    var character: Character {
        willSet(newCharacter) {
            if character.isFavorite != newCharacter.isFavorite {
                isFavoriteSubject.onNext(newCharacter.isFavorite)
            }
        }
    }
    
    var isFavoriteSubject = PublishSubject<Bool>()
    
    init(_ character: Character) {
        self.character = character
    }
}
