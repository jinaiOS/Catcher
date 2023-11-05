//
//  LabelFactory.swift
//  Catcher
//
//  Copyright (c) 2023 z-wook. All right reserved.
//

import UIKit

struct LabelFactory {
    static func makeLabel(
        text: String?,
        font: UIFont,
        backgroundColor: UIColor = .clear,
        textColor: UIColor = .label,
        textAlignment: NSTextAlignment = .center) -> UILabel {
            let label = UILabel()
            label.text = text
            label.font = font
            label.backgroundColor = backgroundColor
            label.textColor = textColor
            label.textAlignment = textAlignment
            return label
        }
}
