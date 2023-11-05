//
//  ButtonFactory.swift
//  Catcher
//
//  Copyright (c) 2023 z-wook. All right reserved.
//

import UIKit

struct ButtonFactory {
    static func makeButton(
        type: UIButton.ButtonType = .system,
        title: String? = nil,
        image: UIImage? = nil,
        titleLabelFont: UIFont = .systemFont(ofSize: 17, weight: .regular),
        titleColor: UIColor = .label,
        tintColor: UIColor = .label,
        backgroundColor: UIColor = .clear,
        cornerRadius: CGFloat = 0) -> UIButton {
            let button = UIButton(type: type)
            button.setTitle(title, for: .normal)
            button.setImage(image, for: .normal)
            button.titleLabel?.font = titleLabelFont
            button.setTitleColor(titleColor, for: .normal)
            button.tintColor = tintColor
            button.backgroundColor = backgroundColor
            button.layer.cornerRadius = cornerRadius
            return button
        }
}
