//
//  AlertFactory.swift
//  Catcher
//
//  Copyright (c) 2023 z-wook. All right reserved.
//

import UIKit

struct AlertFactory {
    static func makeAlert(title: String?,
                          message: String?,
                          firstActionTitle: String?,
                          firstActionStyle: UIAlertAction.Style = .default,
                          firstActionHandler: (() -> Void)? = nil,
                          secondActionTitle: String? = nil,
                          secondActionStyle: UIAlertAction.Style? = .default,
                          secondActionHandler: (() -> Void)? = nil) -> UIAlertController {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let firstAction = UIAlertAction(title: firstActionTitle, style: firstActionStyle) { _ in
            firstActionHandler?()
        }
        alertController.addAction(firstAction)
        
        if let secondActionTitle = secondActionTitle,
           let secondActionStyle = secondActionStyle {
            let secondAction = UIAlertAction(title: secondActionTitle, style: secondActionStyle) { _ in
                secondActionHandler?()
            }
            alertController.addAction(secondAction)
        }
        return alertController
    }
}
