//
//  RoundedButton.swift
//  hw4
//
//  Created by Chernousova Maria on 25.09.2021.
//

import UIKit

final class RoundedButton: UIButton {
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = bounds.height * 0.5
    }
}
