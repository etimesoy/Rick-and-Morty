//
//  CharactersVC.swift
//  Rick&Morty
//
//  Created by Руслан on 14.06.2022.
//

import UIKit

final class CharactersVC: UIViewController {
    // MARK: Dependencies & properties
    
    private let viewModel: CharactersViewModelProtocol
    
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
        
        view.backgroundColor = .systemBackground
        configureBindings()
    }
    
    // MARK: Configuration
    
    private func configureBindings() {
        
    }
}
