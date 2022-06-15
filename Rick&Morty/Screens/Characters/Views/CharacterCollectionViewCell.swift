//
//  CharacterCollectionViewCell.swift
//  Rick&Morty
//
//  Created by Руслан on 15.06.2022.
//

import UIKit

final class CharacterCollectionViewCell: UICollectionViewCell, Identifiable {
    static let reuseID = "CharacterCollectionViewCell"
    
    private lazy var avatarImageView = RMAvatarImageView(frame: .zero)
    
    private lazy var usernameLabel = RMTitleLabel(textAlignment: .center, textStyle: .callout)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        avatarImageView.downloadTask?.cancel()
    }
    
    func setup(with viewModel: CharacterCellViewModel) {
        usernameLabel.text = viewModel.name
        avatarImageView.downloadImage(from: viewModel.image)
    }
    
    private func configure() {
        contentView.addSubview(avatarImageView)
        contentView.addSubview(usernameLabel)
        
        NSLayoutConstraint.activate([
            avatarImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            avatarImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            avatarImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            avatarImageView.widthAnchor.constraint(equalTo: avatarImageView.heightAnchor),
            
            usernameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            usernameLabel.topAnchor.constraint(equalTo: avatarImageView.bottomAnchor, constant: 12),
            usernameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            usernameLabel.heightAnchor.constraint(equalToConstant: 20)
        ])
    }
}
