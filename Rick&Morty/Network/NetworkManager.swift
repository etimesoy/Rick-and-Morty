//
//  NetworkManager.swift
//  Rick&Morty
//
//  Created by Руслан on 14.06.2022.
//

import Foundation

protocol NetworkManagerProtocol {
    func getCharacters() async -> [Character]
}

final class NetworkManager: NetworkManagerProtocol {
    private let decoder = JSONDecoder()
    
    private let baseUrlComponents: URLComponents = {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "rickandmortyapi.com"
//        components.queryItems = [
//            URLQueryItem(name: "q", value: someString),
//            URLQueryItem(name: "sort", value: someAnotherString)
//        ]
        return components
    }()
    
    private func getUrlComponents(for endpointType: EndpointType) -> URLComponents {
        var urlComponents = baseUrlComponents
        urlComponents.path = "/api/" + endpointType.rawValue
        return urlComponents
    }
    
    func getCharacters() async -> [Character] {
        let urlComponents = getUrlComponents(for: .character)
        guard let url = urlComponents.url else { return [] }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            guard let characters = try? decoder.decode(APIResponse<Character>.self, from: data) else {
                return []
            }
            return characters.results
        } catch {
            return []
        }
    }
}
