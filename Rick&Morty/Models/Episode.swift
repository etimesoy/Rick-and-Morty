//
//  Episode.swift
//  Rick&Morty
//
//  Created by Руслан on 17.06.2022.
//

import Foundation

struct Episode: Decodable {
    let id: Int
    let name: String
    let airDate: String
    let episodeCode: String
    let characterUrls: [String]
    let url: String
    
    enum CodingKeys: String, CodingKey {
        case id, name, url
        case airDate = "air_date"
        case episodeCode = "episode"
        case characterUrls = "characters"
    }
}
