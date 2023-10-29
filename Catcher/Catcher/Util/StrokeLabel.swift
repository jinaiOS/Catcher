//
//  StrokeLabel.swift
//  Catcher
//
//  Copyright (c) 2023 z-wook. All right reserved.
//

import UIKit

@IBDesignable
class StrokeLabel: UILabel {
    @IBInspectable var strokeSize: CGFloat = 0
    @IBInspectable var strokeColor: UIColor = .clear
    
    override func drawText(in rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        context?.setLineWidth(self.strokeSize)
        context?.setLineJoin(CGLineJoin.miter)
        context?.setTextDrawingMode(CGTextDrawingMode.stroke)
        self.textColor = self.strokeColor
        super.drawText(in: rect)
        context?.setTextDrawingMode(.fill)
        self.textColor = .white
        super.drawText(in: rect)
    }
}
