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
    
    private lazy var nameLabel: UILabel = {
        let label = RMTitleLabel(textAlignment: .left, textStyle: .title1)
        label.text = viewModel.character.name
        return label
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
        configureBindings()
    }
    
    // MARK: Configuration
    
    private func configureSubviews() {
        let padding: CGFloat = 8
        view.addSubview(nameLabel)
        NSLayoutConstraint.activate([
            nameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
            nameLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: padding),
            nameLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -padding)
        ])
    }
    
    private func configureBindings() {
        viewModel.isFavoriteSubject
            .subscribe(onNext: { isFavorite in
                
            })
            .disposed(by: disposeBag)
    }
}
