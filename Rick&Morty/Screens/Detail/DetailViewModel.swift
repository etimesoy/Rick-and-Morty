//
//  DetailViewModel.swift
//  Rick&Morty
//
//  Created by Руслан on 17.06.2022.
//

import Foundation
import RxSwift

protocol DetailViewModelProtocol: AnyObject {
    var name: String { get }
    var imageUrl: String { get }
    var description: String { get }
    var species: String { get }
    var place: String { get }
    var isFavorite: Bool { get set }
    
    func getEpisodesString() async -> String
}

final class DetailViewModel: DetailViewModelProtocol {
    var name: String {
        return character.name
    }
    var imageUrl: String {
        return character.image
    }
    var description: String {
        return "\(character.gender), \(character.status)"
    }
    var species: String {
        if !character.type.isEmpty {
            return "Species: \(character.species), \(character.type)"
        } else {
            return "Species: \(character.species)"
        }
    }
    var place: String {
        return "From \(character.origin.name), last spotted: \(character.location.name)"
    }
    
    var isFavorite: Bool {
        get {
            return character.isFavorite
        }
        set {
            guard character.isFavorite != newValue else { return }
            if newValue {
                firebaseManager.addFavoriteCharacter(characterId: character.id)
            } else {
                firebaseManager.removeFavoriteCharacter(characterId: character.id)
            }
            character.isFavorite = newValue
        }
    }
    
    private var character: Character
    
    private let networkManager: NetworkManagerProtocol
    
    private let firebaseManager: FirebaseManagerProtocol
    
    init(character: Character, networkManager: NetworkManagerProtocol, firebaseManager: FirebaseManagerProtocol) {
        self.character = character
        self.networkManager = networkManager
        self.firebaseManager = firebaseManager
    }
    
    func getEpisodesString() async -> String {
        var episodesString = "Episodes:"
        for episodeUrlString in character.episode {
            if let episode = try? await networkManager.getEpisode(episodeUrlString) {
                episodesString += "\n * \(episode.name)"
            }
        }
        return episodesString
    }
}
