//
//  RMTitleLabel.swift
//  Rick&Morty
//
//  Created by Руслан on 15.06.2022.
//

import UIKit

final class RMTitleLabel: UILabel {
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(textAlignment: NSTextAlignment, textStyle: UIFont.TextStyle) {
        super.init(frame: .zero)
        self.textAlignment = textAlignment
        self.font = .preferredFont(forTextStyle: textStyle)
        configure()
    }
    
    private func configure() {
        textColor = .label
        lineBreakMode = .byTruncatingTail
        minimumScaleFactor = 0.9
        adjustsFontSizeToFitWidth = true
        translatesAutoresizingMaskIntoConstraints = false
    }
}
