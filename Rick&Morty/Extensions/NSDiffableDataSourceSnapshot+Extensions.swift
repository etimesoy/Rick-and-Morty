//
//  NSDiffableDataSourceSnapshot+Extensions.swift
//  Rick&Morty
//
//  Created by Руслан on 15.06.2022.
//

import UIKit

extension NSDiffableDataSourceSnapshot {
    init(sections: SectionIdentifierType...) {
        self.init()
        appendSections(sections)
    }
}
