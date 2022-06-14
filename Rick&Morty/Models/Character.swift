//
//  Character.swift
//  Rick&Morty
//
//  Created by Руслан on 14.06.2022.
//

import Foundation

struct Character: Decodable {
    let id: Int
    let name: String
    let status: String
    let species: String
    let type: String
    let gender: String
    let origin: Place
    let location: Place
    let image: String
    let episode: [String]
    let url: String
}

struct Place: Decodable {
    let name: String
    let url: String
}
