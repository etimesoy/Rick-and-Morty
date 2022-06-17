//
//  RMAvatarImageView.swift
//  Rick&Morty
//
//  Created by Руслан on 15.06.2022.
//

import UIKit

final class RMAvatarImageView: UIImageView {
    private let cacheManager = CacheManager.shared
    
    private let placeholderImage = UIImage(named: "avatar-placeholder")
    
    var downloadTask: Task<Void, Never>?
    
    init(cornerRadius: CGFloat? = nil) {
        super.init(frame: .zero)
        if let cornerRadius = cornerRadius {
            layer.cornerRadius = cornerRadius
        }
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
        image = placeholderImage
        clipsToBounds = true
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    func downloadImage(from urlString: String) {
        downloadTask = Task { [weak self] in
            self?.image = await cacheManager.image(forKey: urlString)
            downloadTask = nil
        }
    }
}
