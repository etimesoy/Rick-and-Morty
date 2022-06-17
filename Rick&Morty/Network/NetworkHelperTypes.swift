//
//  NetworkHelperTypes.swift
//  Rick&Morty
//
//  Created by Руслан on 14.06.2022.
//

import Foundation

enum Network {
    enum EndpointType: String {
        case character, location, episode
    }

    struct APIResponse<Model: Decodable>: Decodable {
        let info: APIInfo
        let results: [Model]
    }

    struct APIInfo: Decodable {
        let count: Int
        let pages: Int
        let next: String?
        let prev: String?
    }
    
    enum Error: Swift.Error {
        case invalidUrl
    }
}
