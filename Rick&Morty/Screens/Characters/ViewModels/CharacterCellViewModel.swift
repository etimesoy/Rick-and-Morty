//
//  CharacterCellViewModel.swift
//  Rick&Morty
//
//  Created by Руслан on 15.06.2022.
//

import Foundation

struct CharacterCellViewModel: Hashable {
    let id: Int
    let name: String
    let image: String
    
    init(_ character: Character) {
        id = character.id
        name = character.name
        image = character.image
    }
}
