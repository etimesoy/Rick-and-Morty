//
//  DetailViewController.swift
//  Rick&Morty
//
//  Created by Руслан on 17.06.2022.
//

import UIKit
import RxSwift

final class DetailViewController: UIViewController {
    // MARK: UI
    
    private var favoriteButtonImage: UIImage? {
        let imageSystemName = viewModel.isFavorite ? "heart.fill" : "heart"
        return UIImage(systemName: imageSystemName)
    }
    
    private lazy var closeButton: UIButton = {
        let button = UIButton(type: .close)
        button.rx.tap.bind { [weak self] in
            self?.dismiss(animated: true)
        }.disposed(by: disposeBag)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var favoriteButton: UIButton = {
        var configuration = UIButton.Configuration.plain()
        configuration.image = favoriteButtonImage
        configuration.baseForegroundColor = .systemRed
        
        let button = UIButton(configuration: configuration)
        button.rx.tap.bind { [weak self] in
            guard let `self` = self else { return }
            self.viewModel.isFavorite.toggle()
            self.favoriteButton.setImage(self.favoriteButtonImage, for: .normal)
        }.disposed(by: disposeBag)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var avatarImageView: UIImageView = {
        let imageView = RMAvatarImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.downloadImage(from: viewModel.imageUrl)
        return imageView
    }()
    
    private lazy var textLabelsView: UIView = {
        let view = UIView()
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        view.layer.cornerRadius = .textLabelsViewCornerRadius
        view.backgroundColor = .systemBackground
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var labelsStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [
            RMTitleLabel(textAlignment: .left, textStyle: .title1, text: viewModel.name),
            RMTitleLabel(textAlignment: .left, textStyle: .subheadline, text: viewModel.description),
            RMTitleLabel(textAlignment: .left, textStyle: .title3, text: viewModel.species),
            RMTitleLabel(textAlignment: .left, textStyle: .title3, text: viewModel.place),
            RMTitleLabel(textAlignment: .left, textStyle: .title3, text: viewModel.episodes.joined(separator: ",\n")),
            UIView()
        ])
        stackView.arrangedSubviews.forEach { ($0 as? UILabel)?.numberOfLines = 0 }
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    // MARK: Dependencies & properties
    
    private let viewModel: DetailViewModelProtocol
    
    private let disposeBag = DisposeBag()
    
    // MARK: Initializers
    
    init(viewModel: DetailViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        configureSubviews()
    }
    
    // MARK: Configuration
    
    private func configureSubviews() {
        view.addSubview(avatarImageView)
        NSLayoutConstraint.activate([
            avatarImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            avatarImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            avatarImageView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            avatarImageView.widthAnchor.constraint(equalTo: avatarImageView.heightAnchor)
        ])
        
        let padding: CGFloat = 16
        let buttonSize: CGFloat = 50
        
        view.addSubview(closeButton)
        NSLayoutConstraint.activate([
            closeButton.leadingAnchor.constraint(equalTo: avatarImageView.leadingAnchor, constant: padding),
            closeButton.topAnchor.constraint(equalTo: avatarImageView.topAnchor, constant: padding),
            closeButton.widthAnchor.constraint(equalToConstant: buttonSize),
            closeButton.widthAnchor.constraint(equalTo: closeButton.heightAnchor)
        ])
        
        view.addSubview(favoriteButton)
        NSLayoutConstraint.activate([
            favoriteButton.topAnchor.constraint(equalTo: avatarImageView.topAnchor, constant: padding),
            favoriteButton.trailingAnchor.constraint(equalTo: avatarImageView.trailingAnchor, constant: -padding),
            favoriteButton.widthAnchor.constraint(equalToConstant: buttonSize),
            favoriteButton.widthAnchor.constraint(equalTo: favoriteButton.heightAnchor)
        ])
        
        view.addSubview(textLabelsView)
        NSLayoutConstraint.activate([
            textLabelsView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            textLabelsView.topAnchor.constraint(equalTo: avatarImageView.bottomAnchor,
                                                constant: -.textLabelsViewCornerRadius),
            textLabelsView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            textLabelsView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        textLabelsView.addSubview(labelsStackView)
        NSLayoutConstraint.activate([
            labelsStackView.leadingAnchor.constraint(equalTo: textLabelsView.leadingAnchor, constant: padding),
            labelsStackView.topAnchor.constraint(equalTo: textLabelsView.topAnchor, constant: padding),
            labelsStackView.trailingAnchor.constraint(equalTo: textLabelsView.trailingAnchor, constant: -padding),
            labelsStackView.bottomAnchor.constraint(equalTo: textLabelsView.bottomAnchor, constant: -padding)
        ])
    }
}

extension CGFloat {
    static let textLabelsViewCornerRadius: CGFloat = 20
}
