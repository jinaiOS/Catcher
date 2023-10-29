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
    
    static func makeUserInfoText(text: String, alignment: NSTextAlignment, range: (Int, Int)) -> NSMutableAttributedString {
        let nsRange: NSRange = NSMakeRange(range.0, range.1)
        let label = UILabel()
        label.textAlignment = alignment
        label.textColor = .label
        let text = NSMutableAttributedString(
            string: text,
            attributes: [.font: ThemeFont.demibold(size: 22)])
        text.addAttributes(
            [.font: ThemeFont.bold(size: 30)],
            range: nsRange)
        return text
    }
}

extension NSMutableAttributedString {
    var height: CGFloat {
        let rect = boundingRect(
            with: CGSize(width: UIScreen.main.bounds.width, height: .greatestFiniteMagnitude),
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            context: nil
        )
        return ceil(rect.height)
    }
}
