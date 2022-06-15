//
//  CharactersViewController.swift
//  Rick&Morty
//
//  Created by Руслан on 14.06.2022.
//

import UIKit
import RxSwift
import RxCocoa

final class CharactersViewController: UIViewController {
    // MARK: UI
    
    private lazy var searchController: UISearchController = {
        let searchController = UISearchController()
        searchController.searchBar.placeholder = "Enter character name..."
        searchController.obscuresBackgroundDuringPresentation = false
        return searchController
    }()
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout.threeColumnLayout(collectionViewWidth: view.bounds.width)
        let collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.register(CharacterCollectionViewCell.self, forCellWithReuseIdentifier: CharacterCollectionViewCell.reuseID)
        collectionView.keyboardDismissMode = .onDrag
        return collectionView
    }()
    
    // MARK: Dependencies & properties
    
    enum CollectionSection { case main }
    
    private lazy var dataSource = {
        return UICollectionViewDiffableDataSource<CollectionSection, CharacterCellViewModel>(
            collectionView: collectionView
        ) { collectionView, indexPath, cellViewModel in
            let cell = collectionView.dequeueCellOfType(CharacterCollectionViewCell.self, for: indexPath)
            cell.setup(with: cellViewModel)
            return cell
        }
    }()
    
    private let viewModel: CharactersViewModelProtocol
    
    private var characterCellViewModels: [CharacterCellViewModel] = []
    
    private let disposeBag = DisposeBag()
    
    // MARK: Initializers
    
    init(viewModel: CharactersViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureViewController()
        configureBindings()
    }
    
    // MARK: Configuration
    
    private func configureViewController() {
        title = "Characters"
        tabBarItem = UITabBarItem(title: "Characters", image: UIImage(systemName: "person.crop.circle"), tag: 0)
        
        view.backgroundColor = .systemBackground
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.searchController = searchController
        
        view.addSubview(collectionView)
    }
    
    private func configureBindings() {
        viewModel.characterCellViewModels
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] viewModels in
                guard let self = self else { return }
                self.characterCellViewModels = viewModels
                self.reloadCollectionViewData()
            })
            .disposed(by: disposeBag)
        viewModel.nextCharacterCellViewModels
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] viewModels in
                guard let self = self else { return }
                self.characterCellViewModels += viewModels
                self.reloadCollectionViewData()
            })
            .disposed(by: disposeBag)
        searchController.searchBar.rx.text
            .orEmpty
            .skip(1)
            .debounce(.milliseconds(300), scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] query in
                guard let self = self else { return }
                self.viewModel.filterCellViewModels(searchString: query)
                self.collectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: .top, animated: true)
            })
            .disposed(by: disposeBag)
        collectionView.rx.didEndDecelerating
            .subscribe(onNext: { [weak self] in
                self?.loadNextCellViewModelsIfNeeded()
            })
            .disposed(by: disposeBag)
    }
    
    private func reloadCollectionViewData() {
        var snapshot = NSDiffableDataSourceSnapshot<CollectionSection, CharacterCellViewModel>(sections: .main)
        snapshot.appendItems(characterCellViewModels, toSection: .main)
        dataSource.apply(snapshot)
    }
    
    private func loadNextCellViewModelsIfNeeded() {
        let height = collectionView.frame.size.height
        let offsetY = collectionView.contentOffset.y
        let contentHeight = collectionView.contentSize.height
        
        if height + offsetY > contentHeight {
            viewModel.getNextCellViewModels()
        }
    }
}
