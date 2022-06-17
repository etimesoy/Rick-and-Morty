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
    
    private var rightBarButtonItemMenu: UIMenu {
        UIMenu(
            title: "Filter options",
            children: [
                UIAction(
                    title: "Favorites",
                    image: UIImage(systemName: "heart.fill"),
                    handler: { [self] action in
                        let newState = action.state.toggled()
                        viewModel.addFilterOption(.favorites(newState == .on))
                        reconfigureRightBarButtonItem(newFavoritesActionState: newState)
                    }
                ),
                UIMenu(title: "Status", options: [.singleSelection], children:
                        ["Alive", "Dead", "unknown"].map { title in
                            UIAction(title: title, handler: { [self] _ in
                                guard let status = Status(rawValue: title) else { return }
                                viewModel.addFilterOption(.status(status))
                            })
                        }
                      ),
                UIMenu(title: "Gender", options: [.singleSelection], children:
                        ["Female", "Male", "Genderless", "unknown"].map { title in
                            UIAction(title: title) { [self] _ in
                                guard let gender = Gender(rawValue: title) else { return }
                                viewModel.addFilterOption(.gender(gender))
                            }
                        }
                      ),
                UIMenu(options: .displayInline, children: [
                    UIAction(title: "Clear all") { [self] _ in
                        viewModel.clearFilterOptions()
                        navigationItem.rightBarButtonItem?.menu = rightBarButtonItemMenu
                    }
                ])
            ]
        )
    }
    
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
    
    private lazy var dataSource = UICollectionViewDiffableDataSource<CollectionSection, CharacterCellViewModel>(
        collectionView: collectionView
    ) { collectionView, indexPath, cellViewModel in
        let cell = collectionView.dequeueCellOfType(CharacterCollectionViewCell.self, for: indexPath)
        cell.setup(with: cellViewModel)
        return cell
    }
    
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
        configureNavigationBar()
        configureBindings()
    }
    
    // MARK: Configuration
    
    private func configureViewController() {
        title = "Characters"
        view.backgroundColor = .systemBackground
        view.addSubview(collectionView)
    }
    
    private func configureNavigationBar() {
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.searchController = searchController
        reconfigureRightBarButtonItem()
    }
    
    private func reconfigureRightBarButtonItem(newFavoritesActionState: UIAction.State = .off) {
        guard let menu = navigationItem.rightBarButtonItem?.menu else {
            navigationItem.rightBarButtonItem = UIBarButtonItem(
                title: nil,
                image: UIImage(systemName: "line.3.horizontal.decrease.circle"),
                primaryAction: nil,
                menu: rightBarButtonItemMenu
            )
            return
        }
        guard let favoritesAction = menu.children.first as? UIAction else { return }
        favoritesAction.state = newFavoritesActionState
    }
    
    private func configureBindings() {
        viewModel.characterCellViewModels
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] viewModels in
                guard let `self` = self else { return }
                self.characterCellViewModels = viewModels
                self.reloadCollectionViewData()
            })
            .disposed(by: disposeBag)
        viewModel.nextCharacterCellViewModels
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] viewModels in
                guard let `self` = self else { return }
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
                guard let `self` = self else { return }
                self.viewModel.addFilterOption(.search(query))
                self.collectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: .top, animated: true)
            })
            .disposed(by: disposeBag)
        collectionView.rx.didEndDecelerating
            .subscribe(onNext: { [weak self] in
                self?.loadNextCellViewModelsIfNeeded()
            })
            .disposed(by: disposeBag)
        collectionView.rx.itemSelected
            .compactMap { [weak self] indexPath in
                return self?.characterCellViewModels[indexPath.item].id
            }
            .subscribe(onNext: { [weak self] cellViewModelId in
                guard let disposeBag = self?.disposeBag else { return }
                self?.viewModel.getCharacter(id: cellViewModelId)
                    .observe(on: MainScheduler.instance)
                    .subscribe(onSuccess: { character in
                        let detailViewModel = DetailViewModel(character, networkManager: NetworkManager())
                        let detailViewController = DetailViewController(viewModel: detailViewModel)
                        self?.present(detailViewController, animated: true)
                    })
                    .disposed(by: disposeBag)
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
