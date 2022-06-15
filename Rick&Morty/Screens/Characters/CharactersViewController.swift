//
//  CharactersViewController.swift
//  Rick&Morty
//
//  Created by Руслан on 14.06.2022.
//

import UIKit
import RxSwift

final class CharactersViewController: UIViewController {
    // MARK: UI
    
    private lazy var searchController: UISearchController = {
        let searchController = UISearchController()
        searchController.searchResultsUpdater = self
        searchController.searchBar.placeholder = "Enter character name..."
        searchController.obscuresBackgroundDuringPresentation = false
        return searchController
    }()
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout.threeColumnLayout(collectionViewWidth: view.bounds.width)
        let collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.register(CharacterCollectionViewCell.self, forCellWithReuseIdentifier: CharacterCollectionViewCell.reuseID)
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
    }
    
    private func reloadCollectionViewData() {
        var snapshot = NSDiffableDataSourceSnapshot<CollectionSection, CharacterCellViewModel>(sections: .main)
        snapshot.appendItems(characterCellViewModels, toSection: .main)
        dataSource.apply(snapshot)
    }
}

extension CharactersViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        viewModel.filterCellViewModels(searchString: searchController.searchBar.text)
    }
}

extension CharactersViewController: UICollectionViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let height = scrollView.frame.size.height
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        
        if height + offsetY > contentHeight {
            viewModel.getNextCellViewModels()
        }
    }
}
