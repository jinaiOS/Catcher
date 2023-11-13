//
//  UIButton+.swift
//  Catcher
//
//  Copyright (c) 2023 z-wook. All right reserved.
//

import UIKit

extension UIButton {
    static let debounceDelay: Double = 1
    
    func debounce(delay: Double = UIButton.debounceDelay) {
        isEnabled = false
        let deadline = DispatchTime.now() + delay
        DispatchQueue.main.asyncAfter(deadline: deadline) { [weak self] in
            guard let self = self else { return }
            self.isEnabled = true
        }
    }
}
