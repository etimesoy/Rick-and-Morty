//
//  CacheManager.swift
//  Rick&Morty
//
//  Created by Руслан on 15.06.2022.
//

import UIKit

final class CacheManager {
    static let shared = CacheManager()
    
    private let cache = NSCache<NSString, UIImage>()
    
    private init() {}
    
    func image(forKey key: String) async -> UIImage? {
        let cacheKey = NSString(string: key)
        if let image = cache.object(forKey: cacheKey) { return image }
        
        guard let url = URL(string: key),
              let result = try? await URLSession.shared.data(from: url),
              let image = UIImage(data: result.0) else { return nil }
        
        cache.setObject(image, forKey: cacheKey)
        
        return image
    }
}
