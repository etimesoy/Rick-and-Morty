//
//  FirebaseManager.swift
//  Rick&Morty
//
//  Created by Руслан on 17.06.2022.
//

import Foundation
import FirebaseFirestore

protocol FirebaseManagerProtocol: AnyObject {
    func isFavoriteCharacter(characterId: Int, completion: @escaping (Bool) -> Void)
    func addFavoriteCharacter(characterId: Int)
    func removeFavoriteCharacter(characterId: Int)
    func getFavoriteCharacterIds(completion: @escaping ([Int]) -> Void)
}

final class FirebaseManager: FirebaseManagerProtocol {
    let database = Firestore.firestore()
    
    lazy var docRef = database.document("rick&morty/PpBuC3pP1ksKSxpXYnlu")
    
    let favoritesArrayKey = "favorites"
    
    func isFavoriteCharacter(characterId: Int, completion: @escaping (Bool) -> Void) {
        docRef.getDocument { [weak self] snapshot, error in
            guard let `self` = self, let data = snapshot?.data(), error == nil,
                  let favoritesArray = data[self.favoritesArrayKey] as? [Int] else {
                      completion(false)
                      return
                  }
            completion(favoritesArray.contains(characterId))
        }
    }
    
    func addFavoriteCharacter(characterId: Int) {
        docRef.getDocument { [weak self] snapshot, error in
            guard let `self` = self, let data = snapshot?.data(), error == nil,
                var favoritesArray = data[self.favoritesArrayKey] as? [Int],
                !favoritesArray.contains(characterId) else {
                return
            }
            favoritesArray.append(characterId)
            self.docRef.setData([
                self.favoritesArrayKey: favoritesArray
            ])
        }
    }
    
    func removeFavoriteCharacter(characterId: Int) {
        docRef.getDocument { [weak self] snapshot, error in
            guard let `self` = self, let data = snapshot?.data(), error == nil,
                  var favoritesArray = data[self.favoritesArrayKey] as? [Int],
                  favoritesArray.contains(characterId) else {
                      return
                  }
            favoritesArray.removeAll { $0 == characterId }
            self.docRef.setData([
                self.favoritesArrayKey: favoritesArray
            ])
        }
    }
    
    func getFavoriteCharacterIds(completion: @escaping ([Int]) -> Void) {
        docRef.getDocument { [weak self] snapshot, error in
            guard let `self` = self, let data = snapshot?.data(), error == nil,
                  let favoritesArray = data[self.favoritesArrayKey] as? [Int] else {
                      completion([])
                      return
                  }
            completion(favoritesArray)
        }
    }
}
