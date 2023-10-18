//
//  NSAttributedString+.swift
//  Catcher
//
//  Copyright (c) 2023 z-wook. All right reserved.
//

import UIKit

extension NSAttributedString {
    static func makeNavigationTitle(title: String) -> NSAttributedString {
        let titleFont = ThemeFont.bold(size: 20)
        let titleAttributes: [NSAttributedString.Key: Any] = [
            .font: titleFont,
            .foregroundColor: UIColor.label
        ]
        let attributedTitle = NSAttributedString(string: title, attributes: titleAttributes)
        return attributedTitle
    }
}
