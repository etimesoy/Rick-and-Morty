//
//  UIMenuElement.State+Extensions.swift
//  Rick&Morty
//
//  Created by Руслан on 16.06.2022.
//

import UIKit

extension UIMenuElement.State {
    func toggled() -> UIMenuElement.State {
        return self == .off ? .on : .off
    }
}
