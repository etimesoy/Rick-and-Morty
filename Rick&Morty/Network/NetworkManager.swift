//
//  NetworkManager.swift
//  Rick&Morty
//
//  Created by Руслан on 14.06.2022.
//

import Foundation

protocol NetworkManagerProtocol {
    func getCharacters(name: String?, status: Status?, gender: Gender?) async -> [Character]
    func getNextCharacters() async -> [Character]?
}

final class NetworkManager: NetworkManagerProtocol {
    private let decoder = JSONDecoder()
    
    private var nextPageUrlString: String?
    
    private let baseUrlComponents: URLComponents = {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "rickandmortyapi.com"
        return components
    }()
    
    private func getUrlComponents(
        for endpointType: Network.EndpointType,
        with queryItems: [String: String?]
    ) -> URLComponents {
        var urlComponents = baseUrlComponents
        urlComponents.path = "/api/" + endpointType.rawValue
        urlComponents.queryItems = queryItems.compactMap { (key, value) -> URLQueryItem? in
            guard let value = value else { return nil }
            return URLQueryItem(name: key, value: value)
        }
//        if !urlQueryItems.isEmpty { urlComponents.queryItems = urlQueryItems }
        return urlComponents
    }
    
    private func requestData(from url: URL) async throws -> Network.APIResponse<Character> {
        let (data, _) = try await URLSession.shared.data(from: url)
        let apiResponse = try decoder.decode(Network.APIResponse<Character>.self, from: data)
        nextPageUrlString = apiResponse.info.next
        return apiResponse
    }
    
    func getCharacters(name: String?, status: Status?, gender: Gender?) async -> [Character] {
        let urlComponents = getUrlComponents(for: .character, with: [
            "name": name, "status": status?.rawValue, "gender": gender?.rawValue
        ])
        guard let url = urlComponents.url else { return [] }
        let apiResponse = try? await requestData(from: url)
        return apiResponse?.results ?? []
    }
    
    func getNextCharacters() async -> [Character]? {
        guard let nextPageUrlString = nextPageUrlString,
              let url = URL(string: nextPageUrlString) else { return nil }
        
        let apiResponse = try? await requestData(from: url)
        return apiResponse?.results
    }
}
